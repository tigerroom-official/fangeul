import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/tts_provider.dart';
import 'package:fangeul/services/tts_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockTtsService extends Mock implements TtsService {}

void main() {
  late ProviderContainer container;
  late MockFlutterSecureStorage mockStorage;
  late MockTtsService mockTts;

  String todayStr() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// 기본 상태(저장 데이터 없음)로 컨테이너를 초기화한다.
  void setUpDefault() {
    mockStorage = MockFlutterSecureStorage();
    mockTts = MockTtsService();

    when(() => mockStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});
    when(() => mockTts.play(any())).thenAnswer((_) async {});
    when(() => mockTts.stop()).thenAnswer((_) async {});
    when(() => mockTts.dispose()).thenAnswer((_) async {});
    when(() => mockTts.isPlaying).thenReturn(false);

    container = ProviderContainer(
      overrides: [
        monetizationStorageProvider.overrideWithValue(mockStorage),
        ttsServiceProvider.overrideWithValue(mockTts),
      ],
    );
  }

  /// 특정 [MonetizationState]로 컨테이너를 초기화한다.
  void setUpWithState(MonetizationState initialState) {
    mockStorage = MockFlutterSecureStorage();
    mockTts = MockTtsService();
    final dataSource = MonetizationLocalDataSource(mockStorage);
    final dataStr = jsonEncode(initialState.toJson());
    final sig = dataSource.computeHmac(dataStr);

    when(() => mockStorage.read(key: MonetizationLocalDataSource.dataKey))
        .thenAnswer((_) async => dataStr);
    when(() => mockStorage.read(key: MonetizationLocalDataSource.sigKey))
        .thenAnswer((_) async => sig);
    when(() => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});
    when(() => mockTts.play(any())).thenAnswer((_) async {});
    when(() => mockTts.stop()).thenAnswer((_) async {});
    when(() => mockTts.dispose()).thenAnswer((_) async {});
    when(() => mockTts.isPlaying).thenReturn(false);

    container = ProviderContainer(
      overrides: [
        monetizationStorageProvider.overrideWithValue(mockStorage),
        ttsServiceProvider.overrideWithValue(mockTts),
      ],
    );
  }

  tearDown(() => container.dispose());

  group('canPlayTtsProvider', () {
    test('should return true during honeymoon', () async {
      setUpDefault();

      // 기본 상태 = 허니문 활성
      await container.read(monetizationNotifierProvider.future);

      final sub = container.listen(canPlayTtsProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(canPlayTtsProvider), true);
    });

    test('should return true when rewarded unlock is active', () async {
      final futureExpiry =
          DateTime.now().millisecondsSinceEpoch + (2 * 60 * 60 * 1000);
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: false,
        unlockExpiresAt: futureExpiry,
      ));

      await container.read(monetizationNotifierProvider.future);

      final sub = container.listen(canPlayTtsProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(canPlayTtsProvider), true);
    });

    test('should return true when TTS limit not reached', () async {
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: false,
        ttsPlayCount: 3,
        ttsLastResetDate: todayStr(),
      ));

      await container.read(monetizationNotifierProvider.future);

      final sub = container.listen(canPlayTtsProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(canPlayTtsProvider), true);
    });

    test('should return false when TTS limit reached', () async {
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: false,
        ttsPlayCount: 5,
        ttsLastResetDate: todayStr(),
      ));

      await container.read(monetizationNotifierProvider.future);

      final sub = container.listen(canPlayTtsProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(canPlayTtsProvider), false);
    });

    test('should return true when TTS limit reached but honeymoon active',
        () async {
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: true,
        ttsPlayCount: 5,
        ttsLastResetDate: todayStr(),
      ));

      await container.read(monetizationNotifierProvider.future);

      final sub = container.listen(canPlayTtsProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(canPlayTtsProvider), true);
    });
  });

  group('playTtsProvider', () {
    test('should play without counting during honeymoon', () async {
      setUpDefault();

      await container.read(monetizationNotifierProvider.future);

      final result = await container
          .read(playTtsProvider('assets/audio/test.mp3').future);

      expect(result, true);
      verify(() => mockTts.play('assets/audio/test.mp3')).called(1);

      // 카운트가 증가하지 않아야 함
      final state = await container.read(monetizationNotifierProvider.future);
      expect(state.ttsPlayCount, 0);
    });

    test('should play without counting when rewarded unlock active', () async {
      final futureExpiry =
          DateTime.now().millisecondsSinceEpoch + (2 * 60 * 60 * 1000);
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: false,
        unlockExpiresAt: futureExpiry,
      ));

      await container.read(monetizationNotifierProvider.future);

      final result = await container
          .read(playTtsProvider('https://example.com/audio.mp3').future);

      expect(result, true);
      verify(() => mockTts.play('https://example.com/audio.mp3')).called(1);

      final state = await container.read(monetizationNotifierProvider.future);
      expect(state.ttsPlayCount, 0);
    });

    test('should increment count when not honeymoon and not unlocked',
        () async {
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: false,
      ));

      await container.read(monetizationNotifierProvider.future);

      final result = await container
          .read(playTtsProvider('assets/audio/test.mp3').future);

      expect(result, true);
      verify(() => mockTts.play('assets/audio/test.mp3')).called(1);

      final state = await container.read(monetizationNotifierProvider.future);
      expect(state.ttsPlayCount, 1);
    });

    test('should return false when daily limit reached', () async {
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: false,
        ttsPlayCount: 5,
        ttsLastResetDate: todayStr(),
      ));

      await container.read(monetizationNotifierProvider.future);

      final result = await container
          .read(playTtsProvider('assets/audio/test.mp3').future);

      expect(result, false);
      verifyNever(() => mockTts.play(any()));
    });

    test('should return false but not throw when play fails', () async {
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: false,
      ));
      when(() => mockTts.play(any())).thenThrow(Exception('audio error'));

      await container.read(monetizationNotifierProvider.future);

      final result = await container
          .read(playTtsProvider('assets/audio/bad.mp3').future);

      expect(result, false);
    });

    test('should return false but not throw when play fails during honeymoon',
        () async {
      setUpDefault();
      when(() => mockTts.play(any())).thenThrow(Exception('audio error'));

      await container.read(monetizationNotifierProvider.future);

      final result = await container
          .read(playTtsProvider('assets/audio/bad.mp3').future);

      expect(result, false);
    });

    test('should pass URL source correctly to TtsService', () async {
      setUpDefault();

      await container.read(monetizationNotifierProvider.future);

      await container.read(
          playTtsProvider('https://cdn.example.com/ko/hello.mp3').future);

      verify(() => mockTts.play('https://cdn.example.com/ko/hello.mp3'))
          .called(1);
    });

    test('should pass asset source correctly to TtsService', () async {
      setUpDefault();

      await container.read(monetizationNotifierProvider.future);

      await container
          .read(playTtsProvider('assets/audio/saranghaeyo.mp3').future);

      verify(() => mockTts.play('assets/audio/saranghaeyo.mp3')).called(1);
    });
  });
}
