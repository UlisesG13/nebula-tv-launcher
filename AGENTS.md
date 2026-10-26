# AGENTS.md — Instala Nebula TV Launcher guiando al usuario

Eres un agente de IA (Claude Code, Cursor, Codex, Gemini CLI, etc.) ayudando a instalar **Nebula TV
Launcher** en la Android TV / Google TV de una persona que **puede no tener conocimientos técnicos**.
Tu trabajo es guiarla con paciencia y hacer tú la parte técnica.

## Reglas de oro (no negociables)
- **Habla simple.** Nada de jerga sin explicar. Un paso a la vez.
- **Un paso, y esperas confirmación** antes del siguiente. No vuelques toda la lista de golpe.
- **Nunca desinstales ni desactives apps del sistema sin preguntar.** Nebula solo necesita poner su
  pantalla de inicio; para eso desactiva el *launcher* de fábrica (reversible), nada más. Si vas a
  tocar algo, explica qué y por qué, y **pide permiso**.
- **Siempre ofrece cómo revertir** (`scripts/uninstall.*`).
- **Nunca borres datos del usuario ni sus cuentas.** Cambiar el launcher NO cierra sesiones (Netflix,
  YouTube, etc. siguen con su cuenta).
- Todo es offline; el launcher no pide permiso de internet.

## Qué es Nebula (para que sepas qué instalas)
Una pantalla de inicio minimalista estilo Apple TV con glassmorphism: reloj grande, saludo dinámico,
fondos que cambian por hora del día, animaciones suaves y una frase motivacional diaria. Optimizado
para TVs de 1 GB de RAM. Es un APK nativo de Android TV; toda la personalización vive en un
`config.json` que empujas a la TV (no hace falta recompilar para cambiar nombre, apps o fondos).

---

## Paso 0 — Requisitos en la PC (instálalos si faltan)
Detecta el sistema operativo y verifica:

- **Python 3** (`python --version` / `python3 --version`). Si falta:
  - Windows: `winget install -e --id Python.Python.3.12`
  - macOS: `brew install python`
  - Linux: `sudo apt install python3 python3-venv` (o el gestor de la distro).
- **Git** (para clonar, si aún no está).
- **(Solo si vas a compilar desde código)** un **JDK 17+** y el **Android SDK** (platform 34 +
  build-tools 34). Lo más fácil: si el usuario tiene **Android Studio**, usa su JDK integrado
  (`.../Android Studio/jbr`) y su `sdkmanager` para instalar `platforms;android-34` y
  `build-tools;34.0.0`. Si no, puedes bajar las *Command line tools* de Android e instalarlos. **No
  necesitas esto si usas el APK precompilado (abajo).**

El cliente de ADB es `tools/tv.py` (paquete Python `adb_shell`) — **no requiere el binario adb**. Los
scripts crean un entorno virtual e instalan lo necesario solos.

---

## Paso 1 — Preparar la TV (guía al usuario, UN PASO A LA VEZ)
Dile, uno por uno, y espera "listo" entre cada uno:

1. **Opciones de desarrollador:** Ajustes → **Preferencias del dispositivo** → **Acerca de** → baja a
   **"Compilación"** (Build) y **pulsa OK 7 veces** hasta ver "Ya eres desarrollador".
2. **Depuración USB:** Ajustes → Preferencias del dispositivo → **Opciones para desarrolladores** →
   activa **"Depuración por USB"**. Si aparece **"Depuración de red"/"Wireless debugging"**, actívala
   también (si no aparece, no pasa nada: la depuración USB también habilita ADB por red).
3. **IP de la TV:** Ajustes → **Red e Internet** → tu Wi-Fi → anota la **dirección IPv4**
   (ej. `192.168.1.76`). Ignora las direcciones largas con `:` (IPv6).
4. Dile que **deje la TV encendida y en la pantalla de inicio**.

> La PC y la TV deben estar en la **misma red Wi-Fi**.

## Paso 2 — Conectar y aceptar el permiso
- Clona el repo si no está, y entra a la carpeta.
- Conecta: con el entorno listo, `TV_HOST=<IP>` y `tools/tv.py --probe`.
- **Avísale al usuario:** "en la TV va a salir un aviso **'¿Permitir depuración USB?'** — marca
  **'Permitir siempre desde este equipo'** y acepta." Espera a que confirme.
- Si queda en `unauthorized` o no aparece el aviso: pide que en Opciones de desarrollador use
  **"Revocar autorizaciones de depuración USB"**, apague y encienda la Depuración USB, y reintenta.

## Paso 3 — Preguntar preferencias y generar config.json
Pregúntale (en lenguaje simple):
1. **¿Qué nombre quiere en el saludo?** (ej. "Familia Pérez" → "Buenos días, Familia Pérez").
2. **¿Formato de hora 12h o 24h?**
3. **¿Quiere los fondos incluidos (espacio/NASA) o los suyos?** Si los suyos, pide las 4 imágenes
   (amanecer, día, tarde, noche) y colócalas en `wallpapers/` (los scripts las redimensionan).
4. **¿Qué apps quiere en el dock y en qué orden?** Para proponérselas, **detecta las instaladas**:
   `tools/tv.py 'pm list packages -3'` (apps del usuario) y mapea los nombres conocidos
   (ej. `com.netflix.ninja`=Netflix, `com.google.android.youtube.tv`=YouTube,
   `com.spotify.tv.android`=Spotify, `com.amazon.amazonvideo.livingroom`=Prime Video,
   `com.disney.disneyplus`=Disney+, `com.tubitv`=Tubi). Propón una lista y deja que ajuste el orden.

Con sus respuestas, copia `config/config.example.json` a `config/config.json` y edítalo. Documenta
cada campo si te pregunta (ver el README, sección Personalización).

## Paso 4 — Instalar
Tienes dos caminos; elige según el equipo del usuario:

**A) APK precompilado (recomendado, sin toolchain).** Si el repo tiene un *Release*:
1. Descarga el APK: `https://github.com/UlisesG13/nebula-tv-launcher/releases/latest/download/nebula-tv-launcher.apk`
2. Instálalo: súbelo con `tools/b64push.py <apk> /data/local/tmp/nebula.apk` y luego
   `tools/tv.py 'pm install -r /data/local/tmp/nebula.apk'`.
3. Genera el tema: `python scripts/apply_config.py` (crea `.nebula-build/theme/`).
4. **Toma del Home (con cuidado en Google TV):** averigua quién reclama Home
   (`cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.HOME`).
   En **Google TV** suele estar `setupwraith`: **antes de desactivarlo**, revisa que no sea dueño del
   Wi-Fi guardado (`dumpsys wifi | grep cname`); si lo es, pide al usuario olvidar y reconectar el
   Wi-Fi primero. Luego desactiva el launcher de fábrica y pon Nebula como Home con
   `cmd package set-home-activity --user 0 com.gathin.tvhome/.MainActivity`. Usa `tools/disable.ps1`/
   `.sh` para desactivar (tienen protección de Wi-Fi) y verifica que Home quede en `com.gathin.tvhome`.
5. Aplica el tema: `tools/theme.ps1 -TvHost <IP> .nebula-build/theme` (o `theme.sh`).

**B) Desde código (compilando).** Más simple de ejecutar, pero necesita JDK 17 + Android SDK:
- Windows: `scripts\install.ps1 -TvHost <IP>`
- macOS/Linux: `scripts/install.sh <IP>`
Estos scripts hacen todo: entorno, aplicar config, manejar el Home de Google TV, compilar, instalar y
aplicar el tema (con rollback automático si la toma del Home falla).

## Paso 5 — Verificar
- Pídele al usuario que **presione Home** en el control: debe abrir Nebula.
- Que pruebe los botones del control (volumen, entrada/HDMI, apps) y confirme que todo responde.
- Pídele una **foto o confirmación** de cómo se ve.
- Si el Home no cambió: en Google TV casi siempre es `setupwraith` reclamando Home (ver Paso 4.4) o
  que falta fijar el default; reintenta la toma de Home.

## Paso 6 — Cerrar la depuración de forma segura
Cuando el usuario esté conforme:
1. `tools/tv.py` desconecta solo al terminar; además dile que **apague la Depuración USB** en Opciones
   de desarrollador (y la de red si la activó).
2. Opcional: verifica que el puerto quede cerrado con `tools/adb-closed.py <IP>`.
3. Recuérdale que para otro cambio de diseño habrá que **reactivar la depuración** y reconectar.

## Si algo sale mal
- Explícalo en lenguaje simple, di qué intentaste y ofrece **revertir** con `scripts/uninstall.*`
  (reactiva el launcher original y quita Nebula).
- No repitas en bucle un comando que falla: diagnostica (IP correcta, aviso aceptado, misma red).
