import 'package:flauncher/widgets/focus_keyboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<LogicalKeyboardKey> pressed;
  late List<LogicalKeyboardKey> longPressed;
  late FocusNode cardNode;
  late FocusNode otherNode;

  setUp(() {
    pressed = [];
    longPressed = [];
    cardNode = FocusNode(debugLabel: 'card');
    otherNode = FocusNode(debugLabel: 'other');
  });

  tearDown(() {
    cardNode.dispose();
    otherNode.dispose();
  });

  Widget host({bool showCard = true}) => MaterialApp(
        home: Column(
          children: [
            if (showCard)
              FocusKeyboardListener(
                onPressed: (key) {
                  pressed.add(key);
                  return KeyEventResult.handled;
                },
                onLongPress: (key) {
                  longPressed.add(key);
                  return KeyEventResult.handled;
                },
                builder: (_) => Focus(
                  focusNode: cardNode,
                  autofocus: true,
                  child: const SizedBox(width: 10, height: 10),
                ),
              ),
            Focus(focusNode: otherNode, child: const SizedBox(width: 10, height: 10)),
          ],
        ),
      );

  bool pendingLongPress(WidgetTester tester) =>
      (tester.state(find.byType(FocusKeyboardListener)) as dynamic)
          .hasPendingLongPress as bool;

  const hold = FocusKeyboardListener.defaultLongPressDelay;

  testWidgets('long press delay for OK is 5 seconds', (tester) async {
    expect(hold, const Duration(seconds: 5));
  });

  testWidgets('short OK press launches and releases the timer', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    expect(pendingLongPress(tester), isTrue);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);

    expect(pressed, [LogicalKeyboardKey.select]);
    expect(longPressed, isEmpty);
    expect(pendingLongPress(tester), isFalse);

    // Pasado el tiempo de espera no debe dispararse nada.
    await tester.pump(hold * 2);
    expect(longPressed, isEmpty);
  });

  testWidgets('holding OK opens the menu only after 5 s, once', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    // Repeticiones del control durante la espera: no adelantan el menú.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 450));
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.select);
    }
    expect(longPressed, isEmpty);

    await tester.pump(const Duration(milliseconds: 600));
    expect(longPressed, [LogicalKeyboardKey.select]);
    expect(pendingLongPress(tester), isFalse);

    // Más repeticiones y el KeyUp tras abrir el menú no lanzan la app.
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.select);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
    expect(longPressed, hasLength(1));
    expect(pressed, isEmpty);
  });

  testWidgets('losing focus mid-hold cancels the pending long press', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    expect(pendingLongPress(tester), isTrue);

    otherNode.requestFocus();
    await tester.pump();
    expect(pendingLongPress(tester), isFalse);

    await tester.pump(hold * 2);
    expect(longPressed, isEmpty);

    // Al volver, una pulsación corta funciona con normalidad.
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
    cardNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    expect(pressed, [LogicalKeyboardKey.select]);
    expect(longPressed, isEmpty);
  });

  testWidgets('disposing the card mid-hold leaves no timer behind', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    await tester.pumpWidget(host(showCard: false));
    // flutter_test falla si queda un Timer pendiente al terminar el test.
    await tester.pump(hold * 2);
    expect(longPressed, isEmpty);
  });

  testWidgets('menu key opens the menu immediately', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.contextMenu);
    expect(longPressed, [LogicalKeyboardKey.contextMenu]);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.contextMenu);
    expect(pendingLongPress(tester), isFalse);
  });
}
