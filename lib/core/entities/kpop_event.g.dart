// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kpop_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KpopEventImpl _$$KpopEventImplFromJson(Map<String, dynamic> json) =>
    _$KpopEventImpl(
      date: json['date'] as String,
      type: json['type'] as String,
      artist: json['artist'] as String,
      group: json['group'] as String,
      situation: json['situation'] as String,
    );

Map<String, dynamic> _$$KpopEventImplToJson(_$KpopEventImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'type': instance.type,
      'artist': instance.artist,
      'group': instance.group,
      'situation': instance.situation,
    };
