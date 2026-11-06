import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WeatherStatusBarWidget extends StatefulWidget {
  final FocusNode? focusNode;

  const WeatherStatusBarWidget({Key? key, this.focusNode}) : super(key: key);

  @override
  State<WeatherStatusBarWidget> createState() => _WeatherStatusBarWidgetState();
}

class _WeatherStatusBarWidgetState extends State<WeatherStatusBarWidget> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsService, (bool, bool, bool)>(
      selector: (_, settings) => (
        settings.showWeatherInStatusBar,
        settings.showWeatherWarnings,
        settings.useFahrenheit,
      ),
      builder: (context, settingsTuple, _) {
        final (showWeather, showWarnings, useFahrenheit) = settingsTuple;
        if (!showWeather) return const SizedBox.shrink();

        return Consumer<WeatherService>(
          builder: (context, weatherService, _) {
            final weather = weatherService.weatherData;
            if (weather == null) return const SizedBox.shrink();

            final updatedAt = weather.timestamp == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(weather.timestamp! * 1000);
            final dataStale = updatedAt == null ||
                DateTime.now().difference(updatedAt) > const Duration(hours: 2);
            final bool isWarning = showWarnings && weather.hasWarning && !dataStale;
            final icon = weather.getConditionIcon();
            final tempText = weather.formatTemperature(useFahrenheit: useFahrenheit);

            String displayText;
            if (isWarning && weather.warningText != null) {
              if (Localizations.localeOf(context).languageCode == "es") {
                final warningName = weather.warningType.name == "rain"
                    ? "Lluvia"
                    : weather.warningType.name == "snow"
                        ? "Nieve"
                        : weather.warningType.name == "hail"
                            ? "Granizo"
                            : "Tormenta";
                final dayIndex = weather.warningDayIndex ?? 0;
                final dayLabel = dayIndex == 0
                    ? "hoy"
                    : dayIndex == 1
                        ? "mañana"
                        : "el ${["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo"][DateTime.now().add(Duration(days: dayIndex)).weekday - 1]}";
                final probability = weather.warningPrecipProbability;
                final probabilityLabel = probability != null && probability > 0
                    ? " (${probability}%)"
                    : "";
                displayText = "$tempText • $warningName $dayLabel$probabilityLabel";
              } else {
                displayText = "$tempText • ${weather.warningText}";
              }
            } else {
              displayText = tempText;
            }

            // Datos meteorologicos reales recibidos de Alerta EC.
            final city = (weather.location ?? "").split(",").first.trim();
            final condition = (weather.currentCondition ?? "").trim();
            int displayDegrees(int celsius) =>
                useFahrenheit ? (celsius * 9 / 5 + 32).round() : celsius;
            final details = <String>[];
            details.add(displayText);
            if (!isWarning && condition.isNotEmpty) details.add(condition);
            if (weather.todayMaxTemp != null && weather.todayMinTemp != null) {
              final high = displayDegrees(weather.todayMaxTemp!);
              final low = displayDegrees(weather.todayMinTemp!);
              details.add("↑ " + high.toString() + "° ↓ " + low.toString() + "°");
            }
            if (dataStale) {
              details.add(Localizations.localeOf(context).languageCode == "es"
                  ? "Datos sin actualizar"
                  : "Weather not updated");
            }
            displayText = details.join(" • ");

            final theme = Theme.of(context);

            return Actions(
              actions: <Type, Action<Intent>>{
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) => weatherService.openBreezyWeather(),
                ),
                ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
                  onInvoke: (_) => weatherService.openBreezyWeather(),
                ),
              },
              child: Focus(
                focusNode: widget.focusNode,
                onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
                child: InkWell(
                  onTap: () => weatherService.openBreezyWeather(),
                  canRequestFocus: false,
                  borderRadius: BorderRadius.circular(14),
                  focusColor: Colors.transparent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.28,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _focused
                            ? theme.colorScheme.primary
                            : Colors.white.withOpacity(0.12),
                        width: 1,
                      ),
                      boxShadow: _focused
                          ? const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: Colors.white,
                          shadows: const [
                            Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 4)
                          ],
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (city.isNotEmpty)
                                Text(
                                  city,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              Text(
                                displayText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
