// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_idol_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableGroupsHash() => r'12f82b756ce8623949b25b1da83ebe6901b1c942';

/// 사용 가능한 그룹 목록 (assets/groups/groups.json 로드).
///
/// Copied from [availableGroups].
@ProviderFor(availableGroups)
final availableGroupsProvider = FutureProvider<List<IdolGroup>>.internal(
  availableGroups,
  name: r'availableGroupsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableGroupsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableGroupsRef = FutureProviderRef<List<IdolGroup>>;
String _$myIdolDisplayNameHash() => r'fe05eb9cfaca39da1e0d7d19c748cc683b6b8052';

/// 현재 선택된 그룹의 표시 이름 (name_en).
///
/// 템플릿 치환에 사용. 미설정 시 null.
/// 커스텀 입력은 `"custom:그룹명"` 형태로 저장된다.
///
/// Copied from [myIdolDisplayName].
@ProviderFor(myIdolDisplayName)
final myIdolDisplayNameProvider = AutoDisposeFutureProvider<String?>.internal(
  myIdolDisplayName,
  name: r'myIdolDisplayNameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myIdolDisplayNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyIdolDisplayNameRef = AutoDisposeFutureProviderRef<String?>;
String _$myIdolMemberNameHash() => r'8bc1ba36549f19296c4a8d811b72f96dbafce5e3';

/// 현재 설정된 멤버명.
///
/// 멤버 전용 템플릿 치환에 사용. 그룹 미설정이면 null 반환.
///
/// **반응성 제약:** 이 provider는 [myIdolNotifierProvider](그룹 ID)만 watch한다.
/// [MyIdolNotifier.selectMember]만 단독 호출하면 이 provider가 갱신되지 않는다.
/// 현재 IdolSelectScreen은 `select()` + `selectMember()`를 항상 함께 호출하므로
/// 문제없지만, 향후 "멤버만 변경" 시나리오 추가 시 invalidation 처리 필요.
///
/// Copied from [myIdolMemberName].
@ProviderFor(myIdolMemberName)
final myIdolMemberNameProvider = AutoDisposeFutureProvider<String?>.internal(
  myIdolMemberName,
  name: r'myIdolMemberNameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myIdolMemberNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyIdolMemberNameRef = AutoDisposeFutureProviderRef<String?>;
String _$myIdolNotifierHash() => r'77d67f583bb2eae5c8427e1977aef391043f92ea';

/// 마이 아이돌 선택 Notifier.
///
/// SharedPreferences에 선택된 그룹 ID를 저장한다.
/// 듀얼 FlutterEngine 환경에서 cross-engine sync를 위해 `prefs.reload()` 수행.
///
/// Copied from [MyIdolNotifier].
@ProviderFor(MyIdolNotifier)
final myIdolNotifierProvider =
    AsyncNotifierProvider<MyIdolNotifier, String?>.internal(
  MyIdolNotifier.new,
  name: r'myIdolNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myIdolNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MyIdolNotifier = AsyncNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
