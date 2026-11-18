import 'dart:async';

import 'package:flauncher/providers/daily_traffic_counter.dart';
import 'package:flauncher/providers/network_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'daily_data_usage_widget.dart';

/// Indicador de la barra de estado: tipo de conexión (Wi-Fi / cable),
/// velocidad de bajada y subida en tiempo real y consumo del periodo.
///
/// Velocidad en 2 líneas de 14 px y el consumo a la derecha, centrado en
/// vertical (30 px de texto dentro de la barra de 72 dp). El botón de permiso,
/// si aparece, queda en la misma fila que el resto de la barra: así la flecha
/// abajo desde Ajustes vuelve a las apps y no se desvía hacia él. Si falta ancho
/// (por ejemplo con el clima visible), el bloque se reduce proporcionalmente
/// en vez de recortarse o empujar a los widgets de la derecha.
class NetworkTrafficIndicator extends StatelessWidget {
  const NetworkTrafficIndicator({super.key});

  static const TextStyle lineStyle = TextStyle(
    fontSize: 15,
    height: 1.0,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    // Cifras de ancho fijo: el bloque no "baila" al cambiar los valores.
    fontFeatures: [FontFeature.tabularFigures()],
    shadows: [Shadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 3)],
  );

  @override
  Widget build(BuildContext context) {
    final networkType = context.select<NetworkService, NetworkType>((s) => s.networkType);
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final (IconData icon, String label) = switch (networkType) {
      NetworkType.Wired => (Icons.settings_ethernet, isEs ? 'Cable de red' : 'Ethernet'),
      NetworkType.Wifi => (Icons.wifi, 'Wi-Fi'),
      NetworkType.Cellular => (Icons.signal_cellular_alt, isEs ? 'Datos móviles' : 'Mobile data'),
      NetworkType.Vpn => (Icons.vpn_key, 'VPN'),
      NetworkType.Unknown => (Icons.link_off, isEs ? 'Sin conexión' : 'Offline'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.0,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Semantics(
                label: label,
                child: Icon(icon, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const LiveTrafficRates(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Velocidad de bajada y subida (una por línea) y consumo del día, todo con
/// la misma lectura de los contadores de tráfico cada 2 s, solo mientras el
/// launcher está en primer plano; con otra app abierta no hace trabajo (el
/// tráfico de ese tiempo se suma al volver, ver DailyTrafficCounter).
class LiveTrafficRates extends StatefulWidget {
  const LiveTrafficRates({super.key});

  static const Duration interval = Duration(seconds: 2);

  /// Reloj usado para calcular la velocidad (reemplazable en pruebas).
  @visibleForTesting
  static DateTime Function() clock = DateTime.now;

  @override
  State<LiveTrafficRates> createState() => _LiveTrafficRatesState();
}

class _LiveTrafficRatesState extends State<LiveTrafficRates> with WidgetsBindingObserver {
  Timer? _timer;
  List<int>? _last;
  DateTime? _lastAt;
  int? _downBytesPerSecond;
  int? _upBytesPerSecond;
  bool _unsupported = false;
  DailyTrafficCounter? _counter;
  int? _todayBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      _counter = DailyTrafficCounter(prefs, clock: LiveTrafficRates.clock);
      _seedFromSystem();
      setState(() => _todayBytes = _counter!.todayBytes);
    }).catchError((Object _) {
      // Sin almacenamiento: se muestra solo la velocidad.
    });
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stop();
    _counter?.save();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _seedFromSystem();
      _start();
    } else {
      _stop();
      _counter?.save();
    }
  }

  // Con permiso de uso (Android 6+), el consumo exacto del sistema.
  Future<void> _seedFromSystem() async {
    final network = context.read<NetworkService>();
    if (!network.hasUsageStatsPermission) return;
    final systemToday = await network.getDataUsageForPeriod('daily');
    if (!mounted || systemToday <= 0) return;
    _counter?.seedFromSystem(systemToday);
    final today = _counter?.todayBytes;
    if (today != null && today != _todayBytes) setState(() => _todayBytes = today);
  }

  void _start() {
    if (_timer != null || _unsupported) return;
    // Tras una pausa la primera lectura solo fija la referencia.
    _last = null;
    _lastAt = null;
    _sample();
    _timer = Timer.periodic(LiveTrafficRates.interval, (_) => _sample());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _sample() async {
    final totals = await context.read<NetworkService>().getTrafficTotals();
    if (!mounted) return;
    if (totals == null) {
      _stop();
      setState(() => _unsupported = true);
      return;
    }
    final now = LiveTrafficRates.clock();
    final counter = _counter;
    if (counter != null) {
      counter.addSample(totals[0] + totals[1]);
      final today = counter.todayBytes;
      if (today != _todayBytes) setState(() => _todayBytes = today);
    }
    final last = _last;
    final lastAt = _lastAt;
    _last = totals;
    _lastAt = now;
    if (last == null || lastAt == null) return;
    final ms = now.difference(lastAt).inMilliseconds;
    if (ms <= 0) return;
    // Los contadores se reinician si cae la interfaz: nunca valores negativos.
    final down = ((totals[0] - last[0]).clamp(0, 1 << 40) * 1000 / ms).round();
    final up = ((totals[1] - last[1]).clamp(0, 1 << 40) * 1000 / ms).round();
    if (down != _downBytesPerSecond || up != _upBytesPerSecond) {
      setState(() {
        _downBytesPerSecond = down;
        _upBytesPerSecond = up;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final period = context.select<SettingsService, String>((s) => s.dataUsagePeriod);
    final network = context.watch<NetworkService>();
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final showPermission = network.usageStatsSupported && !network.hasUsageStatsPermission;

    // Semana/mes: solo el sistema lo sabe (permiso de uso). Sin contadores de
    // tráfico tampoco hay contador propio.
    final Widget usage = (period == 'daily' || period.isEmpty) && !_unsupported
        ? Text(
            '${isEs ? 'Hoy' : 'Today'}: ${_todayBytes == null ? '—' : formatDailyBytes(_todayBytes!)}',
            key: const Key('today-usage'),
            style: NetworkTrafficIndicator.lineStyle.copyWith(fontWeight: FontWeight.w600),
          )
        : const DailyDataUsageWidget(compact: true);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_unsupported)
          ConstrainedBox(
            // Ancho de "↓ 999 KB/s": evita que el bloque cambie de tamaño cada 2 s.
            constraints: const BoxConstraints(minWidth: 100),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('↓ ${formatRate(_downBytesPerSecond)}', style: NetworkTrafficIndicator.lineStyle),
                Text('↑ ${formatRate(_upBytesPerSecond)}', style: NetworkTrafficIndicator.lineStyle),
              ],
            ),
          ),
        const SizedBox(width: 12),
        usage,
        // En la misma fila (centrado): la flecha abajo desde Ajustes no se
        // desvía hacia el botón.
        if (showPermission && usage is Text) ...[
          const SizedBox(width: 10),
          const UsageAccessButton(),
        ],
      ],
    );
  }
}

/// Abre "Acceso a datos de uso" del sistema con un Intent directo. Si el
/// televisor no tiene esa pantalla, explica cómo concederlo por ADB.
class UsageAccessButton extends StatelessWidget {
  const UsageAccessButton({super.key});

  static Future<void> request(BuildContext context) async {
    final network = context.read<NetworkService>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final opened = await network.requestPermission();
    if (!opened) {
      messenger?.showSnackBar(SnackBar(
        duration: const Duration(seconds: 8),
        content: Text(isEs
            ? 'Este televisor no tiene la pantalla "Acceso a datos de uso". '
                'Desde un PC: adb shell appops set com.clicktv.launcher GET_USAGE_STATS allow'
            : 'This TV has no "Usage access" screen. '
                'From a PC: adb shell appops set com.clicktv.launcher GET_USAGE_STATS allow'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        minimumSize: const Size(0, 24),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 13, height: 1.0),
      ),
      icon: const Icon(Icons.data_usage, size: 16),
      label: Text(isEs ? 'Consumo exacto' : 'Exact usage'),
      onPressed: () => request(context),
    );
  }
}

/// Velocidad compacta: "—" sin datos aún, KB/s por debajo de 1 MB/s y MB/s
/// con un decimal por encima.
String formatRate(int? bytesPerSecond) {
  if (bytesPerSecond == null) return '— KB/s';
  if (bytesPerSecond < 1024 * 1024) {
    return '${(bytesPerSecond / 1024).round()} KB/s';
  }
  return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
}
