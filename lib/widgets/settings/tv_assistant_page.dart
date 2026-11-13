import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/launcher_state.dart';
import 'package:flauncher/widgets/settings/accessibility_page.dart';
import 'package:flauncher/widgets/settings/backup_restore_page.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/tv_cleanup_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Asistente en pasos para configurar CLICK TV sin Shizuku ni adb: muestra el estado que la app
/// puede leer y lleva a la pantalla del sistema donde se cambia cada opción.
class TvAssistantPage extends StatefulWidget {
  static const String routeName = "tv_assistant";

  const TvAssistantPage({super.key});

  @override
  State<TvAssistantPage> createState() => _TvAssistantPageState();
}

class _TvAssistantPageState extends State<TvAssistantPage> with WidgetsBindingObserver {
  bool _accessibilityOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    await context.read<LauncherState>().refresh(context.read<AppsService>());
    try {
      final bool on = await FLauncherChannel().checkAccessibilityPermission();
      if (mounted) setState(() => _accessibilityOn = on);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bool isDefault = context.watch<LauncherState>().isDefaultLauncher;

    return SafeArea(
      minimum: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        children: [
          Text(
            'Asistente de CLICK TV',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          _Step(
            autofocus: true,
            title: '1. Inicio del TV',
            status: isDefault ? 'CLICK TV es el inicio' : 'Todavía no es el inicio',
            ok: isDefault,
            hint: 'Elige CLICK TV como aplicación de inicio. Puedes volver al inicio de fábrica cuando quieras desde la misma pantalla.',
            action: 'Elegir inicio',
            onPressed: () => FLauncherChannel().openDefaultLauncherSettings(),
          ),
          _Step(
            title: '2. Botón Inicio del control',
            status: _accessibilityOn ? 'Corrección activada' : 'Corrección desactivada',
            ok: _accessibilityOn,
            hint: 'Si quieres que el botón Inicio del control abra CLICK TV, actívala. Si prefieres el inicio de Google TV, déjala desactivada. Tú decides.',
            action: 'Ver opciones',
            onPressed: () => Navigator.of(context).pushNamed(AccessibilityPage.routeName),
          ),
          _Step(
            title: '3. Apps de fábrica',
            status: 'Opcional',
            ok: null,
            hint: 'Mira qué apps de fábrica sólo aportan telemetría o promoción, y copia los comandos para desactivarlas. Nunca se desinstala nada.',
            action: 'Ver lista',
            onPressed: () => Navigator.of(context).pushNamed(TvCleanupPage.routeName),
          ),
          _Step(
            title: '4. Copia de seguridad',
            status: 'Recomendado antes de cambiar algo',
            ok: null,
            hint: 'Guarda la configuración de CLICK TV antes de hacer cambios grandes.',
            action: 'Abrir',
            onPressed: () => Navigator.of(context).pushNamed(BackupRestorePage.routeName),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final bool autofocus;
  final String title;
  final String status;
  final bool? ok;
  final String hint;
  final String action;
  final VoidCallback onPressed;

  const _Step({
    this.autofocus = false,
    required this.title,
    required this.status,
    required this.ok,
    required this.hint,
    required this.action,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = ok == null ? Colors.white70 : (ok! ? Colors.green : Colors.orange);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FocusableSettingsTile(
          autofocus: autofocus,
          leading: Icon(
            ok == null ? Icons.info_outline : (ok! ? Icons.check_circle : Icons.radio_button_unchecked),
            size: 28,
            color: color,
          ),
          title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
          trailing: Text(status, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
          onPressed: onPressed,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Text(
            hint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70, height: 1.35),
          ),
        ),
      ],
    );
  }
}
