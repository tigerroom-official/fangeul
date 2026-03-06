// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monetization_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonetizationStateImpl _$$MonetizationStateImplFromJson(
        Map<String, dynamic> json) =>
    _$MonetizationStateImpl(
      installDate: json['install_date'] as String?,
      honeymoonActive: json['honeymoon_active'] as bool? ?? true,
      favoriteSlotLimit: (json['favorite_slot_limit'] as num?)?.toInt() ?? 0,
      ttsPlayCount: (json['tts_play_count'] as num?)?.toInt() ?? 0,
      ttsLastResetDate: json['tts_last_reset_date'] as String?,
      adWatchCount: (json['ad_watch_count'] as num?)?.toInt() ?? 0,
      adLastResetDate: json['ad_last_reset_date'] as String?,
      lastAdWatchTimestamp:
          (json['last_ad_watch_timestamp'] as num?)?.toInt() ?? 0,
      unlockExpiresAt: (json['unlock_expires_at'] as num?)?.toInt() ?? 0,
      purchasedPackIds: (json['purchased_pack_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ddayUnlockedDates: (json['dday_unlocked_dates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hasThemePicker: json['has_theme_picker'] as bool? ?? false,
      lastTimestamp: (json['last_timestamp'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MonetizationStateImplToJson(
        _$MonetizationStateImpl instance) =>
    <String, dynamic>{
      'install_date': instance.installDate,
      'honeymoon_active': instance.honeymoonActive,
      'favorite_slot_limit': instance.favoriteSlotLimit,
      'tts_play_count': instance.ttsPlayCount,
      'tts_last_reset_date': instance.ttsLastResetDate,
      'ad_watch_count': instance.adWatchCount,
      'ad_last_reset_date': instance.adLastResetDate,
      'last_ad_watch_timestamp': instance.lastAdWatchTimestamp,
      'unlock_expires_at': instance.unlockExpiresAt,
      'purchased_pack_ids': instance.purchasedPackIds,
      'dday_unlocked_dates': instance.ddayUnlockedDates,
      'has_theme_picker': instance.hasThemePicker,
      'last_timestamp': instance.lastTimestamp,
    };
