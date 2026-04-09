import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/presentation/providers/remote_config_providers.dart';
import 'package:fangeul/services/tts_service.dart';

part 'tts_provider.g.dart';

/// 이번 세션에서 이미 재생된 audioId 목록 (재재생 시 카운트 스킵 + UI 표시).
final sessionPlayedIds = <String>{};

/// 특정 audioId가 이번 세션에서 재생된 적 있는지 확인한다.
bool hasPlayedInSession(String audioId) => sessionPlayedIds.contains(audioId);

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

  // 1. 제한 확인 (카운트 증가 없이)
  final needsCount = !hasIap && !sessionPlayedIds.contains(audioId);
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
    sessionPlayedIds.add(audioId);
  }
  return true;
}
