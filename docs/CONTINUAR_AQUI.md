# CONTINUAR AQUI — CLICK TV LAUNCHER

## Estado de esta rama

- Rama de trabajo: `chore/click-tv-launcher-audit`.
- Identidad visible: CLICK TV LAUNCHER by CLICK TV DIGITAL.
- `applicationId`: `com.clicktv.launcher`.
- `minSdk`: 21 (Android 5.0); `targetSdk`/`compileSdk`: 35.
- `versionCode`: 8113, superior a 8111.
- ABI release: `armeabi-v7a` y `arm64-v8a`, con APK universal y divididos.
- Splash oficial conservado en 1920×1080, relación 16:9 y sin recortes.
- Logo pequeño y banner grande alineados con el recurso oficial CLICK TV DIGITAL.
- Español seleccionado como idioma inicial; se mantienen los demás idiomas.
- Navegación con control remoto mediante atajos D-pad, OK/Enter, Atrás y acciones de foco.
- Donaciones: se conservan los diez métodos existentes. Binance, GitHub Sponsors y Patreon siguen pendientes y no tienen enlaces inventados ni activación de pagos.
- Licencia GPL v3, avisos y atribuciones originales conservados.

## Verificaciones realizadas

- Auditoría de configuración, manifest, recursos, localización, donaciones, navegación y workflows: realizada en esta rama.
- Inspección de dimensiones: splash 1920×1080; logo 512×512; banner 640×360.
- Pruebas automatizadas y compilación local: intentadas; no ejecutables en este entorno porque `flutter` no está instalado (`exit 127`).
- Validación de firma: definida en GitHub Actions; requiere los secretos oficiales y no se ejecuta aquí sin ellos.
- No se instaló ninguna APK en un televisor, no se actualizó una aplicación instalada y no se eliminaron datos.

## Siguiente paso seguro

1. Ejecutar `flutter pub get`, `flutter gen-l10n` y `flutter test`.
2. Ejecutar la acción manual `CLICK TV LAUNCHER - Validar APK firmada` con los cuatro secretos de firma.
3. Revisar `apksigner`, package `com.clicktv.launcher`, `versionCode`, ABI y SHA-256 del certificado oficial.
4. Probar el APK firmado en equipos Android 5.0+, Android TV y Google TV de 32/64 bits.
5. Solo después de verificar el certificado y contar con autorización explícita, considerar actualizar una instalación existente.

No hacer push, publicar releases, instalar en televisores ni borrar datos desde esta rama sin autorización.
