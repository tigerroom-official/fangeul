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
String _$canPlayTtsHash() => r'f5656d02dea5503c97da7a6a5ae415131d70bbed';

/// TTS 재생 가능 여부 편의 Provider.
///
/// 허니문 중이면 무제한. 그 외에는 일일 5회 제한
/// ([MonetizationNotifier.dailyTtsLimit]). 해금 경로는 IAP만.
///
/// Copied from [canPlayTts].
@ProviderFor(canPlayTts)
final canPlayTtsProvider = AutoDisposeProvider<bool>.internal(
  canPlayTts,
  name: r'canPlayTtsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$canPlayTtsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CanPlayTtsRef = AutoDisposeProviderRef<bool>;
String _$playTtsHash() => r'5d3f7c08d16d0fc88ec1b510921f45dbc1f8302e';

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
/// 일일 제한 확인 → 카운트 기록 → 재생 순서로 진행.
/// 허니문/보상형 해금 활성 시 카운트를 소모하지 않고 무제한 재생.
/// 제한 도달 시 false를 반환하고 재생하지 않는다.
///
/// [source]는 에셋 경로('assets/audio/...')  또는 원격 URL.
///
/// Copied from [playTts].
@ProviderFor(playTts)
const playTtsProvider = PlayTtsFamily();

/// TTS 재생을 시도한다.
///
/// 일일 제한 확인 → 카운트 기록 → 재생 순서로 진행.
/// 허니문/보상형 해금 활성 시 카운트를 소모하지 않고 무제한 재생.
/// 제한 도달 시 false를 반환하고 재생하지 않는다.
///
/// [source]는 에셋 경로('assets/audio/...')  또는 원격 URL.
///
/// Copied from [playTts].
class PlayTtsFamily extends Family<AsyncValue<bool>> {
  /// TTS 재생을 시도한다.
  ///
  /// 일일 제한 확인 → 카운트 기록 → 재생 순서로 진행.
  /// 허니문/보상형 해금 활성 시 카운트를 소모하지 않고 무제한 재생.
  /// 제한 도달 시 false를 반환하고 재생하지 않는다.
  ///
  /// [source]는 에셋 경로('assets/audio/...')  또는 원격 URL.
  ///
  /// Copied from [playTts].
  const PlayTtsFamily();

  /// TTS 재생을 시도한다.
  ///
  /// 일일 제한 확인 → 카운트 기록 → 재생 순서로 진행.
  /// 허니문/보상형 해금 활성 시 카운트를 소모하지 않고 무제한 재생.
  /// 제한 도달 시 false를 반환하고 재생하지 않는다.
  ///
  /// [source]는 에셋 경로('assets/audio/...')  또는 원격 URL.
  ///
  /// Copied from [playTts].
  PlayTtsProvider call(
    String source,
  ) {
    return PlayTtsProvider(
      source,
    );
  }

  @override
  PlayTtsProvider getProviderOverride(
    covariant PlayTtsProvider provider,
  ) {
    return call(
      provider.source,
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
/// 일일 제한 확인 → 카운트 기록 → 재생 순서로 진행.
/// 허니문/보상형 해금 활성 시 카운트를 소모하지 않고 무제한 재생.
/// 제한 도달 시 false를 반환하고 재생하지 않는다.
///
/// [source]는 에셋 경로('assets/audio/...')  또는 원격 URL.
///
/// Copied from [playTts].
class PlayTtsProvider extends AutoDisposeFutureProvider<bool> {
  /// TTS 재생을 시도한다.
  ///
  /// 일일 제한 확인 → 카운트 기록 → 재생 순서로 진행.
  /// 허니문/보상형 해금 활성 시 카운트를 소모하지 않고 무제한 재생.
  /// 제한 도달 시 false를 반환하고 재생하지 않는다.
  ///
  /// [source]는 에셋 경로('assets/audio/...')  또는 원격 URL.
  ///
  /// Copied from [playTts].
  PlayTtsProvider(
    String source,
  ) : this._internal(
          (ref) => playTts(
            ref as PlayTtsRef,
            source,
          ),
          from: playTtsProvider,
          name: r'playTtsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$playTtsHash,
          dependencies: PlayTtsFamily._dependencies,
          allTransitiveDependencies: PlayTtsFamily._allTransitiveDependencies,
          source: source,
        );

  PlayTtsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.source,
  }) : super.internal();

  final String source;

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
        source: source,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _PlayTtsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayTtsProvider && other.source == source;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, source.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlayTtsRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `source` of this provider.
  String get source;
}

class _PlayTtsProviderElement extends AutoDisposeFutureProviderElement<bool>
    with PlayTtsRef {
  _PlayTtsProviderElement(super.provider);

  @override
  String get source => (origin as PlayTtsProvider).source;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
