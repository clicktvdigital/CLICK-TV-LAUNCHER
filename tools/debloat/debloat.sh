#!/usr/bin/env bash
# CLICK TV LAUNCHER - módulo de desactivación de bloatware por ADB.
#
# Desactiva (pm disable-user, usuario 0) paquetes de una lista. Nunca desinstala.
# Lo que se desactiva se puede volver a activar con "restore".
# Inspirado en tools/disable.sh de Clean Your TV (MIT, Gathin); ver THIRD_PARTY_NOTICES.md.
#
# Uso:
#   TV_HOST=192.168.1.50 tools/debloat/debloat.sh plan    tools/debloat/lists/generic.txt
#   TV_HOST=192.168.1.50 tools/debloat/debloat.sh apply   tools/debloat/lists/generic.txt
#   TV_HOST=192.168.1.50 tools/debloat/debloat.sh restore tools/debloat/lists/generic.txt
#
# Variables opcionales:
#   TV_HOST       IP del TV (se usa adb connect IP:5555). Si no se define, usa el dispositivo ya conectado.
#   ADB           binario adb (por defecto: adb). En Termux: pkg install android-tools
#   KEEP_LAUNCHER no toca launchers; ver PROTECTED abajo.
#   STATE_FILE    registro de lo desactivado (por defecto: ~/.clicktv-debloat-state.txt)
#
# Códigos de salida: 0 correcto; 1 algún paquete falló; 2 uso incorrecto o lista rechazada
# (nada se envió al TV).
set -euo pipefail
export LC_ALL=C

ADB="${ADB:-adb}"
STATE_FILE="${STATE_FILE:-$HOME/.clicktv-debloat-state.txt}"

usage() {
  echo "uso: [TV_HOST=ip] $0 {plan|apply|restore} <lista>" >&2
  exit 2
}

[ $# -eq 2 ] || usage
MODE="$1"
LIST="$2"
case "$MODE" in plan|apply|restore) ;; *) usage ;; esac
[ -r "$LIST" ] || { echo "no se puede leer la lista: $LIST" >&2; exit 2; }

# ---------------------------------------------------------------------------
# Paquetes protegidos: nunca se desactivan aunque aparezcan en la lista.
# Un TV puede no volver a arrancar si se desactivan (ver Clean Your TV #884, #1578).
# ---------------------------------------------------------------------------
CORE_RE='^(android|android\.ext\.(services|shared)|com\.android\.sdksandbox|com\.android\.location\.fused|com\.android\.systemui|com\.android\.shell|com\.android\.phone|com\.android\.settings|com\.android\.tv\.settings|com\.(google\.)?android\.(permissioncontroller|packageinstaller|ext\.services|ext\.shared|modulemetadata)|com\.google\.android\.overlay\.modules.*|com\.android\.providers\..*|com\.cltv\.mal|com\.mediatek\.(tis|tv\.service|tv\.agent))$'
CORE_OK='^com\.android\.providers\.(calendar|contacts|userdictionary|blockednumber)$'
# Wi-Fi guardado por el asistente de configuración: desactivarlo borra la red y el TV se queda sin ADB.
WIFI_OWNER=com.google.android.tungsten.setupwraith
# Accesibilidad y launchers: se gestionan a mano, no con esta herramienta.
PROTECTED_RE='^(com\.google\.android\.marvin\.talkback|com\.google\.android\.apps\.tv\.launcherx|com\.google\.android\.tvlauncher|com\.google\.android\.leanbacklauncher|com\.google\.android\.leanbacklauncher\.recommendations|com\.mitv\.tvhome|com\.clicktv\.launcher|com\.leanbitlab\.ltvL)$'
PKG_RE='^[A-Za-z_][A-Za-z0-9_]*(\.[A-Za-z0-9_]+)+$'

# ---------------------------------------------------------------------------
# Leer la lista: quita BOM, CRLF, comentarios y líneas vacías.
# ---------------------------------------------------------------------------
PKGS="$(awk 'NR==1{sub(/^\357\273\277/,"")} {sub(/\r$/,""); print}' "$LIST" \
  | grep -vE '^\s*(#|$)' | sed -E 's/#.*$//' | awk '{print $1}' || true)"

if [ -z "$PKGS" ]; then
  echo "lista sin paquetes (todo comentado o vacío): $LIST. Nada se envió al TV." >&2
  exit 2
fi

BAD="$(printf '%s\n' "$PKGS" | grep -vE "$PKG_RE" || true)"
if [ -n "$BAD" ]; then
  { echo "lista rechazada, estas entradas no son nombres de paquete:"; printf '  %s\n' $BAD; } >&2
  exit 2
fi

CORE="$(printf '%s\n' "$PKGS" | grep -E "$CORE_RE" | grep -vE "$CORE_OK" || true)"
if [ -n "$CORE" ]; then
  { echo "lista rechazada: contiene paquetes del sistema o del middleware del TV:"
    printf '  %s\n' $CORE
    echo "Quítalos de la lista (o coméntalos). Nada se envió al TV."; } >&2
  exit 2
fi

# Separar protegidos de los que sí se procesan.
PROTECTED="$(printf '%s\n' "$PKGS" | grep -E "$PROTECTED_RE" || true)"
[ -n "$PROTECTED" ] && echo "omitidos (protegidos, gestiónalos a mano): $(echo $PROTECTED)" >&2
PKGS="$(printf '%s\n' "$PKGS" | grep -vE "$PROTECTED_RE" || true)"

if printf '%s\n' "$PKGS" | grep -qx "$WIFI_OWNER"; then
  echo "omitido $WIFI_OWNER: borraría la red Wi-Fi guardada y el TV perdería ADB." >&2
  echo "  Olvida la red en el TV y vuelve a unirte, o desactívalo tú si el TV usa Ethernet." >&2
  PKGS="$(printf '%s\n' "$PKGS" | grep -vx "$WIFI_OWNER" || true)"
fi

# ---------------------------------------------------------------------------
# Conexión ADB.
# ---------------------------------------------------------------------------
if [ "$MODE" != plan ]; then
  command -v "$ADB" >/dev/null 2>&1 || { echo "no encuentro '$ADB'. En Termux: pkg install android-tools" >&2; exit 2; }
  if [ -n "${TV_HOST:-}" ]; then
    "$ADB" connect "$TV_HOST:5555" >/dev/null 2>&1 || true
    SERIAL="$TV_HOST:5555"
  else
    SERIAL=""
  fi
  # Comprobar que hay un dispositivo en estado "device".
  if [ -n "$SERIAL" ]; then
    STATE="$("$ADB" -s "$SERIAL" get-state 2>/dev/null || true)"
  else
    STATE="$("$ADB" get-state 2>/dev/null || true)"
  fi
  if [ "$STATE" != device ]; then
    echo "no hay TV conectado por ADB${TV_HOST:+ ($TV_HOST)}. Activa la depuración USB y acepta la huella en el TV." >&2
    exit 2
  fi
fi

adb_cmd() {
  if [ -n "${SERIAL:-}" ]; then "$ADB" -s "$SERIAL" "$@"; else "$ADB" "$@"; fi
}

FAILED=0
COUNT=0

# ---------------------------------------------------------------------------
# Acciones.
# ---------------------------------------------------------------------------
case "$MODE" in
  plan)
    echo "Se desactivarían (usuario 0) $(printf '%s\n' "$PKGS" | grep -c . || true) paquetes:"
    printf '  pm disable-user --user 0 %s\n' $PKGS
    echo "Nada se ha enviado al TV. Usa 'apply' para ejecutarlo."
    exit 0 ;;

  apply)
    mkdir -p "$(dirname "$STATE_FILE")"
    for pkg in $PKGS; do
      # Registrar solo los que estaban habilitados antes, para que "restore" no active lo que ya estaba apagado.
      before="$(adb_cmd shell pm list packages -d "$pkg" 2>/dev/null | tr -d '\r' || true)"
      if printf '%s' "$before" | grep -qx "package:$pkg"; then
        echo "ya desactivado: $pkg"
        continue
      fi
      out="$(adb_cmd shell pm disable-user --user 0 "$pkg" 2>&1 | tr -d '\r' || true)"
      if printf '%s' "$out" | grep -qiE 'disabled|new state: disabled'; then
        echo "desactivado: $pkg"
        echo "$pkg" >> "$STATE_FILE"
        COUNT=$((COUNT+1))
      else
        echo "FALLO: $pkg -> $out" >&2
        FAILED=1
      fi
    done
    echo "listo: $COUNT desactivados. Registro: $STATE_FILE"
    ;;

  restore)
    # Solo se reactivan los paquetes que este script desactivó (están en el registro).
    # Los que ya venían apagados de fábrica no se tocan.
    for pkg in $PKGS; do
      if [ ! -f "$STATE_FILE" ] || ! grep -qx "$pkg" "$STATE_FILE"; then
        echo "omitido (no lo desactivó este script): $pkg"
        continue
      fi
      out="$(adb_cmd shell pm enable "$pkg" 2>&1 | tr -d '\r' || true)"
      if printf '%s' "$out" | grep -qiE 'enabled|new state: enabled'; then
        echo "reactivado: $pkg"
        # grep -v sale con código 1 si no quedan líneas: por eso el "|| true".
        { grep -vx "$pkg" "$STATE_FILE" || true; } > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
        COUNT=$((COUNT+1))
      else
        echo "FALLO: $pkg -> $out" >&2
        FAILED=1
      fi
    done
    echo "listo: $COUNT reactivados."
    ;;
esac

exit "$FAILED"
