// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monetization_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MonetizationState _$MonetizationStateFromJson(Map<String, dynamic> json) {
  return _MonetizationState.fromJson(json);
}

/// @nodoc
mixin _$MonetizationState {
  /// 앱 설치 날짜 (yyyy-MM-dd). null이면 아직 설정되지 않음.
  String? get installDate => throw _privateConstructorUsedError;

  /// 허니문(무료 체험) 기간 활성 여부. 기본 true.
  bool get honeymoonActive => throw _privateConstructorUsedError;

  /// 즐겨찾기 슬롯 제한. 0 = 무제한 (허니문/Pro), 3 = 기본 제한.
  int get favoriteSlotLimit => throw _privateConstructorUsedError;

  /// 오늘 TTS 재생 횟수.
  int get ttsPlayCount => throw _privateConstructorUsedError;

  /// TTS 횟수 마지막 리셋 날짜 (yyyy-MM-dd).
  String? get ttsLastResetDate => throw _privateConstructorUsedError;

  /// 오늘 보상형 광고 시청 횟수.
  int get adWatchCount => throw _privateConstructorUsedError;

  /// 광고 횟수 마지막 리셋 날짜 (yyyy-MM-dd).
  String? get adLastResetDate => throw _privateConstructorUsedError;

  /// 마지막 광고 시청 타임스탬프 (ms since epoch). 5분 쿨다운 검증용.
  int get lastAdWatchTimestamp => throw _privateConstructorUsedError;

  /// 해금 만료 타임스탬프 (ms since epoch). 0 = 해금 없음.
  int get unlockExpiresAt => throw _privateConstructorUsedError;

  /// 구매 완료된 팩 ID 목록.
  List<String> get purchasedPackIds => throw _privateConstructorUsedError;

  /// D-day 해금 날짜 목록 ('{date}_{eventId}' 형식).
  List<String> get ddayUnlockedDates => throw _privateConstructorUsedError;

  /// 단조증가 타임스탬프 (밀리초). 시간 조작 방어용.
  int get lastTimestamp => throw _privateConstructorUsedError;

  /// Serializes this MonetizationState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonetizationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonetizationStateCopyWith<MonetizationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonetizationStateCopyWith<$Res> {
  factory $MonetizationStateCopyWith(
          MonetizationState value, $Res Function(MonetizationState) then) =
      _$MonetizationStateCopyWithImpl<$Res, MonetizationState>;
  @useResult
  $Res call(
      {String? installDate,
      bool honeymoonActive,
      int favoriteSlotLimit,
      int ttsPlayCount,
      String? ttsLastResetDate,
      int adWatchCount,
      String? adLastResetDate,
      int lastAdWatchTimestamp,
      int unlockExpiresAt,
      List<String> purchasedPackIds,
      List<String> ddayUnlockedDates,
      int lastTimestamp});
}

/// @nodoc
class _$MonetizationStateCopyWithImpl<$Res, $Val extends MonetizationState>
    implements $MonetizationStateCopyWith<$Res> {
  _$MonetizationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonetizationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? installDate = freezed,
    Object? honeymoonActive = null,
    Object? favoriteSlotLimit = null,
    Object? ttsPlayCount = null,
    Object? ttsLastResetDate = freezed,
    Object? adWatchCount = null,
    Object? adLastResetDate = freezed,
    Object? lastAdWatchTimestamp = null,
    Object? unlockExpiresAt = null,
    Object? purchasedPackIds = null,
    Object? ddayUnlockedDates = null,
    Object? lastTimestamp = null,
  }) {
    return _then(_value.copyWith(
      installDate: freezed == installDate
          ? _value.installDate
          : installDate // ignore: cast_nullable_to_non_nullable
              as String?,
      honeymoonActive: null == honeymoonActive
          ? _value.honeymoonActive
          : honeymoonActive // ignore: cast_nullable_to_non_nullable
              as bool,
      favoriteSlotLimit: null == favoriteSlotLimit
          ? _value.favoriteSlotLimit
          : favoriteSlotLimit // ignore: cast_nullable_to_non_nullable
              as int,
      ttsPlayCount: null == ttsPlayCount
          ? _value.ttsPlayCount
          : ttsPlayCount // ignore: cast_nullable_to_non_nullable
              as int,
      ttsLastResetDate: freezed == ttsLastResetDate
          ? _value.ttsLastResetDate
          : ttsLastResetDate // ignore: cast_nullable_to_non_nullable
              as String?,
      adWatchCount: null == adWatchCount
          ? _value.adWatchCount
          : adWatchCount // ignore: cast_nullable_to_non_nullable
              as int,
      adLastResetDate: freezed == adLastResetDate
          ? _value.adLastResetDate
          : adLastResetDate // ignore: cast_nullable_to_non_nullable
              as String?,
      lastAdWatchTimestamp: null == lastAdWatchTimestamp
          ? _value.lastAdWatchTimestamp
          : lastAdWatchTimestamp // ignore: cast_nullable_to_non_nullable
              as int,
      unlockExpiresAt: null == unlockExpiresAt
          ? _value.unlockExpiresAt
          : unlockExpiresAt // ignore: cast_nullable_to_non_nullable
              as int,
      purchasedPackIds: null == purchasedPackIds
          ? _value.purchasedPackIds
          : purchasedPackIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      ddayUnlockedDates: null == ddayUnlockedDates
          ? _value.ddayUnlockedDates
          : ddayUnlockedDates // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lastTimestamp: null == lastTimestamp
          ? _value.lastTimestamp
          : lastTimestamp // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MonetizationStateImplCopyWith<$Res>
    implements $MonetizationStateCopyWith<$Res> {
  factory _$$MonetizationStateImplCopyWith(_$MonetizationStateImpl value,
          $Res Function(_$MonetizationStateImpl) then) =
      __$$MonetizationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? installDate,
      bool honeymoonActive,
      int favoriteSlotLimit,
      int ttsPlayCount,
      String? ttsLastResetDate,
      int adWatchCount,
      String? adLastResetDate,
      int lastAdWatchTimestamp,
      int unlockExpiresAt,
      List<String> purchasedPackIds,
      List<String> ddayUnlockedDates,
      int lastTimestamp});
}

/// @nodoc
class __$$MonetizationStateImplCopyWithImpl<$Res>
    extends _$MonetizationStateCopyWithImpl<$Res, _$MonetizationStateImpl>
    implements _$$MonetizationStateImplCopyWith<$Res> {
  __$$MonetizationStateImplCopyWithImpl(_$MonetizationStateImpl _value,
      $Res Function(_$MonetizationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MonetizationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? installDate = freezed,
    Object? honeymoonActive = null,
    Object? favoriteSlotLimit = null,
    Object? ttsPlayCount = null,
    Object? ttsLastResetDate = freezed,
    Object? adWatchCount = null,
    Object? adLastResetDate = freezed,
    Object? lastAdWatchTimestamp = null,
    Object? unlockExpiresAt = null,
    Object? purchasedPackIds = null,
    Object? ddayUnlockedDates = null,
    Object? lastTimestamp = null,
  }) {
    return _then(_$MonetizationStateImpl(
      installDate: freezed == installDate
          ? _value.installDate
          : installDate // ignore: cast_nullable_to_non_nullable
              as String?,
      honeymoonActive: null == honeymoonActive
          ? _value.honeymoonActive
          : honeymoonActive // ignore: cast_nullable_to_non_nullable
              as bool,
      favoriteSlotLimit: null == favoriteSlotLimit
          ? _value.favoriteSlotLimit
          : favoriteSlotLimit // ignore: cast_nullable_to_non_nullable
              as int,
      ttsPlayCount: null == ttsPlayCount
          ? _value.ttsPlayCount
          : ttsPlayCount // ignore: cast_nullable_to_non_nullable
              as int,
      ttsLastResetDate: freezed == ttsLastResetDate
          ? _value.ttsLastResetDate
          : ttsLastResetDate // ignore: cast_nullable_to_non_nullable
              as String?,
      adWatchCount: null == adWatchCount
          ? _value.adWatchCount
          : adWatchCount // ignore: cast_nullable_to_non_nullable
              as int,
      adLastResetDate: freezed == adLastResetDate
          ? _value.adLastResetDate
          : adLastResetDate // ignore: cast_nullable_to_non_nullable
              as String?,
      lastAdWatchTimestamp: null == lastAdWatchTimestamp
          ? _value.lastAdWatchTimestamp
          : lastAdWatchTimestamp // ignore: cast_nullable_to_non_nullable
              as int,
      unlockExpiresAt: null == unlockExpiresAt
          ? _value.unlockExpiresAt
          : unlockExpiresAt // ignore: cast_nullable_to_non_nullable
              as int,
      purchasedPackIds: null == purchasedPackIds
          ? _value._purchasedPackIds
          : purchasedPackIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      ddayUnlockedDates: null == ddayUnlockedDates
          ? _value._ddayUnlockedDates
          : ddayUnlockedDates // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lastTimestamp: null == lastTimestamp
          ? _value.lastTimestamp
          : lastTimestamp // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MonetizationStateImpl implements _MonetizationState {
  const _$MonetizationStateImpl(
      {this.installDate,
      this.honeymoonActive = true,
      this.favoriteSlotLimit = 0,
      this.ttsPlayCount = 0,
      this.ttsLastResetDate,
      this.adWatchCount = 0,
      this.adLastResetDate,
      this.lastAdWatchTimestamp = 0,
      this.unlockExpiresAt = 0,
      final List<String> purchasedPackIds = const [],
      final List<String> ddayUnlockedDates = const [],
      this.lastTimestamp = 0})
      : _purchasedPackIds = purchasedPackIds,
        _ddayUnlockedDates = ddayUnlockedDates;

  factory _$MonetizationStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonetizationStateImplFromJson(json);

  /// 앱 설치 날짜 (yyyy-MM-dd). null이면 아직 설정되지 않음.
  @override
  final String? installDate;

  /// 허니문(무료 체험) 기간 활성 여부. 기본 true.
  @override
  @JsonKey()
  final bool honeymoonActive;

  /// 즐겨찾기 슬롯 제한. 0 = 무제한 (허니문/Pro), 3 = 기본 제한.
  @override
  @JsonKey()
  final int favoriteSlotLimit;

  /// 오늘 TTS 재생 횟수.
  @override
  @JsonKey()
  final int ttsPlayCount;

  /// TTS 횟수 마지막 리셋 날짜 (yyyy-MM-dd).
  @override
  final String? ttsLastResetDate;

  /// 오늘 보상형 광고 시청 횟수.
  @override
  @JsonKey()
  final int adWatchCount;

  /// 광고 횟수 마지막 리셋 날짜 (yyyy-MM-dd).
  @override
  final String? adLastResetDate;

  /// 마지막 광고 시청 타임스탬프 (ms since epoch). 5분 쿨다운 검증용.
  @override
  @JsonKey()
  final int lastAdWatchTimestamp;

  /// 해금 만료 타임스탬프 (ms since epoch). 0 = 해금 없음.
  @override
  @JsonKey()
  final int unlockExpiresAt;

  /// 구매 완료된 팩 ID 목록.
  final List<String> _purchasedPackIds;

  /// 구매 완료된 팩 ID 목록.
  @override
  @JsonKey()
  List<String> get purchasedPackIds {
    if (_purchasedPackIds is EqualUnmodifiableListView)
      return _purchasedPackIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_purchasedPackIds);
  }

  /// D-day 해금 날짜 목록 ('{date}_{eventId}' 형식).
  final List<String> _ddayUnlockedDates;

  /// D-day 해금 날짜 목록 ('{date}_{eventId}' 형식).
  @override
  @JsonKey()
  List<String> get ddayUnlockedDates {
    if (_ddayUnlockedDates is EqualUnmodifiableListView)
      return _ddayUnlockedDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ddayUnlockedDates);
  }

  /// 단조증가 타임스탬프 (밀리초). 시간 조작 방어용.
  @override
  @JsonKey()
  final int lastTimestamp;

  @override
  String toString() {
    return 'MonetizationState(installDate: $installDate, honeymoonActive: $honeymoonActive, favoriteSlotLimit: $favoriteSlotLimit, ttsPlayCount: $ttsPlayCount, ttsLastResetDate: $ttsLastResetDate, adWatchCount: $adWatchCount, adLastResetDate: $adLastResetDate, lastAdWatchTimestamp: $lastAdWatchTimestamp, unlockExpiresAt: $unlockExpiresAt, purchasedPackIds: $purchasedPackIds, ddayUnlockedDates: $ddayUnlockedDates, lastTimestamp: $lastTimestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonetizationStateImpl &&
            (identical(other.installDate, installDate) ||
                other.installDate == installDate) &&
            (identical(other.honeymoonActive, honeymoonActive) ||
                other.honeymoonActive == honeymoonActive) &&
            (identical(other.favoriteSlotLimit, favoriteSlotLimit) ||
                other.favoriteSlotLimit == favoriteSlotLimit) &&
            (identical(other.ttsPlayCount, ttsPlayCount) ||
                other.ttsPlayCount == ttsPlayCount) &&
            (identical(other.ttsLastResetDate, ttsLastResetDate) ||
                other.ttsLastResetDate == ttsLastResetDate) &&
            (identical(other.adWatchCount, adWatchCount) ||
                other.adWatchCount == adWatchCount) &&
            (identical(other.adLastResetDate, adLastResetDate) ||
                other.adLastResetDate == adLastResetDate) &&
            (identical(other.lastAdWatchTimestamp, lastAdWatchTimestamp) ||
                other.lastAdWatchTimestamp == lastAdWatchTimestamp) &&
            (identical(other.unlockExpiresAt, unlockExpiresAt) ||
                other.unlockExpiresAt == unlockExpiresAt) &&
            const DeepCollectionEquality()
                .equals(other._purchasedPackIds, _purchasedPackIds) &&
            const DeepCollectionEquality()
                .equals(other._ddayUnlockedDates, _ddayUnlockedDates) &&
            (identical(other.lastTimestamp, lastTimestamp) ||
                other.lastTimestamp == lastTimestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      installDate,
      honeymoonActive,
      favoriteSlotLimit,
      ttsPlayCount,
      ttsLastResetDate,
      adWatchCount,
      adLastResetDate,
      lastAdWatchTimestamp,
      unlockExpiresAt,
      const DeepCollectionEquality().hash(_purchasedPackIds),
      const DeepCollectionEquality().hash(_ddayUnlockedDates),
      lastTimestamp);

  /// Create a copy of MonetizationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonetizationStateImplCopyWith<_$MonetizationStateImpl> get copyWith =>
      __$$MonetizationStateImplCopyWithImpl<_$MonetizationStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MonetizationStateImplToJson(
      this,
    );
  }
}

abstract class _MonetizationState implements MonetizationState {
  const factory _MonetizationState(
      {final String? installDate,
      final bool honeymoonActive,
      final int favoriteSlotLimit,
      final int ttsPlayCount,
      final String? ttsLastResetDate,
      final int adWatchCount,
      final String? adLastResetDate,
      final int lastAdWatchTimestamp,
      final int unlockExpiresAt,
      final List<String> purchasedPackIds,
      final List<String> ddayUnlockedDates,
      final int lastTimestamp}) = _$MonetizationStateImpl;

  factory _MonetizationState.fromJson(Map<String, dynamic> json) =
      _$MonetizationStateImpl.fromJson;

  /// 앱 설치 날짜 (yyyy-MM-dd). null이면 아직 설정되지 않음.
  @override
  String? get installDate;

  /// 허니문(무료 체험) 기간 활성 여부. 기본 true.
  @override
  bool get honeymoonActive;

  /// 즐겨찾기 슬롯 제한. 0 = 무제한 (허니문/Pro), 3 = 기본 제한.
  @override
  int get favoriteSlotLimit;

  /// 오늘 TTS 재생 횟수.
  @override
  int get ttsPlayCount;

  /// TTS 횟수 마지막 리셋 날짜 (yyyy-MM-dd).
  @override
  String? get ttsLastResetDate;

  /// 오늘 보상형 광고 시청 횟수.
  @override
  int get adWatchCount;

  /// 광고 횟수 마지막 리셋 날짜 (yyyy-MM-dd).
  @override
  String? get adLastResetDate;

  /// 마지막 광고 시청 타임스탬프 (ms since epoch). 5분 쿨다운 검증용.
  @override
  int get lastAdWatchTimestamp;

  /// 해금 만료 타임스탬프 (ms since epoch). 0 = 해금 없음.
  @override
  int get unlockExpiresAt;

  /// 구매 완료된 팩 ID 목록.
  @override
  List<String> get purchasedPackIds;

  /// D-day 해금 날짜 목록 ('{date}_{eventId}' 형식).
  @override
  List<String> get ddayUnlockedDates;

  /// 단조증가 타임스탬프 (밀리초). 시간 조작 방어용.
  @override
  int get lastTimestamp;

  /// Create a copy of MonetizationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonetizationStateImplCopyWith<_$MonetizationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
