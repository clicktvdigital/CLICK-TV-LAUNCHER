#!/usr/bin/env bash
# CLICK TV LAUNCHER - hace que CLICK TV sea la pantalla de inicio (Home) del TV, por ADB.
#
# Pasos:
#   1. Comprueba que la app está instalada.
#   2. Fija CLICK TV como Home (cmd package set-home-activity).
#   3. Desactiva el launcher de fábrica (pm disable-user --user 0). Se puede omitir con STOCK_LAUNCHER=none.
#   4. Comprueba que el Home resuelve a CLICK TV. Si no, reactiva el launcher de fábrica y sale con error.
#
# Basado en el procedimiento de launcher/build-and-install.sh de Clean Your TV (MIT, Gathin):
# en Android TV con tvlauncher activo, Home sigue resolviendo a tvlauncher aunque set-home-activity
# responda "Success". Ver THIRD_PARTY_NOTICES.md.
#
# Uso (Termux, con adb):
#   TV_HOST=192.168.100.11 tools/debloat/set-home.sh
#   TV_HOST=192.168.100.11 STOCK_LAUNCHER=com.google.android.tvlauncher tools/debloat/set-home.sh
#
# Códigos de salida: 0 CLICK TV es Home; 1 no se pudo (el launcher de fábrica se reactivó si se había tocado); 2 uso o TV no conectado.
set -euo pipefail
export LC_ALL=C

ADB="${ADB:-adb}"
PKG="${APP_PACKAGE:-com.clicktv.launcher}"
COMPONENT="${APP_COMPONENT:-com.clicktv.launcher/com.leanbitlab.ltvL.MainActivity}"
STOCK="${STOCK_LAUNCHER:-com.google.android.tvlauncher}"

command -v "$ADB" >/dev/null 2>&1 || { echo "no encuentro '$ADB'. En Termux: pkg install android-tools" >&2; exit 2; }

if [ -n "${TV_HOST:-}" ]; then
  "$ADB" connect "$TV_HOST:5555" >/dev/null 2>&1 || true
  SERIAL="$TV_HOST:5555"
else
  SERIAL=""
fi
adb_cmd() { if [ -n "$SERIAL" ]; then "$ADB" -s "$SERIAL" "$@"; else "$ADB" "$@"; fi; }

if [ "$(adb_cmd get-state 2>/dev/null || true)" != device ]; then
  echo "no hay TV conectado por ADB${TV_HOST:+ ($TV_HOST)}." >&2
  exit 2
fi

# 1. Instalada?
if [ -z "$(adb_cmd shell pm path "$PKG" 2>/dev/null | tr -d '\r')" ]; then
  echo "$PKG no está instalada en el TV. Instala primero el APK (adb install -r app.apk)." >&2
  exit 2
fi

# Quién responde a Home ahora (para poder revertir).
home_now() {
  adb_cmd shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME 2>/dev/null \
    | tr -d '\r' | tail -n 1
}
echo "Home actual: $(home_now)"

# 2. Fijar Home.
OUT="$(adb_cmd shell cmd package set-home-activity "$COMPONENT" 2>&1 | tr -d '\r' || true)"
echo "set-home-activity: $OUT"

# 3. Desactivar el launcher de fábrica.
if [ "$STOCK" != none ]; then
  OUT="$(adb_cmd shell pm disable-user --user 0 "$STOCK" 2>&1 | tr -d '\r' || true)"
  echo "desactivar $STOCK: $OUT"
fi

# 4. Comprobar.
NOW="$(home_now)"
echo "Home después: $NOW"
if printf '%s' "$NOW" | grep -q "$PKG"; then
  echo "OK: CLICK TV es la pantalla de inicio."
  exit 0
fi

echo "ERROR: Home sigue resolviendo a '$NOW', no a $PKG. Reactivo $STOCK." >&2
if [ "$STOCK" != none ]; then
  adb_cmd shell pm enable "$STOCK" >/dev/null 2>&1 || true
fi
exit 1
