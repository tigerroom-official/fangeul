// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DailyCard {
  /// 카드 날짜 (yyyy-MM-dd)
  String get date => throw _privateConstructorUsedError;

  /// 선정된 문구의 팩 내 인덱스
  int get phraseIndex => throw _privateConstructorUsedError;

  /// 선정된 문구
  Phrase get phrase => throw _privateConstructorUsedError;

  /// 문구가 속한 팩 ID
  String get packId => throw _privateConstructorUsedError;

  /// 완료 여부
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Create a copy of DailyCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyCardCopyWith<DailyCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyCardCopyWith<$Res> {
  factory $DailyCardCopyWith(DailyCard value, $Res Function(DailyCard) then) =
      _$DailyCardCopyWithImpl<$Res, DailyCard>;
  @useResult
  $Res call(
      {String date,
      int phraseIndex,
      Phrase phrase,
      String packId,
      bool isCompleted});

  $PhraseCopyWith<$Res> get phrase;
}

/// @nodoc
class _$DailyCardCopyWithImpl<$Res, $Val extends DailyCard>
    implements $DailyCardCopyWith<$Res> {
  _$DailyCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? phraseIndex = null,
    Object? phrase = null,
    Object? packId = null,
    Object? isCompleted = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      phraseIndex: null == phraseIndex
          ? _value.phraseIndex
          : phraseIndex // ignore: cast_nullable_to_non_nullable
              as int,
      phrase: null == phrase
          ? _value.phrase
          : phrase // ignore: cast_nullable_to_non_nullable
              as Phrase,
      packId: null == packId
          ? _value.packId
          : packId // ignore: cast_nullable_to_non_nullable
              as String,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of DailyCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PhraseCopyWith<$Res> get phrase {
    return $PhraseCopyWith<$Res>(_value.phrase, (value) {
      return _then(_value.copyWith(phrase: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DailyCardImplCopyWith<$Res>
    implements $DailyCardCopyWith<$Res> {
  factory _$$DailyCardImplCopyWith(
          _$DailyCardImpl value, $Res Function(_$DailyCardImpl) then) =
      __$$DailyCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String date,
      int phraseIndex,
      Phrase phrase,
      String packId,
      bool isCompleted});

  @override
  $PhraseCopyWith<$Res> get phrase;
}

/// @nodoc
class __$$DailyCardImplCopyWithImpl<$Res>
    extends _$DailyCardCopyWithImpl<$Res, _$DailyCardImpl>
    implements _$$DailyCardImplCopyWith<$Res> {
  __$$DailyCardImplCopyWithImpl(
      _$DailyCardImpl _value, $Res Function(_$DailyCardImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? phraseIndex = null,
    Object? phrase = null,
    Object? packId = null,
    Object? isCompleted = null,
  }) {
    return _then(_$DailyCardImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      phraseIndex: null == phraseIndex
          ? _value.phraseIndex
          : phraseIndex // ignore: cast_nullable_to_non_nullable
              as int,
      phrase: null == phrase
          ? _value.phrase
          : phrase // ignore: cast_nullable_to_non_nullable
              as Phrase,
      packId: null == packId
          ? _value.packId
          : packId // ignore: cast_nullable_to_non_nullable
              as String,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$DailyCardImpl implements _DailyCard {
  const _$DailyCardImpl(
      {required this.date,
      required this.phraseIndex,
      required this.phrase,
      required this.packId,
      this.isCompleted = false});

  /// 카드 날짜 (yyyy-MM-dd)
  @override
  final String date;

  /// 선정된 문구의 팩 내 인덱스
  @override
  final int phraseIndex;

  /// 선정된 문구
  @override
  final Phrase phrase;

  /// 문구가 속한 팩 ID
  @override
  final String packId;

  /// 완료 여부
  @override
  @JsonKey()
  final bool isCompleted;

  @override
  String toString() {
    return 'DailyCard(date: $date, phraseIndex: $phraseIndex, phrase: $phrase, packId: $packId, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyCardImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.phraseIndex, phraseIndex) ||
                other.phraseIndex == phraseIndex) &&
            (identical(other.phrase, phrase) || other.phrase == phrase) &&
            (identical(other.packId, packId) || other.packId == packId) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, date, phraseIndex, phrase, packId, isCompleted);

  /// Create a copy of DailyCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyCardImplCopyWith<_$DailyCardImpl> get copyWith =>
      __$$DailyCardImplCopyWithImpl<_$DailyCardImpl>(this, _$identity);
}

abstract class _DailyCard implements DailyCard {
  const factory _DailyCard(
      {required final String date,
      required final int phraseIndex,
      required final Phrase phrase,
      required final String packId,
      final bool isCompleted}) = _$DailyCardImpl;

  /// 카드 날짜 (yyyy-MM-dd)
  @override
  String get date;

  /// 선정된 문구의 팩 내 인덱스
  @override
  int get phraseIndex;

  /// 선정된 문구
  @override
  Phrase get phrase;

  /// 문구가 속한 팩 ID
  @override
  String get packId;

  /// 완료 여부
  @override
  bool get isCompleted;

  /// Create a copy of DailyCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyCardImplCopyWith<_$DailyCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
