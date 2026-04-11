import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:fangeul/presentation/constants/app_constants.dart';

/// TTS 재생 서비스.
///
/// just_audio [AudioPlayer]를 래핑하여 한국어 발음 재생을 관리한다.
/// 번들된 에셋 또는 원격 URL에서 오디오를 재생한다.
///
/// 매 재생마다 새 [AudioPlayer] 인스턴스를 생성하여
/// 이전 재생의 상태가 간섭하지 않도록 보장한다.
class TtsService {
  static const _baseUrl = AppConstants.ttsCdnBaseUrl;

  AudioPlayer? _player;

  /// [audioId]를 R2 CDN URL로 변환한다.
  ///
  /// 팩 접두사(`_` 기준 첫 세그먼트)로 서브폴더를 결정한다.
  /// 예: `"birthday_hello"` → `https://tts.tigerroom.app/ko/birthday/birthday_hello.mp3`
  static String audioUrl(String audioId) {
    final pack = audioId.split('_').first;
    return '$_baseUrl/$pack/$audioId.mp3';
  }

  /// [audioId]로 재생한다. 로컬 캐시 우선, 없으면 R2 스트리밍 + 백그라운드 캐싱.
  ///
  /// 캐시된 파일이 있으면 로컬 파일을 재생하고,
  /// 없으면 R2 URL을 스트리밍하면서 백그라운드로 캐싱한다.
  Future<void> playById(String audioId) async {
    final file = await _cachedFile(audioId);
    if (file.existsSync()) {
      await play(file.path);
    } else {
      final url = audioUrl(audioId);
      await play(url);
      _cacheInBackground(audioId, url);
    }
  }

  /// 오디오 URL, 로컬 파일 경로, 또는 에셋 경로로 재생한다.
  ///
  /// [source]가 `http`로 시작하면 원격 URL로,
  /// `/`로 시작하면 로컬 파일 경로로,
  /// 그 외에는 번들 에셋 경로로 처리한다.
  /// 이전 플레이어가 있으면 dispose 후 새로 생성한다.
  ///
  /// 에러 발생 시 debugPrint로 로깅하고 예외를 재전파한다.
  Future<void> play(String source) async {
    await _disposePlayer();
    _player = AudioPlayer();
    try {
      if (source.startsWith('http')) {
        await _player!.setUrl(source);
      } else if (source.startsWith('/')) {
        await _player!.setFilePath(source);
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
  Future<void> dispose() async {
    await _disposePlayer();
  }

  /// [audioId]에 대응하는 로컬 캐시 파일을 반환한다.
  Future<File> _cachedFile(String audioId) async {
    final dir = await getApplicationCacheDirectory();
    return File('${dir.path}/tts/$audioId.mp3');
  }

  /// [url]의 오디오를 백그라운드에서 로컬 캐시로 저장한다.
  ///
  /// `.tmp` 파일에 먼저 쓴 뒤 atomic rename하여
  /// 네트워크 실패 시 부분 기록된 mp3가 캐시에 남지 않도록 한다.
  /// 캐싱 실패는 무시한다 — 다음 재생 시 다시 스트리밍된다.
  Future<void> _cacheInBackground(String audioId, String url) async {
    try {
      final file = await _cachedFile(audioId);
      if (file.existsSync()) return;
      await file.parent.create(recursive: true);
      final tmpFile = File('${file.path}.tmp');
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse(url));
        final response = await request.close();
        await response.pipe(tmpFile.openWrite());
        await tmpFile.rename(file.path);
      } finally {
        client.close();
        try {
          if (await tmpFile.exists()) await tmpFile.delete();
        } catch (_) {}
      }
    } catch (_) {
      // 캐싱 실패는 무시 — 다음에 다시 스트리밍
    }
  }

  /// 기존 플레이어를 안전하게 dispose한다.
  Future<void> _disposePlayer() async {
    final old = _player;
    _player = null;
    await old?.dispose();
  }
}
