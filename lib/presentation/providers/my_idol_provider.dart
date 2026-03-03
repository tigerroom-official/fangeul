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
  static const _memberKey = 'my_idol_member_name';

  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getString(_key);
  }

  /// 마이 아이돌 그룹을 선택한다.
  ///
  /// [build]가 아직 실행 중이면 완료될 때까지 기다린 후 state를 설정한다.
  /// Riverpod의 AsyncNotifier는 수동 state 설정 후에도 build() 완료 시
  /// 반환값으로 state를 덮어쓰므로, build 완료를 보장해야 한다.
  Future<void> select(String groupId) async {
    try {
      await future;
    } catch (_) {}
    state = AsyncData(groupId);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, groupId);
    } catch (e) {
      debugPrint('MyIdolNotifier: save failed — $e');
    }
  }

  /// 마이 아이돌 선택을 초기화한다.
  ///
  /// 그룹 ID와 멤버명 모두 삭제한다.
  Future<void> clear() async {
    try {
      await future;
    } catch (_) {}
    state = const AsyncData(null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      await prefs.remove(_memberKey);
    } catch (e) {
      debugPrint('MyIdolNotifier: clear failed — $e');
    }
  }

  /// 멤버명을 저장한다.
  Future<void> selectMember(String memberName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_memberKey, memberName);
    } catch (e) {
      debugPrint('MyIdolNotifier: save member failed — $e');
    }
  }

  /// 멤버명을 삭제한다.
  Future<void> clearMember() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_memberKey);
    } catch (e) {
      debugPrint('MyIdolNotifier: clear member failed — $e');
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
/// 커스텀 입력은 `"custom:그룹명"` 형태로 저장된다.
@riverpod
Future<String?> myIdolDisplayName(MyIdolDisplayNameRef ref) async {
  final groupId = await ref.watch(myIdolNotifierProvider.future);
  if (groupId == null) return null;

  // 커스텀 입력: "custom:그룹명" 형태
  if (groupId.startsWith('custom:')) {
    return groupId.substring(7);
  }

  final groups = await ref.watch(availableGroupsProvider.future);
  final group = groups.where((g) => g.id == groupId).firstOrNull;
  return group?.nameEn;
}

/// 현재 설정된 멤버명.
///
/// 멤버 전용 템플릿 치환에 사용. 그룹 미설정이면 null 반환.
@riverpod
Future<String?> myIdolMemberName(MyIdolMemberNameRef ref) async {
  final groupId = await ref.watch(myIdolNotifierProvider.future);
  if (groupId == null) return null;

  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  return prefs.getString('my_idol_member_name');
}
