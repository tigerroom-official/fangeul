// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'color_pack.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ColorPack _$ColorPackFromJson(Map<String, dynamic> json) {
  return _ColorPack.fromJson(json);
}

/// @nodoc
mixin _$ColorPack {
  /// 팩 고유 식별자 (예: "purple_dream").
  String get id => throw _privateConstructorUsedError;

  /// 한국어 이름 (예: "퍼플 드림").
  String get nameKo => throw _privateConstructorUsedError;

  /// 영문 이름 (예: "Purple Dream").
  String get nameEn => throw _privateConstructorUsedError;

  /// 메인 컬러 hex (예: "#A855F7").
  String get primaryColor => throw _privateConstructorUsedError;

  /// 보조 컬러 hex (예: "#7C3AED").
  String get secondaryColor => throw _privateConstructorUsedError;

  /// Google Play SKU ID.
  String get skuId => throw _privateConstructorUsedError;

  /// 가격 (원).
  int get priceKrw => throw _privateConstructorUsedError;

  /// 포함 문구 수.
  int get phraseCount => throw _privateConstructorUsedError;

  /// 포함 발음 수.
  int get pronunciationCount => throw _privateConstructorUsedError;

  /// true이면 IAP 전용 (보상형 해금 불가).
  bool get iapOnly => throw _privateConstructorUsedError;

  /// Serializes this ColorPack to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ColorPack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ColorPackCopyWith<ColorPack> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ColorPackCopyWith<$Res> {
  factory $ColorPackCopyWith(ColorPack value, $Res Function(ColorPack) then) =
      _$ColorPackCopyWithImpl<$Res, ColorPack>;
  @useResult
  $Res call(
      {String id,
      String nameKo,
      String nameEn,
      String primaryColor,
      String secondaryColor,
      String skuId,
      int priceKrw,
      int phraseCount,
      int pronunciationCount,
      bool iapOnly});
}

/// @nodoc
class _$ColorPackCopyWithImpl<$Res, $Val extends ColorPack>
    implements $ColorPackCopyWith<$Res> {
  _$ColorPackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ColorPack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameKo = null,
    Object? nameEn = null,
    Object? primaryColor = null,
    Object? secondaryColor = null,
    Object? skuId = null,
    Object? priceKrw = null,
    Object? phraseCount = null,
    Object? pronunciationCount = null,
    Object? iapOnly = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nameKo: null == nameKo
          ? _value.nameKo
          : nameKo // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      primaryColor: null == primaryColor
          ? _value.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryColor: null == secondaryColor
          ? _value.secondaryColor
          : secondaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      skuId: null == skuId
          ? _value.skuId
          : skuId // ignore: cast_nullable_to_non_nullable
              as String,
      priceKrw: null == priceKrw
          ? _value.priceKrw
          : priceKrw // ignore: cast_nullable_to_non_nullable
              as int,
      phraseCount: null == phraseCount
          ? _value.phraseCount
          : phraseCount // ignore: cast_nullable_to_non_nullable
              as int,
      pronunciationCount: null == pronunciationCount
          ? _value.pronunciationCount
          : pronunciationCount // ignore: cast_nullable_to_non_nullable
              as int,
      iapOnly: null == iapOnly
          ? _value.iapOnly
          : iapOnly // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ColorPackImplCopyWith<$Res>
    implements $ColorPackCopyWith<$Res> {
  factory _$$ColorPackImplCopyWith(
          _$ColorPackImpl value, $Res Function(_$ColorPackImpl) then) =
      __$$ColorPackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String nameKo,
      String nameEn,
      String primaryColor,
      String secondaryColor,
      String skuId,
      int priceKrw,
      int phraseCount,
      int pronunciationCount,
      bool iapOnly});
}

/// @nodoc
class __$$ColorPackImplCopyWithImpl<$Res>
    extends _$ColorPackCopyWithImpl<$Res, _$ColorPackImpl>
    implements _$$ColorPackImplCopyWith<$Res> {
  __$$ColorPackImplCopyWithImpl(
      _$ColorPackImpl _value, $Res Function(_$ColorPackImpl) _then)
      : super(_value, _then);

  /// Create a copy of ColorPack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameKo = null,
    Object? nameEn = null,
    Object? primaryColor = null,
    Object? secondaryColor = null,
    Object? skuId = null,
    Object? priceKrw = null,
    Object? phraseCount = null,
    Object? pronunciationCount = null,
    Object? iapOnly = null,
  }) {
    return _then(_$ColorPackImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nameKo: null == nameKo
          ? _value.nameKo
          : nameKo // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      primaryColor: null == primaryColor
          ? _value.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryColor: null == secondaryColor
          ? _value.secondaryColor
          : secondaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      skuId: null == skuId
          ? _value.skuId
          : skuId // ignore: cast_nullable_to_non_nullable
              as String,
      priceKrw: null == priceKrw
          ? _value.priceKrw
          : priceKrw // ignore: cast_nullable_to_non_nullable
              as int,
      phraseCount: null == phraseCount
          ? _value.phraseCount
          : phraseCount // ignore: cast_nullable_to_non_nullable
              as int,
      pronunciationCount: null == pronunciationCount
          ? _value.pronunciationCount
          : pronunciationCount // ignore: cast_nullable_to_non_nullable
              as int,
      iapOnly: null == iapOnly
          ? _value.iapOnly
          : iapOnly // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ColorPackImpl implements _ColorPack {
  const _$ColorPackImpl(
      {required this.id,
      required this.nameKo,
      required this.nameEn,
      required this.primaryColor,
      required this.secondaryColor,
      required this.skuId,
      required this.priceKrw,
      this.phraseCount = 50,
      this.pronunciationCount = 30,
      this.iapOnly = false});

  factory _$ColorPackImpl.fromJson(Map<String, dynamic> json) =>
      _$$ColorPackImplFromJson(json);

  /// 팩 고유 식별자 (예: "purple_dream").
  @override
  final String id;

  /// 한국어 이름 (예: "퍼플 드림").
  @override
  final String nameKo;

  /// 영문 이름 (예: "Purple Dream").
  @override
  final String nameEn;

  /// 메인 컬러 hex (예: "#A855F7").
  @override
  final String primaryColor;

  /// 보조 컬러 hex (예: "#7C3AED").
  @override
  final String secondaryColor;

  /// Google Play SKU ID.
  @override
  final String skuId;

  /// 가격 (원).
  @override
  final int priceKrw;

  /// 포함 문구 수.
  @override
  @JsonKey()
  final int phraseCount;

  /// 포함 발음 수.
  @override
  @JsonKey()
  final int pronunciationCount;

  /// true이면 IAP 전용 (보상형 해금 불가).
  @override
  @JsonKey()
  final bool iapOnly;

  @override
  String toString() {
    return 'ColorPack(id: $id, nameKo: $nameKo, nameEn: $nameEn, primaryColor: $primaryColor, secondaryColor: $secondaryColor, skuId: $skuId, priceKrw: $priceKrw, phraseCount: $phraseCount, pronunciationCount: $pronunciationCount, iapOnly: $iapOnly)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ColorPackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameKo, nameKo) || other.nameKo == nameKo) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            (identical(other.secondaryColor, secondaryColor) ||
                other.secondaryColor == secondaryColor) &&
            (identical(other.skuId, skuId) || other.skuId == skuId) &&
            (identical(other.priceKrw, priceKrw) ||
                other.priceKrw == priceKrw) &&
            (identical(other.phraseCount, phraseCount) ||
                other.phraseCount == phraseCount) &&
            (identical(other.pronunciationCount, pronunciationCount) ||
                other.pronunciationCount == pronunciationCount) &&
            (identical(other.iapOnly, iapOnly) || other.iapOnly == iapOnly));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      nameKo,
      nameEn,
      primaryColor,
      secondaryColor,
      skuId,
      priceKrw,
      phraseCount,
      pronunciationCount,
      iapOnly);

  /// Create a copy of ColorPack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ColorPackImplCopyWith<_$ColorPackImpl> get copyWith =>
      __$$ColorPackImplCopyWithImpl<_$ColorPackImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ColorPackImplToJson(
      this,
    );
  }
}

abstract class _ColorPack implements ColorPack {
  const factory _ColorPack(
      {required final String id,
      required final String nameKo,
      required final String nameEn,
      required final String primaryColor,
      required final String secondaryColor,
      required final String skuId,
      required final int priceKrw,
      final int phraseCount,
      final int pronunciationCount,
      final bool iapOnly}) = _$ColorPackImpl;

  factory _ColorPack.fromJson(Map<String, dynamic> json) =
      _$ColorPackImpl.fromJson;

  /// 팩 고유 식별자 (예: "purple_dream").
  @override
  String get id;

  /// 한국어 이름 (예: "퍼플 드림").
  @override
  String get nameKo;

  /// 영문 이름 (예: "Purple Dream").
  @override
  String get nameEn;

  /// 메인 컬러 hex (예: "#A855F7").
  @override
  String get primaryColor;

  /// 보조 컬러 hex (예: "#7C3AED").
  @override
  String get secondaryColor;

  /// Google Play SKU ID.
  @override
  String get skuId;

  /// 가격 (원).
  @override
  int get priceKrw;

  /// 포함 문구 수.
  @override
  int get phraseCount;

  /// 포함 발음 수.
  @override
  int get pronunciationCount;

  /// true이면 IAP 전용 (보상형 해금 불가).
  @override
  bool get iapOnly;

  /// Create a copy of ColorPack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ColorPackImplCopyWith<_$ColorPackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
