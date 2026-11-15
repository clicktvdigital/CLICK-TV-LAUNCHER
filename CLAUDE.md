# CLAUDE.md — memoria del proyecto CLICK TV LAUNCHER

Este archivo se carga al iniciar cada sesión en este repositorio. Mantenlo corto, verificado y actualizado cuando cambie el estado real.

## Identidad

- App: **CLICK TV LAUNCHER by CLICK TV DIGITAL**, launcher Flutter para Android TV / Google TV / TV Box.
- Base: FLauncher (GPLv3). Conserva licencia, copyright y atribuciones de los autores originales.
- Paquete de producción: `com.clicktv.launcher`.
- Idioma de interfaz y documentación: español (con localizaciones adicionales). Responder al equipo en español.

## Repositorio de release (decisión)

- **Repositorio oficial de release: `clicktvdigital/CLICK-TV-LAUNCHER`** (público). Tiene los tags `v2026.11.12` y `v2026.11.13`, y el workflow `.github/workflows/release.yml` se dispara con tags `v*`.
- `clicktvdigital/CLICK-TV-LAUNCHER-REBUILD` (privado, último push 2026-10-17) **fue eliminado por el responsable el 2026-11-15**. El respaldo local previo a su borrado no se completó: no hay copia del historial en esta sesión. Si se necesita recuperarlo, la vía es buscar clones locales o pedir restauración a GitHub Support. No era el repo de release.
- Versión actual: `2026.11.13+8114` (alineada con el tag `v2026.11.13`). Tag y `versionName` deben coincidir.
- La versión está fijada en cinco sitios; cambiarla exige actualizarlos todos: `pubspec.yaml`, `.github/workflows/release.yml` (`version_code = 8114`), `.github/workflows/clicktv-build-test.yml` (`8114`), `android/app/build.gradle` (valor por defecto `'8114'`) y `test/widgets/settings/flauncher_about_dialog_test.dart`.
- El `versionCode` debe ser siempre mayor que el de la última APK publicada (nunca reutilizar un número).

## Ramas

- Rama de trabajo de esta sesión: `claude/bold-newton-2h6b1j`. `main` y `origin/main` apuntan al mismo commit.
- `docs/CONTINUAR_AQUI.md` menciona `test/click-tv-launcher-paralelo`; esa rama ya está fusionada en `main`. El documento está desactualizado en ese punto.
- Ramas remotas **sin fusionar** en `main` (revisar antes de borrar): `chore/click-tv-launcher-audit`, `claude/quirky-bardeen-373gty`, `claude/vigilant-shannon-xvf76q`, `claude/wizardly-albattani-a06e8v`, `clicktv-mejoras`.
- No hacer push a `main` ni crear PR sin que el usuario lo pida explícitamente.

## Comandos de desarrollo

Requisitos (según README): Flutter 3.24.5, Java 21, Android SDK API 35.

```bash
flutter pub get
flutter gen-l10n
flutter test
flutter build apk --debug --target-platform=android-arm,android-arm64
```

- Antes de un commit: `git diff --check` y revisar que no se incluyan APK, respaldos, informes locales, secretos ni datos de pago.
- Antes de instalar una APK: validar `applicationId`, `versionCode`, ABI y certificado de firma.

## Reglas de contenido (no negociables)

- No publicar datos de cuentas bancarias, titulares, correos, payloads QR ni credenciales en README, logs o informes.
- No publicar APK ni cambiar la visibilidad del repositorio sin auditoría de secretos, licencias y CI.
- Los métodos de donación sin destino oficial confirmado (Binance, GitHub Sponsors, Patreon) se muestran como pendientes, no como pagos activos.
- Las funciones de clima, Alerta EC, tráfico de red y orden inteligente siguen en revisión; no anunciarlas como terminadas.

## Estado de validación

- Las pruebas de CI deben consultarse por `headSha` exacto; un workflow en rojo no se considera verde.
- Pendiente físico en TV (no verificable por CI): splash en arranque en frío, lectura de QR desde cámara, legibilidad 720p/1080p, comportamiento del mando y de Atrás.

## Skills del proyecto (`.claude/skills/`)

Instaladas como archivos versionados del repo, para que estén disponibles en cada sesión:

| Skill | Origen | Uso |
| --- | --- | --- |
| `impeccable` | github.com/pbakaus/impeccable (MIT) | Diseño, crítica y pulido de interfaces. Se invoca con `/impeccable`. |
| `graphify` | github.com/safishamsi/graphify (MIT) | Grafo de conocimiento del código. Se invoca con `/graphify`. Requiere CLI (ver abajo). |
| `emil-design-eng` | github.com/emilkowalski/skills (MIT) | Criterio de UI, transiciones y detalles de interacción. |
| `review-animations` | github.com/emilkowalski/skills | Revisión estricta de animaciones y movimiento. |
| `pick-ui-library` | github.com/emilkowalski/skills | Elegir librería de UI para una tarea concreta. |

Limitaciones de la instalación actual:
- **Impeccable**: solo se copiaron los SKILL.md y las 36 referencias. Faltan `scripts/impeccable` (motor/detector) y el hook de diseño, que requieren ejecutar el instalador. Para completarlo, el responsable del repo puede ejecutar `npx impeccable install --providers=claude --scope=project` y revisar qué hook propone antes de aceptarlo.
- **Graphify**: el skill necesita el CLI. Para usarlo localmente: `pip install graphifyy` (el paquete se llama `graphifyy` temporalmente). No se instaló en el entorno de esta sesión.
- Las salidas de Graphify (`graphify-out/`, `.graphify_*`) están en `.gitignore`.

## Estado de herramientas (revisar al iniciar sesión)

Los plugins se activan por cuenta, no por repo: este archivo solo registra qué falta.

**Plugins a activar en la cuenta (pendientes):**
- Dart and Flutter (oficial, `plugin_01YDaEFPGsRoFQj4zBhuw7fn`): pruebas de widgets, arquitectura, layouts responsivos, integración.
- Flutter Skills (`plugin_01ASc3bFGmz44EnftMaomCJ5`): Clean Architecture, widget composition, testing, CI/CD y Riverpod.
- clean-architecture (`plugin_019brWQHvTfrt2tZY1xRJE8P`): capas y regla de dependencias.

Si la sesión no muestra estos plugins, pedir las tarjetas de instalación con esos IDs.

**Skills en el repo (`.claude/skills/`), activos:** impeccable, graphify, emil-design-eng, review-animations, pick-ui-library, taste-skill (solo SKILL.md y dos referencias).

**Pendientes de instalación en el repo:**
- impeccable: motor `scripts/impeccable` y hook (`npx impeccable install --providers=claude --scope=project`, revisando el hook).
- graphify: CLI (`pip install graphifyy`).
- taste-skill: faltan sus sub-archivos; la ruta del repo no se localizó.

**Skills no encontrados** (no inventar rutas): `flutter-building-layouts`, `flutter-tizen-tv-remote-input`, `android-dev`, `mobile-toolchain-unifier`. Pedir enlace al repo al usuario.

**Riverpod:** `flutter_riverpod` 2.6.1 instalado, sin migrar código (la app usa `provider`).

**Compilar APK local:** requiere Android SDK en `/opt/android-sdk` (API 35, build-tools 35.0.0, platform-tools) y el flag `--android-project-arg localDebug=true`, porque el build debug normal exige la keystore paralela. El SDK no persiste entre sesiones: reinstalar con `sdkmanager` o añadir un setup script al entorno.

## Cómo mantener esta memoria

Actualizar este archivo cuando cambien: el repo de release, la rama de trabajo, el estado de CI de una versión, o las skills instaladas. No guardar aquí credenciales ni datos personales.
