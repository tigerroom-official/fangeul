import 'package:flutter/material.dart';

/// Fangeul 앱의 루트 위젯.
class FangeulApp extends StatelessWidget {
  /// Creates the root [FangeulApp] widget.
  const FangeulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fangeul',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C5CE7),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C5CE7),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Fangeul — Coming Soon'),
        ),
      ),
    );
  }
}
