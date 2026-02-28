import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  /// 초기 로드 완료 future. save가 로드 완료 후에만 실행되도록 게이트 역할.
  late final Future<void> _loaded;

  @override
  List<String> build() {
    _loaded = _loadFromPrefs();
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);
      if (json != null) {
        final saved = (jsonDecode(json) as List).cast<String>();
        // merge: 현재 state(로드 중 추가된 항목)를 앞에, 저장 데이터를 뒤에
        // 중복 제거 + _maxEntries 제한
        final merged = [...state];
        for (final item in saved) {
          if (!merged.contains(item)) {
            merged.add(item);
          }
        }
        state = merged.length > _maxEntries
            ? merged.sublist(0, _maxEntries)
            : merged;
      }
    } catch (e) {
      debugPrint('CopyHistoryNotifier: load failed — $e');
    }
  }

  Future<void> _saveToPrefs() async {
    // 로드 완료 대기 — 로드 전 save가 원본 데이터를 덮어쓰는 것을 방지
    await _loaded;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }
}
