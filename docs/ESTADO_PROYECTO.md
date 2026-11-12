# Estado del proyecto: CLICK TV Launcher y Alerta EC

Documento de continuidad. Léelo antes de empezar cualquier sesión nueva.

## Ramas y builds

- Launcher: rama `claude/wizardly-albattani-a06e8v`.
  Último build: ejecución 36 (commit `89a4266`). Artefacto: `CLICK-TV-LAUNCHER-PRUEBA-FIRMADA`.
- Alerta EC: rama `claude/clima-launcher-por-defecto` (repo `clicktvdigital/Alerta-EC`).
  Último build: ejecución 18 (commit `b16ae4c`). Artefacto: `ALERTA-EC-v0.1.11-RELEASE-PRUEBA`, APK `Alerta-EC-v0.1.11.apk`.
- Instalar siempre los builds firmados de release (no el debug). Paquete de Alerta EC: `com.clicktvdigital.alertaec`. Paquete del launcher: `com.clicktv.launcher`.
- TV: `192.168.100.11:5555` (SWTV-20SA, armeabi-v7a, 1920x1080, densidad 320).

## Lo que ya funciona en el TV (verificado)

- Clima en la barra superior y notificación de Alerta EC (con el permiso de notificaciones concedido).
- Fondos de Ecuador con subtítulo solo con el lugar (sin hora del día).
- Lluvia: la barra muestra la hora en que empieza (próximas 24 h, 30 % o más).

## Pendiente de verificar en el TV

- Banner de CLICK TV con la franja negra solo arriba (commit `89a4266`).
- Barra del clima con cada dato en su línea (commit `d4bb8f4`).
- Intro de Alerta EC en horizontal: carpeta `res/raw-land` (commit `b16ae4c`).
- Banner de Alerta EC con el logo horizontal completo (commit `4fb9505`, dentro de la ejecución 18).

## Pendiente sin resolver

- **Teclas arriba y abajo en Alerta EC** (pantalla principal y Configuración). El diagnóstico con `uiautomator dump` muestra 27 elementos enfocables y el foco en un contenedor grande del panel derecho que no está en el código del proyecto. No se debe disparar otro build sin identificar ese componente.
- Pruebas físicas que solo puede hacer el usuario: splash en arranque en frío, escanear el QR de Donativos, mando con el firmware real.
- Decidir si CLICK TV queda como pantalla de inicio (`set-home.sh` desactiva el launcher de fábrica).
- Versión final: launcher `2026.11.12` con `versionCode` 8114, y Alerta EC `0.1.12` con `versionCode` 112. Los dos workflows de release tienen números fijos que hay que cambiar.
- Publicar release con tag: solo con confirmación explícita del usuario, porque es pública.

## Preferencias del usuario (aplican siempre)

- Imágenes completas: sin recortes que quiten contenido, sin difuminado, sin barras laterales. La franja negra solo arriba es aceptable.
- Banners y tarjetas uniformes en 16:9; sin imágenes verticales.
- Los textos del clima deben verse completos: cada dato en su propia línea.
- El pop-up del launcher no debe repetir las notificaciones de Alerta EC.
- Hablar en español, de forma directa, sin sobreactuar.
- No hacer cambios a ciegas: verificar en el TV antes de declarar algo arreglado.

## Cómo instalar un build firmado

```fish
set DIR ~/clicktv-run
rm -rf $DIR; mkdir -p $DIR
gh run download <RUN_ID> -R clicktvdigital/CLICK-TV-LAUNCHER -n CLICK-TV-LAUNCHER-PRUEBA-FIRMADA -D $DIR
set APK (find $DIR -name '*.apk' | head -n 1)
adb -s 192.168.100.11:5555 install -r $APK
adb -s 192.168.100.11:5555 shell am force-stop com.clicktv.launcher
adb -s 192.168.100.11:5555 shell am start -W -n com.clicktv.launcher/com.leanbitlab.ltvL.MainActivity
```

Para Alerta EC, el mismo bloque con `-R clicktvdigital/Alerta-EC`, `-n ALERTA-EC-v0.1.11-RELEASE-PRUEBA`, APK `Alerta-EC-v0.1.11.apk` y paquete `com.clicktvdigital.alertaec`.
