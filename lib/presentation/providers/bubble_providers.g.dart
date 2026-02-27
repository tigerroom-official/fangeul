// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bubble_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$floatingBubbleChannelHash() =>
    r'0e87b9119b4c20e0f7c6a2cf7ef8a0e90df80117';

/// FloatingBubbleChannel Provider.
///
/// Copied from [floatingBubbleChannel].
@ProviderFor(floatingBubbleChannel)
final floatingBubbleChannelProvider =
    AutoDisposeProvider<FloatingBubbleChannel>.internal(
  floatingBubbleChannel,
  name: r'floatingBubbleChannelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$floatingBubbleChannelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FloatingBubbleChannelRef
    = AutoDisposeProviderRef<FloatingBubbleChannel>;
String _$bubbleNotifierHash() => r'5f5be15e8e0127081ec2cafea0684ab51a8484aa';

/// 버블 상태 Notifier.
///
/// [FloatingBubbleChannel]을 통해 네이티브 버블 서비스를 제어하고
/// 현재 상태를 [BubbleState]로 관리한다.
///
/// Copied from [BubbleNotifier].
@ProviderFor(BubbleNotifier)
final bubbleNotifierProvider =
    AutoDisposeNotifierProvider<BubbleNotifier, BubbleState>.internal(
  BubbleNotifier.new,
  name: r'bubbleNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bubbleNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BubbleNotifier = AutoDisposeNotifier<BubbleState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
