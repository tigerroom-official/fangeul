// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhraseImpl _$$PhraseImplFromJson(Map<String, dynamic> json) => _$PhraseImpl(
      ko: json['ko'] as String,
      roman: json['roman'] as String,
      context: json['context'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      translations: (json['translations'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      situation: json['situation'] as String?,
      isTemplate: json['is_template'] as bool? ?? false,
      audioId: json['audio_id'] as String?,
    );

Map<String, dynamic> _$$PhraseImplToJson(_$PhraseImpl instance) =>
    <String, dynamic>{
      'ko': instance.ko,
      'roman': instance.roman,
      'context': instance.context,
      'tags': instance.tags,
      'translations': instance.translations,
      'situation': instance.situation,
      'is_template': instance.isTemplate,
      'audio_id': instance.audioId,
    };
