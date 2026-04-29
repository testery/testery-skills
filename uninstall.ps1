#Requires -Version 5.0
[CmdletBinding()]
param(
    [switch]$User,
    [switch]$Project,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$SrcSkills   = Join-Path $ScriptDir 'skills'
$SrcCommands = Join-Path $ScriptDir 'commands'

$Base = if ($Project) { Join-Path (Get-Location) '.claude' } else { Join-Path $HOME '.claude' }

function Remove-Dir {
    param([string]$Src, [string]$Dest, [string]$Label)
    if (-not (Test-Path $Src)) { return }
    Get-ChildItem -LiteralPath $Src | ForEach-Object {
        $target = Join-Path $Dest $_.Name
        if (Test-Path $target) {
            Write-Host "  [remove] $Label/$($_.Name)"
            if (-not $DryRun) { Remove-Item -LiteralPath $target -Recurse -Force }
        }
    }
}

Write-Host "Uninstalling from: $Base"
Remove-Dir -Src $SrcSkills   -Dest (Join-Path $Base 'skills')   -Label 'skills'
Remove-Dir -Src $SrcCommands -Dest (Join-Path $Base 'commands') -Label 'commands'
Write-Host "Done."
