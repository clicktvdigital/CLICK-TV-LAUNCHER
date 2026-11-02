import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:flauncher/widgets/settings/donate_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
    binding.platformDispatcher.clearTextScaleFactorTestValue();
  });

  testWidgets('shows the initial QR completely on a 1280x720 TV', (tester) async {
    await _pumpDonateDialog(tester, const Size(1280, 720));

    final qr = tester.getRect(find.byType(QrImageView));
    expect(qr.left, greaterThanOrEqualTo(0));
    expect(qr.top, greaterThanOrEqualTo(0));
    expect(qr.right, lessThanOrEqualTo(1280));
    expect(qr.bottom, lessThanOrEqualTo(720));
    expect(qr.width, closeTo(qr.height, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses the available space on a 1920x1080 TV', (tester) async {
    await _pumpDonateDialog(tester, const Size(1920, 1080));

    final qr = tester.getRect(find.byType(QrImageView));
    expect(qr.width, greaterThan(180));
    expect(qr.width, closeTo(qr.height, 1));
    expect(qr.bottom, lessThanOrEqualTo(1080));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the narrow layout usable with larger text', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(640, 720);
    binding.window.devicePixelRatioTestValue = 1;
    binding.platformDispatcher.textScaleFactorTestValue = 1.35;
    await _pumpDonateDialog(tester, null);

    expect(find.text('Cerrar'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNWidgets(16));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows Ecuadorian voluntary support tiers without changing methods',
      (tester) async {
    await _pumpDonateDialog(tester, const Size(1280, 720));

    expect(find.textContaining('INVÍTAME UN CAFECITO'), findsOneWidget);
    expect(find.textContaining('INVÍTAME UN TAMALITO LOJANO CON CAFÉ'), findsOneWidget);
    expect(find.textContaining('INVÍTAME UN ENCEBOLLADO'), findsOneWidget);
    expect(find.textContaining('AMIGO DE CLICK TV'), findsOneWidget);
    expect(find.textContaining('PROTECTOR DE CLICK TV'), findsOneWidget);
    expect(find.textContaining('ALIADO DE CLICK TV'), findsOneWidget);
    expect(find.text('Banco Pichincha'), findsOneWidget);
    expect(find.text('PayPal'), findsOneWidget);

    await tester.tap(find.textContaining('INVÍTAME UN CAFECITO'));
    await tester.pump();
    expect(find.textContaining('Sugerencia seleccionada'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changes method without closing the dialog', (tester) async {
    await _pumpDonateDialog(tester, const Size(1280, 720));

    await tester.scrollUntilVisible(
      find.text('PayPal'),
      200,
      scrollable: find.byType(ListView),
    );
    await tester.tap(find.text('PayPal').first);
    await tester.pumpAndSettle();

    expect(find.byType(DonateDialog), findsOneWidget);
    expect(find.text('PayPal'), findsAtLeastNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps pending methods without creating a QR', (tester) async {
    await _pumpDonateDialog(tester, const Size(1280, 720));

    await tester.scrollUntilVisible(
      find.text('Binance'),
      200,
      scrollable: find.byType(ListView),
    );
    await tester.tap(find.text('Binance').first);
    await tester.pumpAndSettle();

    expect(find.text('Enlace de donación pendiente de confirmar. '
        'No hay QR de pago disponible para este método.'), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);
    expect(find.text('Ver QR ampliado'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(1280, 720), Size(1920, 1080)]) {
    testWidgets('opens a square expanded QR within the viewport at ${size.width}x${size.height}',
        (tester) async {
      await _pumpDonateDialog(tester, size);

      await tester.ensureVisible(find.text('Ver QR ampliado'));
      await tester.tap(find.text('Ver QR ampliado'));
      await tester.pumpAndSettle();

      expect(find.text('QR ampliado · Banco Pichincha'), findsOneWidget);
      final expandedQrFinder = find.byType(QrImageView).last;
      final expandedQr = tester.getRect(expandedQrFinder);
      // qr_flutter 4.1.0 does not expose QrImageView.data. The production
      // dialog passes the same payload to both views; assert that the
      // original and expanded QR widgets coexist instead of reaching through
      // a package-private implementation detail.
      expect(find.byType(QrImageView), findsNWidgets(2));
      expect(expandedQr.width, closeTo(expandedQr.height, 1));
      expect(expandedQr.left, greaterThanOrEqualTo(0));
      expect(expandedQr.top, greaterThanOrEqualTo(0));
      expect(expandedQr.right, lessThanOrEqualTo(size.width));
      expect(expandedQr.bottom, lessThanOrEqualTo(size.height));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Back closes the expanded QR before the donate dialog', (tester) async {
    await _pumpDonateDialog(tester, const Size(1280, 720));
    await tester.ensureVisible(find.text('Ver QR ampliado'));
    await tester.tap(find.text('Ver QR ampliado'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('QR ampliado · Banco Pichincha'), findsNothing);
    expect(find.byType(DonateDialog), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(DonateDialog), findsNothing);
  });

  testWidgets('opens the expanded QR from the narrow layout with larger text', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(640, 720);
    binding.window.devicePixelRatioTestValue = 1;
    binding.platformDispatcher.textScaleFactorTestValue = 1.35;
    await _pumpDonateDialog(tester, null);

    await tester.ensureVisible(find.text('Ver QR ampliado'));
    await tester.tap(find.text('Ver QR ampliado'));
    await tester.pumpAndSettle();

    expect(find.text('QR ampliado · Banco Pichincha'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports remote focus and closes one dialog route', (tester) async {
    await _pumpDonateDialog(tester, const Size(1280, 720));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
    expect(find.byType(DonateDialog), findsNothing);
  });

  testWidgets('Back closes only the donate dialog route', (tester) async {
    await _pumpDonateDialog(tester, const Size(1280, 720));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(DonateDialog), findsNothing);
  });
}

Future<void> _pumpDonateDialog(WidgetTester tester, Size? size) async {
  if (size != null) {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = size;
    binding.window.devicePixelRatioTestValue = 1;
    binding.platformDispatcher.textScaleFactorTestValue = 1;
  }

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const DonateDialog(),
              ),
              child: const Text('Abrir donativos'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir donativos'));
  await tester.pumpAndSettle();
}
