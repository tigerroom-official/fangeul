// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'converter_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ConverterState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(String input, String output, ConvertMode mode)
        result,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(String input, String output, ConvertMode mode)? result,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(String input, String output, ConvertMode mode)? result,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConverterInitial value) initial,
    required TResult Function(ConverterResult value) result,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConverterInitial value)? initial,
    TResult? Function(ConverterResult value)? result,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConverterInitial value)? initial,
    TResult Function(ConverterResult value)? result,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConverterStateCopyWith<$Res> {
  factory $ConverterStateCopyWith(
          ConverterState value, $Res Function(ConverterState) then) =
      _$ConverterStateCopyWithImpl<$Res, ConverterState>;
}

/// @nodoc
class _$ConverterStateCopyWithImpl<$Res, $Val extends ConverterState>
    implements $ConverterStateCopyWith<$Res> {
  _$ConverterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConverterState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ConverterInitialImplCopyWith<$Res> {
  factory _$$ConverterInitialImplCopyWith(_$ConverterInitialImpl value,
          $Res Function(_$ConverterInitialImpl) then) =
      __$$ConverterInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ConverterInitialImplCopyWithImpl<$Res>
    extends _$ConverterStateCopyWithImpl<$Res, _$ConverterInitialImpl>
    implements _$$ConverterInitialImplCopyWith<$Res> {
  __$$ConverterInitialImplCopyWithImpl(_$ConverterInitialImpl _value,
      $Res Function(_$ConverterInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConverterState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ConverterInitialImpl implements ConverterInitial {
  const _$ConverterInitialImpl();

  @override
  String toString() {
    return 'ConverterState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ConverterInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(String input, String output, ConvertMode mode)
        result,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(String input, String output, ConvertMode mode)? result,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(String input, String output, ConvertMode mode)? result,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConverterInitial value) initial,
    required TResult Function(ConverterResult value) result,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConverterInitial value)? initial,
    TResult? Function(ConverterResult value)? result,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConverterInitial value)? initial,
    TResult Function(ConverterResult value)? result,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class ConverterInitial implements ConverterState {
  const factory ConverterInitial() = _$ConverterInitialImpl;
}

/// @nodoc
abstract class _$$ConverterResultImplCopyWith<$Res> {
  factory _$$ConverterResultImplCopyWith(_$ConverterResultImpl value,
          $Res Function(_$ConverterResultImpl) then) =
      __$$ConverterResultImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String input, String output, ConvertMode mode});
}

/// @nodoc
class __$$ConverterResultImplCopyWithImpl<$Res>
    extends _$ConverterStateCopyWithImpl<$Res, _$ConverterResultImpl>
    implements _$$ConverterResultImplCopyWith<$Res> {
  __$$ConverterResultImplCopyWithImpl(
      _$ConverterResultImpl _value, $Res Function(_$ConverterResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConverterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = null,
    Object? output = null,
    Object? mode = null,
  }) {
    return _then(_$ConverterResultImpl(
      input: null == input
          ? _value.input
          : input // ignore: cast_nullable_to_non_nullable
              as String,
      output: null == output
          ? _value.output
          : output // ignore: cast_nullable_to_non_nullable
              as String,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as ConvertMode,
    ));
  }
}

/// @nodoc

class _$ConverterResultImpl implements ConverterResult {
  const _$ConverterResultImpl(
      {required this.input, required this.output, required this.mode});

  @override
  final String input;
  @override
  final String output;
  @override
  final ConvertMode mode;

  @override
  String toString() {
    return 'ConverterState.result(input: $input, output: $output, mode: $mode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConverterResultImpl &&
            (identical(other.input, input) || other.input == input) &&
            (identical(other.output, output) || other.output == output) &&
            (identical(other.mode, mode) || other.mode == mode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, input, output, mode);

  /// Create a copy of ConverterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConverterResultImplCopyWith<_$ConverterResultImpl> get copyWith =>
      __$$ConverterResultImplCopyWithImpl<_$ConverterResultImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(String input, String output, ConvertMode mode)
        result,
  }) {
    return result(input, output, mode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(String input, String output, ConvertMode mode)? result,
  }) {
    return result?.call(input, output, mode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(String input, String output, ConvertMode mode)? result,
    required TResult orElse(),
  }) {
    if (result != null) {
      return result(input, output, mode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConverterInitial value) initial,
    required TResult Function(ConverterResult value) result,
  }) {
    return result(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConverterInitial value)? initial,
    TResult? Function(ConverterResult value)? result,
  }) {
    return result?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConverterInitial value)? initial,
    TResult Function(ConverterResult value)? result,
    required TResult orElse(),
  }) {
    if (result != null) {
      return result(this);
    }
    return orElse();
  }
}

abstract class ConverterResult implements ConverterState {
  const factory ConverterResult(
      {required final String input,
      required final String output,
      required final ConvertMode mode}) = _$ConverterResultImpl;

  String get input;
  String get output;
  ConvertMode get mode;

  /// Create a copy of ConverterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConverterResultImplCopyWith<_$ConverterResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
