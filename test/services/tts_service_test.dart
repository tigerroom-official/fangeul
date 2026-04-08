import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/services/tts_service.dart';

void main() {
  group('TtsService', () {
    late TtsService service;

    setUp(() {
      service = TtsService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('should create without errors', () {
      expect(service, isNotNull);
    });

    test('should report isPlaying as false initially', () {
      expect(service.isPlaying, false);
    });

    test('should safely stop when no player exists', () async {
      // stop()은 플레이어가 없을 때 예외 없이 동작해야 한다
      await service.stop();
    });

    test('should safely dispose without prior play', () async {
      // dispose()는 play() 호출 없이도 예외 없이 동작해야 한다
      await service.dispose();
      expect(service.isPlaying, false);
    });

    test('should safely dispose multiple times', () async {
      await service.dispose();
      await service.dispose(); // 중복 dispose도 안전
      expect(service.isPlaying, false);
    });

    test('should report isPlaying as false after dispose', () async {
      await service.dispose();
      expect(service.isPlaying, false);
    });

    // Note: play()의 실제 오디오 재생은 통합 테스트에서 검증.
    // just_audio AudioPlayer는 네이티브 플랫폼 의존이므로
    // 유닛 테스트에서는 생성/dispose 안전성만 검증한다.
  });

  group('TtsService.audioUrl', () {
    test('should construct R2 URL with pack subfolder from audioId', () {
      expect(
        TtsService.audioUrl('birthday_hello'),
        'https://tts.tigerroom.app/ko/birthday/birthday_hello.mp3',
      );
    });

    test('should handle audioId with multiple underscores', () {
      expect(
        TtsService.audioUrl('comeback_cheer_up'),
        'https://tts.tigerroom.app/ko/comeback/comeback_cheer_up.mp3',
      );
    });

    test('should handle audioId with single segment (no underscore)', () {
      expect(
        TtsService.audioUrl('hello'),
        'https://tts.tigerroom.app/ko/hello/hello.mp3',
      );
    });
  });
}
