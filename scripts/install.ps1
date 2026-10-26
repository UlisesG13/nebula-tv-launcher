# Nebula TV Launcher - instalador (Windows / PowerShell)
#
#   scripts\install.ps1 -TvHost 192.168.1.50
#
# Si no pasas -TvHost te la pregunta. Requiere: Python 3, y para compilar un JDK 17+ y el Android SDK
# (platform 34 + build-tools 34). Tu agente de IA puede instalarlos por ti (ver AGENTS.md).
param(
    [string]$TvHost
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo

if (-not $TvHost) { $TvHost = Read-Host 'IP de la TV (Ajustes > Red), ej. 192.168.1.50' }
if (-not $TvHost) { throw 'Necesito la IP de la TV.' }
$env:TV_HOST = $TvHost

# --- 0. config.json ---
if (-not (Test-Path 'config\config.json')) {
    Copy-Item 'config\config.example.json' 'config\config.json'
    Write-Host 'Creé config\config.json desde el ejemplo. Edítalo (o deja que tu agente lo genere) y vuelve a correr.' -ForegroundColor Yellow
}

# --- 1. Entorno Python (cliente ADB tv.py, sin binario adb) ---
if (-not (Test-Path 'tools\venv')) { python -m venv tools\venv }
$py = 'tools\venv\Scripts\python.exe'
& $py -m pip install --quiet --upgrade pip
& $py -m pip install --quiet -r tools\requirements.txt

# --- 2. Conectar a la TV ---
Write-Host "Conectando a $TvHost ..." -ForegroundColor Cyan
& $py tools\tv.py --probe
if ($LASTEXITCODE -ne 0) { throw "No pude conectar a la TV. Revisa la IP, que la Depuracion USB este activa y acepta el aviso en la TV." }

# --- 3. Aplicar config -> tema ---
$theme = (& $py scripts\apply_config.py | Select-Object -Last 1).Trim()
if (-not (Test-Path $theme)) { throw "apply_config.py no genero el tema." }

# --- 4. Google TV: si el asistente de setup (setupwraith) reclama el Home, desactivarlo primero ---
$claimants = (& $py tools\tv.py 'cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.HOME') -join "`n"
if ($claimants -match 'setupwraith') {
    Write-Host 'Google TV detectado: desactivando el asistente de setup (con proteccion de Wi-Fi)...' -ForegroundColor Cyan
    'com.google.android.tungsten.setupwraith' | Out-File -Encoding ascii "$env:TEMP\nebula-setupwraith.txt"
    powershell -ExecutionPolicy Bypass -File tools\disable.ps1 -TvHost $TvHost "$env:TEMP\nebula-setupwraith.txt"
}

# --- 5. Compilar + instalar + poner como Home (con rollback automatico) ---
$env:JAVA_HOME = if ($env:JAVA_HOME) { $env:JAVA_HOME } elseif (Test-Path "$env:LOCALAPPDATA\Programs\Android Studio\jbr\bin\java.exe") { "$env:LOCALAPPDATA\Programs\Android Studio\jbr" } else { $env:JAVA_HOME }
powershell -ExecutionPolicy Bypass -File launcher\build-and-install.ps1 -TvHost $TvHost
if ($LASTEXITCODE -ne 0) { throw 'Fallo la instalacion del launcher (ver mensajes arriba).' }

# --- 6. Aplicar el tema (saludo, apps, wallpapers por hora, estilo) ---
powershell -ExecutionPolicy Bypass -File tools\theme.ps1 -TvHost $TvHost $theme

Write-Host ''
Write-Host 'LISTO. Presiona Home en el control para ver Nebula TV Launcher.' -ForegroundColor Green
Write-Host 'Si algo salio mal, revierte con: scripts\uninstall.ps1 -TvHost ' $TvHost -ForegroundColor DarkGray
