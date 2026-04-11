import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/presentation/providers/analytics_providers.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/services/analytics_events.dart';
import 'package:fangeul/services/tts_service.dart';

part 'tts_provider.g.dart';

/// 오늘 이미 재생된 audioId 목록 — SharedPreferences에 영속화된다.
///
/// 앱 재시작 시에도 이미 들은 문구의 카운트를 다시 소모하지 않도록 보장한다.
/// 날짜가 변경되면 `build()`에서 자동으로 클리어된다.
@Riverpod(keepAlive: true)
class TtsPlayedIds extends _$TtsPlayedIds {
  /// SharedPreferences 키 — 재생된 audioId JSON 배열.
  static const prefsKey = 'tts_played_ids';

  /// SharedPreferences 키 — 재생 기록 날짜 (YYYY-MM-DD).
  static const prefsDateKey = 'tts_played_ids_date';

  @override
  Set<String> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedDate = prefs.getString(prefsDateKey);
    final today = _todayStr();

    // 날짜 변경 → 초기화
    if (savedDate != today) {
      prefs.setString(prefsDateKey, today);
      prefs.remove(prefsKey);
      return {};
    }

    final json = prefs.getString(prefsKey);
    if (json != null) {
      try {
        return (jsonDecode(json) as List).cast<String>().toSet();
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  /// [audioId]가 오늘 이미 재생된 적 있는지 확인한다.
  bool contains(String audioId) => state.contains(audioId);

  /// [audioId]를 오늘 재생 목록에 추가하고 SharedPreferences에 저장한다.
  void add(String audioId) {
    state = {...state, audioId};
    _persist();
  }

  void _persist() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(prefsKey, jsonEncode(state.toList()));
    prefs.setString(prefsDateKey, _todayStr());
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}

/// TtsService 인스턴스 Provider.
///
/// 앱 전체에서 단일 인스턴스를 공유한다.
/// 테스트에서 mock으로 override 가능.
@Riverpod(keepAlive: true)
TtsService ttsService(TtsServiceRef ref) {
  final service = TtsService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
}

/// TTS 재생을 시도한다.
///
/// [TtsService.playById]로 재생한다.
/// 같은 세션 내 동일 audioId 재재생 시 카운트를 소모하지 않는다.
/// 제한 도달 시 false를 반환하고 재생하지 않는다.
/// 카운트는 재생 성공 후에만 소모된다 (네트워크 실패 시 쿼터 낭비 방지).
@riverpod
Future<bool> playTts(PlayTtsRef ref, String audioId) async {
  final hasIap = ref.read(hasAnyIapProvider);
  final tts = ref.read(ttsServiceProvider);
  final notifier = ref.read(monetizationNotifierProvider.notifier);

  final playedIds = ref.read(ttsPlayedIdsProvider.notifier);

  // 1. 제한 확인 (카운트 증가 없이)
  final needsCount = !hasIap && !playedIds.contains(audioId);
  if (needsCount && notifier.isTtsLimitReached) return false;

  // 2. 재생
  try {
    await tts.playById(audioId);
  } catch (e) {
    debugPrint('[playTts] play failed — $e');
    return false;
  }

  // 3. 성공 → 이벤트 기록
  ref.read(analyticsServiceProvider).logEvent(
    AnalyticsEvents.ttsPlay,
    {AnalyticsParams.audioId: audioId},
  );

  // 4. 성공 후에만 카운트 소모 + played IDs 영속화
  if (needsCount) {
    await notifier.recordTtsPlay();
    playedIds.add(audioId);
  }
  return true;
}
