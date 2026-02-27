// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'phrase_pack.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PhrasePack _$PhrasePackFromJson(Map<String, dynamic> json) {
  return _PhrasePack.fromJson(json);
}

/// @nodoc
mixin _$PhrasePack {
  /// 팩 고유 식별자 (예: "basic_love")
  String get id => throw _privateConstructorUsedError;

  /// 영문 팩 이름 (예: "Love & Support")
  String get name => throw _privateConstructorUsedError;

  /// 한국어 팩 이름 (예: "사랑 & 응원")
  String get nameKo => throw _privateConstructorUsedError;

  /// 무료 여부. false이면 [unlockType]으로 해금 필요.
  bool get isFree => throw _privateConstructorUsedError;

  /// 해금 방식 (예: "rewarded_ad"). [isFree]가 true이면 null.
  String? get unlockType => throw _privateConstructorUsedError;

  /// 팩에 포함된 문구 목록
  List<Phrase> get phrases => throw _privateConstructorUsedError;

  /// Serializes this PhrasePack to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhrasePack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhrasePackCopyWith<PhrasePack> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhrasePackCopyWith<$Res> {
  factory $PhrasePackCopyWith(
          PhrasePack value, $Res Function(PhrasePack) then) =
      _$PhrasePackCopyWithImpl<$Res, PhrasePack>;
  @useResult
  $Res call(
      {String id,
      String name,
      String nameKo,
      bool isFree,
      String? unlockType,
      List<Phrase> phrases});
}

/// @nodoc
class _$PhrasePackCopyWithImpl<$Res, $Val extends PhrasePack>
    implements $PhrasePackCopyWith<$Res> {
  _$PhrasePackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhrasePack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameKo = null,
    Object? isFree = null,
    Object? unlockType = freezed,
    Object? phrases = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameKo: null == nameKo
          ? _value.nameKo
          : nameKo // ignore: cast_nullable_to_non_nullable
              as String,
      isFree: null == isFree
          ? _value.isFree
          : isFree // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockType: freezed == unlockType
          ? _value.unlockType
          : unlockType // ignore: cast_nullable_to_non_nullable
              as String?,
      phrases: null == phrases
          ? _value.phrases
          : phrases // ignore: cast_nullable_to_non_nullable
              as List<Phrase>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PhrasePackImplCopyWith<$Res>
    implements $PhrasePackCopyWith<$Res> {
  factory _$$PhrasePackImplCopyWith(
          _$PhrasePackImpl value, $Res Function(_$PhrasePackImpl) then) =
      __$$PhrasePackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String nameKo,
      bool isFree,
      String? unlockType,
      List<Phrase> phrases});
}

/// @nodoc
class __$$PhrasePackImplCopyWithImpl<$Res>
    extends _$PhrasePackCopyWithImpl<$Res, _$PhrasePackImpl>
    implements _$$PhrasePackImplCopyWith<$Res> {
  __$$PhrasePackImplCopyWithImpl(
      _$PhrasePackImpl _value, $Res Function(_$PhrasePackImpl) _then)
      : super(_value, _then);

  /// Create a copy of PhrasePack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameKo = null,
    Object? isFree = null,
    Object? unlockType = freezed,
    Object? phrases = null,
  }) {
    return _then(_$PhrasePackImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameKo: null == nameKo
          ? _value.nameKo
          : nameKo // ignore: cast_nullable_to_non_nullable
              as String,
      isFree: null == isFree
          ? _value.isFree
          : isFree // ignore: cast_nullable_to_non_nullable
              as bool,
      unlockType: freezed == unlockType
          ? _value.unlockType
          : unlockType // ignore: cast_nullable_to_non_nullable
              as String?,
      phrases: null == phrases
          ? _value._phrases
          : phrases // ignore: cast_nullable_to_non_nullable
              as List<Phrase>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PhrasePackImpl implements _PhrasePack {
  const _$PhrasePackImpl(
      {required this.id,
      required this.name,
      required this.nameKo,
      this.isFree = true,
      this.unlockType,
      final List<Phrase> phrases = const []})
      : _phrases = phrases;

  factory _$PhrasePackImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhrasePackImplFromJson(json);

  /// 팩 고유 식별자 (예: "basic_love")
  @override
  final String id;

  /// 영문 팩 이름 (예: "Love & Support")
  @override
  final String name;

  /// 한국어 팩 이름 (예: "사랑 & 응원")
  @override
  final String nameKo;

  /// 무료 여부. false이면 [unlockType]으로 해금 필요.
  @override
  @JsonKey()
  final bool isFree;

  /// 해금 방식 (예: "rewarded_ad"). [isFree]가 true이면 null.
  @override
  final String? unlockType;

  /// 팩에 포함된 문구 목록
  final List<Phrase> _phrases;

  /// 팩에 포함된 문구 목록
  @override
  @JsonKey()
  List<Phrase> get phrases {
    if (_phrases is EqualUnmodifiableListView) return _phrases;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_phrases);
  }

  @override
  String toString() {
    return 'PhrasePack(id: $id, name: $name, nameKo: $nameKo, isFree: $isFree, unlockType: $unlockType, phrases: $phrases)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhrasePackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameKo, nameKo) || other.nameKo == nameKo) &&
            (identical(other.isFree, isFree) || other.isFree == isFree) &&
            (identical(other.unlockType, unlockType) ||
                other.unlockType == unlockType) &&
            const DeepCollectionEquality().equals(other._phrases, _phrases));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, nameKo, isFree,
      unlockType, const DeepCollectionEquality().hash(_phrases));

  /// Create a copy of PhrasePack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhrasePackImplCopyWith<_$PhrasePackImpl> get copyWith =>
      __$$PhrasePackImplCopyWithImpl<_$PhrasePackImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhrasePackImplToJson(
      this,
    );
  }
}

abstract class _PhrasePack implements PhrasePack {
  const factory _PhrasePack(
      {required final String id,
      required final String name,
      required final String nameKo,
      final bool isFree,
      final String? unlockType,
      final List<Phrase> phrases}) = _$PhrasePackImpl;

  factory _PhrasePack.fromJson(Map<String, dynamic> json) =
      _$PhrasePackImpl.fromJson;

  /// 팩 고유 식별자 (예: "basic_love")
  @override
  String get id;

  /// 영문 팩 이름 (예: "Love & Support")
  @override
  String get name;

  /// 한국어 팩 이름 (예: "사랑 & 응원")
  @override
  String get nameKo;

  /// 무료 여부. false이면 [unlockType]으로 해금 필요.
  @override
  bool get isFree;

  /// 해금 방식 (예: "rewarded_ad"). [isFree]가 true이면 null.
  @override
  String? get unlockType;

  /// 팩에 포함된 문구 목록
  @override
  List<Phrase> get phrases;

  /// Create a copy of PhrasePack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhrasePackImplCopyWith<_$PhrasePackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
