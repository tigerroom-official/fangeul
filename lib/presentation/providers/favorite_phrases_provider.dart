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

  /// 초기 로드 완료 future. save가 로드 완료 후에만 실행되도록 게이트 역할.
  late final Future<void> _loaded;

  @override
  Set<String> build() {
    _loaded = _loadFromPrefs();
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
      final saved = (jsonDecode(json) as List).cast<String>().toSet();
      // merge: 저장된 데이터 + 로드 중 발생한 mutation 보존
      state = {...saved, ...state};
    }
  }

  Future<void> _saveToPrefs() async {
    // 로드 완료 대기 — 로드 전 save가 원본 데이터를 덮어쓰는 것을 방지
    await _loaded;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toList()));
  }
}
