import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/app.dart';
import 'package:fangeul/presentation/providers/analytics_providers.dart';
import 'package:fangeul/presentation/providers/remote_config_providers.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/router/app_router.dart';
import 'package:fangeul/presentation/providers/ad_service_provider.dart';
import 'package:fangeul/presentation/providers/iap_provider.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';
import 'package:fangeul/services/analytics_events.dart';
import 'package:fangeul/services/firebase_analytics_service.dart';
import 'package:fangeul/services/firebase_remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('[main] Firebase.initializeApp failed: $e');
  }

  // Crashlytics: Flutter 프레임워크 에러 캡처
  try {
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    if (kDebugMode) {
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(false);
    }
  } catch (e) {
    debugPrint('[main] Crashlytics setup failed: $e');
  }

  final configService = FirebaseRemoteConfigService();
  try {
    await configService.initialize();
  } catch (e) {
    debugPrint('[main] RemoteConfig initialize failed: $e');
  }

  final prefs = await SharedPreferences.getInstance();

  // 첫 실행 체크: 온보딩 미완료 시 아이돌 선택으로 시작
  final isOnboardingDone = prefs.getBool('onboarding_done') ?? false;

  final analyticsService = FirebaseAnalyticsService();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      remoteConfigServiceProvider.overrideWithValue(configService),
      analyticsServiceProvider.overrideWithValue(analyticsService),
      if (!isOnboardingDone)
        initialRouteOverrideProvider
            .overrideWithValue('/onboarding/idol-select'),
    ],
  );

  container.read(analyticsServiceProvider).logEvent(AnalyticsEvents.appOpen);

  // AdMob SDK 초기화 (fire-and-forget, provider 인스턴스 사용)
  container.read(adServiceProvider).initialize();

  // 일일 카운터(광고/TTS) 리셋 — 앱 시작 시 날짜 변경 확인
  // AsyncNotifier build 완료 대기 후 리셋 호출
  container.read(monetizationNotifierProvider.future).then((_) {
    container
        .read(monetizationNotifierProvider.notifier)
        .checkDailyReset()
        .catchError((Object e) {
      debugPrint('[main] checkDailyReset failed: $e');
    });
  }).catchError((Object e) {
    debugPrint('[main] monetization init failed: $e');
  });

  // IAP 서비스 eager 초기화 — 상품 로드 후 iapProductsLoadedProvider가 true로 전환
  container.read(iapServiceProvider);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FangeulApp(),
    ),
  );
}
