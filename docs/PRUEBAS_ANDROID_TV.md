# CLICK TV LAUNCHER: pruebas Android TV

Trabajar en `test/click-tv-launcher-paralelo`. No es necesario crear otro
checkout ni un worktree. No desinstalar el launcher existente ni borrar datos.
El nombre, splash, diseño personalizado e idioma español se conservan.

## Preparación y pruebas

Requisitos: Flutter **3.24.5**, JDK **21** (compilación Java 17), Android SDK
platform 35 y build-tools 35.0.0, ADB y `libsqlite3.so.0` en Linux.
La política de red necesita `storage.googleapis.com` para Flutter/Dart y
`api.github.com` para consultar Actions, además del preset de gestores de paquetes.
Git usa la autenticación inyectada de la plataforma; no poner tokens en scripts.

```sh
cd /workspace/CLICK-TV-LAUNCHER
export JAVA_HOME=/workspace/toolchains/jdk-21.0.9+10
export ANDROID_HOME=/workspace/toolchains/android
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PUB_CACHE=/workspace/toolchains/pub-cache
export GRADLE_USER_HOME=/workspace/toolchains/gradle-cache
# El entorno ya incluye la configuración de proxy y CA en ese directorio.
export PATH="/workspace/toolchains/flutter/bin:$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$PATH"
flutter --version
flutter pub get --enforce-lockfile
dart run build_runner build --delete-conflicting-outputs --build-filter=test/mocks.mocks.dart
test -s test/mocks.mocks.dart
dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
flutter gen-l10n
flutter test test/providers/apps_service_startup_test.dart test/flauncher_channel_test.dart test/widgets/startup_splash_test.dart test/custom_traversal_policy_test.dart test/actions_test.dart test/widgets/app_card_test.dart
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

Conservar los proxy y certificados CA proporcionados por la plataforma.
Para Gradle/Java, configurar el proxy mediante sus propiedades JVM si el entorno
no lo inyecta automáticamente; no desactivar TLS ni validaciones de firma.

## APK DEBUG

La compilación compartida usa los secretos `PARALLEL_DEBUG_*` ya definidos en
GitHub Actions. No sustituir su certificado ni publicar las claves.

El workflow `clicktv-debug-tv.yml` permite ejecución manual desde la rama de
pruebas y genera el artefacto **CLICK-TV-LAUNCHER-ANDROID-TV-DEBUG**, con un APK
universal para ARMv7 y ARM64. Verifica minSdk 21 y la firma compatible con API 21.
El job completo de pruebas Flutter se ejecuta por separado; revisar también su
resultado. Las pruebas dirigidas de inicio y control remoto sí bloquean el APK.
Los artefactos requieren acceso al repositorio y caducan a los 14 días.

Para desarrollar localmente sin las claves compartidas:

```sh
ORG_GRADLE_PROJECT_localDebug=true flutter build apk --debug --target-platform=android-arm,android-arm64
```

Esta opción usa la clave DEBUG estándar de Android y el paquete independiente
`com.clicktv.launcher.test.local.debug`. El compartido mantiene
`com.clicktv.launcher.test.parallel.debug`. Así no se reemplaza la aplicación
existente con una clave diferente. No usar esta opción para distribución de
producción. El APK estará bajo `build/app/outputs/flutter-apk/` o
`build/app/outputs/apk/debug/`; comprobar la salida real de la compilación.

## Comprobación desde Termux en el M201 (API 22, ARM de 32 bits)

Una vez descargado y extraído el APK desde el artefacto de Actions:

```sh
adb devices
adb shell getprop ro.build.version.sdk
adb shell getprop ro.product.cpu.abi
adb install -r /ruta/CLICK-TV-LAUNCHER-ANDROID-TV-DEBUG.apk
pkg=com.clicktv.launcher.test.parallel.debug
# Para un APK local, usar: pkg=com.clicktv.launcher.test.local.debug
adb shell am start -W -n "$pkg/com.leanbitlab.ltvL.MainActivity"
adb logcat -d -v threadtime AndroidRuntime:E flutter:V ClickTvLauncher:V ActivityManager:I System.err:W '*:S' > clicktv-inicio.log
```

No ejecutar `pm clear`, `adb uninstall` ni borrar respaldos si falla la instalación.
Si aparece `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, comprobar el paquete y certificado;
no desinstalar como solución automática.

Esperar a que aparezca la categoría principal y comprobar que contiene aplicaciones
TV y aplicaciones normales del Box. Probar estas teclas, observando cada resultado:

```sh
adb shell input keyevent 22  # derecha
adb shell input keyevent 21  # izquierda
adb shell input keyevent 20  # abajo
adb shell input keyevent 19  # arriba
adb shell input keyevent 23  # aceptar: abre la aplicación enfocada
adb shell input keyevent 4   # volver
```

Comprobar foco visible, apertura de apps, regreso al launcher y persistencia de
categorías tras abrirlo otra vez. Repetir en Android TV moderno ARM64. En API 21–22
el consumo de datos no está disponible: no se debe cargar `NetworkStatsManager`,
solicitar su permiso ni bloquear por ello el catálogo de aplicaciones.

Si aparece «Reintentar», guardar `clicktv-inicio.log`, pulsar el botón con el mando
y enviar el registro junto con el modelo, API, ABI y resultado de instalación.
Las pruebas widget no sustituyen esta comprobación en hardware.

## Ejecuciones solicitadas

- https://github.com/clicktvdigital/CLICK-TV-LAUNCHER/actions/runs/41876510856
- https://github.com/clicktvdigital/CLICK-TV-LAUNCHER/actions/runs/41879572279

No se puede afirmar su estado ni la existencia de un APK sin consultar las
respuestas autenticadas de GitHub. Un cambio local de workflow no modifica una
ejecución antigua; requiere subirlo a la rama de pruebas y ejecutar el nuevo flujo.
