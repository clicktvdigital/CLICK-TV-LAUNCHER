import 'package:flauncher/providers/network_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DailyDataUsageWidget extends StatelessWidget {
  /// Versión de una línea a 14 px para la barra de estado (con la velocidad
  /// encima, ver NetworkTrafficIndicator).
  final bool compact;

  const DailyDataUsageWidget({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NetworkService, SettingsService>(
      builder: (context, networkService, settingsService, _) {
        final isEs = Localizations.localeOf(context).languageCode == 'es';
        if (!networkService.hasUsageStatsPermission) {
          return TextButton.icon(
             style: compact
                 ? TextButton.styleFrom(
                     padding: EdgeInsets.zero,
                     minimumSize: const Size(0, 14),
                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                     visualDensity: VisualDensity.compact,
                     textStyle: const TextStyle(fontSize: 13, height: 1.0),
                   )
                 : null,
             icon: Icon(Icons.data_usage, size: compact ? 14 : 20),
             label: Text(isEs ? "Permitir ver consumo" : "Grant Usage Permission"),
             onPressed: () => networkService.requestPermission(),
          );
        }

        final period = settingsService.dataUsagePeriod;
        String label;
        switch (period) {
          case 'weekly':
            label = isEs ? 'Semana: ' : 'Weekly: ';
            break;
          case 'monthly':
            label = isEs ? 'Mes: ' : 'Monthly: ';
            break;
          case 'daily':
          default:
            label = isEs ? 'Hoy: ' : 'Daily: ';
            break;
        }

        return FutureBuilder<int>(
          future: networkService.getDataUsageForPeriod(period),
          builder: (context, snapshot) {
            final usage = snapshot.data ?? networkService.dailyDataUsage;
            final usageString = _formatBytes(usage);

            return RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: compact ? 14 : 20,
                  height: compact ? 1.0 : null,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 4)
                  ],
                ),
                children: [
                  TextSpan(text: label),
                  TextSpan(
                    text: usageString,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = 0;
    double d = bytes.toDouble();
    while (d >= 1024 && i < suffixes.length - 1) {
      d /= 1024;
      i++;
    }
    return "${d.toStringAsFixed(2)} ${suffixes[i]}";
  }
}
