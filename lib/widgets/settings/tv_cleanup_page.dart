import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Apps de fábrica de Google TV / Android TV que sólo aportan telemetría, feedback o promoción.
/// Misma lista que tools/debloat/lists/generic.txt. Se DESACTIVAN, nunca se desinstalan.
const List<String> kGenericDebloatPackages = [
  'com.google.android.feedback',
  'com.google.android.tv.bugreportsender',
  'com.android.tv.feedbackconsent',
  'com.google.android.tvrecommendations',
  'com.google.android.katniss',
  'com.google.android.partnersetup',
  'com.google.android.videos',
  'fusion.android.tv.demo',
];

class TvCleanupPage extends StatelessWidget {
  static const String routeName = "tv_cleanup";

  const TvCleanupPage({super.key});

  String get _disableCommands => kGenericDebloatPackages
      .map((p) => 'adb shell pm disable-user --user 0 $p')
      .join('\n');

  String get _restoreCommands =>
      kGenericDebloatPackages.map((p) => 'adb shell pm enable $p').join('\n');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        children: [
          Text(
            'Apps de fábrica',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Estas apps solo aportan telemetría, promoción o pruebas. Se desactivan, no se desinstalan, '
              'y se pueden volver a activar en cualquier momento. La app no puede hacerlo sola: '
              'copia los comandos y ejecútalos desde una computadora o desde Termux con adb.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70, height: 1.35),
            ),
          ),
          for (final package in kGenericDebloatPackages)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: Text(package, style: Theme.of(context).textTheme.bodySmall),
            ),
          const SizedBox(height: 12),
          FocusableSettingsTile(
            autofocus: true,
            leading: const Icon(Icons.copy, size: 28),
            title: Text('Copiar comandos para desactivar', style: Theme.of(context).textTheme.bodyMedium),
            onPressed: () => Clipboard.setData(ClipboardData(text: _disableCommands)),
          ),
          FocusableSettingsTile(
            leading: const Icon(Icons.restore, size: 28),
            title: Text('Copiar comandos para restaurar', style: Theme.of(context).textTheme.bodyMedium),
            onPressed: () => Clipboard.setData(ClipboardData(text: _restoreCommands)),
          ),
        ],
      ),
    );
  }
}
