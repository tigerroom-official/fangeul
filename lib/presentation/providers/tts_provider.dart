import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/remote_config_providers.dart';
import 'package:fangeul/services/tts_service.dart';

part 'tts_provider.g.dart';

/// 중복 TTS 매핑 — 템플릿 문구 중 다른 팩과 동일한 음성을 공유하는 항목.
const _audioIdAliases = <String, String>{
  'idol_01': 'love_01',
  'idol_03': 'cback_01',
  'idol_04': 'bday_01',
  'idol_07': 'love_25',
  'idol_14': 'idol_02',
};

/// audioId를 실제 오디오 파일 ID로 변환한다.
///
/// [_audioIdAliases]에 매핑이 있으면 변환된 ID를, 없으면 원본을 반환한다.
String resolveAudioId(String audioId) => _audioIdAliases[audioId] ?? audioId;

/// 이번 세션에서 이미 카운트된 audioId 목록 (재재생 시 카운트 스킵).
final _sessionPlayedIds = <String>{};

/// 세션 재생 이력을 초기화한다. 테스트 전용.
@visibleForTesting
void clearSessionPlayedIds() => _sessionPlayedIds.clear();

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

/// TTS 재생 가능 여부 편의 Provider.
///
/// 허니문 중이면 무제한. 그 외에는 Remote Config의 일일 TTS 제한 적용.
/// 해금 경로는 IAP만.
@riverpod
bool canPlayTts(CanPlayTtsRef ref) {
  if (ref.watch(isHoneymoonProvider)) return true;

  final state = ref.watch(monetizationNotifierProvider).valueOrNull;
  if (state == null) return false;

  final config = ref.watch(remoteConfigValuesProvider);

  // 날짜가 바뀌었으면 카운트 리셋된 것으로 간주
  final now = DateTime.now();
  final todayStr =
      '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  if (state.ttsLastResetDate != todayStr) return true;

  return state.ttsPlayCount < config.dailyTtsLimit;
}

/// TTS 재생을 시도한다.
///
/// [audioId]를 alias 매핑으로 변환한 뒤 [TtsService.playById]로 재생한다.
/// 허니문 활성 시 카운트를 소모하지 않고 무제한 재생.
/// 같은 세션 내 동일 audioId 재재생 시 카운트를 소모하지 않는다.
/// 제한 도달 시 false를 반환하고 재생하지 않는다.
@riverpod
Future<bool> playTts(PlayTtsRef ref, String audioId) async {
  final isHoneymoon = ref.read(isHoneymoonProvider);
  final tts = ref.read(ttsServiceProvider);
  final resolved = resolveAudioId(audioId);

  // 허니문이 아닌 경우, 세션 내 첫 재생만 카운트
  if (!isHoneymoon && !_sessionPlayedIds.contains(resolved)) {
    final notifier = ref.read(monetizationNotifierProvider.notifier);
    final success = await notifier.recordTtsPlay();
    if (!success) return false;
    _sessionPlayedIds.add(resolved);
  }

  try {
    await tts.playById(resolved);
    return true;
  } catch (e) {
    debugPrint('[playTts] play failed — $e');
    return false;
  }
}
