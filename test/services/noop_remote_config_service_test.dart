import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/remote_config_values.dart';
import 'package:fangeul/services/noop_remote_config_service.dart';

void main() {
  group('NoopRemoteConfigService', () {
    late NoopRemoteConfigService service;

    setUp(() {
      service = NoopRemoteConfigService();
    });

    test('should initialize without error', () async {
      await service.initialize();
    });

    test('should return default values', () {
      final values = service.values;
      expect(values.honeymoonDays, 14);
      expect(values.defaultSlotLimit, 5);
      expect(values.dailyAdLimit, 3);
    });

    test('should return const RemoteConfigValues', () {
      expect(service.values, isA<RemoteConfigValues>());
    });
  });
}
