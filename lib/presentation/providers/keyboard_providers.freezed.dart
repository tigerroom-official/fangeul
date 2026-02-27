// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keyboard_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$KeyboardState {
  CapsMode get capsMode => throw _privateConstructorUsedError;

  /// Create a copy of KeyboardState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KeyboardStateCopyWith<KeyboardState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeyboardStateCopyWith<$Res> {
  factory $KeyboardStateCopyWith(
          KeyboardState value, $Res Function(KeyboardState) then) =
      _$KeyboardStateCopyWithImpl<$Res, KeyboardState>;
  @useResult
  $Res call({CapsMode capsMode});
}

/// @nodoc
class _$KeyboardStateCopyWithImpl<$Res, $Val extends KeyboardState>
    implements $KeyboardStateCopyWith<$Res> {
  _$KeyboardStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KeyboardState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? capsMode = null,
  }) {
    return _then(_value.copyWith(
      capsMode: null == capsMode
          ? _value.capsMode
          : capsMode // ignore: cast_nullable_to_non_nullable
              as CapsMode,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KeyboardStateImplCopyWith<$Res>
    implements $KeyboardStateCopyWith<$Res> {
  factory _$$KeyboardStateImplCopyWith(
          _$KeyboardStateImpl value, $Res Function(_$KeyboardStateImpl) then) =
      __$$KeyboardStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CapsMode capsMode});
}

/// @nodoc
class __$$KeyboardStateImplCopyWithImpl<$Res>
    extends _$KeyboardStateCopyWithImpl<$Res, _$KeyboardStateImpl>
    implements _$$KeyboardStateImplCopyWith<$Res> {
  __$$KeyboardStateImplCopyWithImpl(
      _$KeyboardStateImpl _value, $Res Function(_$KeyboardStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of KeyboardState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? capsMode = null,
  }) {
    return _then(_$KeyboardStateImpl(
      capsMode: null == capsMode
          ? _value.capsMode
          : capsMode // ignore: cast_nullable_to_non_nullable
              as CapsMode,
    ));
  }
}

/// @nodoc

class _$KeyboardStateImpl extends _KeyboardState {
  const _$KeyboardStateImpl({this.capsMode = CapsMode.off}) : super._();

  @override
  @JsonKey()
  final CapsMode capsMode;

  @override
  String toString() {
    return 'KeyboardState(capsMode: $capsMode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeyboardStateImpl &&
            (identical(other.capsMode, capsMode) ||
                other.capsMode == capsMode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, capsMode);

  /// Create a copy of KeyboardState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KeyboardStateImplCopyWith<_$KeyboardStateImpl> get copyWith =>
      __$$KeyboardStateImplCopyWithImpl<_$KeyboardStateImpl>(this, _$identity);
}

abstract class _KeyboardState extends KeyboardState {
  const factory _KeyboardState({final CapsMode capsMode}) = _$KeyboardStateImpl;
  const _KeyboardState._() : super._();

  @override
  CapsMode get capsMode;

  /// Create a copy of KeyboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KeyboardStateImplCopyWith<_$KeyboardStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
