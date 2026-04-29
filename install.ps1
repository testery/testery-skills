#Requires -Version 5.0
<#
.SYNOPSIS
  Installs Testery Claude Code skills and slash commands.
.DESCRIPTION
  Default: user-level ($HOME\.claude\). Use -Project to install into .\.claude\.
.PARAMETER User
  Install to $HOME\.claude (default).
.PARAMETER Project
  Install to .\.claude in the current directory.
.PARAMETER DryRun
  Show what would be installed without writing.
.PARAMETER Force
  Overwrite existing entries with the same name.
#>
[CmdletBinding()]
param(
    [switch]$User,
    [switch]$Project,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$SrcSkills   = Join-Path $ScriptDir 'skills'
$SrcCommands = Join-Path $ScriptDir 'commands'

if ($Project) {
    $Base = Join-Path (Get-Location) '.claude'
} else {
    $Base = Join-Path $HOME '.claude'
}

$DestSkills   = Join-Path $Base 'skills'
$DestCommands = Join-Path $Base 'commands'

Write-Host "Installing testery-skills to: $Base"
Write-Host "  Source skills:   $SrcSkills"
Write-Host "  Source commands: $SrcCommands"
$mode = if ($DryRun) { 'dry-run' } else { 'write' }
$forceText = if ($Force) { 'yes' } else { 'no' }
Write-Host "  Mode: $mode   Force: $forceText`n"

function Install-Dir {
    param([string]$Src, [string]$Dest, [string]$Label)
    if (-not (Test-Path $Src)) { Write-Host "  ($Label) source missing at $Src; skipping"; return }
    Get-ChildItem -LiteralPath $Src | ForEach-Object {
        $name   = $_.Name
        $target = Join-Path $Dest $name
        if ((Test-Path $target) -and (-not $Force)) {
            Write-Host "  [skip] $Label/$name (exists; use -Force to overwrite)"
            return
        }
        Write-Host "  [copy] $Label/$name -> $target"
        if (-not $DryRun) {
            if (-not (Test-Path $Dest)) { New-Item -ItemType Directory -Path $Dest -Force | Out-Null }
            if (Test-Path $target) { Remove-Item -LiteralPath $target -Recurse -Force }
            Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force
        }
    }
}

Install-Dir -Src $SrcSkills   -Dest $DestSkills   -Label 'skills'
Install-Dir -Src $SrcCommands -Dest $DestCommands -Label 'commands'

Write-Host "`nDone.`n"
Write-Host "Next steps:"
Write-Host "  1. Ensure the Testery CLI is installed:  pip install testery"
Write-Host "  2. Set your API token: `$env:TESTERY_TOKEN = '<your-token>'"
Write-Host "  3. (Optional) Configure the Testery MCP server."
Write-Host "  4. Open Claude Code and try a command, e.g.  /testery-list-active-test-runs"
