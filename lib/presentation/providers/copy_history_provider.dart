import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'copy_history_provider.g.dart';

/// 복사 이력 Provider.
///
/// 최근 복사한 텍스트를 시간순(최신 우선)으로 관리한다.
/// 최대 20개까지 유지하며, shared_preferences에 persist.
@riverpod
class CopyHistoryNotifier extends _$CopyHistoryNotifier {
  static const _key = 'copy_history';
  static const _maxEntries = 20;

  @override
  List<String> build() {
    _loadFromPrefs();
    return [];
  }

  /// 새 항목을 이력 앞에 추가한다.
  ///
  /// 이미 존재하는 항목이면 앞으로 이동.
  /// 최대 [_maxEntries]개 유지.
  void addEntry(String text) {
    if (text.isEmpty) return;

    final current = [...state];
    current.remove(text);
    current.insert(0, text);

    if (current.length > _maxEntries) {
      state = current.sublist(0, _maxEntries);
    } else {
      state = current;
    }
    _saveToPrefs();
  }

  /// 모든 이력을 삭제한다.
  void clearAll() {
    state = [];
    _saveToPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      final list = (jsonDecode(json) as List).cast<String>();
      state = list;
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }
}
