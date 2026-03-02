// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kpop_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

KpopEvent _$KpopEventFromJson(Map<String, dynamic> json) {
  return _KpopEvent.fromJson(json);
}

/// @nodoc
mixin _$KpopEvent {
  /// MM-DD 형식의 날짜 (예: "03-09")
  String get date => throw _privateConstructorUsedError;

  /// 이벤트 유형 (birthday / comeback / debut_anniversary)
  String get type => throw _privateConstructorUsedError;

  /// 아티스트 이름 (예: "슈가")
  String get artist => throw _privateConstructorUsedError;

  /// 그룹 이름 (예: "BTS")
  String get group => throw _privateConstructorUsedError;

  /// Phrase.situation과 매칭되는 상황 태그
  String get situation => throw _privateConstructorUsedError;

  /// Serializes this KpopEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KpopEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KpopEventCopyWith<KpopEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KpopEventCopyWith<$Res> {
  factory $KpopEventCopyWith(KpopEvent value, $Res Function(KpopEvent) then) =
      _$KpopEventCopyWithImpl<$Res, KpopEvent>;
  @useResult
  $Res call(
      {String date,
      String type,
      String artist,
      String group,
      String situation});
}

/// @nodoc
class _$KpopEventCopyWithImpl<$Res, $Val extends KpopEvent>
    implements $KpopEventCopyWith<$Res> {
  _$KpopEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KpopEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? type = null,
    Object? artist = null,
    Object? group = null,
    Object? situation = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      group: null == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as String,
      situation: null == situation
          ? _value.situation
          : situation // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KpopEventImplCopyWith<$Res>
    implements $KpopEventCopyWith<$Res> {
  factory _$$KpopEventImplCopyWith(
          _$KpopEventImpl value, $Res Function(_$KpopEventImpl) then) =
      __$$KpopEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String date,
      String type,
      String artist,
      String group,
      String situation});
}

/// @nodoc
class __$$KpopEventImplCopyWithImpl<$Res>
    extends _$KpopEventCopyWithImpl<$Res, _$KpopEventImpl>
    implements _$$KpopEventImplCopyWith<$Res> {
  __$$KpopEventImplCopyWithImpl(
      _$KpopEventImpl _value, $Res Function(_$KpopEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of KpopEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? type = null,
    Object? artist = null,
    Object? group = null,
    Object? situation = null,
  }) {
    return _then(_$KpopEventImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      group: null == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as String,
      situation: null == situation
          ? _value.situation
          : situation // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$KpopEventImpl implements _KpopEvent {
  const _$KpopEventImpl(
      {required this.date,
      required this.type,
      required this.artist,
      required this.group,
      required this.situation});

  factory _$KpopEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$KpopEventImplFromJson(json);

  /// MM-DD 형식의 날짜 (예: "03-09")
  @override
  final String date;

  /// 이벤트 유형 (birthday / comeback / debut_anniversary)
  @override
  final String type;

  /// 아티스트 이름 (예: "슈가")
  @override
  final String artist;

  /// 그룹 이름 (예: "BTS")
  @override
  final String group;

  /// Phrase.situation과 매칭되는 상황 태그
  @override
  final String situation;

  @override
  String toString() {
    return 'KpopEvent(date: $date, type: $type, artist: $artist, group: $group, situation: $situation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KpopEventImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.situation, situation) ||
                other.situation == situation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, type, artist, group, situation);

  /// Create a copy of KpopEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KpopEventImplCopyWith<_$KpopEventImpl> get copyWith =>
      __$$KpopEventImplCopyWithImpl<_$KpopEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KpopEventImplToJson(
      this,
    );
  }
}

abstract class _KpopEvent implements KpopEvent {
  const factory _KpopEvent(
      {required final String date,
      required final String type,
      required final String artist,
      required final String group,
      required final String situation}) = _$KpopEventImpl;

  factory _KpopEvent.fromJson(Map<String, dynamic> json) =
      _$KpopEventImpl.fromJson;

  /// MM-DD 형식의 날짜 (예: "03-09")
  @override
  String get date;

  /// 이벤트 유형 (birthday / comeback / debut_anniversary)
  @override
  String get type;

  /// 아티스트 이름 (예: "슈가")
  @override
  String get artist;

  /// 그룹 이름 (예: "BTS")
  @override
  String get group;

  /// Phrase.situation과 매칭되는 상황 태그
  @override
  String get situation;

  /// Create a copy of KpopEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KpopEventImplCopyWith<_$KpopEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
