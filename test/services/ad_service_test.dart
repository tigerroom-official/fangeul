import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/services/ad_ids.dart';
import 'package:fangeul/services/ad_service.dart';

void main() {
  group('AdIds', () {
    test('should return test IDs in debug mode', () {
      expect(AdIds.bannerId, contains('3940256099942544'));
      expect(AdIds.rewardedId, contains('3940256099942544'));
    });

    test('should have different banner and rewarded IDs', () {
      expect(AdIds.bannerId, isNot(equals(AdIds.rewardedId)));
    });
  });

  group('AdService', () {
    test('should create without errors', () {
      final service = AdService();
      expect(service.isRewardedReady, false);
      expect(service.isInitialized, false);
    });

    test('should safely dispose without loaded ads', () {
      final service = AdService();
      service.dispose(); // Should not throw
    });
  });
}
