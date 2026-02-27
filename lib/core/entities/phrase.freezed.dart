// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'phrase.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Phrase _$PhraseFromJson(Map<String, dynamic> json) {
  return _Phrase.fromJson(json);
}

/// @nodoc
mixin _$Phrase {
  /// 한글 원문 (예: "사랑해요")
  String get ko => throw _privateConstructorUsedError;

  /// 로마자 발음 (예: "saranghaeyo")
  String get roman => throw _privateConstructorUsedError;

  /// 문구 사용 맥락 설명 (예: "General love expression, polite form")
  String get context => throw _privateConstructorUsedError;

  /// 분류 태그 (예: ["love", "daily"])
  List<String> get tags => throw _privateConstructorUsedError;

  /// 다국어 번역 — 키: 언어 코드, 값: 번역문
  Map<String, String> get translations => throw _privateConstructorUsedError;

  /// Serializes this Phrase to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Phrase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhraseCopyWith<Phrase> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhraseCopyWith<$Res> {
  factory $PhraseCopyWith(Phrase value, $Res Function(Phrase) then) =
      _$PhraseCopyWithImpl<$Res, Phrase>;
  @useResult
  $Res call(
      {String ko,
      String roman,
      String context,
      List<String> tags,
      Map<String, String> translations});
}

/// @nodoc
class _$PhraseCopyWithImpl<$Res, $Val extends Phrase>
    implements $PhraseCopyWith<$Res> {
  _$PhraseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Phrase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ko = null,
    Object? roman = null,
    Object? context = null,
    Object? tags = null,
    Object? translations = null,
  }) {
    return _then(_value.copyWith(
      ko: null == ko
          ? _value.ko
          : ko // ignore: cast_nullable_to_non_nullable
              as String,
      roman: null == roman
          ? _value.roman
          : roman // ignore: cast_nullable_to_non_nullable
              as String,
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      translations: null == translations
          ? _value.translations
          : translations // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PhraseImplCopyWith<$Res> implements $PhraseCopyWith<$Res> {
  factory _$$PhraseImplCopyWith(
          _$PhraseImpl value, $Res Function(_$PhraseImpl) then) =
      __$$PhraseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String ko,
      String roman,
      String context,
      List<String> tags,
      Map<String, String> translations});
}

/// @nodoc
class __$$PhraseImplCopyWithImpl<$Res>
    extends _$PhraseCopyWithImpl<$Res, _$PhraseImpl>
    implements _$$PhraseImplCopyWith<$Res> {
  __$$PhraseImplCopyWithImpl(
      _$PhraseImpl _value, $Res Function(_$PhraseImpl) _then)
      : super(_value, _then);

  /// Create a copy of Phrase
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ko = null,
    Object? roman = null,
    Object? context = null,
    Object? tags = null,
    Object? translations = null,
  }) {
    return _then(_$PhraseImpl(
      ko: null == ko
          ? _value.ko
          : ko // ignore: cast_nullable_to_non_nullable
              as String,
      roman: null == roman
          ? _value.roman
          : roman // ignore: cast_nullable_to_non_nullable
              as String,
      context: null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      translations: null == translations
          ? _value._translations
          : translations // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PhraseImpl implements _Phrase {
  const _$PhraseImpl(
      {required this.ko,
      required this.roman,
      required this.context,
      final List<String> tags = const [],
      final Map<String, String> translations = const {}})
      : _tags = tags,
        _translations = translations;

  factory _$PhraseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhraseImplFromJson(json);

  /// 한글 원문 (예: "사랑해요")
  @override
  final String ko;

  /// 로마자 발음 (예: "saranghaeyo")
  @override
  final String roman;

  /// 문구 사용 맥락 설명 (예: "General love expression, polite form")
  @override
  final String context;

  /// 분류 태그 (예: ["love", "daily"])
  final List<String> _tags;

  /// 분류 태그 (예: ["love", "daily"])
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// 다국어 번역 — 키: 언어 코드, 값: 번역문
  final Map<String, String> _translations;

  /// 다국어 번역 — 키: 언어 코드, 값: 번역문
  @override
  @JsonKey()
  Map<String, String> get translations {
    if (_translations is EqualUnmodifiableMapView) return _translations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_translations);
  }

  @override
  String toString() {
    return 'Phrase(ko: $ko, roman: $roman, context: $context, tags: $tags, translations: $translations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhraseImpl &&
            (identical(other.ko, ko) || other.ko == ko) &&
            (identical(other.roman, roman) || other.roman == roman) &&
            (identical(other.context, context) || other.context == context) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._translations, _translations));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      ko,
      roman,
      context,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_translations));

  /// Create a copy of Phrase
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhraseImplCopyWith<_$PhraseImpl> get copyWith =>
      __$$PhraseImplCopyWithImpl<_$PhraseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhraseImplToJson(
      this,
    );
  }
}

abstract class _Phrase implements Phrase {
  const factory _Phrase(
      {required final String ko,
      required final String roman,
      required final String context,
      final List<String> tags,
      final Map<String, String> translations}) = _$PhraseImpl;

  factory _Phrase.fromJson(Map<String, dynamic> json) = _$PhraseImpl.fromJson;

  /// 한글 원문 (예: "사랑해요")
  @override
  String get ko;

  /// 로마자 발음 (예: "saranghaeyo")
  @override
  String get roman;

  /// 문구 사용 맥락 설명 (예: "General love expression, polite form")
  @override
  String get context;

  /// 분류 태그 (예: ["love", "daily"])
  @override
  List<String> get tags;

  /// 다국어 번역 — 키: 언어 코드, 값: 번역문
  @override
  Map<String, String> get translations;

  /// Create a copy of Phrase
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhraseImplCopyWith<_$PhraseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
