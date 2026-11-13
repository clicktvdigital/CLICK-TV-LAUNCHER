# CONTINUAR AQUÍ — CLICK TV LAUNCHER

Documento maestro para continuar el trabajo sin mezclar validaciones de CI con observaciones físicas de un televisor.

## Identidad y alcance

- Proyecto: **CLICK TV LAUNCHER by CLICK TV DIGITAL**.
- Repositorio: `clicktvdigital/CLICK-TV-LAUNCHER`.
- Rama de desarrollo: `test/click-tv-launcher-paralelo`.
- Paquete de producción documentado: `com.clicktv.launcher`.
- Licencia: GNU GPLv3, con créditos y avisos de FLauncher/LeanBitLab conservados.
- Compatibilidad objetivo: Android API 21+, Android TV/Google TV, `armeabi-v7a` y `arm64-v8a`.

La rama de pruebas no debe confundirse con `main`. No se debe publicar una APK ni cambiar la visibilidad del repositorio hasta completar la auditoría de secretos, licencias, recursos y CI.

## Arquitectura de trabajo

La aplicación es Flutter con integración Android nativa para el arranque, canales del sistema y compatibilidad TV. La navegación se realiza mediante foco, cruceta, OK/Enter, Atrás y atajos de mando. Las pruebas de widgets validan restricciones, foco y rutas; no sustituyen una observación física del dispositivo.

## Funciones disponibles

- Launcher de Android TV sin anuncios, con categorías y personalización.
- Español predeterminado y localizaciones adicionales.
- Splash con identidad CLICK TV y banner DEBUG oculto visualmente sin desactivar la depuración.
- Acerca de con logo oficial y cuatro enlaces:
  - https://click-tv-streaming.vercel.app
  - https://t.me/clicktvgo
  - https://t.me/click_tv_streaming
  - https://t.me/clicktvdigital
- Accesibilidad con `SafeArea`, desplazamiento y textos localizados.
- Donativos con los métodos existentes, QR ampliado para payloads válidos y métodos pendientes sin QR ficticio.

## Estado de validación

### CI

Las pruebas deben consultarse por `headSha` exacto. Un workflow global en rojo no se considera verde aunque determinados tests hayan pasado. La ejecución asociada al commit 87f2859 estaba compilando el APK Android TV al iniciar este documento; sus resultados finales deben verificarse antes de presentar una versión estable.

### Comprobación física en TV

Todavía deben separarse de CI estas comprobaciones:

- Splash visible durante un arranque frío real.
- Lectura de QR con la cámara de un teléfono frente al TV.
- Legibilidad en 720p, 1080p y escalado ampliado.
- Comportamiento del mando y del botón Atrás en el firmware concreto.

## Donativos

La aplicación conserva diez métodos configurados en su código, incluidos bancos ecuatorianos, Deuna!, PayPhone y PayPal. Binance, GitHub Sponsors y Patreon permanecen pendientes si no existe un destino oficial confirmado. Los datos de cuenta, titulares, correos, enlaces y payloads QR no deben copiarse a informes, README ni logs.

La interfaz puede mostrar aportes voluntarios sugeridos:

- Aporte único: cafecito $1, tamalito lojano con café $3, encebollado $5.
- Patrocinio mensual sugerido: Amigo $2/mes, Protector $5/mes, Aliado $10/mes.

Estas cantidades son orientativas. No habilitan cobros recurrentes ni prometen beneficios que la aplicación no implemente.

## Pendientes priorizados

1. Completar la validación de CI del commit actual y distinguir fallos históricos de regresiones.
2. Observar el splash en un arranque frío del TV sin introducir demoras artificiales.
3. Escanear físicamente un QR ampliado y documentar solo el resultado, sin publicar el payload.
4. Diagnosticar la fuente de clima y su relación real —si existe— con Alerta EC.
5. Indicador ligero de tráfico de red, sin pruebas de velocidad ni polling permanente. Ya existe `DailyDataUsageWidget` con uso diario, semanal y mensual; se quitó el `Timer` de 5 minutos de `NetworkService`, que hacía polling. Falta comprobarlo en TV y ejecutar `flutter test`, que no se pudo correr en el entorno de Claude.
6. Revisar orden inteligente de aplicaciones únicamente con fixtures y requisitos confirmados.

## Cómo continuar

```bash
git switch test/click-tv-launcher-paralelo
git status --short --branch
flutter pub get
flutter gen-l10n
flutter test
```

Antes de un commit, ejecutar `git diff --check` y revisar que no se incluyan informes locales, APK, respaldos, secretos ni datos de pago. Antes de instalar, comprobar package, versión, ABI, firma y respaldo. No cambiar `main` ni modificar un televisor durante las validaciones de documentación.

### Entorno de trabajo: Termux + fish + adb

El trabajo de instalación y pruebas se hace desde **Termux** en Android, usando **fish** como shell y **adb** para hablar con el televisor. Los comandos de esta sección son orientativos: confirmar cada uno en el dispositivo antes de depender de él.

Instalación de herramientas en Termux (una sola vez):

```bash
pkg update && pkg upgrade
pkg install git gh openssh android-tools fish
```

Abrir fish dentro de Termux (en Termux no se cambia el shell por defecto con `chsh`):

```bash
fish
```

Conexión adb al televisor por depuración inalámbrica. Activar en el TV: Ajustes → Preferencias del dispositivo → Opciones de desarrollador → Depuración inalámbrica (o Depuración ADB). El teléfono y el TV deben estar en la misma red Wi-Fi.

```bash
adb pair IP_DEL_TV:PUERTO_DE_EMPAREJAMIENTO
adb connect IP_DEL_TV:PUERTO_DE_CONEXION
adb devices
```

Notas:
- `adb pair` pide un código de seis dígitos que muestra el TV; el puerto de emparejamiento y el de conexión suelen ser distintos.
- Si `adb devices` no muestra el TV como `device`, revisar la red y repetir el emparejamiento.
- No copiar IP, códigos ni números de serie del televisor a este documento ni a los commits.

### Verificar conexión adb y rama desde Termux

Comprobar en este orden. Ninguno de estos comandos instala, borra ni cambia nada en el televisor.

```bash
# 1. Conexión adb: debe aparecer el TV con estado "device"
adb devices -l

# 2. Identificar el TV conectado (modelo y versión de Android)
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release

# 3. Versión instalada del launcher (paquete de la compilación de pruebas)
adb shell dumpsys package com.clicktv.launcher.test.parallel.debug | grep -E "versionName|versionCode"
```

Si el paquete instalado es el de depuración local, el sufijo es `.local.debug` en lugar de `.test.parallel.debug`. Confirmar cuál corresponde a la compilación que se está probando.

```bash
# 4. Rama y commit locales
cd ~/CLICK-TV-LAUNCHER
git rev-parse --abbrev-ref HEAD
git log -1 --oneline

# 5. Diferencias con el remoto (sin modificar nada)
git fetch origin
git status -sb
```

Lectura esperada: la rama debe ser `claude/vigilant-shannon-xvf76q`, `git status -sb` no debe mostrar `ahead` ni `behind`, y los archivos modificados deben ser solo los que se esperan.

Estado de CI de la rama (desde Termux con `gh`):

```bash
gh run list --branch claude/vigilant-shannon-xvf76q --limit 5
gh run view ID_DEL_RUN --json status,conclusion,headSha
```

Un run solo cuenta como válido si su `headSha` coincide con `git rev-parse HEAD`.

### GitHub desde Termux

Autenticación con `gh` desde Termux:

```bash
gh auth login
gh auth setup-git
gh auth status
```

Recomendación: no pegar tokens en el chat ni en archivos del repositorio. Si se usa un token, guardarlo en un archivo local fuera del repo y pasarlo con `gh auth login --with-token < RUTA_DEL_ARCHIVO`. El token debe tener solo los permisos necesarios y no debe aparecer en `git diff`, README ni logs.

Alternativa con SSH: generar una clave con `ssh-keygen -t ed25519`, registrar la parte pública en GitHub y usar la URL `git@github.com:clicktvdigital/CLICK-TV-LAUNCHER.git`.

Flujo básico de trabajo en la rama de desarrollo:

```bash
git switch claude/vigilant-shannon-xvf76q
git pull --ff-only
git status --short --branch
git push -u origin claude/vigilant-shannon-xvf76q
```

## Recursos públicos

Se reutilizan el logo `assets/icon.png`, el banner `assets/banner.png`, el splash `assets/click_tv_splash.png` y las capturas auténticas en `docs/images/`. Los banners SVG históricos que contienen la marca LTvLauncher no se usan como cabecera de CLICK TV; se conservan solo para no eliminar recursos de terceros sin una decisión de licencia.

## Pantalla de inicio del TV (opcional, cambia el sistema)

`tools/debloat/set-home.sh` deja CLICK TV como pantalla de inicio por ADB. Desactiva el launcher de fábrica y, si la comprobación final no ve CLICK TV como Home, lo reactiva y sale con error. Es un cambio del sistema del televisor: hazlo solo después de confirmar la instalación y tener el respaldo de la APK.

Antes de ejecutarlo, confirma el nombre del launcher de fábrica de tu TV:

```bash
adb -s 192.168.100.11:5555 shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME
```

Después, desde Termux, en la carpeta del repositorio:

```bash
TV_HOST=192.168.100.11 STOCK_LAUNCHER=NOMBRE_DEL_LAUNCHER_DE_FABRICA tools/debloat/set-home.sh
```

Códigos de salida: `0` CLICK TV es Home; `1` no se pudo y el launcher de fábrica se reactivó; `2` uso incorrecto o TV no conectado. Para volver atrás a mano: `adb -s 192.168.100.11:5555 shell pm enable NOMBRE_DEL_LAUNCHER_DE_FABRICA`.

Los banners personalizados se guardan por nombre de paquete (`custom_banner_<paquete>`) y se conservan al actualizar con `install -r`. Se pierden solo si se desinstala la app.
