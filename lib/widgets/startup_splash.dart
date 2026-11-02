import 'package:flutter/material.dart';

/// Immediate Flutter fallback for devices that do not display the native
/// Android starting window reliably.
class StartupSplash extends StatelessWidget {
  const StartupSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: Image(
          image: AssetImage('assets/click_tv_splash.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
