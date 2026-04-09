// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ttsServiceHash() => r'a08a6921cd67b3920f0affe7ded798623d538315';

/// TtsService 인스턴스 Provider.
///
/// 앱 전체에서 단일 인스턴스를 공유한다.
/// 테스트에서 mock으로 override 가능.
///
/// Copied from [ttsService].
@ProviderFor(ttsService)
final ttsServiceProvider = Provider<TtsService>.internal(
  ttsService,
  name: r'ttsServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$ttsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TtsServiceRef = ProviderRef<TtsService>;
String _$playTtsHash() => r'db020b70741da2e6e9f558420606b9256547029b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// TTS 재생을 시도한다.
///
/// [TtsService.playById]로 재생한다.
/// 같은 세션 내 동일 audioId 재재생 시 카운트를 소모하지 않는다.
/// 제한 도달 시 false를 반환하고 재생하지 않는다.
/// 카운트는 재생 성공 후에만 소모된다 (네트워크 실패 시 쿼터 낭비 방지).
///
/// Copied from [playTts].
@ProviderFor(playTts)
const playTtsProvider = PlayTtsFamily();

/// TTS 재생을 시도한다.
///
/// [TtsService.playById]로 재생한다.
/// 같은 세션 내 동일 audioId 재재생 시 카운트를 소모하지 않는다.
/// 제한 도달 시 false를 반환하고 재생하지 않는다.
/// 카운트는 재생 성공 후에만 소모된다 (네트워크 실패 시 쿼터 낭비 방지).
///
/// Copied from [playTts].
class PlayTtsFamily extends Family<AsyncValue<bool>> {
  /// TTS 재생을 시도한다.
  ///
  /// [TtsService.playById]로 재생한다.
  /// 같은 세션 내 동일 audioId 재재생 시 카운트를 소모하지 않는다.
  /// 제한 도달 시 false를 반환하고 재생하지 않는다.
  /// 카운트는 재생 성공 후에만 소모된다 (네트워크 실패 시 쿼터 낭비 방지).
  ///
  /// Copied from [playTts].
  const PlayTtsFamily();

  /// TTS 재생을 시도한다.
  ///
  /// [TtsService.playById]로 재생한다.
  /// 같은 세션 내 동일 audioId 재재생 시 카운트를 소모하지 않는다.
  /// 제한 도달 시 false를 반환하고 재생하지 않는다.
  /// 카운트는 재생 성공 후에만 소모된다 (네트워크 실패 시 쿼터 낭비 방지).
  ///
  /// Copied from [playTts].
  PlayTtsProvider call(
    String audioId,
  ) {
    return PlayTtsProvider(
      audioId,
    );
  }

  @override
  PlayTtsProvider getProviderOverride(
    covariant PlayTtsProvider provider,
  ) {
    return call(
      provider.audioId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'playTtsProvider';
}

/// TTS 재생을 시도한다.
///
/// [TtsService.playById]로 재생한다.
/// 같은 세션 내 동일 audioId 재재생 시 카운트를 소모하지 않는다.
/// 제한 도달 시 false를 반환하고 재생하지 않는다.
/// 카운트는 재생 성공 후에만 소모된다 (네트워크 실패 시 쿼터 낭비 방지).
///
/// Copied from [playTts].
class PlayTtsProvider extends AutoDisposeFutureProvider<bool> {
  /// TTS 재생을 시도한다.
  ///
  /// [TtsService.playById]로 재생한다.
  /// 같은 세션 내 동일 audioId 재재생 시 카운트를 소모하지 않는다.
  /// 제한 도달 시 false를 반환하고 재생하지 않는다.
  /// 카운트는 재생 성공 후에만 소모된다 (네트워크 실패 시 쿼터 낭비 방지).
  ///
  /// Copied from [playTts].
  PlayTtsProvider(
    String audioId,
  ) : this._internal(
          (ref) => playTts(
            ref as PlayTtsRef,
            audioId,
          ),
          from: playTtsProvider,
          name: r'playTtsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$playTtsHash,
          dependencies: PlayTtsFamily._dependencies,
          allTransitiveDependencies: PlayTtsFamily._allTransitiveDependencies,
          audioId: audioId,
        );

  PlayTtsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.audioId,
  }) : super.internal();

  final String audioId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(PlayTtsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlayTtsProvider._internal(
        (ref) => create(ref as PlayTtsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        audioId: audioId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _PlayTtsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayTtsProvider && other.audioId == audioId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, audioId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlayTtsRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `audioId` of this provider.
  String get audioId;
}

class _PlayTtsProviderElement extends AutoDisposeFutureProviderElement<bool>
    with PlayTtsRef {
  _PlayTtsProviderElement(super.provider);

  @override
  String get audioId => (origin as PlayTtsProvider).audioId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
