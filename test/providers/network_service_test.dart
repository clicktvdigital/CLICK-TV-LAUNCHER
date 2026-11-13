import 'package:flauncher/providers/network_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_async/fake_async.dart';
import 'dart:async';

import '../mocks.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockFLauncherChannel mockChannel;
  late NetworkService networkService;
  void Function(Map<String, dynamic>)? networkListener;

  setUp(() {
    mockChannel = MockFLauncherChannel();
    when(mockChannel.getActiveNetworkInformation())
        .thenAnswer((_) async => <String, dynamic>{});
    when(mockChannel.checkUsageStatsPermission())
        .thenAnswer((_) async => false);
    when(mockChannel.addNetworkChangedListener(any)).thenAnswer((invocation) {
      networkListener = invocation.positionalArguments[0] as void Function(Map<String, dynamic>);
    });
    networkService = NetworkService(mockChannel);
  });

  tearDown(() {
    networkService.dispose();
  });

  group('getDataUsageForPeriod', () {
    test('returns daily usage when period is "daily"', () async {
      when(mockChannel.getDailyDataUsage()).thenAnswer((_) async => 100);

      final result = await networkService.getDataUsageForPeriod('daily');

      expect(result, 100);
      verify(mockChannel.getDailyDataUsage()).called(1);
      verifyNever(mockChannel.getWeeklyDataUsage());
      verifyNever(mockChannel.getMonthlyDataUsage());
    });

    test('returns weekly usage when period is "weekly"', () async {
      when(mockChannel.getWeeklyDataUsage()).thenAnswer((_) async => 500);

      final result = await networkService.getDataUsageForPeriod('weekly');

      expect(result, 500);
      verify(mockChannel.getWeeklyDataUsage()).called(1);
      verifyNever(mockChannel.getDailyDataUsage());
      verifyNever(mockChannel.getMonthlyDataUsage());
    });

    test('returns monthly usage when period is "monthly"', () async {
      when(mockChannel.getMonthlyDataUsage()).thenAnswer((_) async => 2000);

      final result = await networkService.getDataUsageForPeriod('monthly');

      expect(result, 2000);
      verify(mockChannel.getMonthlyDataUsage()).called(1);
      verifyNever(mockChannel.getDailyDataUsage());
      verifyNever(mockChannel.getWeeklyDataUsage());
    });

    test('returns daily usage when period is unknown', () async {
      when(mockChannel.getDailyDataUsage()).thenAnswer((_) async => 100);

      final result = await networkService.getDataUsageForPeriod('unknown_period');

      expect(result, 100);
      verify(mockChannel.getDailyDataUsage()).called(1);
      verifyNever(mockChannel.getWeeklyDataUsage());
      verifyNever(mockChannel.getMonthlyDataUsage());
    });
  });

  group('refreshPermissionAndUsage', () {
    test('when permission granted, fetches usage once and notifies listeners', () {
      fakeAsync((async) {
        when(mockChannel.checkUsageStatsPermission()).thenAnswer((_) async => true);
        when(mockChannel.getDailyDataUsage()).thenAnswer((_) async => 100);

        int listenerCallCount = 0;
        networkService.addListener(() {
          listenerCallCount++;
        });

        networkService.refreshPermissionAndUsage();
        async.flushMicrotasks();

        expect(networkService.hasUsageStatsPermission, isTrue);
        expect(networkService.dailyDataUsage, 100);
        expect(listenerCallCount, greaterThanOrEqualTo(2));
        verify(mockChannel.getDailyDataUsage()).called(1);

        // Sin polling: pasar el tiempo no provoca nuevas consultas.
        async.elapse(const Duration(minutes: 15));
        verify(mockChannel.getDailyDataUsage()).called(1);
      });
    });

    test('when permission denied, does not fetch usage and notifies listeners', () {
      fakeAsync((async) {
        when(mockChannel.checkUsageStatsPermission()).thenAnswer((_) async => false);
        when(mockChannel.getDailyDataUsage()).thenAnswer((_) async => 100);

        int listenerCallCount = 0;
        networkService.addListener(() {
          listenerCallCount++;
        });

        networkService.refreshPermissionAndUsage();
        async.flushMicrotasks();

        expect(networkService.hasUsageStatsPermission, isFalse);
        expect(listenerCallCount, 1);

        async.elapse(const Duration(minutes: 15));
        verifyNever(mockChannel.getDailyDataUsage());
      });
    });

    test('each refresh fetches usage on demand and does not add periodic fetches', () {
      fakeAsync((async) {
        when(mockChannel.checkUsageStatsPermission()).thenAnswer((_) async => true);
        when(mockChannel.getDailyDataUsage()).thenAnswer((_) async => 100);

        networkService.refreshPermissionAndUsage();
        async.flushMicrotasks();
        async.elapse(const Duration(minutes: 4));

        when(mockChannel.getDailyDataUsage()).thenAnswer((_) async => 200);

        networkService.refreshPermissionAndUsage();
        async.flushMicrotasks();

        expect(networkService.dailyDataUsage, 200);
        verify(mockChannel.getDailyDataUsage()).called(2);

        // Ni a los 5 ni a los 10 minutos debe haber consultas automáticas.
        async.elapse(const Duration(minutes: 10));
        verify(mockChannel.getDailyDataUsage()).called(2);
      });
    });
  });

  group('network events safety', () {
    test('handles CELLULAR_STATE_CHANGED with out-of-bounds index without throwing', () {
      expect(networkListener, isNotNull);
      expect(() => networkListener!({'name': 'CELLULAR_STATE_CHANGED', 'arguments': 999}), returnsNormally);
      expect(networkService.cellularNetworkType, CellularNetworkType.Unknown);
      expect(() => networkListener!({'name': 'CELLULAR_STATE_CHANGED', 'arguments': -5}), returnsNormally);
      expect(networkService.cellularNetworkType, CellularNetworkType.Unknown);
    });
  });
}
