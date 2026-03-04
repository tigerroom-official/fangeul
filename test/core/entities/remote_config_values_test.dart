import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/remote_config_values.dart';

void main() {
  group('RemoteConfigValues', () {
    test('should have correct default values', () {
      const values = RemoteConfigValues();
      expect(values.honeymoonDays, 14);
      expect(values.defaultSlotLimit, 5);
      expect(values.dailyAdLimit, 3);
      expect(values.adCooldownMinutes, 5);
      expect(values.unlockDurationHours, 4);
      expect(values.dailyTtsLimit, 5);
      expect(values.conversionTriggerAdCount, 3);
    });

    test('should accept custom values', () {
      const values = RemoteConfigValues(
        honeymoonDays: 7,
        defaultSlotLimit: 3,
        dailyAdLimit: 5,
        adCooldownMinutes: 10,
        unlockDurationHours: 8,
        dailyTtsLimit: 10,
        conversionTriggerAdCount: 5,
      );
      expect(values.honeymoonDays, 7);
      expect(values.defaultSlotLimit, 3);
      expect(values.dailyAdLimit, 5);
      expect(values.adCooldownMinutes, 10);
      expect(values.unlockDurationHours, 8);
      expect(values.dailyTtsLimit, 10);
      expect(values.conversionTriggerAdCount, 5);
    });
  });
}
