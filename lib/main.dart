import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/app.dart';
import 'package:fangeul/presentation/providers/analytics_providers.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/services/analytics_events.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
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
