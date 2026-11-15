import 'package:flauncher/custom_traversal_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bajar a una fila fuera de pantalla desplaza la vista vertical', (tester) async {
    final scrollController = ScrollController();
    final rowFocusNodes = List.generate(6, (_) => FocusNode());

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FocusTraversalGroup(
          policy: RowByRowTraversalPolicy(),
          child: SizedBox(
            height: 400,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  for (var i = 0; i < rowFocusNodes.length; i++)
                    SizedBox(
                      height: 200,
                      child: Row(
                        children: [
                          Focus(
                            focusNode: rowFocusNodes[i],
                            autofocus: i == 0,
                            child: const SizedBox(width: 100, height: 100),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(rowFocusNodes[0].hasPrimaryFocus, isTrue);

    for (var i = 0; i < 5; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
    }

    expect(rowFocusNodes[5].hasPrimaryFocus, isTrue);
    // La fila enfocada debe quedar dentro del viewport (400 px de alto).
    expect(scrollController.offset, greaterThan(0));
    final rowRect = tester.getRect(find.byWidgetPredicate(
      (w) => w is Focus && w.focusNode == rowFocusNodes[5],
    ));
    final viewportRect = tester.getRect(find.byType(SingleChildScrollView));
    expect(rowRect.top >= viewportRect.top - 1 && rowRect.bottom <= viewportRect.bottom + 1, isTrue,
        reason: 'La fila enfocada debe estar visible en el viewport');

    for (final node in rowFocusNodes) {
      node.dispose();
    }
    scrollController.dispose();
  });
}
