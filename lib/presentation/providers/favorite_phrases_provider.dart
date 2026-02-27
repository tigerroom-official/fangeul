import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'favorite_phrases_provider.g.dart';

/// 즐겨찾기 문구 Provider.
///
/// 사용자가 탭한 문구의 한글(ko)을 Set으로 관리한다.
/// shared_preferences에 persist.
@riverpod
class FavoritePhrasesNotifier extends _$FavoritePhrasesNotifier {
  static const _key = 'favorite_phrases';

  @override
  Set<String> build() {
    _loadFromPrefs();
    return {};
  }

  /// 즐겨찾기 토글 -- 있으면 제거, 없으면 추가.
  void toggle(String phraseKo) {
    final current = {...state};
    if (current.contains(phraseKo)) {
      current.remove(phraseKo);
    } else {
      current.add(phraseKo);
    }
    state = current;
    _saveToPrefs();
  }

  /// 즐겨찾기 여부 확인.
  bool isFavorite(String phraseKo) => state.contains(phraseKo);

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      final list = (jsonDecode(json) as List).cast<String>();
      state = list.toSet();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toList()));
  }
}
