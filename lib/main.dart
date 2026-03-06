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
import 'package:fangeul/services/analytics_events.dart';
import 'package:fangeul/services/firebase_analytics_service.dart';
import 'package:fangeul/services/ad_service.dart';
import 'package:fangeul/services/firebase_remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // AdMob SDK 초기화 (fire-and-forget, 크리티컬 패스 미포함)
  AdService().initialize();

  // Crashlytics: Flutter 프레임워크 에러 캡처
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Crashlytics: 비동기 에러(플랫폼 디스패처) 캡처
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 디버그 빌드에서는 Crashlytics 비활성화 (노이즈 방지)
  if (kDebugMode) {
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(false);
  }

  final configService = FirebaseRemoteConfigService();
  await configService.initialize();

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

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FangeulApp(),
    ),
  );
}
