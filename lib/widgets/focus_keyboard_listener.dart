/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';

import 'package:flauncher/widgets/app_card_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Registro de diagnóstico del control remoto. Se ve en el TV box con:
///   adb logcat -s flutter | grep CTVKEY
/// Solo escribe en eventos de teclas de validación/menú (no en cada frame).
void ctvKeyLog(String message) {
  final now = DateTime.now();
  final t = '${now.second.toString().padLeft(2, '0')}.'
      '${now.millisecond.toString().padLeft(3, '0')}';
  debugPrint('CTVKEY $t $message');
}

String _keyName(LogicalKeyboardKey key) =>
    key.debugName ?? '0x${key.keyId.toRadixString(16)}';

class FocusKeyboardListener extends StatefulWidget {
  /// Tiempo que hay que mantener OK (D-pad center) para abrir el menú de
  /// configuración de la tarjeta. Las teclas Menú/Info lo abren al instante.
  static const Duration defaultLongPressDelay = Duration(seconds: 1);

  /// Margen para confirmar que OK se soltó de verdad. Algunos controles IR de
  /// TV box (aml_keypad) envían OK con el código físico de Control Right;
  /// Flutter lo trata como modificador y en cada repetición de la tecla
  /// sostenida sintetiza un KeyUp seguido de un KeyDown (~100 ms entre pares,
  /// 5-20 ms entre el KeyUp y el KeyDown, medido en el TV box). Si llega otro
  /// KeyDown de la tecla dentro de este margen, es la misma pulsación.
  static const Duration releaseGrace = Duration(milliseconds: 150);

  /// Momento del último evento de una tecla de validación (OK) visto por
  /// cualquier tarjeta. El menú lo usa para saber si se abrió con OK todavía
  /// sostenido aunque Flutter lo reporte suelto entre dos pares sintetizados.
  static DateTime? lastValidationKeyEventAt;

  final WidgetBuilder builder;
  final KeyEventResult Function(LogicalKeyboardKey)? onPressed;
  final KeyEventResult Function(LogicalKeyboardKey)? onLongPress;
  final Duration longPressDelay;

  FocusKeyboardListener({
    Key? key,
    required this.builder,
    this.onPressed,
    this.onLongPress,
    this.longPressDelay = defaultLongPressDelay,
  }) : super(key: key);

  @override
  _FocusKeyboardListenerState createState() => _FocusKeyboardListenerState();
}

// Tecla registrada en su KeyDown: tecla lógica y momento de la pulsación.
class _PressedKey {
  const _PressedKey(this.logicalKey, this.pressedAt);

  final LogicalKeyboardKey logicalKey;
  final DateTime pressedAt;
}

class _FocusKeyboardListenerState extends State<FocusKeyboardListener> {
  // Un KeyDown repetido de una tecla de validación antes de este tiempo se
  // considera duplicado del control. Después se trata como pulsación nueva,
  // para que una tecla cuyo KeyUp se perdió no quede bloqueada. Debe superar
  // la espera de la pulsación larga: si fuese menor, un KeyDown duplicado a
  // mitad de la espera se tomaría como pulsación nueva.
  Duration get _staleKeyDelay =>
      widget.longPressDelay + const Duration(seconds: 1);

  // Un solo temporizador por tarjeta, sin trabajo periódico: el hilo principal
  // queda libre durante toda la espera (importante en TV box de 1 GB).
  Timer? _longPressTimer;
  bool _longPressTriggered = false;

  // KeyUp de OK pendiente de confirmar (ver FocusKeyboardListener.releaseGrace).
  Timer? _releaseTimer;
  // El temporizador de 1 s se cumplió mientras había un KeyUp sin confirmar:
  // la decisión se toma al llegar la continuación o al confirmar la liberación.
  bool _longPressDue = false;
  int? _keyDownAt;
  final Set<LogicalKeyboardKey> _handledKeys = {};

  // Teclas físicas pulsadas. Algunos controles de TV box envían la misma tecla
  // física con códigos lógicos distintos al presionar y al soltar (por ejemplo
  // Select y Control Right), así que el KeyUp se empareja por tecla física y
  // usa la tecla lógica registrada en el KeyDown.
  final Map<PhysicalKeyboardKey, _PressedKey> _pressedKeys = {};

  @visibleForTesting
  bool get hasPendingLongPress => _longPressTimer?.isActive ?? false;

  @override
  void dispose() {
    _cancelLongPressTimer();
    _cancelReleaseTimer();
    _pressedKeys.clear();
    _handledKeys.clear();
    super.dispose();
  }

  void _cancelReleaseTimer() {
    _releaseTimer?.cancel();
    _releaseTimer = null;
  }

  void _cancelLongPressTimer() {
    _longPressTimer?.cancel();
    // Se suelta la referencia para liberar el cierre (tecla y callback).
    _longPressTimer = null;
  }

  // Descarta cualquier pulsación en curso. Se usa al perder el foco (por
  // ejemplo cuando se abre el menú y el KeyUp ya no llega a esta tarjeta) y
  // cuando un KeyUp se perdió; si no, la siguiente pulsación corta podía abrir
  // el menú al instante o quedar ignorada.
  void _resetPressState() {
    _cancelLongPressTimer();
    _cancelReleaseTimer();
    _longPressDue = false;
    _longPressTriggered = false;
    _keyDownAt = null;
    _pressedKeys.clear();
    _handledKeys.clear();
  }

  @override
  Widget build(BuildContext context) => Focus(
        canRequestFocus: false,
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            if (_keyDownAt != null || _longPressTriggered) {
              ctvKeyLog('card#${identityHashCode(this)} perdió el foco: se descarta la pulsación');
            }
            _resetPressState();
          }
        },
        onKeyEvent: (_, keyEvent) => _handleKey(context, keyEvent),
        child: Builder(builder: widget.builder),
      );

  KeyEventResult _handleKey(BuildContext context, KeyEvent keyEvent) {
    if (AppCardKeys.validationKeys.contains(keyEvent.logicalKey)) {
      FocusKeyboardListener.lastValidationKeyEventAt = DateTime.now();
    }
    final result = _handleKeyInner(context, keyEvent);
    final key = keyEvent.logicalKey;
    if (AppCardKeys.longPressableKeys.contains(key) ||
        AppCardKeys.validationKeys.contains(key) ||
        _pressedKeys.isNotEmpty) {
      ctvKeyLog('card#${identityHashCode(this)} ${keyEvent.runtimeType} '
          'logical=${_keyName(key)} physical=0x${keyEvent.physicalKey.usbHidUsage.toRadixString(16)} '
          'synth=${keyEvent.synthesized} -> ${result.name} keyDownAt=${_keyDownAt != null} '
          'triggered=$_longPressTriggered timer=${_longPressTimer?.isActive ?? false}');
    }
    return result;
  }

  KeyEventResult _handleKeyInner(BuildContext context, KeyEvent keyEvent) {
    if (keyEvent is KeyDownEvent) {
      final now = DateTime.now();
      final physicalKey = keyEvent.physicalKey;
      final tracked = _pressedKeys[physicalKey];
      // Solo las teclas de validación bloquean duplicados. En las flechas el
      // foco puede cambiar entre KeyDown y KeyUp, y el registro quedaría
      // obsoleto en este widget.
      if (tracked != null &&
          AppCardKeys.longPressableKeys.contains(tracked.logicalKey)) {
        if (now.difference(tracked.pressedAt) < _staleKeyDelay) {
          // KeyDown duplicado sin KeyUp: no reinicia la pulsación.
          return KeyEventResult.handled;
        }
        // KeyUp perdido: se empieza de cero en vez de heredar el estado viejo.
        _resetPressState();
      }
      _pressedKeys[physicalKey] = _PressedKey(keyEvent.logicalKey, now);
      return _keyDownEvent(context, keyEvent.logicalKey);
    }

    if (keyEvent is KeyRepeatEvent) {
      final key = _pressedKeys[keyEvent.physicalKey]?.logicalKey ??
          keyEvent.logicalKey;

      // Una vez abierto el menú, las repeticiones de OK se ignoran hasta el
      // KeyUp; si no, una repetición podría lanzar la app por accidente.
      // Antes de eso solo comparan la hora (sin trabajo extra) como respaldo
      // por si el temporizador se retrasa en un equipo lento.
      if (_longPressTriggered && AppCardKeys.longPressableKeys.contains(key)) {
        return KeyEventResult.handled;
      }

      if (AppCardKeys.isArrowKey(key)) {
        final result = widget.onPressed?.call(key) ?? KeyEventResult.ignored;
        if (result == KeyEventResult.handled) {
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      }
      return _keyDownEvent(context, key);
    }

    if (keyEvent is KeyUpEvent) {
      final key = _pressedKeys.remove(keyEvent.physicalKey)?.logicalKey ??
          keyEvent.logicalKey;
      return _keyUpEvent(context, key);
    }

    return KeyEventResult.handled;
  }

  KeyEventResult _keyDownEvent(BuildContext context, LogicalKeyboardKey key) {
    // Menu or info key opens options immediately without waiting
    if (AppCardKeys.menuKeys.contains(key)) {
      _cancelLongPressTimer();
      _longPressTriggered = false;
      _keyDownAt = null;
      return widget.onLongPress?.call(key) ?? KeyEventResult.ignored;
    }

    if (!AppCardKeys.longPressableKeys.contains(key)) {
      final result = widget.onPressed?.call(key) ?? KeyEventResult.ignored;
      if (result == KeyEventResult.handled) {
        _handledKeys.add(key);
      }
      return result;
    }

    if (_releaseTimer != null) {
      // KeyDown dentro del margen tras un KeyUp: es la misma pulsación
      // sostenida (par KeyUp/KeyDown sintetizado). No se reinicia la espera.
      _cancelReleaseTimer();
      if ((_longPressDue || _longPress()) && !_longPressTriggered) {
        _longPressDue = false;
        ctvKeyLog('card#${identityHashCode(this)} continuación: espera cumplida');
        _cancelLongPressTimer();
        _longPressTriggered = true;
        _keyDownAt = null;
        widget.onLongPress?.call(key);
      }
      return KeyEventResult.handled;
    }

    if (_keyDownAt == null) {
      _keyDownAt = DateTime.now().millisecondsSinceEpoch;
      _longPressTriggered = false;
      _longPressDue = false;
      _cancelLongPressTimer();
      _longPressTimer = Timer(widget.longPressDelay, () => _fireLongPress(key));
      return KeyEventResult.handled;
    } else if (_longPress() && !_longPressTriggered) {
      // Respaldo si el temporizador se retrasó (hilo ocupado en equipos lentos).
      _cancelLongPressTimer();
      _longPressTriggered = true;
      _keyDownAt = null;
      return widget.onLongPress?.call(key) ?? KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _fireLongPress(LogicalKeyboardKey key) {
    _longPressTimer = null;
    ctvKeyLog('card#${identityHashCode(this)} temporizador cumplido '
        'mounted=$mounted keyDownAt=${_keyDownAt != null}');
    if (!mounted || _keyDownAt == null) return;
    // Si hay un KeyUp sin confirmar, se decide al llegar la continuación
    // (KeyDown) o al confirmarse la liberación.
    if (_releaseTimer != null) {
      _longPressDue = true;
      return;
    }
    // Se marca antes de mostrar el diálogo: el KeyUp de esta misma pulsación
    // solo cierra el ciclo y nunca abre la app (ver _keyUpEvent).
    _longPressTriggered = true;
    _keyDownAt = null;
    widget.onLongPress?.call(key);
  }

  KeyEventResult _keyUpEvent(BuildContext context, LogicalKeyboardKey key) {
    if (_handledKeys.remove(key)) {
      _cancelLongPressTimer();
      return KeyEventResult.handled;
    }
    if (AppCardKeys.longPressableKeys.contains(key) &&
        (_keyDownAt != null || _longPressTriggered)) {
      // Se espera el margen antes de dar la tecla por soltada.
      _cancelReleaseTimer();
      _releaseTimer = Timer(FocusKeyboardListener.releaseGrace, () {
        _releaseTimer = null;
        if (mounted) _confirmRelease(key);
      });
      return KeyEventResult.handled;
    }
    _cancelLongPressTimer();
    return KeyEventResult.ignored;
  }

  void _confirmRelease(LogicalKeyboardKey key) {
    _cancelLongPressTimer();
    if (_longPressTriggered) {
      // KeyUp de la pulsación larga: se reinicia la bandera y no se lanza la app.
      _longPressTriggered = false;
      return;
    }
    if (_keyDownAt != null) {
      final heldMs = DateTime.now().millisecondsSinceEpoch - _keyDownAt!;
      final due = _longPressDue;
      _longPressDue = false;
      if (due || heldMs >= widget.longPressDelay.inMilliseconds) {
        // La espera se cumplió durante el margen: es pulsación larga.
        _keyDownAt = null;
        ctvKeyLog('card#${identityHashCode(this)} soltada tras $heldMs ms: pulsación larga');
        widget.onLongPress?.call(key);
        return;
      }
      _keyDownAt = null;
      ctvKeyLog('card#${identityHashCode(this)} soltada tras $heldMs ms: pulsación corta');
      widget.onPressed?.call(key);
    }
  }

  bool _longPress() =>
      _keyDownAt != null &&
      DateTime.now().millisecondsSinceEpoch - _keyDownAt! >=
          widget.longPressDelay.inMilliseconds;
}
