$ErrorActionPreference = "Stop"

$codex = Get-Command codex -ErrorAction SilentlyContinue
if (-not $codex) {
    throw "Codex CLI was not found. Install or update Codex CLI, then run this installer again."
}

Push-Location $PSScriptRoot
try {
    & $codex.Source plugin marketplace add $PSScriptRoot
    & $codex.Source plugin add "everything-evenhub@even-realities-community"
}
finally {
    Pop-Location
}

Write-Host "Everything Even Hub is installed. Restart Codex and open a new task."
