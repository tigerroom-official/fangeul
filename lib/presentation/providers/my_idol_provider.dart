import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/core/entities/idol_group.dart';

part 'my_idol_provider.g.dart';

/// 마이 아이돌 선택 Notifier.
///
/// SharedPreferences에 선택된 그룹 ID를 저장한다.
/// 듀얼 FlutterEngine 환경에서 cross-engine sync를 위해 `prefs.reload()` 수행.
@Riverpod(keepAlive: true)
class MyIdolNotifier extends _$MyIdolNotifier {
  static const _key = 'my_idol_group_id';

  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getString(_key);
  }

  /// 마이 아이돌 그룹을 선택한다.
  Future<void> select(String groupId) async {
    state = AsyncData(groupId);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, groupId);
    } catch (e) {
      debugPrint('MyIdolNotifier: save failed — $e');
    }
  }

  /// 마이 아이돌 선택을 초기화한다.
  Future<void> clear() async {
    state = const AsyncData(null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      debugPrint('MyIdolNotifier: clear failed — $e');
    }
  }
}

/// 사용 가능한 그룹 목록 (assets/groups/groups.json 로드).
@Riverpod(keepAlive: true)
Future<List<IdolGroup>> availableGroups(AvailableGroupsRef ref) async {
  final jsonStr = await rootBundle.loadString('assets/groups/groups.json');
  final data = json.decode(jsonStr) as Map<String, dynamic>;
  final list = data['groups'] as List<dynamic>;
  return list
      .map((e) => IdolGroup.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// 현재 선택된 그룹의 표시 이름 (name_en).
///
/// 템플릿 치환에 사용. 미설정 시 null.
@riverpod
Future<String?> myIdolDisplayName(MyIdolDisplayNameRef ref) async {
  final groupId = await ref.watch(myIdolNotifierProvider.future);
  if (groupId == null) return null;

  final groups = await ref.watch(availableGroupsProvider.future);
  final group = groups.where((g) => g.id == groupId).firstOrNull;
  return group?.nameEn;
}
