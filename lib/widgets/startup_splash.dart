import 'package:flutter/material.dart';

/// Splash de Flutter. Es el mismo archivo y el mismo encuadre que el splash
/// nativo (res/drawable-nodpi/click_tv_splash.png en launch_background.xml),
/// así el paso del nativo a Flutter no produce un salto visual.
class StartupSplash extends StatelessWidget {
  const StartupSplash({super.key});

  /// Proveedor compartido: main() lo decodifica antes del primer frame y aquí
  /// se reutiliza desde la caché, sin un frame negro intermedio.
  static const AssetImage image = AssetImage('assets/click_tv_splash.png');

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: Image(
          image: StartupSplash.image,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
