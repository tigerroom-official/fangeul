import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/core/entities/remote_config_values.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/remote_config_providers.dart';
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
    when(() => mockTts.playById(any())).thenAnswer((_) async {});
    when(() => mockTts.play(any())).thenAnswer((_) async {});
    when(() => mockTts.stop()).thenAnswer((_) async {});
    when(() => mockTts.dispose()).thenAnswer((_) async {});
    when(() => mockTts.isPlaying).thenReturn(false);

    container = ProviderContainer(
      overrides: [
        monetizationStorageProvider.overrideWithValue(mockStorage),
        ttsServiceProvider.overrideWithValue(mockTts),
        remoteConfigValuesProvider
            .overrideWithValue(const RemoteConfigValues()),
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
    when(() => mockTts.playById(any())).thenAnswer((_) async {});
    when(() => mockTts.play(any())).thenAnswer((_) async {});
    when(() => mockTts.stop()).thenAnswer((_) async {});
    when(() => mockTts.dispose()).thenAnswer((_) async {});
    when(() => mockTts.isPlaying).thenReturn(false);

    container = ProviderContainer(
      overrides: [
        monetizationStorageProvider.overrideWithValue(mockStorage),
        ttsServiceProvider.overrideWithValue(mockTts),
        remoteConfigValuesProvider
            .overrideWithValue(const RemoteConfigValues()),
      ],
    );
  }

  tearDown(() {
    container.dispose();
    clearSessionPlayedIds();
  });

  group('resolveAudioId', () {
    test('should resolve alias to mapped audioId', () {
      setUpDefault();
      expect(resolveAudioId('idol_01'), 'love_01');
      expect(resolveAudioId('idol_03'), 'cback_01');
      expect(resolveAudioId('idol_04'), 'bday_01');
      expect(resolveAudioId('idol_07'), 'love_25');
      expect(resolveAudioId('idol_14'), 'idol_02');
    });

    test('should return original audioId when no alias exists', () {
      setUpDefault();
      expect(resolveAudioId('love_01'), 'love_01');
      expect(resolveAudioId('bday_05'), 'bday_05');
      expect(resolveAudioId('unknown_99'), 'unknown_99');
    });
  });

  group('canPlayTtsProvider', () {
    test('should return true during honeymoon', () async {
      setUpDefault();

      // 기본 상태 = 허니문 활성
      await container.read(monetizationNotifierProvider.future);

      final sub = container.listen(canPlayTtsProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(canPlayTtsProvider), true);
    });

    test('should respect TTS limit even during theme trial', () async {
      final futureExpiry =
          DateTime.now().millisecondsSinceEpoch + (2 * 60 * 60 * 1000);
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: false,
        themeTrialExpiresAt: futureExpiry,
        ttsPlayCount: 5,
        ttsLastResetDate: todayStr(),
      ));

      await container.read(monetizationNotifierProvider.future);

      final sub = container.listen(canPlayTtsProvider, (_, __) {});
      addTearDown(sub.close);

      // 테마 체험이 활성이어도 TTS 제한은 적용됨 (IAP만 해금)
      expect(container.read(canPlayTtsProvider), false);
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

      final result =
          await container.read(playTtsProvider('love_01').future);

      expect(result, true);
      verify(() => mockTts.playById('love_01')).called(1);

      // 카운트가 증가하지 않아야 함
      final state = await container.read(monetizationNotifierProvider.future);
      expect(state.ttsPlayCount, 0);
    });

    test('should count TTS plays during theme trial (not unlimited)', () async {
      final futureExpiry =
          DateTime.now().millisecondsSinceEpoch + (2 * 60 * 60 * 1000);
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: false,
        themeTrialExpiresAt: futureExpiry,
      ));

      await container.read(monetizationNotifierProvider.future);

      final result = await container
          .read(playTtsProvider('bday_05').future);

      expect(result, true);
      verify(() => mockTts.playById('bday_05')).called(1);

      // 테마 체험 중에도 TTS 카운트 소모됨 (해금 경로 = IAP만)
      final state = await container.read(monetizationNotifierProvider.future);
      expect(state.ttsPlayCount, 1);
    });

    test('should increment count when not honeymoon and not unlocked',
        () async {
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: false,
      ));

      await container.read(monetizationNotifierProvider.future);

      final result =
          await container.read(playTtsProvider('love_01').future);

      expect(result, true);
      verify(() => mockTts.playById('love_01')).called(1);

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

      final result =
          await container.read(playTtsProvider('love_01').future);

      expect(result, false);
      verifyNever(() => mockTts.playById(any()));
    });

    test('should return false but not throw when play fails', () async {
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: false,
      ));
      when(() => mockTts.playById(any())).thenThrow(Exception('audio error'));

      await container.read(monetizationNotifierProvider.future);

      final result =
          await container.read(playTtsProvider('love_01').future);

      expect(result, false);
    });

    test('should return false but not throw when play fails during honeymoon',
        () async {
      setUpDefault();
      when(() => mockTts.playById(any())).thenThrow(Exception('audio error'));

      await container.read(monetizationNotifierProvider.future);

      final result =
          await container.read(playTtsProvider('love_01').future);

      expect(result, false);
    });

    test('should resolve alias and pass resolved audioId to TtsService',
        () async {
      setUpDefault();

      await container.read(monetizationNotifierProvider.future);

      // idol_01은 love_01으로 alias됨
      await container.read(playTtsProvider('idol_01').future);

      verify(() => mockTts.playById('love_01')).called(1);
      verifyNever(() => mockTts.playById('idol_01'));
    });

    test('should pass non-aliased audioId directly to TtsService', () async {
      setUpDefault();

      await container.read(monetizationNotifierProvider.future);

      await container.read(playTtsProvider('bday_05').future);

      verify(() => mockTts.playById('bday_05')).called(1);
    });

    test('should skip counter on same audioId replay within session',
        () async {
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: false,
      ));

      await container.read(monetizationNotifierProvider.future);

      // 첫 재생 — 카운트 1
      final result1 =
          await container.read(playTtsProvider('love_01').future);
      expect(result1, true);

      // 같은 audioId 재재생 — 카운트 여전히 1
      // Riverpod auto-dispose로 새 provider 인스턴스 필요
      container.invalidate(playTtsProvider('love_01'));
      final result2 =
          await container.read(playTtsProvider('love_01').future);
      expect(result2, true);

      final state = await container.read(monetizationNotifierProvider.future);
      expect(state.ttsPlayCount, 1);
    });

    test('should count each different audioId separately', () async {
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: false,
      ));

      await container.read(monetizationNotifierProvider.future);

      // 첫 번째 audioId
      await container.read(playTtsProvider('love_01').future);
      // 두 번째 audioId
      await container.read(playTtsProvider('bday_05').future);

      final state = await container.read(monetizationNotifierProvider.future);
      expect(state.ttsPlayCount, 2);
    });

    test(
        'should skip counter when alias resolves to already-played audioId',
        () async {
      setUpWithState(MonetizationState(
        installDate: todayStr(),
        honeymoonActive: false,
      ));

      await container.read(monetizationNotifierProvider.future);

      // love_01 재생 → 카운트 1
      await container.read(playTtsProvider('love_01').future);

      // idol_01은 love_01으로 resolve됨 → 이미 재생됨 → 카운트 스킵
      await container.read(playTtsProvider('idol_01').future);

      final state = await container.read(monetizationNotifierProvider.future);
      expect(state.ttsPlayCount, 1);

      // 그래도 재생은 됨
      verify(() => mockTts.playById('love_01')).called(2);
    });
  });
}
