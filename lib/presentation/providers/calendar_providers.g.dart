// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarLocalDataSourceHash() =>
    r'dc0a7285f930696d95c8d17f8bbbe44585e6e825';

/// See also [calendarLocalDataSource].
@ProviderFor(calendarLocalDataSource)
final calendarLocalDataSourceProvider =
    AutoDisposeProvider<CalendarLocalDataSource>.internal(
  calendarLocalDataSource,
  name: r'calendarLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalendarLocalDataSourceRef
    = AutoDisposeProviderRef<CalendarLocalDataSource>;
String _$calendarRepositoryHash() =>
    r'01481a55063338fb9c9ee2fdfc95ca9006509b46';

/// See also [calendarRepository].
@ProviderFor(calendarRepository)
final calendarRepositoryProvider =
    AutoDisposeProvider<CalendarRepository>.internal(
  calendarRepository,
  name: r'calendarRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalendarRepositoryRef = AutoDisposeProviderRef<CalendarRepository>;
String _$getTodayEventsUseCaseHash() =>
    r'7c6a8580ff3eef54117cb4af56bd1daf401267c7';

/// See also [getTodayEventsUseCase].
@ProviderFor(getTodayEventsUseCase)
final getTodayEventsUseCaseProvider =
    AutoDisposeProvider<GetTodayEventsUseCase>.internal(
  getTodayEventsUseCase,
  name: r'getTodayEventsUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getTodayEventsUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetTodayEventsUseCaseRef
    = AutoDisposeProviderRef<GetTodayEventsUseCase>;
String _$todayEventsHash() => r'a65a1995fafa23efa3bb8e8cc468b28aa5d23707';

/// 오늘의 K-pop 이벤트 목록
///
/// Copied from [todayEvents].
@ProviderFor(todayEvents)
final todayEventsProvider = AutoDisposeFutureProvider<List<KpopEvent>>.internal(
  todayEvents,
  name: r'todayEventsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todayEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayEventsRef = AutoDisposeFutureProviderRef<List<KpopEvent>>;
String _$todaySuggestedPhrasesHash() =>
    r'c519fd04744e22f9dba6f631962f1df827a12ace';

/// 오늘 이벤트 기반 추천 문구.
///
/// 마이 아이돌 설정 시 해당 그룹 이벤트만 필터링하고
/// 템플릿 문구의 `{{group_name}}`을 치환한다.
///
/// Copied from [todaySuggestedPhrases].
@ProviderFor(todaySuggestedPhrases)
final todaySuggestedPhrasesProvider =
    AutoDisposeFutureProvider<List<Phrase>>.internal(
  todaySuggestedPhrases,
  name: r'todaySuggestedPhrasesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todaySuggestedPhrasesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodaySuggestedPhrasesRef = AutoDisposeFutureProviderRef<List<Phrase>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
