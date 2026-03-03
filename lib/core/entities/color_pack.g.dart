// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'color_pack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ColorPackImpl _$$ColorPackImplFromJson(Map<String, dynamic> json) =>
    _$ColorPackImpl(
      id: json['id'] as String,
      nameKo: json['name_ko'] as String,
      nameEn: json['name_en'] as String,
      primaryColor: json['primary_color'] as String,
      secondaryColor: json['secondary_color'] as String,
      skuId: json['sku_id'] as String,
      priceKrw: (json['price_krw'] as num).toInt(),
      phraseCount: (json['phrase_count'] as num?)?.toInt() ?? 50,
      pronunciationCount: (json['pronunciation_count'] as num?)?.toInt() ?? 30,
      iapOnly: json['iap_only'] as bool? ?? false,
    );

Map<String, dynamic> _$$ColorPackImplToJson(_$ColorPackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_ko': instance.nameKo,
      'name_en': instance.nameEn,
      'primary_color': instance.primaryColor,
      'secondary_color': instance.secondaryColor,
      'sku_id': instance.skuId,
      'price_krw': instance.priceKrw,
      'phrase_count': instance.phraseCount,
      'pronunciation_count': instance.pronunciationCount,
      'iap_only': instance.iapOnly,
    };
