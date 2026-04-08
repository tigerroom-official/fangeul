import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/remote_config_providers.dart';
import 'package:fangeul/services/tts_service.dart';

part 'tts_provider.g.dart';

/// 이번 세션에서 이미 카운트된 audioId 목록 (재재생 시 카운트 스킵).
final _sessionPlayedIds = <String>{};

/// 세션 재생 이력을 초기화한다.
///
/// 보상형 광고로 보너스 재생 횟수를 받은 뒤 호출하여
/// 이전에 재생한 문구도 다시 재생할 수 있게 한다.
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
  final isHoneymoon = ref.watch(isHoneymoonProvider);
  final hasIap = ref.watch(hasAnyIapProvider);
  if (isHoneymoon || hasIap) return true;

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
/// [TtsService.playById]로 재생한다.
/// 허니문 활성 시 카운트를 소모하지 않고 무제한 재생.
/// 같은 세션 내 동일 audioId 재재생 시 카운트를 소모하지 않는다.
/// 제한 도달 시 false를 반환하고 재생하지 않는다.
/// 카운트는 재생 성공 후에만 소모된다 (네트워크 실패 시 쿼터 낭비 방지).
@riverpod
Future<bool> playTts(PlayTtsRef ref, String audioId) async {
  final isHoneymoon = ref.read(isHoneymoonProvider);
  final hasIap = ref.read(hasAnyIapProvider);
  final tts = ref.read(ttsServiceProvider);
  final notifier = ref.read(monetizationNotifierProvider.notifier);

  // 1. 제한 확인 (카운트 증가 없이)
  final needsCount =
      !isHoneymoon && !hasIap && !_sessionPlayedIds.contains(audioId);
  if (needsCount && notifier.isTtsLimitReached) return false;

  // 2. 재생
  try {
    await tts.playById(audioId);
  } catch (e) {
    debugPrint('[playTts] play failed — $e');
    return false;
  }

  // 3. 성공 후에만 카운트 소모
  if (needsCount) {
    await notifier.recordTtsPlay();
    _sessionPlayedIds.add(audioId);
  }
  return true;
}
