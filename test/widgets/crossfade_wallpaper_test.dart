import 'dart:io';
import 'dart:typed_data';

import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/crossfade_wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transparent_image/transparent_image.dart';

void main() {
  test('Ecuador wallpaper rotates every 10 seconds', () {
    expect(ecuadorRotationInterval, const Duration(seconds: 10));
    final start = DateTime(2026, 11, 18, 15, 0, 0);
    final a = ecuadorAssetFor(start);
    expect(ecuadorAssetFor(start.add(const Duration(seconds: 9))), a);
    final b = ecuadorAssetFor(start.add(const Duration(seconds: 10)));
    expect(b, isNot(a));
    expect(ecuadorAllWallpapers, contains(b));
  });

  test('rotation goes through every Ecuador photo, one per 10 s', () {
    final start = DateTime(2026, 11, 18, 15, 0, 0);
    final seen = <String>{
      for (var i = 0; i < ecuadorAllWallpapers.length; i++)
        ecuadorAssetFor(start.add(ecuadorRotationInterval * i)),
    };
    expect(seen.length, ecuadorAllWallpapers.length);
    expect(ecuadorAllWallpapers.length, 9);
  });

  test('every image in assets/fondos/ecuador is in the rotation', () {
    final files = Directory('assets/fondos/ecuador')
        .listSync()
        .whereType<File>()
        .map((f) => f.path.split(Platform.pathSeparator).last)
        .where((name) => name.toLowerCase().endsWith('.jpg') || name.toLowerCase().endsWith('.png'))
        .map((name) => 'assets/fondos/ecuador/$name')
        .toSet();
    expect(files, isNotEmpty);
    expect(ecuadorAllWallpapers.toSet(), files);
  });

  testWidgets('crossfades to the new image after it is decoded, keeping the old one meanwhile', (tester) async {
    final first = MemoryImage(Uint8List.fromList(kTransparentImage));
    final second = MemoryImage(Uint8List.fromList([...kTransparentImage]));

    Widget host(ImageProvider image) => MaterialApp(
          home: CrossfadeWallpaper(image: image, version: 0, width: 800, height: 450),
        );

    await tester.pumpWidget(host(first));
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);

    await tester.pumpWidget(host(second));
    // Mientras se decodifica la nueva sigue visible solo la anterior.
    expect(find.byType(Image), findsOneWidget);
    expect(tester.widget<Image>(find.byType(Image)).image, first);
    // La decodificación de imágenes necesita tiempo real.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
    // Durante el fundido conviven la anterior y la nueva.
    await tester.pump(CrossfadeWallpaper.fadeDuration ~/ 2);
    expect(find.byType(Image), findsNWidgets(2));

    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    final shown = tester.widget<Image>(find.byType(Image));
    expect(shown.image, second);
  });
}
