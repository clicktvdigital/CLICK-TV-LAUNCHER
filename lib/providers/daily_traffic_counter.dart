import 'package:shared_preferences/shared_preferences.dart';

/// Consumo de datos del día calculado con los contadores de tráfico del
/// sistema (TrafficStats: bytes totales desde el arranque, sin permisos).
///
/// Se guarda en SharedPreferences: el día, los bytes acumulados y el último
/// total leído. Así cuenta también el tráfico generado mientras otra app
/// estaba en primer plano (SmartTube, etc.) y sobrevive a reinicios del
/// launcher. Si el total baja, el equipo se reinició y el total actual es todo
/// lo consumido desde el arranque.
class DailyTrafficCounter {
  DailyTrafficCounter(this._prefs, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now {
    _day = _prefs.getString(_kDay) ?? _dayKey(_clock());
    _bytes = _prefs.getInt(_kBytes) ?? 0;
    _last = _prefs.getInt(_kLast);
  }

  static const _kDay = 'traffic_counter_day';
  static const _kBytes = 'traffic_counter_bytes';
  static const _kLast = 'traffic_counter_last_total';
  static const Duration _saveEvery = Duration(seconds: 30);

  final SharedPreferences _prefs;
  final DateTime Function() _clock;
  late String _day;
  late int _bytes;
  int? _last;
  DateTime? _lastSave;

  int get todayBytes {
    _rollDay();
    return _bytes;
  }

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _rollDay() {
    final today = _dayKey(_clock());
    if (today != _day) {
      _day = today;
      _bytes = 0;
    }
  }

  /// Registra un total (bajada + subida) leído del sistema.
  void addSample(int totalBytes) {
    _rollDay();
    final last = _last;
    if (last != null) {
      _bytes += totalBytes >= last ? totalBytes - last : totalBytes;
    }
    _last = totalBytes;
    final now = _clock();
    if (_lastSave == null || now.difference(_lastSave!) >= _saveEvery) {
      save();
    }
  }

  /// Con permiso de uso, Android da el consumo exacto del día (incluye lo
  /// anterior a la instalación): se toma si es mayor que lo contado.
  void seedFromSystem(int systemTodayBytes) {
    _rollDay();
    if (systemTodayBytes > _bytes) _bytes = systemTodayBytes;
  }

  Future<void> save() async {
    _lastSave = _clock();
    await _prefs.setString(_kDay, _day);
    await _prefs.setInt(_kBytes, _bytes);
    final last = _last;
    if (last != null) await _prefs.setInt(_kLast, last);
  }
}

/// MB sin decimales y GB con dos, para la barra de estado.
String formatDailyBytes(int bytes) {
  const mb = 1024 * 1024;
  const gb = mb * 1024;
  if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(2)} GB';
  return '${(bytes / mb).round()} MB';
}
