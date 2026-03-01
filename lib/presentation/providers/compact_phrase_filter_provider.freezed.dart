// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compact_phrase_filter_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CompactPhraseFilter {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() favorites,
    required TResult Function(String packId) pack,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? favorites,
    TResult? Function(String packId)? pack,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? favorites,
    TResult Function(String packId)? pack,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Favorites value) favorites,
    required TResult Function(_Pack value) pack,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Favorites value)? favorites,
    TResult? Function(_Pack value)? pack,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Favorites value)? favorites,
    TResult Function(_Pack value)? pack,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompactPhraseFilterCopyWith<$Res> {
  factory $CompactPhraseFilterCopyWith(
          CompactPhraseFilter value, $Res Function(CompactPhraseFilter) then) =
      _$CompactPhraseFilterCopyWithImpl<$Res, CompactPhraseFilter>;
}

/// @nodoc
class _$CompactPhraseFilterCopyWithImpl<$Res, $Val extends CompactPhraseFilter>
    implements $CompactPhraseFilterCopyWith<$Res> {
  _$CompactPhraseFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompactPhraseFilter
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FavoritesImplCopyWith<$Res> {
  factory _$$FavoritesImplCopyWith(
          _$FavoritesImpl value, $Res Function(_$FavoritesImpl) then) =
      __$$FavoritesImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FavoritesImplCopyWithImpl<$Res>
    extends _$CompactPhraseFilterCopyWithImpl<$Res, _$FavoritesImpl>
    implements _$$FavoritesImplCopyWith<$Res> {
  __$$FavoritesImplCopyWithImpl(
      _$FavoritesImpl _value, $Res Function(_$FavoritesImpl) _then)
      : super(_value, _then);

  /// Create a copy of CompactPhraseFilter
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FavoritesImpl with DiagnosticableTreeMixin implements _Favorites {
  const _$FavoritesImpl();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CompactPhraseFilter.favorites()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CompactPhraseFilter.favorites'));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FavoritesImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() favorites,
    required TResult Function(String packId) pack,
  }) {
    return favorites();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? favorites,
    TResult? Function(String packId)? pack,
  }) {
    return favorites?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? favorites,
    TResult Function(String packId)? pack,
    required TResult orElse(),
  }) {
    if (favorites != null) {
      return favorites();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Favorites value) favorites,
    required TResult Function(_Pack value) pack,
  }) {
    return favorites(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Favorites value)? favorites,
    TResult? Function(_Pack value)? pack,
  }) {
    return favorites?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Favorites value)? favorites,
    TResult Function(_Pack value)? pack,
    required TResult orElse(),
  }) {
    if (favorites != null) {
      return favorites(this);
    }
    return orElse();
  }
}

abstract class _Favorites implements CompactPhraseFilter {
  const factory _Favorites() = _$FavoritesImpl;
}

/// @nodoc
abstract class _$$PackImplCopyWith<$Res> {
  factory _$$PackImplCopyWith(
          _$PackImpl value, $Res Function(_$PackImpl) then) =
      __$$PackImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String packId});
}

/// @nodoc
class __$$PackImplCopyWithImpl<$Res>
    extends _$CompactPhraseFilterCopyWithImpl<$Res, _$PackImpl>
    implements _$$PackImplCopyWith<$Res> {
  __$$PackImplCopyWithImpl(_$PackImpl _value, $Res Function(_$PackImpl) _then)
      : super(_value, _then);

  /// Create a copy of CompactPhraseFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packId = null,
  }) {
    return _then(_$PackImpl(
      null == packId
          ? _value.packId
          : packId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$PackImpl with DiagnosticableTreeMixin implements _Pack {
  const _$PackImpl(this.packId);

  @override
  final String packId;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CompactPhraseFilter.pack(packId: $packId)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CompactPhraseFilter.pack'))
      ..add(DiagnosticsProperty('packId', packId));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackImpl &&
            (identical(other.packId, packId) || other.packId == packId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, packId);

  /// Create a copy of CompactPhraseFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PackImplCopyWith<_$PackImpl> get copyWith =>
      __$$PackImplCopyWithImpl<_$PackImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() favorites,
    required TResult Function(String packId) pack,
  }) {
    return pack(packId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? favorites,
    TResult? Function(String packId)? pack,
  }) {
    return pack?.call(packId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? favorites,
    TResult Function(String packId)? pack,
    required TResult orElse(),
  }) {
    if (pack != null) {
      return pack(packId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Favorites value) favorites,
    required TResult Function(_Pack value) pack,
  }) {
    return pack(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Favorites value)? favorites,
    TResult? Function(_Pack value)? pack,
  }) {
    return pack?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Favorites value)? favorites,
    TResult Function(_Pack value)? pack,
    required TResult orElse(),
  }) {
    if (pack != null) {
      return pack(this);
    }
    return orElse();
  }
}

abstract class _Pack implements CompactPhraseFilter {
  const factory _Pack(final String packId) = _$PackImpl;

  String get packId;

  /// Create a copy of CompactPhraseFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PackImplCopyWith<_$PackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
