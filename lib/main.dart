import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/app.dart';
import 'package:fangeul/presentation/providers/analytics_providers.dart';
import 'package:fangeul/presentation/providers/remote_config_providers.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/router/app_router.dart';
import 'package:fangeul/services/analytics_events.dart';
import 'package:fangeul/services/firebase_remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  final configService = FirebaseRemoteConfigService();
  await configService.initialize();

  final prefs = await SharedPreferences.getInstance();

  // 첫 실행 체크: 온보딩 미완료 시 아이돌 선택으로 시작
  final isOnboardingDone = prefs.getBool('onboarding_done') ?? false;

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      remoteConfigServiceProvider.overrideWithValue(configService),
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
