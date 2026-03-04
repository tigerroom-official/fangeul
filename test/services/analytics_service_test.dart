import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/services/analytics_events.dart';
import 'package:fangeul/services/analytics_service.dart';
import 'package:fangeul/services/noop_analytics_service.dart';

/// 이벤트 기록을 캡처하는 테스트용 구현.
class RecordingAnalyticsService implements AnalyticsService {
  final List<({String name, Map<String, Object>? params})> events = [];
  final List<({String name, String value})> userProperties = [];

  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    events.add((name: name, params: params));
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    userProperties.add((name: name, value: value));
  }
}

void main() {
  group('NoOpAnalyticsService', () {
    late NoOpAnalyticsService service;

    setUp(() {
      service = NoOpAnalyticsService();
    });

    test('should not throw on logEvent', () async {
      await expectLater(
        service.logEvent('test_event'),
        completes,
      );
    });

    test('should not throw on logEvent with params', () async {
      await expectLater(
        service.logEvent('test_event', {'key': 'value'}),
        completes,
      );
    });

    test('should not throw on setUserProperty', () async {
      await expectLater(
        service.setUserProperty('prop', 'value'),
        completes,
      );
    });
  });

  group('RecordingAnalyticsService', () {
    late RecordingAnalyticsService service;

    setUp(() {
      service = RecordingAnalyticsService();
    });

    test('should record logEvent calls', () async {
      await service.logEvent(AnalyticsEvents.appOpen);
      await service.logEvent(
        AnalyticsEvents.phraseCopy,
        {AnalyticsParams.source: 'bubble'},
      );

      expect(service.events, hasLength(2));
      expect(service.events[0].name, AnalyticsEvents.appOpen);
      expect(service.events[0].params, isNull);
      expect(service.events[1].name, AnalyticsEvents.phraseCopy);
      expect(service.events[1].params, {AnalyticsParams.source: 'bubble'});
    });

    test('should record setUserProperty calls', () async {
      await service.setUserProperty('theme', 'dark');

      expect(service.userProperties, hasLength(1));
      expect(service.userProperties[0].name, 'theme');
      expect(service.userProperties[0].value, 'dark');
    });
  });

  group('AnalyticsEvents constants', () {
    test('should have all required event names', () {
      expect(AnalyticsEvents.appOpen, 'app_open');
      expect(AnalyticsEvents.bubbleSessionStart, 'bubble_session_start');
      expect(AnalyticsEvents.bubbleSessionEnd, 'bubble_session_end');
      expect(AnalyticsEvents.phraseCopy, 'phrase_copy');
      expect(AnalyticsEvents.phraseFavorite, 'phrase_favorite');
      expect(AnalyticsEvents.filterChange, 'filter_change');
      expect(AnalyticsEvents.calendarEventView, 'calendar_event_view');
    });

    test('should have monetization event names', () {
      expect(AnalyticsEvents.adBannerImpression, 'ad_banner_impression');
      expect(AnalyticsEvents.adRewardedStart, 'ad_rewarded_start');
      expect(AnalyticsEvents.adRewardedComplete, 'ad_rewarded_complete');
      expect(AnalyticsEvents.adRewardedFailed, 'ad_rewarded_failed');
      expect(AnalyticsEvents.fanPassActivated, 'fan_pass_activated');
      expect(AnalyticsEvents.fanPassExpired, 'fan_pass_expired');
      expect(AnalyticsEvents.iapViewShop, 'iap_view_shop');
      expect(AnalyticsEvents.iapStartPurchase, 'iap_start_purchase');
      expect(AnalyticsEvents.iapPurchaseSuccess, 'iap_purchase_success');
      expect(AnalyticsEvents.iapPurchaseFailed, 'iap_purchase_failed');
      expect(AnalyticsEvents.iapRestorePurchase, 'iap_restore_purchase');
      expect(AnalyticsEvents.favLimitReached, 'fav_limit_reached');
      expect(AnalyticsEvents.ttsLimitReached, 'tts_limit_reached');
      expect(
          AnalyticsEvents.conversionTriggerShown, 'conversion_trigger_shown');
      expect(AnalyticsEvents.conversionTriggerClicked,
          'conversion_trigger_clicked');
      expect(AnalyticsEvents.ddayGiftActivated, 'dday_gift_activated');
      expect(AnalyticsEvents.honeymoonEnded, 'honeymoon_ended');
    });

    test('should have all required param keys', () {
      expect(AnalyticsParams.packId, 'pack_id');
      expect(AnalyticsParams.situation, 'situation');
      expect(AnalyticsParams.source, 'source');
      expect(AnalyticsParams.action, 'action');
      expect(AnalyticsParams.filterType, 'filter_type');
      expect(AnalyticsParams.durationSec, 'duration_sec');
      expect(AnalyticsParams.eventType, 'event_type');
      expect(AnalyticsParams.artist, 'artist');
      expect(AnalyticsParams.skuId, 'sku_id');
      expect(AnalyticsParams.revenue, 'revenue');
      expect(AnalyticsParams.unlockDurationMin, 'unlock_duration_min');
      expect(AnalyticsParams.daysSinceInstall, 'days_since_install');
    });
  });
}
