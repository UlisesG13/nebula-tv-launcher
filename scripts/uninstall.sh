#!/usr/bin/env bash
# Nebula TV Launcher - desinstalador (macOS / Linux)
#   scripts/uninstall.sh 192.168.1.50
# Reactiva el launcher original de la TV y quita Nebula.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"
TV_HOST="${1:-}"
if [ -z "$TV_HOST" ]; then read -r -p "IP de la TV: " TV_HOST; fi
export TV_HOST
PY=tools/venv/bin/python
if [ ! -x "$PY" ]; then python3 -m venv tools/venv; "$PY" -m pip install --quiet -r tools/requirements.txt; fi

echo "Reactivando el launcher original de la TV..."
for p in com.google.android.apps.tv.launcherx com.google.android.tvlauncher \
         com.google.android.leanbacklauncher com.google.android.tungsten.setupwraith; do
  "$PY" tools/tv.py "pm enable $p" >/dev/null 2>&1 || true
done

echo "Quitando Nebula TV Launcher..."
"$PY" tools/tv.py 'pm uninstall com.gathin.tvhome' || true

HOME_NOW="$("$PY" tools/tv.py 'cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME' | tail -n 1)"
echo "Home ahora resuelve a: $HOME_NOW"
echo "Recuerda: en la TV, apaga la Depuracion USB en Opciones de desarrollador cuando termines."
