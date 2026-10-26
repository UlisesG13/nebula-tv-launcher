# Nebula TV Launcher - desinstalador (Windows / PowerShell)
#   scripts\uninstall.ps1 -TvHost 192.168.1.50
# Reactiva el launcher original de la TV y quita Nebula.
param(
    [string]$TvHost
)
$ErrorActionPreference = 'Continue'
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo
if (-not $TvHost) { $TvHost = Read-Host 'IP de la TV' }
$env:TV_HOST = $TvHost
$py = 'tools\venv\Scripts\python.exe'
if (-not (Test-Path $py)) { python -m venv tools\venv; & $py -m pip install --quiet -r tools\requirements.txt }

Write-Host 'Reactivando el launcher original de la TV...' -ForegroundColor Cyan
foreach ($p in @(
    'com.google.android.apps.tv.launcherx',
    'com.google.android.tvlauncher',
    'com.google.android.leanbacklauncher',
    'com.google.android.tungsten.setupwraith')) {
    & $py tools\tv.py "pm enable $p" 2>$null | Out-Null
}

Write-Host 'Quitando Nebula TV Launcher...' -ForegroundColor Cyan
& $py tools\tv.py 'pm uninstall com.gathin.tvhome'

$home = (& $py tools\tv.py 'cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME') | Select-Object -Last 1
Write-Host ("Home ahora resuelve a: " + $home) -ForegroundColor Green
Write-Host 'Recuerda: en la TV, apaga la Depuracion USB en Opciones de desarrollador cuando termines.' -ForegroundColor Yellow
