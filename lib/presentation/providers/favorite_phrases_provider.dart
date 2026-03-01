import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'favorite_phrases_provider.g.dart';

/// 즐겨찾기 문구 Provider.
///
/// 사용자가 탭한 문구의 한글(ko)을 Set으로 관리한다.
/// SharedPreferences에서 비동기 로드하므로 AsyncNotifier로 구현.
/// 소비자는 `AsyncValue<Set<String>>`을 받아 로딩 완료를 자연스럽게 대기한다.
@riverpod
class FavoritePhrasesNotifier extends _$FavoritePhrasesNotifier {
  static const _key = 'favorite_phrases';

  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    // 별도 FlutterEngine(메인앱 엔진)에서 기록한 값을 읽기 위해
    // 플랫폼에서 최신 데이터를 다시 로드한다.
    await prefs.reload();
    final json = prefs.getString(_key);
    if (json != null) {
      return (jsonDecode(json) as List).cast<String>().toSet();
    }
    return {};
  }

  /// 즐겨찾기 토글 -- 있으면 제거, 없으면 추가.
  ///
  /// `build()` 완료를 대기한 뒤 변경하므로 로딩 중 호출해도 안전하다.
  Future<void> toggle(String phraseKo) async {
    final current = {...await future};
    if (current.contains(phraseKo)) {
      current.remove(phraseKo);
    } else {
      current.add(phraseKo);
    }
    state = AsyncData(current);
    _saveToPrefs(current);
  }

  /// 즐겨찾기 여부 확인.
  bool isFavorite(String phraseKo) =>
      (state.valueOrNull ?? {}).contains(phraseKo);

  Future<void> _saveToPrefs(Set<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(favorites.toList()));
    } catch (e) {
      debugPrint('FavoritePhrasesNotifier: save failed — $e');
    }
  }
}
