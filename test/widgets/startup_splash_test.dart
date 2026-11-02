import 'package:flauncher/widgets/startup_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in const [
    Size(1280, 720),
    Size(1920, 1080),
    Size(720, 1280),
  ]) {
    testWidgets('keeps the CLICK TV startup image contained at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: StartupSplash(),
        ),
      );
      await tester.pump();

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      expect(image.fit, BoxFit.contain);
      expect(tester.takeException(), isNull);
    });
  }
}
