import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// TTS 재생 서비스.
///
/// just_audio [AudioPlayer]를 래핑하여 한국어 발음 재생을 관리한다.
/// 번들된 에셋 또는 원격 URL에서 오디오를 재생한다.
///
/// 매 재생마다 새 [AudioPlayer] 인스턴스를 생성하여
/// 이전 재생의 상태가 간섭하지 않도록 보장한다.
class TtsService {
  AudioPlayer? _player;

  /// 오디오 URL 또는 에셋 경로로 재생한다.
  ///
  /// [source]가 `http`로 시작하면 원격 URL로,
  /// 그렇지 않으면 번들 에셋 경로로 처리한다.
  /// 이전 플레이어가 있으면 dispose 후 새로 생성한다.
  ///
  /// 에러 발생 시 debugPrint로 로깅하고 예외를 재전파한다.
  Future<void> play(String source) async {
    await _disposePlayer();
    _player = AudioPlayer();
    try {
      if (source.startsWith('http')) {
        await _player!.setUrl(source);
      } else {
        await _player!.setAsset(source);
      }
      await _player!.play();
    } catch (e) {
      debugPrint('[TtsService] play failed — $e');
      rethrow;
    }
  }

  /// 재생 중지.
  ///
  /// 플레이어가 없으면 아무 동작도 하지 않는다.
  Future<void> stop() async {
    await _player?.stop();
  }

  /// 현재 재생 중인지.
  bool get isPlaying => _player?.playing ?? false;

  /// 리소스 해제.
  ///
  /// Provider dispose 시 호출하여 네이티브 리소스를 정리한다.
  void dispose() {
    _player?.dispose();
    _player = null;
  }

  /// 기존 플레이어를 안전하게 dispose한다.
  Future<void> _disposePlayer() async {
    final old = _player;
    _player = null;
    old?.dispose();
  }
}
