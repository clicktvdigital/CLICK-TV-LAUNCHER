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
- Antes de cualquier release: verificar que `pubspec.yaml` (`version: 2026.10.31+8113` al cierre de esta nota) coincide con el tag que se va a publicar. Hoy el tag más reciente es `v2026.11.13`, así que la versión del pubspec está desfasada y debe revisarse.

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

## Cómo mantener esta memoria

Actualizar este archivo cuando cambien: el repo de release, la rama de trabajo, el estado de CI de una versión, o las skills instaladas. No guardar aquí credenciales ni datos personales.
