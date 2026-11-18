import 'dart:async';

import 'package:flauncher/providers/network_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
              const SizedBox(width: 12),
              const DailyDataUsageWidget(compact: true),
            ],
          ),
        ),
      ),
    );
  }
}

/// Velocidad de bajada y subida, una por línea. Consulta los contadores de
/// tráfico cada 2 s solo mientras el launcher está en primer plano; con otra
/// app abierta (SmartTube, etc.) no hace ningún trabajo.
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _start();
    } else {
      _stop();
    }
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
    if (_unsupported) return const SizedBox.shrink();
    return ConstrainedBox(
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
