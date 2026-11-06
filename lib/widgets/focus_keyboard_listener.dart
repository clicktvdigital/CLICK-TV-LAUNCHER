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
  final WidgetBuilder builder;
  final KeyEventResult Function(LogicalKeyboardKey)? onPressed;
  final KeyEventResult Function(LogicalKeyboardKey)? onLongPress;

  FocusKeyboardListener({
    Key? key,
    required this.builder,
    this.onPressed,
    this.onLongPress,
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
  // Tiempo que hay que mantener OK pulsado para abrir el menú lateral.
  // Antes eran 500 ms; en TV box lentos (o con build debug) una pulsación
  // normal podía superar ese tiempo y abría el menú en vez de lanzar la app.
  static const Duration _longPressDelay = Duration(milliseconds: 800);

  // Un KeyDown repetido de una tecla de validación antes de este tiempo se
  // considera duplicado del control. Después se trata como pulsación nueva,
  // para que una tecla cuyo KeyUp se perdió no quede bloqueada.
  static const Duration _staleKeyDelay = Duration(milliseconds: 2000);

  Timer? _longPressTimer;
  bool _longPressFired = false;
  int? _keyDownAt;
  final Set<LogicalKeyboardKey> _handledKeys = {};

  // Teclas físicas pulsadas. Algunos controles de TV box envían la misma tecla
  // física con códigos lógicos distintos al presionar y al soltar (por ejemplo
  // Select y Control Right), así que el KeyUp se empareja por tecla física y
  // usa la tecla lógica registrada en el KeyDown.
  final Map<PhysicalKeyboardKey, _PressedKey> _pressedKeys = {};

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Focus(
        canRequestFocus: false,
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
          AppCardKeys.longPressableKeys.contains(tracked.logicalKey) &&
          now.difference(tracked.pressedAt) < _staleKeyDelay) {
        // KeyDown duplicado sin KeyUp: no reinicia la pulsación.
        return KeyEventResult.handled;
      }
      _pressedKeys[physicalKey] = _PressedKey(keyEvent.logicalKey, now);
      return _keyDownEvent(context, keyEvent.logicalKey);
    }

    if (keyEvent is KeyRepeatEvent) {
      final key = _pressedKeys[keyEvent.physicalKey]?.logicalKey ??
          keyEvent.logicalKey;

      // Once long press fires, ignore repeats until the key is released.
      // Otherwise a repeat may start a new short press accidentally.
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
      _longPressTimer?.cancel();
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
      _longPressTimer?.cancel();
      _longPressTimer = Timer(_longPressDelay, () {
        if (!mounted) return;
        if (_keyDownAt != null) {
          _longPressFired = true;
          _keyDownAt = null;
          widget.onLongPress?.call(key);
        }
      });
      return KeyEventResult.handled;
    } else if (_longPress() && !_longPressFired) {
      _longPressTimer?.cancel();
      _longPressFired = true;
      _keyDownAt = null;
      return widget.onLongPress?.call(key) ?? KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  KeyEventResult _keyUpEvent(BuildContext context, LogicalKeyboardKey key) {
    _longPressTimer?.cancel();
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
          _longPressDelay.inMilliseconds;
}
