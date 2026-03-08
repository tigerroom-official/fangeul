import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'package:fangeul/core/entities/remote_config_values.dart';
import 'package:fangeul/services/remote_config_service.dart';

/// Firebase Remote Config 구현체.
///
/// 원격 값을 가져오되, 실패 시 기본값으로 폴백한다.
class FirebaseRemoteConfigService implements RemoteConfigService {
  /// Firebase Remote Config 인스턴스를 주입받아 생성한다.
  ///
  /// [instance]가 null이면 싱글턴 인스턴스를 사용한다.
  FirebaseRemoteConfigService([FirebaseRemoteConfig? instance])
      : _rc = instance ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _rc;

  RemoteConfigValues _values = const RemoteConfigValues();

  @override
  Future<void> initialize() async {
    await _rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await _rc.setDefaults({
      'honeymoon_days': 14,
      'default_slot_limit': 5,
      'daily_ad_limit': 3,
      'ad_cooldown_minutes': 5,
      'unlock_duration_hours': 24,
      'daily_tts_limit': 5,
      'conversion_trigger_ad_count': 3,
    });

    try {
      await _rc.fetchAndActivate();
    } catch (_) {
      // 네트워크 실패 시 기본값 사용
    }

    _values = RemoteConfigValues(
      honeymoonDays: _rc.getInt('honeymoon_days'),
      defaultSlotLimit: _rc.getInt('default_slot_limit'),
      dailyAdLimit: _rc.getInt('daily_ad_limit'),
      adCooldownMinutes: _rc.getInt('ad_cooldown_minutes'),
      unlockDurationHours: _rc.getInt('unlock_duration_hours'),
      dailyTtsLimit: _rc.getInt('daily_tts_limit'),
      conversionTriggerAdCount: _rc.getInt('conversion_trigger_ad_count'),
    );
  }

  @override
  RemoteConfigValues get values => _values;
}
