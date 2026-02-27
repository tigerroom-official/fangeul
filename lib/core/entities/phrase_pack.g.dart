// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrase_pack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhrasePackImpl _$$PhrasePackImplFromJson(Map<String, dynamic> json) =>
    _$PhrasePackImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      nameKo: json['name_ko'] as String,
      isFree: json['is_free'] as bool? ?? true,
      unlockType: json['unlock_type'] as String?,
      phrases: (json['phrases'] as List<dynamic>?)
              ?.map((e) => Phrase.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PhrasePackImplToJson(_$PhrasePackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_ko': instance.nameKo,
      'is_free': instance.isFree,
      'unlock_type': instance.unlockType,
      'phrases': instance.phrases,
    };
