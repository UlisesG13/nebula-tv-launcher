#!/usr/bin/env bash
# Nebula TV Launcher - instalador (macOS / Linux)
#
#   scripts/install.sh 192.168.1.50
#
# Si no pasas la IP te la pregunta. Requiere: Python 3, y para compilar un JDK 17+ y el Android SDK
# (platform 34 + build-tools 34). Tu agente de IA puede instalarlos por ti (ver AGENTS.md).
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

TV_HOST="${1:-}"
if [ -z "$TV_HOST" ]; then read -r -p "IP de la TV (Ajustes > Red), ej. 192.168.1.50: " TV_HOST; fi
[ -n "$TV_HOST" ] || { echo "Necesito la IP de la TV."; exit 1; }
export TV_HOST

# 0. config.json
if [ ! -f config/config.json ]; then
  cp config/config.example.json config/config.json
  echo "Cree config/config.json desde el ejemplo. Editalo (o deja que tu agente lo genere) y vuelve a correr."
fi

# 1. Entorno Python (cliente ADB tv.py)
[ -d tools/venv ] || python3 -m venv tools/venv
PY=tools/venv/bin/python
"$PY" -m pip install --quiet --upgrade pip
"$PY" -m pip install --quiet -r tools/requirements.txt

# 2. Conectar
echo "Conectando a $TV_HOST ..."
"$PY" tools/tv.py --probe || { echo "No pude conectar. Revisa la IP, la Depuracion USB y acepta el aviso en la TV."; exit 1; }

# 3. Aplicar config -> tema
THEME="$("$PY" scripts/apply_config.py | tail -n 1)"
[ -d "$THEME" ] || { echo "apply_config.py no genero el tema."; exit 1; }

# 4. Google TV: desactivar el asistente de setup si reclama el Home
if "$PY" tools/tv.py 'cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.HOME' | grep -q setupwraith; then
  echo "Google TV detectado: desactivando el asistente de setup (con proteccion de Wi-Fi)..."
  echo 'com.google.android.tungsten.setupwraith' > "${TMPDIR:-/tmp}/nebula-setupwraith.txt"
  bash tools/disable.sh "${TMPDIR:-/tmp}/nebula-setupwraith.txt" || true
fi

# 5. Compilar + instalar + poner como Home (con rollback automatico)
bash launcher/build-and-install.sh

# 6. Aplicar el tema
bash tools/theme.sh "$THEME"

echo ""
echo "LISTO. Presiona Home en el control para ver Nebula TV Launcher."
echo "Si algo salio mal, revierte con: scripts/uninstall.sh $TV_HOST"
