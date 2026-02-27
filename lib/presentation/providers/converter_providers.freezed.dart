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
    required TResult Function() loading,
    required TResult Function(String input, String output, ConvertMode mode)
        success,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String input, String output, ConvertMode mode)? success,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String input, String output, ConvertMode mode)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConverterInitial value) initial,
    required TResult Function(ConverterLoading value) loading,
    required TResult Function(ConverterSuccess value) success,
    required TResult Function(ConverterError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConverterInitial value)? initial,
    TResult? Function(ConverterLoading value)? loading,
    TResult? Function(ConverterSuccess value)? success,
    TResult? Function(ConverterError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConverterInitial value)? initial,
    TResult Function(ConverterLoading value)? loading,
    TResult Function(ConverterSuccess value)? success,
    TResult Function(ConverterError value)? error,
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
    required TResult Function() loading,
    required TResult Function(String input, String output, ConvertMode mode)
        success,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String input, String output, ConvertMode mode)? success,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String input, String output, ConvertMode mode)? success,
    TResult Function(String message)? error,
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
    required TResult Function(ConverterLoading value) loading,
    required TResult Function(ConverterSuccess value) success,
    required TResult Function(ConverterError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConverterInitial value)? initial,
    TResult? Function(ConverterLoading value)? loading,
    TResult? Function(ConverterSuccess value)? success,
    TResult? Function(ConverterError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConverterInitial value)? initial,
    TResult Function(ConverterLoading value)? loading,
    TResult Function(ConverterSuccess value)? success,
    TResult Function(ConverterError value)? error,
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
abstract class _$$ConverterLoadingImplCopyWith<$Res> {
  factory _$$ConverterLoadingImplCopyWith(_$ConverterLoadingImpl value,
          $Res Function(_$ConverterLoadingImpl) then) =
      __$$ConverterLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ConverterLoadingImplCopyWithImpl<$Res>
    extends _$ConverterStateCopyWithImpl<$Res, _$ConverterLoadingImpl>
    implements _$$ConverterLoadingImplCopyWith<$Res> {
  __$$ConverterLoadingImplCopyWithImpl(_$ConverterLoadingImpl _value,
      $Res Function(_$ConverterLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConverterState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ConverterLoadingImpl implements ConverterLoading {
  const _$ConverterLoadingImpl();

  @override
  String toString() {
    return 'ConverterState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ConverterLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String input, String output, ConvertMode mode)
        success,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String input, String output, ConvertMode mode)? success,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String input, String output, ConvertMode mode)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConverterInitial value) initial,
    required TResult Function(ConverterLoading value) loading,
    required TResult Function(ConverterSuccess value) success,
    required TResult Function(ConverterError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConverterInitial value)? initial,
    TResult? Function(ConverterLoading value)? loading,
    TResult? Function(ConverterSuccess value)? success,
    TResult? Function(ConverterError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConverterInitial value)? initial,
    TResult Function(ConverterLoading value)? loading,
    TResult Function(ConverterSuccess value)? success,
    TResult Function(ConverterError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class ConverterLoading implements ConverterState {
  const factory ConverterLoading() = _$ConverterLoadingImpl;
}

/// @nodoc
abstract class _$$ConverterSuccessImplCopyWith<$Res> {
  factory _$$ConverterSuccessImplCopyWith(_$ConverterSuccessImpl value,
          $Res Function(_$ConverterSuccessImpl) then) =
      __$$ConverterSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String input, String output, ConvertMode mode});
}

/// @nodoc
class __$$ConverterSuccessImplCopyWithImpl<$Res>
    extends _$ConverterStateCopyWithImpl<$Res, _$ConverterSuccessImpl>
    implements _$$ConverterSuccessImplCopyWith<$Res> {
  __$$ConverterSuccessImplCopyWithImpl(_$ConverterSuccessImpl _value,
      $Res Function(_$ConverterSuccessImpl) _then)
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
    return _then(_$ConverterSuccessImpl(
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

class _$ConverterSuccessImpl implements ConverterSuccess {
  const _$ConverterSuccessImpl(
      {required this.input, required this.output, required this.mode});

  @override
  final String input;
  @override
  final String output;
  @override
  final ConvertMode mode;

  @override
  String toString() {
    return 'ConverterState.success(input: $input, output: $output, mode: $mode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConverterSuccessImpl &&
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
  _$$ConverterSuccessImplCopyWith<_$ConverterSuccessImpl> get copyWith =>
      __$$ConverterSuccessImplCopyWithImpl<_$ConverterSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String input, String output, ConvertMode mode)
        success,
    required TResult Function(String message) error,
  }) {
    return success(input, output, mode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String input, String output, ConvertMode mode)? success,
    TResult? Function(String message)? error,
  }) {
    return success?.call(input, output, mode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String input, String output, ConvertMode mode)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(input, output, mode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConverterInitial value) initial,
    required TResult Function(ConverterLoading value) loading,
    required TResult Function(ConverterSuccess value) success,
    required TResult Function(ConverterError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConverterInitial value)? initial,
    TResult? Function(ConverterLoading value)? loading,
    TResult? Function(ConverterSuccess value)? success,
    TResult? Function(ConverterError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConverterInitial value)? initial,
    TResult Function(ConverterLoading value)? loading,
    TResult Function(ConverterSuccess value)? success,
    TResult Function(ConverterError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class ConverterSuccess implements ConverterState {
  const factory ConverterSuccess(
      {required final String input,
      required final String output,
      required final ConvertMode mode}) = _$ConverterSuccessImpl;

  String get input;
  String get output;
  ConvertMode get mode;

  /// Create a copy of ConverterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConverterSuccessImplCopyWith<_$ConverterSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConverterErrorImplCopyWith<$Res> {
  factory _$$ConverterErrorImplCopyWith(_$ConverterErrorImpl value,
          $Res Function(_$ConverterErrorImpl) then) =
      __$$ConverterErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ConverterErrorImplCopyWithImpl<$Res>
    extends _$ConverterStateCopyWithImpl<$Res, _$ConverterErrorImpl>
    implements _$$ConverterErrorImplCopyWith<$Res> {
  __$$ConverterErrorImplCopyWithImpl(
      _$ConverterErrorImpl _value, $Res Function(_$ConverterErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConverterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ConverterErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ConverterErrorImpl implements ConverterError {
  const _$ConverterErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'ConverterState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConverterErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of ConverterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConverterErrorImplCopyWith<_$ConverterErrorImpl> get copyWith =>
      __$$ConverterErrorImplCopyWithImpl<_$ConverterErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String input, String output, ConvertMode mode)
        success,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(String input, String output, ConvertMode mode)? success,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String input, String output, ConvertMode mode)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConverterInitial value) initial,
    required TResult Function(ConverterLoading value) loading,
    required TResult Function(ConverterSuccess value) success,
    required TResult Function(ConverterError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConverterInitial value)? initial,
    TResult? Function(ConverterLoading value)? loading,
    TResult? Function(ConverterSuccess value)? success,
    TResult? Function(ConverterError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConverterInitial value)? initial,
    TResult Function(ConverterLoading value)? loading,
    TResult Function(ConverterSuccess value)? success,
    TResult Function(ConverterError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ConverterError implements ConverterState {
  const factory ConverterError(final String message) = _$ConverterErrorImpl;

  String get message;

  /// Create a copy of ConverterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConverterErrorImplCopyWith<_$ConverterErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
