import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:fangeul/core/entities/phrase_pack.dart';

/// 로컬 에셋에서 문구 팩 JSON을 로드하는 데이터소스.
///
/// `assets/phrases/` 디렉토리의 JSON 파일을 파싱하여 [PhrasePack] 목록으로 변환.
/// 앱 생명주기 동안 메모리 캐시를 유지하여 중복 로드를 방지한다.
class PhraseLocalDataSource {
  final AssetBundle _assetBundle;

  /// 메모리 캐시 — packId → PhrasePack
  final Map<String, PhrasePack> _cache = {};

  /// 전체 로드 완료 여부
  bool _allLoaded = false;

  /// 에셋에 존재하는 팩 ID 목록 (매니페스트에서 탐색)
  static const List<String> knownPackIds = [
    'basic_love',
    'birthday_pack',
    'comeback_pack',
    'daily_pack',
    'my_idol_pack',
  ];

  PhraseLocalDataSource({AssetBundle? assetBundle})
      : _assetBundle = assetBundle ?? rootBundle;

  /// 모든 문구 팩을 로드한다.
  ///
  /// 캐시된 경우 캐시에서 반환.
  Future<List<PhrasePack>> getAllPacks() async {
    if (_allLoaded) {
      return _cache.values.toList();
    }

    for (final packId in knownPackIds) {
      if (!_cache.containsKey(packId)) {
        final pack = await _loadPack(packId);
        if (pack != null) {
          _cache[packId] = pack;
        }
      }
    }

    _allLoaded = true;
    return _cache.values.toList();
  }

  /// ID로 특정 문구 팩을 로드한다.
  Future<PhrasePack?> getPackById(String packId) async {
    if (_cache.containsKey(packId)) {
      return _cache[packId];
    }

    final pack = await _loadPack(packId);
    if (pack != null) {
      _cache[packId] = pack;
    }
    return pack;
  }

  Future<PhrasePack?> _loadPack(String packId) async {
    try {
      final jsonStr =
          await _assetBundle.loadString('assets/phrases/$packId.json');
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return PhrasePack.fromJson(json);
    } catch (e) {
      return null;
    }
  }
}
