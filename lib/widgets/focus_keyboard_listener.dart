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

class FocusKeyboardListener extends StatefulWidget {
  /// Tiempo que hay que mantener OK (D-pad center) para abrir el menú de
  /// configuración de la tarjeta. Las teclas Menú/Info lo abren al instante.
  static const Duration defaultLongPressDelay = Duration(seconds: 5);

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
  bool _longPressFired = false;
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
    _pressedKeys.clear();
    _handledKeys.clear();
    super.dispose();
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
    _longPressFired = false;
    _keyDownAt = null;
    _pressedKeys.clear();
    _handledKeys.clear();
  }

  @override
  Widget build(BuildContext context) => Focus(
        canRequestFocus: false,
        onFocusChange: (hasFocus) {
          if (!hasFocus) _resetPressState();
        },
        onKeyEvent: (_, keyEvent) => _handleKey(context, keyEvent),
        child: Builder(builder: widget.builder),
      );

  KeyEventResult _handleKey(BuildContext context, KeyEvent keyEvent) {
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
      if (_longPressFired && AppCardKeys.longPressableKeys.contains(key)) {
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
      _longPressFired = false;
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

    if (_keyDownAt == null) {
      _keyDownAt = DateTime.now().millisecondsSinceEpoch;
      _longPressFired = false;
      _cancelLongPressTimer();
      _longPressTimer = Timer(widget.longPressDelay, () => _fireLongPress(key));
      return KeyEventResult.handled;
    } else if (_longPress() && !_longPressFired) {
      // Respaldo si el temporizador se retrasó (hilo ocupado en equipos lentos).
      _cancelLongPressTimer();
      _longPressFired = true;
      _keyDownAt = null;
      return widget.onLongPress?.call(key) ?? KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _fireLongPress(LogicalKeyboardKey key) {
    _longPressTimer = null;
    if (!mounted || _keyDownAt == null) return;
    _longPressFired = true;
    _keyDownAt = null;
    widget.onLongPress?.call(key);
  }

  KeyEventResult _keyUpEvent(BuildContext context, LogicalKeyboardKey key) {
    _cancelLongPressTimer();
    if (_handledKeys.remove(key)) {
      return KeyEventResult.handled;
    }
    if (_longPressFired) {
      _longPressFired = false;
      return KeyEventResult.handled;
    }
    if (_keyDownAt != null) {
      _keyDownAt = null;
      return widget.onPressed?.call(key) ?? KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  bool _longPress() =>
      _keyDownAt != null &&
      DateTime.now().millisecondsSinceEpoch - _keyDownAt! >=
          widget.longPressDelay.inMilliseconds;
}
