import 'package:flauncher/providers/daily_traffic_counter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const mb = 1024 * 1024;
  late DateTime now;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    now = DateTime(2026, 11, 18, 10);
  });

  DailyTrafficCounter counter() => DailyTrafficCounter(prefs, clock: () => now);

  test('first sample only sets the reference; later samples add the difference', () {
    final c = counter();
    c.addSample(100 * mb);
    expect(c.todayBytes, 0);
    c.addSample(130 * mb);
    expect(c.todayBytes, 30 * mb);
  });

  test('traffic while the launcher was closed is counted on the next start', () async {
    final c = counter();
    c.addSample(100 * mb);
    c.addSample(110 * mb);
    await c.save();

    final reopened = counter();
    reopened.addSample(150 * mb); // SmartTube consumió 40 MB mientras tanto
    expect(reopened.todayBytes, 50 * mb);
  });

  test('a reboot (total goes down) counts the new total since boot', () {
    final c = counter();
    c.addSample(500 * mb);
    c.addSample(510 * mb);
    c.addSample(20 * mb); // reinicio: contadores desde cero
    expect(c.todayBytes, 30 * mb);
  });

  test('resets at midnight', () {
    final c = counter();
    c.addSample(100 * mb);
    c.addSample(200 * mb);
    expect(c.todayBytes, 100 * mb);
    now = DateTime(2026, 11, 19, 0, 1);
    expect(c.todayBytes, 0);
    c.addSample(210 * mb);
    expect(c.todayBytes, 10 * mb);
  });

  test('takes the exact system value when it is larger', () {
    final c = counter();
    c.addSample(100 * mb);
    c.addSample(105 * mb);
    c.seedFromSystem(800 * mb);
    expect(c.todayBytes, 800 * mb);
    c.seedFromSystem(1 * mb);
    expect(c.todayBytes, 800 * mb);
  });

  test('formatDailyBytes uses whole MB and GB with two decimals', () {
    expect(formatDailyBytes(0), '0 MB');
    expect(formatDailyBytes(753 * mb), '753 MB');
    expect(formatDailyBytes(1117 * mb), '1.09 GB');
  });
}
