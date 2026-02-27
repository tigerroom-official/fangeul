// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$phraseLocalDataSourceHash() =>
    r'4639857fc11b9fae87960c8d5482faabf990f599';

/// See also [phraseLocalDataSource].
@ProviderFor(phraseLocalDataSource)
final phraseLocalDataSourceProvider =
    AutoDisposeProvider<PhraseLocalDataSource>.internal(
  phraseLocalDataSource,
  name: r'phraseLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$phraseLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PhraseLocalDataSourceRef
    = AutoDisposeProviderRef<PhraseLocalDataSource>;
String _$phraseRepositoryHash() => r'021af2110e2cb4ca7089eded870065ebde9435df';

/// See also [phraseRepository].
@ProviderFor(phraseRepository)
final phraseRepositoryProvider = AutoDisposeProvider<PhraseRepository>.internal(
  phraseRepository,
  name: r'phraseRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$phraseRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PhraseRepositoryRef = AutoDisposeProviderRef<PhraseRepository>;
String _$getPhrasesUseCaseHash() => r'9cd1ccfc1818baffe3e7b1162daed3ad86b8055c';

/// See also [getPhrasesUseCase].
@ProviderFor(getPhrasesUseCase)
final getPhrasesUseCaseProvider =
    AutoDisposeProvider<GetPhrasesUseCase>.internal(
  getPhrasesUseCase,
  name: r'getPhrasesUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getPhrasesUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetPhrasesUseCaseRef = AutoDisposeProviderRef<GetPhrasesUseCase>;
String _$getPhrasesByTagUseCaseHash() =>
    r'53bd9fd0a066c971ad7618ec0851b7bd279a35fe';

/// See also [getPhrasesByTagUseCase].
@ProviderFor(getPhrasesByTagUseCase)
final getPhrasesByTagUseCaseProvider =
    AutoDisposeProvider<GetPhrasesByTagUseCase>.internal(
  getPhrasesByTagUseCase,
  name: r'getPhrasesByTagUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getPhrasesByTagUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetPhrasesByTagUseCaseRef
    = AutoDisposeProviderRef<GetPhrasesByTagUseCase>;
String _$getDailyCardUseCaseHash() =>
    r'15032703adef096b0169750b968ed7789c6f0b95';

/// See also [getDailyCardUseCase].
@ProviderFor(getDailyCardUseCase)
final getDailyCardUseCaseProvider =
    AutoDisposeProvider<GetDailyCardUseCase>.internal(
  getDailyCardUseCase,
  name: r'getDailyCardUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getDailyCardUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetDailyCardUseCaseRef = AutoDisposeProviderRef<GetDailyCardUseCase>;
String _$allPhrasesHash() => r'de95cbb02063d02535b3cff1d0606adadc380cfd';

/// 전체 문구 팩 목록
///
/// Copied from [allPhrases].
@ProviderFor(allPhrases)
final allPhrasesProvider = AutoDisposeFutureProvider<List<PhrasePack>>.internal(
  allPhrases,
  name: r'allPhrasesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allPhrasesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllPhrasesRef = AutoDisposeFutureProviderRef<List<PhrasePack>>;
String _$phrasesByTagHash() => r'dc9b28a270a0170b03481e7de1e5c02c17519624';

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

/// 태그별 문구 필터
///
/// Copied from [phrasesByTag].
@ProviderFor(phrasesByTag)
const phrasesByTagProvider = PhrasesByTagFamily();

/// 태그별 문구 필터
///
/// Copied from [phrasesByTag].
class PhrasesByTagFamily extends Family<AsyncValue<List<Phrase>>> {
  /// 태그별 문구 필터
  ///
  /// Copied from [phrasesByTag].
  const PhrasesByTagFamily();

  /// 태그별 문구 필터
  ///
  /// Copied from [phrasesByTag].
  PhrasesByTagProvider call(
    String tag,
  ) {
    return PhrasesByTagProvider(
      tag,
    );
  }

  @override
  PhrasesByTagProvider getProviderOverride(
    covariant PhrasesByTagProvider provider,
  ) {
    return call(
      provider.tag,
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
  String? get name => r'phrasesByTagProvider';
}

/// 태그별 문구 필터
///
/// Copied from [phrasesByTag].
class PhrasesByTagProvider extends AutoDisposeFutureProvider<List<Phrase>> {
  /// 태그별 문구 필터
  ///
  /// Copied from [phrasesByTag].
  PhrasesByTagProvider(
    String tag,
  ) : this._internal(
          (ref) => phrasesByTag(
            ref as PhrasesByTagRef,
            tag,
          ),
          from: phrasesByTagProvider,
          name: r'phrasesByTagProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$phrasesByTagHash,
          dependencies: PhrasesByTagFamily._dependencies,
          allTransitiveDependencies:
              PhrasesByTagFamily._allTransitiveDependencies,
          tag: tag,
        );

  PhrasesByTagProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tag,
  }) : super.internal();

  final String tag;

  @override
  Override overrideWith(
    FutureOr<List<Phrase>> Function(PhrasesByTagRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PhrasesByTagProvider._internal(
        (ref) => create(ref as PhrasesByTagRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tag: tag,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Phrase>> createElement() {
    return _PhrasesByTagProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PhrasesByTagProvider && other.tag == tag;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tag.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PhrasesByTagRef on AutoDisposeFutureProviderRef<List<Phrase>> {
  /// The parameter `tag` of this provider.
  String get tag;
}

class _PhrasesByTagProviderElement
    extends AutoDisposeFutureProviderElement<List<Phrase>>
    with PhrasesByTagRef {
  _PhrasesByTagProviderElement(super.provider);

  @override
  String get tag => (origin as PhrasesByTagProvider).tag;
}

String _$dailyCardHash() => r'2717a654a80fce36116cc175dab30242e7c95869';

/// 오늘의 카드
///
/// Copied from [dailyCard].
@ProviderFor(dailyCard)
const dailyCardProvider = DailyCardFamily();

/// 오늘의 카드
///
/// Copied from [dailyCard].
class DailyCardFamily extends Family<AsyncValue<DailyCard?>> {
  /// 오늘의 카드
  ///
  /// Copied from [dailyCard].
  const DailyCardFamily();

  /// 오늘의 카드
  ///
  /// Copied from [dailyCard].
  DailyCardProvider call(
    String date,
  ) {
    return DailyCardProvider(
      date,
    );
  }

  @override
  DailyCardProvider getProviderOverride(
    covariant DailyCardProvider provider,
  ) {
    return call(
      provider.date,
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
  String? get name => r'dailyCardProvider';
}

/// 오늘의 카드
///
/// Copied from [dailyCard].
class DailyCardProvider extends AutoDisposeFutureProvider<DailyCard?> {
  /// 오늘의 카드
  ///
  /// Copied from [dailyCard].
  DailyCardProvider(
    String date,
  ) : this._internal(
          (ref) => dailyCard(
            ref as DailyCardRef,
            date,
          ),
          from: dailyCardProvider,
          name: r'dailyCardProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dailyCardHash,
          dependencies: DailyCardFamily._dependencies,
          allTransitiveDependencies: DailyCardFamily._allTransitiveDependencies,
          date: date,
        );

  DailyCardProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final String date;

  @override
  Override overrideWith(
    FutureOr<DailyCard?> Function(DailyCardRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DailyCardProvider._internal(
        (ref) => create(ref as DailyCardRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DailyCard?> createElement() {
    return _DailyCardProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyCardProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DailyCardRef on AutoDisposeFutureProviderRef<DailyCard?> {
  /// The parameter `date` of this provider.
  String get date;
}

class _DailyCardProviderElement
    extends AutoDisposeFutureProviderElement<DailyCard?> with DailyCardRef {
  _DailyCardProviderElement(super.provider);

  @override
  String get date => (origin as DailyCardProvider).date;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
