import 'package:dpad/dpad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Same key configuration as FLauncherApp: dpad supplies traversal and focus
// restoration only, while arrow keys keep using Flutter's directional actions.
const DpadKeySet _dpadTraversalOnly = DpadKeySet(
  up: [],
  down: [],
  left: [],
  right: [],
  back: [],
  menu: [],
);

void main() {
  testWidgets('arrow keys move focus between siblings with dpad wrapped',
      (tester) async {
    final first = FocusNode(debugLabel: 'first');
    final second = FocusNode(debugLabel: 'second');
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    await tester.pumpWidget(MaterialApp(
      builder: Dpad.wrap(keySet: _dpadTraversalOnly),
      home: Scaffold(
        body: Row(
          children: [
            Focus(
                focusNode: first, child: const SizedBox(width: 50, height: 50)),
            Focus(
                focusNode: second,
                child: const SizedBox(width: 50, height: 50)),
          ],
        ),
      ),
    ));

    first.requestFocus();
    await tester.pump();
    expect(first.hasPrimaryFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(second.hasPrimaryFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(first.hasPrimaryFocus, isTrue);
  });
}
