<#
.SYNOPSIS
  Live ANSI dashboard for a Testery test run (PowerShell).
.DESCRIPTION
  Polls the Testery API every -Poll seconds and renders a multi-line dashboard
  with a progress bar, counts, ETA, and currently-running tests. Exits 0 when
  the run completes successfully, 1 on test failure or error.
.EXAMPLE
  testery-watch.ps1 12345
  testery-watch.ps1 12345 -Poll 5 -Token $env:TESTERY_TOKEN
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$RunId,
    [string]$Token = $env:TESTERY_TOKEN,
    [int]$Poll     = $(if ($env:TESTERY_WATCH_POLL) { [int]$env:TESTERY_WATCH_POLL } else { 3 }),
    [string]$Api   = $(if ($env:TESTERY_API_URL) { $env:TESTERY_API_URL } else { 'https://api.testery.io' })
)

$ErrorActionPreference = 'Stop'

# Load token from credentials file if not provided
if (-not $Token) {
    $credPath = Join-Path $HOME '.testery\credentials'
    if (Test-Path $credPath) {
        $line = Get-Content $credPath | Where-Object { $_ -match '^TESTERY_TOKEN=' } | Select-Object -First 1
        if ($line) { $Token = ($line -split '=', 2)[1].Trim() }
    }
}
if (-not $Token) { Write-Error "no TESTERY_TOKEN set (or run /testery-onboard)"; exit 2 }

$ESC = [char]27
$useColor = -not $env:NO_COLOR -and $Host.UI.RawUI -ne $null
function C([string]$code, [string]$text) {
    if ($useColor) { return "$ESC[${code}m$text$ESC[0m" } else { return $text }
}

# Hide cursor; restore on exit
[Console]::Write("$ESC[?25l")
$prevLines = 0

function Cleanup { [Console]::Write("$ESC[?25h"); Write-Host "" }
trap { Cleanup; break }

function Format-Duration([int]$sec) {
    if ($sec -lt 0) { $sec = 0 }
    return ('{0:D2}:{1:D2}' -f [int]([math]::Floor($sec/60)), ($sec % 60))
}

function Get-Status {
    $headers = @{ Authorization = "Bearer $Token" }
    try { $run    = Invoke-RestMethod -Headers $headers -Uri "$Api/test-runs/$RunId" } catch { $run = @{} }
    try { $tests  = Invoke-RestMethod -Headers $headers -Uri "$Api/test-runs/$RunId/test-run-tests" } catch { $tests = @() }

    $byStatus = @{ PASS=0; FAIL=0; SKIP=0; RUN=0; QUEUE=0 }
    $now = New-Object System.Collections.Generic.List[string]
    foreach ($t in $tests) {
        switch -Regex ($t.status) {
            '^(PASS|PASSED)$'                              { $byStatus.PASS++  }
            '^(FAIL|FAILED)$'                              { $byStatus.FAIL++  }
            '^(SKIP|SKIPPED|PENDING|IGNORED)$'             { $byStatus.SKIP++  }
            '^(RUNNING|IN_PROGRESS)$'                      {
                $byStatus.RUN++
                if ($now.Count -lt 5) {
                    $name = $t.name; if (-not $name) { $name = $t.testName }; if (-not $name) { $name = $t.description }
                    if ($name) { $now.Add($name) }
                }
            }
            '^(QUEUED|PENDING_RUN)$'                        { $byStatus.QUEUE++ }
        }
    }

    [pscustomobject]@{
        Status   = if ($run.status) { $run.status } else { 'UNKNOWN' }
        Project  = if ($run.project) { $run.project } else { '' }
        Env      = if ($run.environment) { $run.environment } else { '' }
        Total    = $tests.Count
        Pass     = $byStatus.PASS
        Fail     = $byStatus.FAIL
        Skip     = $byStatus.SKIP
        Running  = $byStatus.RUN
        Queued   = $byStatus.QUEUE
        Started  = if ($run.startedAt) { [datetime]$run.startedAt } elseif ($run.createdAt) { [datetime]$run.createdAt } else { Get-Date }
        Now      = $now
    }
}

function Render($s) {
    $cols = [Math]::Min([Math]::Max($Host.UI.RawUI.WindowSize.Width, 50), 100)
    $inner = $cols - 2
    $done  = $s.Pass + $s.Fail + $s.Skip
    $pct   = if ($s.Total -gt 0) { [int](($done * 100) / $s.Total) } else { 0 }
    $elapsed = [int]((Get-Date) - $s.Started).TotalSeconds
    $eta = if ($done -gt 0 -and $pct -gt 0 -and $pct -lt 100) {
        '~' + (Format-Duration ([int]($elapsed * (100 - $pct) / $pct)))
    } else { '?' }

    $barW   = [Math]::Max($cols - 18, 10)
    $filled = [int]($pct * $barW / 100)
    $bar    = (C '32' ('█' * $filled)) + (C '90' ('░' * ($barW - $filled)))

    $top = '╭' + ('─' * $inner) + '╮'
    $bot = '╰' + ('─' * $inner) + '╯'

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add((C '1' $top))
    $hdr = "│ $(C '1' 'Testery') · run $(C '34' $RunId) · $($s.Project) @ $($s.Env)"
    $lines.Add($hdr.PadRight($cols - 1) + '│')
    $lines.Add('│' + (' ' * $inner) + '│')
    $lines.Add(("│ $bar  {0,3}%" -f $pct).PadRight($cols - 1) + '│')
    $lines.Add('│' + (' ' * $inner) + '│')
    $counts = ('│ ✅ {0,2} passed   ❌ {1,2} failed   ⏭  {2,2} skipped   🟡 {3,2} running' -f `
        $s.Pass, $s.Fail, $s.Skip, $s.Running)
    $lines.Add($counts.PadRight($cols - 1) + '│')
    $stats = ("│ ⏱  elapsed: {0}   eta: {1}   queued: {2} / total: {3}" -f `
        (Format-Duration $elapsed), $eta, $s.Queued, $s.Total)
    $lines.Add($stats.PadRight($cols - 1) + '│')
    $lines.Add('│' + (' ' * $inner) + '│')
    $lines.Add(('│ ' + (C '2' 'Now running:')).PadRight($cols - 1) + '│')
    if ($s.Now.Count -eq 0) {
        $msg = if ($s.Status -eq 'RUNNING' -or $s.Status -eq 'IN_PROGRESS') {
            '(waiting for tests to start…)'
        } else { "status: $($s.Status)" }
        $lines.Add(('│   ' + (C '2' $msg)).PadRight($cols - 1) + '│')
    } else {
        foreach ($n in $s.Now) {
            $maxLen = $inner - 6
            $nm = if ($n.Length -gt $maxLen) { $n.Substring(0, $maxLen - 1) + '…' } else { $n }
            $lines.Add(('│   🟡 ' + $nm).PadRight($cols - 1) + '│')
        }
    }
    $lines.Add((C '1' $bot))

    if ($script:prevLines -gt 0) { [Console]::Write("$ESC[$($script:prevLines)A") }
    foreach ($l in $lines) { [Console]::Write("$ESC[2K$ESC[G$l`n") }
    $script:prevLines = $lines.Count
}

try {
    while ($true) {
        $s = Get-Status
        Render $s
        switch -Regex ($s.Status) {
            '^(PASS|PASSED|COMPLETE|COMPLETED|SUCCESS|SUCCEEDED)$' { Cleanup; exit 0 }
            '^(FAIL|FAILED|ERROR|ERRORED|CANCELLED|CANCELED)$'      { Cleanup; exit 1 }
        }
        Start-Sleep -Seconds $Poll
    }
} finally {
    Cleanup
}
