import 'package:flauncher/widgets/settings/donate_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

Finder _key(String value) => find.byKey(ValueKey(value));
Finder _method(int index) => _key('donativo-metodo-$index');

bool _focused(WidgetTester tester, Finder finder) =>
    tester.widget<ButtonStyleButton>(finder).focusNode!.hasFocus;

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void _inside(Rect child, Rect viewport) {
  expect(child.left, greaterThanOrEqualTo(viewport.left - .1));
  expect(child.top, greaterThanOrEqualTo(viewport.top - .1));
  expect(child.right, lessThanOrEqualTo(viewport.right + .1));
  expect(child.bottom, lessThanOrEqualTo(viewport.bottom + .1));
}

void _checkQr(WidgetTester tester, Size logical) {
  final qr = tester.getRect(find.byType(QrImageView));
  expect(qr.width, closeTo(qr.height, .01));
  expect(qr.width, greaterThanOrEqualTo(180));
  _inside(qr, Offset.zero & logical);
  // Screen bounds alone miss clipping by a smaller inner viewport.
  _inside(qr, tester.getRect(_key('donativo-detalle')));
  _inside(tester.getRect(_key('donativo-cerrar')), Offset.zero & logical);
  expect(tester.takeException(), isNull);
}

Future<void> _open(WidgetTester tester, Size logical, {
  double density = 1,
  double textScale = 1,
  bool overscan = false,
}) async {
  tester.view.physicalSize = logical * density;
  tester.view.devicePixelRatio = density;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  await tester.pumpWidget(MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: overscan ? const EdgeInsets.fromLTRB(24, 16, 24, 16) : EdgeInsets.zero,
      ),
      child: child!,
    ),
    home: Builder(builder: (context) => Scaffold(
      body: Center(child: ElevatedButton(
        onPressed: () => showDialog<void>(context: context,
          builder: (_) => const DonateDialog()),
        child: const Text('Abrir donativos'),
      )),
    )),
  ));
  await tester.tap(find.text('Abrir donativos'));
  await tester.pumpAndSettle();
}

void main() {
  for (final size in const [Size(960, 540), Size(1280, 720), Size(1920, 1080)]) {
    testWidgets('QR and pinned close fit the actual viewport at $size', (tester) async {
      await _open(tester, size, density: size.width == 960 ? 2 : 1);
      _checkQr(tester, size);
      expect(_focused(tester, _method(0)), isTrue);

      // Scrolling all detail actions must not move or crop the pinned QR/footer.
      await _press(tester, LogicalKeyboardKey.arrowRight);
      final qrBefore = tester.getRect(find.byType(QrImageView));
      for (var i = 0; i < 7; i++) {
        await _press(tester, LogicalKeyboardKey.arrowDown);
      }
      expect(_focused(tester, _key('donativo-aporte-5')), isTrue);
      final detailViewport = tester.getRect(_key('donativo-scroll-detalle'));
      _inside(tester.getRect(_key('donativo-aporte-5')), detailViewport);
      expect(tester.getRect(find.byType(QrImageView)), qrBefore);
      _checkQr(tester, size);
    });

    testWidgets('expanded QR and return button fit without scrolling at $size', (tester) async {
      await _open(tester, size, density: size.width == 960 ? 2 : 1);
      await _press(tester, LogicalKeyboardKey.select); // method -> QR
      expect(_focused(tester, _key('donativo-qr')), isTrue);
      await _press(tester, LogicalKeyboardKey.select); // QR -> enlarged view
      expect(find.text('QR ampliado · Banco Pichincha'), findsOneWidget);
      final expanded = tester.getRect(find.byType(QrImageView).last);
      expect(expanded.width, closeTo(expanded.height, .01));
      expect(expanded.width, greaterThanOrEqualTo(180));
      _inside(expanded, Offset.zero & size);
      _inside(tester.getRect(_key('donativo-qr-volver')), Offset.zero & size);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('OK closes expanded QR and restores its original focus', (tester) async {
    await _open(tester, const Size(960, 540));
    await _press(tester, LogicalKeyboardKey.select);
    await _press(tester, LogicalKeyboardKey.select);
    expect(find.text('QR ampliado · Banco Pichincha'), findsOneWidget);
    await _press(tester, LogicalKeyboardKey.select);
    expect(find.text('QR ampliado · Banco Pichincha'), findsNothing);
    expect(_focused(tester, _key('donativo-qr')), isTrue);
    expect(find.byType(DonateDialog), findsOneWidget);
  });

  testWidgets('960x540 with overscan and enlarged text keeps QR and close visible', (tester) async {
    const size = Size(960, 540);
    await _open(tester, size, density: 2, textScale: 1.35, overscan: true);
    _checkQr(tester, size);
    _inside(tester.getRect(_key('donativo-cerrar')), const Rect.fromLTRB(24, 16, 936, 524));
    await _press(tester, LogicalKeyboardKey.select);
    await _press(tester, LogicalKeyboardKey.select);
    final enlarged = tester.getRect(find.byType(QrImageView).last);
    expect(enlarged.width, closeTo(enlarged.height, .01));
    _inside(enlarged, const Rect.fromLTRB(24, 16, 936, 524));
    expect(tester.takeException(), isNull);
  });

  testWidgets('all ten methods can be visited and revisited using only the D-pad', (tester) async {
    await _open(tester, const Size(960, 540), density: 2);
    const names = ['Banco Pichincha', 'Banco Guayaquil', 'Produbanco',
      'Banco del Pacífico', 'Deuna!', 'PayPhone', 'PayPal', 'Binance',
      'GitHub Sponsors', 'Patreon'];
    const numbers = ['2205375908', '0013647475', '12009308674', '1062494589', '7701517809'];
    const links = ['https://ppls.me/izAAuu8fptGHF6uZBV9L4Q',
      'https://www.paypal.com/ncp/payment/NKS3NQA6Q2Q5N'];
    for (var round = 0; round < 2; round++) {
      for (var i = 0; i < names.length; i++) {
        expect(_focused(tester, _method(i)), isTrue);
        _inside(tester.getRect(_method(i)), tester.getRect(_key('donativo-scroll-metodos')));
        await _press(tester, LogicalKeyboardKey.select);
        expect(tester.widget<Text>(_key('donativo-titulo-metodo')).data, names[i]);
        if (i < 5) expect(find.text(numbers[i]), findsOneWidget);
        if (i == 5 || i == 6) expect(find.text(links[i - 5]), findsOneWidget);
        if (i < 7) {
          expect(_focused(tester, _key('donativo-qr')), isTrue);
          _checkQr(tester, const Size(960, 540));
          await _press(tester, LogicalKeyboardKey.arrowDown);
          expect(_focused(tester, _key('donativo-ampliar')), isTrue);
          await _press(tester, LogicalKeyboardKey.arrowUp);
          expect(_focused(tester, _key('donativo-qr')), isTrue);
        } else {
          expect(find.byType(QrImageView), findsNothing);
          expect(_focused(tester, _key('donativo-aporte-0')), isTrue);
        }
        await _press(tester, LogicalKeyboardKey.arrowLeft);
        expect(_focused(tester, _method(i)), isTrue);
        if (i < names.length - 1) await _press(tester, LogicalKeyboardKey.arrowDown);
      }
      for (var i = 0; i < 9; i++) await _press(tester, LogicalKeyboardKey.arrowUp);
      expect(_focused(tester, _method(0)), isTrue);
    }
    expect(find.byType(DonateDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('right and left return between methods and detail after scrolling', (tester) async {
    await _open(tester, const Size(960, 540));
    for (var i = 0; i < 6; i++) await _press(tester, LogicalKeyboardKey.arrowDown);
    await _press(tester, LogicalKeyboardKey.arrowRight);
    expect(_focused(tester, _key('donativo-qr')), isTrue);
    for (var i = 0; i < 8; i++) await _press(tester, LogicalKeyboardKey.arrowDown);
    expect(_focused(tester, _key('donativo-aporte-5')), isTrue);
    await _press(tester, LogicalKeyboardKey.arrowLeft);
    expect(_focused(tester, _method(6)), isTrue);
    for (var i = 0; i < 6; i++) await _press(tester, LogicalKeyboardKey.arrowUp);
    await _press(tester, LogicalKeyboardKey.enter);
    expect(tester.widget<Text>(_key('donativo-titulo-metodo')).data, 'Banco Pichincha');
    expect(_focused(tester, _key('donativo-qr')), isTrue);
    _checkQr(tester, const Size(960, 540));
  });

  testWidgets('Back restores QR opener, then bank selection, then closes only the dialog', (tester) async {
    await _open(tester, const Size(960, 540));
    await _press(tester, LogicalKeyboardKey.select);
    await _press(tester, LogicalKeyboardKey.arrowDown);
    await _press(tester, LogicalKeyboardKey.select); // zoom control
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('QR ampliado · Banco Pichincha'), findsNothing);
    expect(_focused(tester, _key('donativo-ampliar')), isTrue);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_focused(tester, _method(0)), isTrue);
    expect(find.byType(DonateDialog), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(DonateDialog), findsNothing);
    expect(find.text('Abrir donativos'), findsOneWidget);
  });

  testWidgets('hardware escape and OK return without trapping focus', (tester) async {
    await _open(tester, const Size(960, 540));
    await _press(tester, LogicalKeyboardKey.arrowRight);
    await _press(tester, LogicalKeyboardKey.escape);
    expect(_focused(tester, _method(0)), isTrue);
    await _press(tester, LogicalKeyboardKey.arrowRight);
    for (var i = 0; i < 8; i++) await _press(tester, LogicalKeyboardKey.arrowDown);
    expect(_focused(tester, _key('donativo-volver')), isTrue);
    await _press(tester, LogicalKeyboardKey.select);
    expect(_focused(tester, _method(0)), isTrue);
    await _press(tester, LogicalKeyboardKey.escape);
    expect(find.byType(DonateDialog), findsNothing);
  });

  testWidgets('returning focus to methods also resets Back handling', (tester) async {
    await _open(tester, const Size(960, 540));
    await _press(tester, LogicalKeyboardKey.arrowRight);
    tester.widget<ButtonStyleButton>(_method(0)).focusNode!.requestFocus();
    await tester.pumpAndSettle();
    expect(_focused(tester, _method(0)), isTrue);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(DonateDialog), findsNothing);
    expect(find.text('Abrir donativos'), findsOneWidget);
  });

  testWidgets('close remains outside scrolling and is reachable by remote', (tester) async {
    await _open(tester, const Size(960, 540));
    for (var i = 0; i < 10; i++) await _press(tester, LogicalKeyboardKey.arrowDown);
    expect(_focused(tester, _key('donativo-cerrar')), isTrue);
    await _press(tester, LogicalKeyboardKey.select);
    expect(find.byType(DonateDialog), findsNothing);
  });

  testWidgets('support choices survive method changes without modifying bank data', (tester) async {
    await _open(tester, const Size(960, 540));
    await _press(tester, LogicalKeyboardKey.arrowRight);
    await _press(tester, LogicalKeyboardKey.arrowDown); // zoom
    await _press(tester, LogicalKeyboardKey.arrowDown); // coffee
    await _press(tester, LogicalKeyboardKey.select);
    expect(find.textContaining('Sugerencia seleccionada:'), findsOneWidget);
    await _press(tester, LogicalKeyboardKey.arrowLeft);
    await _press(tester, LogicalKeyboardKey.arrowDown);
    await _press(tester, LogicalKeyboardKey.select);
    expect(find.text('0013647475'), findsOneWidget);
    expect(find.text('Titular: Richard Ontaneda'), findsOneWidget);
    expect(find.text('Contacto: clicktvdigital@gmail.com'), findsOneWidget);
    expect(find.textContaining('Sugerencia seleccionada:'), findsOneWidget);
  });

  testWidgets('compact layout scrolls to QR and keeps close pinned with large text', (tester) async {
    const size = Size(640, 720);
    await _open(tester, size, textScale: 1.35);
    expect(find.byType(OutlinedButton), findsNWidgets(17)); // 10 methods + QR + 6 tiers
    await _press(tester, LogicalKeyboardKey.select);
    _checkQr(tester, size);
    await _press(tester, LogicalKeyboardKey.arrowLeft);
    expect(_focused(tester, _method(0)), isTrue);
    await _press(tester, LogicalKeyboardKey.arrowRight);
    await _press(tester, LogicalKeyboardKey.select);
    expect(find.text('QR ampliado · Banco Pichincha'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
