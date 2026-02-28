import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/app.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';

void main() async {
  enableFlutterDriverExtension();
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const FangeulApp(),
    ),
  );
}
