import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Fondo con fundido suave entre imágenes.
///
/// La imagen nueva se decodifica antes de empezar el fundido (precacheImage):
/// mientras tanto sigue visible la anterior, así nunca aparece un frame vacío.
/// El fundido es solo de opacidad (barato en GPU de TV box).
class CrossfadeWallpaper extends StatefulWidget {
  const CrossfadeWallpaper({
    super.key,
    required this.image,
    required this.version,
    required this.width,
    required this.height,
  });

  static const Duration fadeDuration = Duration(milliseconds: 600);

  final ImageProvider image;

  /// Cambia cuando el usuario elige otro archivo con la misma ruta.
  final int version;
  final double width;
  final double height;

  @override
  State<CrossfadeWallpaper> createState() => _CrossfadeWallpaperState();
}

class _CrossfadeWallpaperState extends State<CrossfadeWallpaper> {
  late ImageProvider _shown = widget.image;
  late int _shownVersion = widget.version;
  int _request = 0;

  @override
  void didUpdateWidget(CrossfadeWallpaper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != _shown || widget.version != _shownVersion) {
      _preloadThenShow(widget.image, widget.version);
    }
  }

  Future<void> _preloadThenShow(ImageProvider image, int version) async {
    final request = ++_request;
    await precacheImage(image, context);
    // Solo se muestra la última imagen pedida.
    if (!mounted || request != _request) return;
    setState(() {
      _shown = image;
      _shownVersion = version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: CrossfadeWallpaper.fadeDuration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(
        fit: StackFit.expand,
        children: [...previous, if (current != null) current],
      ),
      child: Image(
        key: ValueKey(Object.hash(_shown, _shownVersion)),
        image: _shown,
        fit: BoxFit.cover,
        filterQuality: ui.FilterQuality.high,
        gaplessPlayback: true,
        width: widget.width,
        height: widget.height,
      ),
    );
  }
}
