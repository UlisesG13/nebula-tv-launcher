#!/usr/bin/env python3
"""
Nebula TV Launcher — convierte el config/config.json amigable del usuario en el "tema" que entiende
el launcher (y deja los 4 wallpapers listos), en .nebula-build/theme/.

Uso:
    python scripts/apply_config.py [ruta/al/config.json]

Imprime en la última línea la ruta de la carpeta de tema generada, para que install.ps1 / install.sh
la empujen a la TV con tools/theme.(ps1|sh).
"""
import json
import os
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BUILD = os.path.join(ROOT, ".nebula-build")
THEME = os.path.join(BUILD, "theme")
WALLS = os.path.join(THEME, "wallpapers")
MAX_LONG_SIDE = 2560

# Estilo base "Nebula" (glassmorphism + protector + animaciones). El config del usuario se superpone.
BASE_THEME = {
    "columns": 5,
    "background_color": "#05060B",
    "wallpaper": True,
    "wallpaper_rotation_minutes": 60,
    "wallpaper_order": "sequential",
    "wallpaper_dim": 24,
    "wallpaper_captions": False,
    "cinematic_home": False,
    "ambient_glow": False,
    "app_glow": True,
    "dock_glass": True,
    "dock_opacity": 35,
    "dock_even_padding": True,
    "fade_rows": True,
    "icon_only_buttons": True,
    "icon_only_inputs": True,
    "focus_overshoot": True,
    "advanced_effects": True,
    "home_idle_clock_minutes": 5,
    "clock_wallpaper": True,
    "clock_wallpaper_dim": 45,
    "clock_glow": True,
}

# nombre del periodo en el config del usuario -> grupo de wallpaper_moods del launcher
MOOD_MAP = {"morning": "morning", "day": "day", "afternoon": "evening", "night": "night"}
OUT_NAME = {"morning": "amanecer.jpg", "day": "dia.jpg", "afternoon": "tarde.jpg", "night": "noche.jpg"}


def stage_wallpaper(src_rel, out_name):
    src = src_rel if os.path.isabs(src_rel) else os.path.join(ROOT, src_rel)
    if not os.path.exists(src):
        print(f"  AVISO: no existe el wallpaper '{src_rel}', se omite.", file=sys.stderr)
        return False
    dst = os.path.join(WALLS, out_name)
    try:
        from PIL import Image
        img = Image.open(src).convert("RGB")
        w, h = img.size
        if max(w, h) > MAX_LONG_SIDE:
            s = MAX_LONG_SIDE / max(w, h)
            img = img.resize((round(w * s), round(h * s)), Image.LANCZOS)
        img.save(dst, "JPEG", quality=85, optimize=True)
    except Exception:
        shutil.copyfile(src, dst)   # sin Pillow: copiar tal cual
    return True


def main():
    cfg_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "config", "config.json")
    if not os.path.exists(cfg_path):
        sys.exit(f"No se encontró {cfg_path}. Copia config/config.example.json a config/config.json y edítalo.")
    with open(cfg_path, "r", encoding="utf-8") as f:
        cfg = json.load(f)

    if os.path.isdir(BUILD):
        shutil.rmtree(BUILD)
    os.makedirs(WALLS, exist_ok=True)

    theme = dict(BASE_THEME)

    # Saludo
    name = (cfg.get("greeting") or {}).get("name", "").strip()
    if name:
        theme["greeting_name"] = name

    # Formato de hora
    clock = cfg.get("clock_format", "system")
    theme["clock_format"] = clock if clock in ("12h", "24h", "system") else "system"

    # Horarios
    sched = cfg.get("schedule") or {}
    theme["schedule"] = {
        "morning": int(sched.get("morning", 5)),
        "day": int(sched.get("day", 8)),
        "afternoon": int(sched.get("afternoon", 13)),
        "night": int(sched.get("night", 20)),
    }

    # Apps del dock
    dock = cfg.get("dock_apps") or []
    if dock:
        theme["dock_apps"] = dock

    # Wallpapers -> grupos de mood
    walls = cfg.get("wallpapers") or {}
    moods = {}
    for period, path in walls.items():
        if period not in MOOD_MAP:
            continue
        out = OUT_NAME[period]
        if stage_wallpaper(path, out):
            moods.setdefault(MOOD_MAP[period], []).append(out)
    if moods:
        theme["wallpaper_moods"] = moods

    with open(os.path.join(THEME, "config.json"), "w", encoding="utf-8") as f:
        json.dump(theme, f, ensure_ascii=False, indent=2)

    print("Config aplicada. Tema generado en:")
    print(THEME)


if __name__ == "__main__":
    main()
