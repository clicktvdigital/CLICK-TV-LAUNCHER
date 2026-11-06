import 'dart:async';
import 'dart:typed_data';

import 'package:flauncher/database.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StartupChannel extends FLauncherChannel {
  bool fail = false;

  @override
  Future<List<Map<dynamic, dynamic>>> getApplications() async {
    if (fail) throw StateError('PackageManager unavailable');
    return [
      {'packageName': 'tv.player', 'name': 'TV', 'version': '1', 'sideloaded': false},
      {'packageName': 'box.player', 'name': 'Box', 'version': '1', 'sideloaded': true},
    ];
  }

  @override
  void addAppsChangedListener(void Function(Map<String, dynamic>) listener) {}

  @override
  Future<Uint8List> getApplicationIcon(String packageName) async => Uint8List(0);

  @override
  Future<Uint8List> getApplicationBanner(String packageName) async => Uint8List(0);
}

Future<void> _settled(AppsService service) async {
  if (!service.initializing &&
      (service.initialized || service.initializationError != null)) return;
  final completer = Completer<void>();
  void listener() {
    if (!service.initializing &&
      (service.initialized || service.initializationError != null)) {
      if (!completer.isCompleted) completer.complete();
    }
  }
  service.addListener(listener);
  try {
    await completer.future.timeout(const Duration(seconds: 5));
  } finally {
    service.removeListener(listener);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('first boot shows both TV and generic Android box applications', () async {
    final database = FLauncherDatabase.inMemory();
    final service = AppsService(_StartupChannel(), database);
    await _settled(service);
    expect(service.initializationError, isNull);
    expect(service.initialized, isTrue);
    expect(service.categories.single.applications.map((app) => app.packageName),
        unorderedEquals(['tv.player', 'box.player']));
    service.dispose();
    await database.close();
  });

  test('discovery failure finishes with an error and can be retried', () async {
    final database = FLauncherDatabase.inMemory();
    final channel = _StartupChannel()..fail = true;
    final service = AppsService(channel, database);
    await _settled(service);
    expect(service.initialized, isFalse);
    expect(service.initializationError, isA<StateError>());
    channel.fail = false;
    await service.retryInitialization();
    expect(service.initialized, isTrue);
    expect(service.initializationError, isNull);
    expect(service.categories.single.applications, hasLength(2));
    service.dispose();
    await database.close();
  });

  test('failed refresh preserves the saved catalog and category membership', () async {
    final database = FLauncherDatabase.inMemory();
    final channel = _StartupChannel();
    final service = AppsService(channel, database);
    await _settled(service);
    channel.fail = true;
    await service.refreshState();
    expect(service.applications, hasLength(2));
    expect(service.categories.single.applications, hasLength(2));
    service.dispose();
    await database.close();
  });
}
