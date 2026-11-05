# Donaciones: adaptación y control remoto

Rama exclusiva: `test/click-tv-launcher-paralelo`.

El caso de referencia es Android TV 11, 1920 × 1080 físicos, densidad 320 dpi:
**960 × 540 dp**. Las dimensiones del diálogo se calculan sobre el espacio lógico
que queda después de `SafeArea` e insets, no sobre la resolución física.

En TV se muestran dos paneles. La lista de métodos y los datos/aportes pueden
recorrerse verticalmente de forma independiente. El QR cuadrado permanece visible
en el panel de detalle y Cerrar queda fuera de los desplazamientos. En tamaños
estrechos el cuerpo tiene desplazamiento vertical y mantiene el mismo cierre fijo.
El QR ampliado usa el espacio restante real después del título y sus botones;
no descuenta alturas estimadas. Ambos QR conservan el contenido original y una
zona blanca alrededor del código que no cubren los indicadores de foco.

## Mando

- Arriba/abajo en métodos: recorrer bancos y otras opciones, con desplazamiento
  automático. Izquierda también permite volver al método anterior.
- OK o derecha en un método: seleccionarlo y enfocar su QR o primera opción válida.
- OK en el QR o «Ver QR ampliado»: abrir el QR completo. ATRÁS o «Volver»: regresar
  al control que lo abrió, con su foco restaurado.
- Arriba/abajo en detalle: recorrer QR, ampliar, enlace si existe, aportes y volver.
  Derecha avanza entre sus acciones. Izquierda vuelve al método seleccionado.
- ATRÁS desde detalle: volver al selector. ATRÁS desde el selector: cerrar solo
  las donaciones. Cerrar siempre permite salir directamente del diálogo.

## Comprobaciones

```sh
flutter test test/widgets/settings/donate_dialog_test.dart
```

La suite cubre 960 × 540 dp con densidad 2 (1920 × 1080 físicos), 1280 × 720,
1920 × 1080, texto ampliado, márgenes de seguridad y diseño estrecho. Comprueba
los límites internos del detalle, la forma cuadrada del QR, desplazamiento y
cierre fijos; recorre dos veces los diez métodos por D-pad y verifica cuentas,
enlaces, retorno del foco y la secuencia de ATRÁS sin cerrar el launcher.
La lectura real por cámara y el mando físico también deben probarse en el TV.

El workflow `.github/workflows/clicktv-debug-tv.yml` ejecuta estas pruebas antes
de compilar. Conserva el certificado DEBUG paralelo existente, verifica minSdk 21,
firma para API 21 y bibliotecas ARMv7/ARM64, entrega el artefacto y crea un borrador
prerelease dentro del repositorio privado. No publica una Release pública.
El resumen del job muestra la URL real de la Release creada.

Para instalar conservando los datos existentes:

```sh
adb install -r /ruta/CLICK-TV-LAUNCHER-ANDROID-TV-DEBUG.apk
```

No desinstalar ni ejecutar `pm clear`. Un error de certificado debe investigarse,
no resolverse borrando la instalación anterior. Ver `PRUEBAS_ANDROID_TV.md` para
los comandos de arranque y captura del registro desde Termux.
