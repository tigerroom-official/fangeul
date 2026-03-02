// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'idol_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IdolGroup _$IdolGroupFromJson(Map<String, dynamic> json) {
  return _IdolGroup.fromJson(json);
}

/// @nodoc
mixin _$IdolGroup {
  /// 고유 식별자 (예: "bts")
  String get id => throw _privateConstructorUsedError;

  /// 영문 그룹명 (예: "BTS")
  @JsonKey(name: 'name_en')
  String get nameEn => throw _privateConstructorUsedError;

  /// 한글 그룹명 (예: "방탄소년단")
  @JsonKey(name: 'name_ko')
  String get nameKo => throw _privateConstructorUsedError;

  /// Serializes this IdolGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IdolGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IdolGroupCopyWith<IdolGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdolGroupCopyWith<$Res> {
  factory $IdolGroupCopyWith(IdolGroup value, $Res Function(IdolGroup) then) =
      _$IdolGroupCopyWithImpl<$Res, IdolGroup>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'name_en') String nameEn,
      @JsonKey(name: 'name_ko') String nameKo});
}

/// @nodoc
class _$IdolGroupCopyWithImpl<$Res, $Val extends IdolGroup>
    implements $IdolGroupCopyWith<$Res> {
  _$IdolGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IdolGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameEn = null,
    Object? nameKo = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      nameKo: null == nameKo
          ? _value.nameKo
          : nameKo // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IdolGroupImplCopyWith<$Res>
    implements $IdolGroupCopyWith<$Res> {
  factory _$$IdolGroupImplCopyWith(
          _$IdolGroupImpl value, $Res Function(_$IdolGroupImpl) then) =
      __$$IdolGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'name_en') String nameEn,
      @JsonKey(name: 'name_ko') String nameKo});
}

/// @nodoc
class __$$IdolGroupImplCopyWithImpl<$Res>
    extends _$IdolGroupCopyWithImpl<$Res, _$IdolGroupImpl>
    implements _$$IdolGroupImplCopyWith<$Res> {
  __$$IdolGroupImplCopyWithImpl(
      _$IdolGroupImpl _value, $Res Function(_$IdolGroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of IdolGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameEn = null,
    Object? nameKo = null,
  }) {
    return _then(_$IdolGroupImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      nameKo: null == nameKo
          ? _value.nameKo
          : nameKo // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IdolGroupImpl implements _IdolGroup {
  const _$IdolGroupImpl(
      {required this.id,
      @JsonKey(name: 'name_en') required this.nameEn,
      @JsonKey(name: 'name_ko') required this.nameKo});

  factory _$IdolGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdolGroupImplFromJson(json);

  /// 고유 식별자 (예: "bts")
  @override
  final String id;

  /// 영문 그룹명 (예: "BTS")
  @override
  @JsonKey(name: 'name_en')
  final String nameEn;

  /// 한글 그룹명 (예: "방탄소년단")
  @override
  @JsonKey(name: 'name_ko')
  final String nameKo;

  @override
  String toString() {
    return 'IdolGroup(id: $id, nameEn: $nameEn, nameKo: $nameKo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdolGroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.nameKo, nameKo) || other.nameKo == nameKo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nameEn, nameKo);

  /// Create a copy of IdolGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IdolGroupImplCopyWith<_$IdolGroupImpl> get copyWith =>
      __$$IdolGroupImplCopyWithImpl<_$IdolGroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IdolGroupImplToJson(
      this,
    );
  }
}

abstract class _IdolGroup implements IdolGroup {
  const factory _IdolGroup(
          {required final String id,
          @JsonKey(name: 'name_en') required final String nameEn,
          @JsonKey(name: 'name_ko') required final String nameKo}) =
      _$IdolGroupImpl;

  factory _IdolGroup.fromJson(Map<String, dynamic> json) =
      _$IdolGroupImpl.fromJson;

  /// 고유 식별자 (예: "bts")
  @override
  String get id;

  /// 영문 그룹명 (예: "BTS")
  @override
  @JsonKey(name: 'name_en')
  String get nameEn;

  /// 한글 그룹명 (예: "방탄소년단")
  @override
  @JsonKey(name: 'name_ko')
  String get nameKo;

  /// Create a copy of IdolGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IdolGroupImplCopyWith<_$IdolGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
