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

            final isEs = Localizations.localeOf(context).languageCode == "es";

            // Línea de lluvia o aviso (opcional).
            String? alertLine;
            if (weather.rainStart != null) {
              final rs = weather.rainStart!;
              final h12 = rs.hour % 12 == 0 ? 12 : rs.hour % 12;
              final ampm = rs.hour < 12 ? (isEs ? "a. m." : "AM") : (isEs ? "p. m." : "PM");
              final mm = rs.minute.toString().padLeft(2, '0');
              final now = DateTime.now();
              final sameDay = rs.year == now.year && rs.month == now.month && rs.day == now.day;
              final dayWord = sameDay ? "" : (isEs ? "mañana " : "tomorrow ");
              alertLine = isEs
                  ? "Lluvia ${dayWord}desde $h12:$mm $ampm (${weather.rainStartPercent}%)"
                  : "Rain ${dayWord}from $h12:$mm $ampm (${weather.rainStartPercent}%)";
            }

            // Línea principal: temperatura actual • estado (o aviso).
            String primaryLine;
            final condition = (weather.currentCondition ?? "").trim();
            if (weather.rainStart == null && isWarning && weather.warningText != null) {
              if (isEs) {
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
                primaryLine = "$tempText • $warningName $dayLabel$probabilityLabel";
              } else {
                primaryLine = "$tempText • ${weather.warningText}";
              }
            } else {
              primaryLine = condition.isEmpty ? tempText : "$tempText • $condition";
            }

            // Datos meteorologicos reales recibidos de Alerta EC.
            var city = (weather.location ?? "").split(",").first.trim();
            if (dataStale) {
              final staleLabel = isEs ? "sin actualizar" : "not updated";
              city = city.isEmpty ? staleLabel : "$city • $staleLabel";
            }
            int displayDegrees(int celsius) =>
                useFahrenheit ? (celsius * 9 / 5 + 32).round() : celsius;
            String? rangeLine;
            if (weather.todayMaxTemp != null && weather.todayMinTemp != null) {
              final high = displayDegrees(weather.todayMaxTemp!);
              final low = displayDegrees(weather.todayMinTemp!);
              rangeLine = isEs ? "↑ $high° máx  ↓ $low° mín" : "↑ $high° max  ↓ $low° min";
            }

            // Hasta 4 líneas de 14 px (56 px) en la barra de 72 dp:
            //   1) ciudad  2) temperatura • estado  3) lluvia  4) máx/mín
            final lines = <String>[
              primaryLine,
              if (alertLine != null) alertLine,
              if (rangeLine != null) rangeLine,
            ];

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
                    // Ancho natural del texto (cada dato en su línea corta),
                    // con tope del 36 % para no invadir el indicador de red.
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.36,
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
                                blurRadius: 4,
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
                          // La altura de la barra es fija: con letra del
                          // sistema ampliada las 3 líneas no cabrían.
                          child: MediaQuery.withClampedTextScaling(
                            maxScaleFactor: 1.0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (city.isNotEmpty)
                                  _WeatherLine(city, bold: true),
                                for (final line in lines) _WeatherLine(line),
                              ],
                            ),
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

/// Una línea del clima: siempre una sola línea, con "…" si no cabe el ancho,
/// para que el bloque nunca supere las 3 líneas que caben en la barra.
class _WeatherLine extends StatelessWidget {
  const _WeatherLine(this.text, {this.bold = false});

  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) => Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          height: 1.0,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          color: Colors.white,
        ),
      );
}
