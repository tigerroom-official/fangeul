// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dday_gift_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ddayGiftEventHash() => r'3c09097bb4bd0ea45f1679432faa414c9854ca3b';

/// D-day 선물 대상 이벤트.
///
/// 오늘 유저의 마이 아이돌에 해당하는 이벤트가 있고,
/// 해당 이벤트에 대한 D-day 해금을 아직 수령하지 않은 경우
/// 해당 [KpopEvent]를 반환한다. 없으면 null.
///
/// 이 provider를 watch하여 값이 non-null이면 [showDdayGiftPopup]을 호출한다.
///
/// Copied from [ddayGiftEvent].
@ProviderFor(ddayGiftEvent)
final ddayGiftEventProvider = AutoDisposeFutureProvider<KpopEvent?>.internal(
  ddayGiftEvent,
  name: r'ddayGiftEventProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ddayGiftEventHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DdayGiftEventRef = AutoDisposeFutureProviderRef<KpopEvent?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
