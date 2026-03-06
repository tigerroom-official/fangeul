// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'choeae_color_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChoeaeColorConfig {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String packId) palette,
    required TResult Function(Color seedColor, Color? textColorOverride) custom,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String packId)? palette,
    TResult? Function(Color seedColor, Color? textColorOverride)? custom,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String packId)? palette,
    TResult Function(Color seedColor, Color? textColorOverride)? custom,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChoeaeColorPalette value) palette,
    required TResult Function(ChoeaeColorCustom value) custom,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChoeaeColorPalette value)? palette,
    TResult? Function(ChoeaeColorCustom value)? custom,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChoeaeColorPalette value)? palette,
    TResult Function(ChoeaeColorCustom value)? custom,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChoeaeColorConfigCopyWith<$Res> {
  factory $ChoeaeColorConfigCopyWith(
          ChoeaeColorConfig value, $Res Function(ChoeaeColorConfig) then) =
      _$ChoeaeColorConfigCopyWithImpl<$Res, ChoeaeColorConfig>;
}

/// @nodoc
class _$ChoeaeColorConfigCopyWithImpl<$Res, $Val extends ChoeaeColorConfig>
    implements $ChoeaeColorConfigCopyWith<$Res> {
  _$ChoeaeColorConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChoeaeColorConfig
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ChoeaeColorPaletteImplCopyWith<$Res> {
  factory _$$ChoeaeColorPaletteImplCopyWith(_$ChoeaeColorPaletteImpl value,
          $Res Function(_$ChoeaeColorPaletteImpl) then) =
      __$$ChoeaeColorPaletteImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String packId});
}

/// @nodoc
class __$$ChoeaeColorPaletteImplCopyWithImpl<$Res>
    extends _$ChoeaeColorConfigCopyWithImpl<$Res, _$ChoeaeColorPaletteImpl>
    implements _$$ChoeaeColorPaletteImplCopyWith<$Res> {
  __$$ChoeaeColorPaletteImplCopyWithImpl(_$ChoeaeColorPaletteImpl _value,
      $Res Function(_$ChoeaeColorPaletteImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChoeaeColorConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packId = null,
  }) {
    return _then(_$ChoeaeColorPaletteImpl(
      null == packId
          ? _value.packId
          : packId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ChoeaeColorPaletteImpl extends ChoeaeColorPalette {
  const _$ChoeaeColorPaletteImpl(this.packId) : super._();

  @override
  final String packId;

  @override
  String toString() {
    return 'ChoeaeColorConfig.palette(packId: $packId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChoeaeColorPaletteImpl &&
            (identical(other.packId, packId) || other.packId == packId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, packId);

  /// Create a copy of ChoeaeColorConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChoeaeColorPaletteImplCopyWith<_$ChoeaeColorPaletteImpl> get copyWith =>
      __$$ChoeaeColorPaletteImplCopyWithImpl<_$ChoeaeColorPaletteImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String packId) palette,
    required TResult Function(Color seedColor, Color? textColorOverride) custom,
  }) {
    return palette(packId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String packId)? palette,
    TResult? Function(Color seedColor, Color? textColorOverride)? custom,
  }) {
    return palette?.call(packId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String packId)? palette,
    TResult Function(Color seedColor, Color? textColorOverride)? custom,
    required TResult orElse(),
  }) {
    if (palette != null) {
      return palette(packId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChoeaeColorPalette value) palette,
    required TResult Function(ChoeaeColorCustom value) custom,
  }) {
    return palette(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChoeaeColorPalette value)? palette,
    TResult? Function(ChoeaeColorCustom value)? custom,
  }) {
    return palette?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChoeaeColorPalette value)? palette,
    TResult Function(ChoeaeColorCustom value)? custom,
    required TResult orElse(),
  }) {
    if (palette != null) {
      return palette(this);
    }
    return orElse();
  }
}

abstract class ChoeaeColorPalette extends ChoeaeColorConfig {
  const factory ChoeaeColorPalette(final String packId) =
      _$ChoeaeColorPaletteImpl;
  const ChoeaeColorPalette._() : super._();

  String get packId;

  /// Create a copy of ChoeaeColorConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChoeaeColorPaletteImplCopyWith<_$ChoeaeColorPaletteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChoeaeColorCustomImplCopyWith<$Res> {
  factory _$$ChoeaeColorCustomImplCopyWith(_$ChoeaeColorCustomImpl value,
          $Res Function(_$ChoeaeColorCustomImpl) then) =
      __$$ChoeaeColorCustomImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Color seedColor, Color? textColorOverride});
}

/// @nodoc
class __$$ChoeaeColorCustomImplCopyWithImpl<$Res>
    extends _$ChoeaeColorConfigCopyWithImpl<$Res, _$ChoeaeColorCustomImpl>
    implements _$$ChoeaeColorCustomImplCopyWith<$Res> {
  __$$ChoeaeColorCustomImplCopyWithImpl(_$ChoeaeColorCustomImpl _value,
      $Res Function(_$ChoeaeColorCustomImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChoeaeColorConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? seedColor = null,
    Object? textColorOverride = freezed,
  }) {
    return _then(_$ChoeaeColorCustomImpl(
      seedColor: null == seedColor
          ? _value.seedColor
          : seedColor // ignore: cast_nullable_to_non_nullable
              as Color,
      textColorOverride: freezed == textColorOverride
          ? _value.textColorOverride
          : textColorOverride // ignore: cast_nullable_to_non_nullable
              as Color?,
    ));
  }
}

/// @nodoc

class _$ChoeaeColorCustomImpl extends ChoeaeColorCustom {
  const _$ChoeaeColorCustomImpl(
      {required this.seedColor, this.textColorOverride})
      : super._();

  @override
  final Color seedColor;
  @override
  final Color? textColorOverride;

  @override
  String toString() {
    return 'ChoeaeColorConfig.custom(seedColor: $seedColor, textColorOverride: $textColorOverride)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChoeaeColorCustomImpl &&
            (identical(other.seedColor, seedColor) ||
                other.seedColor == seedColor) &&
            (identical(other.textColorOverride, textColorOverride) ||
                other.textColorOverride == textColorOverride));
  }

  @override
  int get hashCode => Object.hash(runtimeType, seedColor, textColorOverride);

  /// Create a copy of ChoeaeColorConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChoeaeColorCustomImplCopyWith<_$ChoeaeColorCustomImpl> get copyWith =>
      __$$ChoeaeColorCustomImplCopyWithImpl<_$ChoeaeColorCustomImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String packId) palette,
    required TResult Function(Color seedColor, Color? textColorOverride) custom,
  }) {
    return custom(seedColor, textColorOverride);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String packId)? palette,
    TResult? Function(Color seedColor, Color? textColorOverride)? custom,
  }) {
    return custom?.call(seedColor, textColorOverride);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String packId)? palette,
    TResult Function(Color seedColor, Color? textColorOverride)? custom,
    required TResult orElse(),
  }) {
    if (custom != null) {
      return custom(seedColor, textColorOverride);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ChoeaeColorPalette value) palette,
    required TResult Function(ChoeaeColorCustom value) custom,
  }) {
    return custom(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ChoeaeColorPalette value)? palette,
    TResult? Function(ChoeaeColorCustom value)? custom,
  }) {
    return custom?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ChoeaeColorPalette value)? palette,
    TResult Function(ChoeaeColorCustom value)? custom,
    required TResult orElse(),
  }) {
    if (custom != null) {
      return custom(this);
    }
    return orElse();
  }
}

abstract class ChoeaeColorCustom extends ChoeaeColorConfig {
  const factory ChoeaeColorCustom(
      {required final Color seedColor,
      final Color? textColorOverride}) = _$ChoeaeColorCustomImpl;
  const ChoeaeColorCustom._() : super._();

  Color get seedColor;
  Color? get textColorOverride;

  /// Create a copy of ChoeaeColorConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChoeaeColorCustomImplCopyWith<_$ChoeaeColorCustomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
