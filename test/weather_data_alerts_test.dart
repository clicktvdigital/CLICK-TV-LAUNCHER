import "package:flutter_test/flutter_test.dart";
import "package:flauncher/models/weather_data.dart";

void main() {
  test("Current rain is classified as rain today", () {
    final weather = WeatherData.fromJson({
      "currentConditionCode": 500,
      "precipProbability": 80,
    });
    expect(weather.hasWarning, isTrue);
    expect(weather.warningType, WeatherWarningType.rain);
    expect(weather.warningDayIndex, 0);
    expect(weather.warningPrecipProbability, isNull);
  });

  test("Current snow is classified as snow", () {
    final weather = WeatherData.fromJson({
      "currentConditionCode": 600,
    });
    expect(weather.warningType, WeatherWarningType.snow);
  });

  test("Code 611 is hail, not snow", () {
    final weather = WeatherData.fromJson({
      "currentConditionCode": 611,
    });
    expect(weather.warningType, WeatherWarningType.hail);
    expect(weather.warningText, "Hail today");
  });

  test("Tomorrow hail forecast uses tomorrow, not today", () {
    final weather = WeatherData.fromJson({
      "currentConditionCode": 800,
      "forecasts": [
        {"conditionCode": 611, "precipProbability": 70},
      ],
    });
    expect(weather.warningType, WeatherWarningType.hail);
    expect(weather.warningDayIndex, 1);
    expect(weather.warningText, "70% Hail tomorrow");
  });

  test("Current storm takes priority over future rain", () {
    final weather = WeatherData.fromJson({
      "currentConditionCode": 211,
      "forecasts": [
        {"conditionCode": 500, "precipProbability": 90},
      ],
    });
    expect(weather.warningType, WeatherWarningType.storm);
    expect(weather.warningDayIndex, 0);
  });

  test("Clear weather without adverse forecast has no warning", () {
    final weather = WeatherData.fromJson({
      "currentConditionCode": 800,
    });
    expect(weather.hasWarning, isFalse);
    expect(weather.warningType, WeatherWarningType.none);
  });

  test("Gadgetbridge Kelvin temperature converts to Celsius", () {
    final weather = WeatherData.fromJson({
      "currentTemp": 300,
    });
    expect(weather.currentTemp, 27);
  });
}
