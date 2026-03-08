import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/services/tts_service.dart';

part 'tts_provider.g.dart';

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
/// 허니문 중이면 무제한. 그 외에는 일일 5회 제한
/// ([MonetizationNotifier.dailyTtsLimit]). 해금 경로는 IAP만.
@riverpod
bool canPlayTts(CanPlayTtsRef ref) {
  if (ref.watch(isHoneymoonProvider)) return true;

  final state = ref.watch(monetizationNotifierProvider).valueOrNull;
  if (state == null) return false;

  // 날짜가 바뀌었으면 카운트 리셋된 것으로 간주
  final now = DateTime.now();
  final todayStr =
      '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  if (state.ttsLastResetDate != todayStr) return true;

  return state.ttsPlayCount < MonetizationNotifier.dailyTtsLimit;
}

/// TTS 재생을 시도한다.
///
/// 일일 제한 확인 → 카운트 기록 → 재생 순서로 진행.
/// 허니문/보상형 해금 활성 시 카운트를 소모하지 않고 무제한 재생.
/// 제한 도달 시 false를 반환하고 재생하지 않는다.
///
/// [source]는 에셋 경로('assets/audio/...')  또는 원격 URL.
@riverpod
Future<bool> playTts(PlayTtsRef ref, String source) async {
  final honeymoon = ref.read(isHoneymoonProvider);
  final tts = ref.read(ttsServiceProvider);

  // 허니문 시 카운트 소모 없이 재생
  if (honeymoon) {
    try {
      await tts.play(source);
      return true;
    } catch (e) {
      debugPrint('[playTts] play failed — $e');
      return false;
    }
  }

  // 일일 제한 확인 및 카운트 기록
  final notifier = ref.read(monetizationNotifierProvider.notifier);
  final allowed = await notifier.recordTtsPlay();
  if (!allowed) return false;

  try {
    await tts.play(source);
    return true;
  } catch (e) {
    debugPrint('[playTts] play failed — $e');
    return false;
  }
}
