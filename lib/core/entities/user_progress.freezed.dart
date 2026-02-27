// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserProgress {
  /// 현재 연속 스트릭 일수
  int get streak => throw _privateConstructorUsedError;

  /// 누적 스트릭 일수
  int get totalStreakDays => throw _privateConstructorUsedError;

  /// 마지막 완료 날짜 (yyyy-MM-dd)
  String? get lastCompletedDate => throw _privateConstructorUsedError;

  /// 스트릭 프리즈 잔여 횟수
  int get freezeCount => throw _privateConstructorUsedError;

  /// 단조증가 타임스탬프 (밀리초). 시간 조작 방어용.
  int get lastTimestamp => throw _privateConstructorUsedError;

  /// 해금된 팩 ID 목록
  List<String> get unlockedPackIds => throw _privateConstructorUsedError;

  /// 수집한 카드 ID 목록 (v1.1 확장)
  List<String> get collectedCardIds => throw _privateConstructorUsedError;

  /// 스타더스트 포인트 (v1.1 확장)
  int get starDust => throw _privateConstructorUsedError;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProgressCopyWith<UserProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProgressCopyWith<$Res> {
  factory $UserProgressCopyWith(
          UserProgress value, $Res Function(UserProgress) then) =
      _$UserProgressCopyWithImpl<$Res, UserProgress>;
  @useResult
  $Res call(
      {int streak,
      int totalStreakDays,
      String? lastCompletedDate,
      int freezeCount,
      int lastTimestamp,
      List<String> unlockedPackIds,
      List<String> collectedCardIds,
      int starDust});
}

/// @nodoc
class _$UserProgressCopyWithImpl<$Res, $Val extends UserProgress>
    implements $UserProgressCopyWith<$Res> {
  _$UserProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? streak = null,
    Object? totalStreakDays = null,
    Object? lastCompletedDate = freezed,
    Object? freezeCount = null,
    Object? lastTimestamp = null,
    Object? unlockedPackIds = null,
    Object? collectedCardIds = null,
    Object? starDust = null,
  }) {
    return _then(_value.copyWith(
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      totalStreakDays: null == totalStreakDays
          ? _value.totalStreakDays
          : totalStreakDays // ignore: cast_nullable_to_non_nullable
              as int,
      lastCompletedDate: freezed == lastCompletedDate
          ? _value.lastCompletedDate
          : lastCompletedDate // ignore: cast_nullable_to_non_nullable
              as String?,
      freezeCount: null == freezeCount
          ? _value.freezeCount
          : freezeCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastTimestamp: null == lastTimestamp
          ? _value.lastTimestamp
          : lastTimestamp // ignore: cast_nullable_to_non_nullable
              as int,
      unlockedPackIds: null == unlockedPackIds
          ? _value.unlockedPackIds
          : unlockedPackIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      collectedCardIds: null == collectedCardIds
          ? _value.collectedCardIds
          : collectedCardIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      starDust: null == starDust
          ? _value.starDust
          : starDust // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProgressImplCopyWith<$Res>
    implements $UserProgressCopyWith<$Res> {
  factory _$$UserProgressImplCopyWith(
          _$UserProgressImpl value, $Res Function(_$UserProgressImpl) then) =
      __$$UserProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int streak,
      int totalStreakDays,
      String? lastCompletedDate,
      int freezeCount,
      int lastTimestamp,
      List<String> unlockedPackIds,
      List<String> collectedCardIds,
      int starDust});
}

/// @nodoc
class __$$UserProgressImplCopyWithImpl<$Res>
    extends _$UserProgressCopyWithImpl<$Res, _$UserProgressImpl>
    implements _$$UserProgressImplCopyWith<$Res> {
  __$$UserProgressImplCopyWithImpl(
      _$UserProgressImpl _value, $Res Function(_$UserProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? streak = null,
    Object? totalStreakDays = null,
    Object? lastCompletedDate = freezed,
    Object? freezeCount = null,
    Object? lastTimestamp = null,
    Object? unlockedPackIds = null,
    Object? collectedCardIds = null,
    Object? starDust = null,
  }) {
    return _then(_$UserProgressImpl(
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      totalStreakDays: null == totalStreakDays
          ? _value.totalStreakDays
          : totalStreakDays // ignore: cast_nullable_to_non_nullable
              as int,
      lastCompletedDate: freezed == lastCompletedDate
          ? _value.lastCompletedDate
          : lastCompletedDate // ignore: cast_nullable_to_non_nullable
              as String?,
      freezeCount: null == freezeCount
          ? _value.freezeCount
          : freezeCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastTimestamp: null == lastTimestamp
          ? _value.lastTimestamp
          : lastTimestamp // ignore: cast_nullable_to_non_nullable
              as int,
      unlockedPackIds: null == unlockedPackIds
          ? _value._unlockedPackIds
          : unlockedPackIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      collectedCardIds: null == collectedCardIds
          ? _value._collectedCardIds
          : collectedCardIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      starDust: null == starDust
          ? _value.starDust
          : starDust // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$UserProgressImpl implements _UserProgress {
  const _$UserProgressImpl(
      {this.streak = 0,
      this.totalStreakDays = 0,
      this.lastCompletedDate,
      this.freezeCount = 0,
      this.lastTimestamp = 0,
      final List<String> unlockedPackIds = const [],
      final List<String> collectedCardIds = const [],
      this.starDust = 0})
      : _unlockedPackIds = unlockedPackIds,
        _collectedCardIds = collectedCardIds;

  /// 현재 연속 스트릭 일수
  @override
  @JsonKey()
  final int streak;

  /// 누적 스트릭 일수
  @override
  @JsonKey()
  final int totalStreakDays;

  /// 마지막 완료 날짜 (yyyy-MM-dd)
  @override
  final String? lastCompletedDate;

  /// 스트릭 프리즈 잔여 횟수
  @override
  @JsonKey()
  final int freezeCount;

  /// 단조증가 타임스탬프 (밀리초). 시간 조작 방어용.
  @override
  @JsonKey()
  final int lastTimestamp;

  /// 해금된 팩 ID 목록
  final List<String> _unlockedPackIds;

  /// 해금된 팩 ID 목록
  @override
  @JsonKey()
  List<String> get unlockedPackIds {
    if (_unlockedPackIds is EqualUnmodifiableListView) return _unlockedPackIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unlockedPackIds);
  }

  /// 수집한 카드 ID 목록 (v1.1 확장)
  final List<String> _collectedCardIds;

  /// 수집한 카드 ID 목록 (v1.1 확장)
  @override
  @JsonKey()
  List<String> get collectedCardIds {
    if (_collectedCardIds is EqualUnmodifiableListView)
      return _collectedCardIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_collectedCardIds);
  }

  /// 스타더스트 포인트 (v1.1 확장)
  @override
  @JsonKey()
  final int starDust;

  @override
  String toString() {
    return 'UserProgress(streak: $streak, totalStreakDays: $totalStreakDays, lastCompletedDate: $lastCompletedDate, freezeCount: $freezeCount, lastTimestamp: $lastTimestamp, unlockedPackIds: $unlockedPackIds, collectedCardIds: $collectedCardIds, starDust: $starDust)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProgressImpl &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.totalStreakDays, totalStreakDays) ||
                other.totalStreakDays == totalStreakDays) &&
            (identical(other.lastCompletedDate, lastCompletedDate) ||
                other.lastCompletedDate == lastCompletedDate) &&
            (identical(other.freezeCount, freezeCount) ||
                other.freezeCount == freezeCount) &&
            (identical(other.lastTimestamp, lastTimestamp) ||
                other.lastTimestamp == lastTimestamp) &&
            const DeepCollectionEquality()
                .equals(other._unlockedPackIds, _unlockedPackIds) &&
            const DeepCollectionEquality()
                .equals(other._collectedCardIds, _collectedCardIds) &&
            (identical(other.starDust, starDust) ||
                other.starDust == starDust));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      streak,
      totalStreakDays,
      lastCompletedDate,
      freezeCount,
      lastTimestamp,
      const DeepCollectionEquality().hash(_unlockedPackIds),
      const DeepCollectionEquality().hash(_collectedCardIds),
      starDust);

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      __$$UserProgressImplCopyWithImpl<_$UserProgressImpl>(this, _$identity);
}

abstract class _UserProgress implements UserProgress {
  const factory _UserProgress(
      {final int streak,
      final int totalStreakDays,
      final String? lastCompletedDate,
      final int freezeCount,
      final int lastTimestamp,
      final List<String> unlockedPackIds,
      final List<String> collectedCardIds,
      final int starDust}) = _$UserProgressImpl;

  /// 현재 연속 스트릭 일수
  @override
  int get streak;

  /// 누적 스트릭 일수
  @override
  int get totalStreakDays;

  /// 마지막 완료 날짜 (yyyy-MM-dd)
  @override
  String? get lastCompletedDate;

  /// 스트릭 프리즈 잔여 횟수
  @override
  int get freezeCount;

  /// 단조증가 타임스탬프 (밀리초). 시간 조작 방어용.
  @override
  int get lastTimestamp;

  /// 해금된 팩 ID 목록
  @override
  List<String> get unlockedPackIds;

  /// 수집한 카드 ID 목록 (v1.1 확장)
  @override
  List<String> get collectedCardIds;

  /// 스타더스트 포인트 (v1.1 확장)
  @override
  int get starDust;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
