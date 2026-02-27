# Phase 4: UI 레이어 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fangeul 앱의 전체 UI 레이어를 구현한다 — 토큰화 디자인 시스템, 3탭 네비게이션, 홈(데일리 카드+스트릭), 변환기, 문구 라이브러리, 설정, 공유 카드, Lottie 축하 애니메이션.

**Architecture:** Clean Architecture presentation 레이어. Riverpod 상태관리 + go_router 선언적 라우팅 + Material 3 명시적 오버라이드. 모든 컬러/텍스트 스타일을 토큰화하여 다크/라이트 테마 일관성 보장. 폰트는 NotoSansKR 번들로 오프라인 우선.

**Tech Stack:** Flutter 3.x, Riverpod (codegen), go_router, freezed, lottie, share_plus, Material 3

**Design Reference:** `docs/plans/2026-02-27-phase4-ui-design.md`

**기존 테스트:** `flutter test` → 139개 pass (core/engines 99개 + data layer 40개). 이 테스트는 반드시 유지.

---

## Task 1: 의존성 추가 + 폰트 에셋 설정

**Files:**
- Modify: `pubspec.yaml`
- Create: `assets/fonts/` (directory)
- Create: `assets/lottie/` (directory)

**Step 1: pubspec.yaml에 패키지 추가**

`pubspec.yaml`의 `dependencies:` 섹션에 추가:

```yaml
  # 네비게이션
  go_router: ^14.6.2

  # 애니메이션
  lottie: ^3.3.1

  # 공유
  share_plus: ^10.1.4
```

**Step 2: pubspec.yaml에 폰트 선언**

`pubspec.yaml`의 `flutter:` 섹션에 추가:

```yaml
  fonts:
    - family: NotoSansKR
      fonts:
        - asset: assets/fonts/NotoSansKR-Regular.ttf
          weight: 400
        - asset: assets/fonts/NotoSansKR-Medium.ttf
          weight: 500

  assets:
    - assets/phrases/
    - assets/audio/
    - assets/lottie/
```

기존 `assets:` 항목에 `assets/lottie/`를 추가하고, `fonts:` 섹션은 새로 생성.

**Step 3: 폰트 파일 다운로드**

```bash
mkdir -p assets/fonts assets/lottie

# NotoSansKR — Google Fonts에서 개별 weight 다운로드
# Regular (400)
curl -L -o assets/fonts/NotoSansKR-Regular.ttf \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/notosanskr/NotoSansKR%5Bwght%5D.ttf"

# 주의: Variable font 1개로 모든 weight 지원.
# 파일이 너무 크면 (~5MB), fonts.google.com에서 Static 개별 weight 다운로드.
# Regular + Medium 2개만 필요.
```

Variable font가 5MB 초과 시, [fonts.google.com/noto/specimen/Noto+Sans+KR](https://fonts.google.com/noto/specimen/Noto+Sans+KR)에서 Static TTF 개별 다운로드.

**Step 4: Lottie 플레이스홀더 생성**

개발/테스트용 최소 Lottie JSON 파일 2개 생성. 릴리즈 전 LottieFiles.com에서 실제 에셋으로 교체.

`assets/lottie/confetti.json`:
```json
{"v":"5.7.1","fr":30,"ip":0,"op":30,"w":400,"h":400,"nm":"confetti","ddd":0,"assets":[],"layers":[]}
```

`assets/lottie/star_burst.json`:
```json
{"v":"5.7.1","fr":30,"ip":0,"op":30,"w":400,"h":400,"nm":"star_burst","ddd":0,"assets":[],"layers":[]}
```

**Step 5: flutter pub get**

Run: `flutter pub get`
Expected: 패키지 해결 성공, 에러 없음.

**Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock assets/fonts/ assets/lottie/
git commit -m "chore: Phase 4 의존성 추가 — go_router, lottie, share_plus, NotoSansKR 폰트"
```

---

## Task 2: 컬러 토큰 (FangeulColors)

**Files:**
- Create: `lib/presentation/theme/fangeul_colors.dart`

**Step 1: 컬러 토큰 파일 작성**

```dart
import 'package:flutter/material.dart';

/// Fangeul 컬러 토큰.
///
/// 다크/라이트 모드별 surface, 공유 액센트, 팬덤 컬러를 정의한다.
/// 모든 컬러는 패널 토론 결정사항 기반 (docs/discussions/2026-02-27-visual-identity.md).
abstract final class FangeulColors {
  // ── 다크 모드 ──

  /// 가장 깊은 배경 (Scaffold)
  static const darkBackground = Color(0xFF0F0F1A);

  /// 카드, 시트 배경 (딥 네이비)
  static const darkSurface = Color(0xFF1E1E2E);

  /// 컨테이너 배경
  static const darkSurfaceContainer = Color(0xFF282840);

  /// 높은 엘리베이션 컨테이너
  static const darkSurfaceContainerHigh = Color(0xFF323250);

  /// 주 텍스트 (할로 효과 방지, WCAG AA)
  static const darkOnSurface = Color(0xFFE8E8F0);

  /// 보조 텍스트
  static const darkOnSurfaceVariant = Color(0xFFA0A0B8);

  /// 경계선
  static const darkOutline = Color(0xFF4A4A60);

  /// 약한 경계선
  static const darkOutlineVariant = Color(0xFF353550);

  // ── 라이트 모드 ──

  static const lightBackground = Color(0xFFFAFAFE);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceContainer = Color(0xFFF0F0F8);
  static const lightSurfaceContainerHigh = Color(0xFFE8E8F0);
  static const lightOnSurface = Color(0xFF1E1E2E);
  static const lightOnSurfaceVariant = Color(0xFF5A5A70);
  static const lightOutline = Color(0xFFB0B0C0);
  static const lightOutlineVariant = Color(0xFFD8D8E4);

  // ── 액센트 (팬덤 독립) ──

  /// 틸 — Fangeul 고유 프라이머리. 어떤 아이돌 그룹과도 무관.
  static const primary = Color(0xFF4ECDC4);

  /// 틸 다크 컨테이너 (다크 모드)
  static const primaryContainerDark = Color(0xFF1A3A38);

  /// 틸 라이트 컨테이너 (라이트 모드)
  static const primaryContainerLight = Color(0xFFD4F5F2);

  /// 웜 옐로 — CTA, 강조
  static const secondary = Color(0xFFFFE66D);

  /// 코랄 — 경고, 하트
  static const tertiary = Color(0xFFFF6B6B);

  // ── 팬덤 컬러 (공유 카드 테마, v1.1) ──

  static const fandomPurple = Color(0xFFA855F7);
  static const fandomPink = Color(0xFFEC4899);
  static const fandomGreen = Color(0xFF22C55E);
  static const fandomBlue = Color(0xFF3B82F6);
  static const fandomOrange = Color(0xFFF97316);
  static const fandomSilver = Color(0xFF94A3B8);
}
```

**Step 2: 정적 분석 확인**

Run: `flutter analyze lib/presentation/theme/fangeul_colors.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/presentation/theme/fangeul_colors.dart
git commit -m "feat: FangeulColors 컬러 토큰 정의 — 다크/라이트/액센트"
```

---

## Task 3: 텍스트 스타일 (FangeulTextStyles)

**Files:**
- Create: `lib/presentation/theme/fangeul_text_styles.dart`

**Step 1: 텍스트 스타일 파일 작성**

```dart
import 'package:flutter/material.dart';

/// Fangeul 텍스트 스타일 토큰.
///
/// NotoSansKR 번들 폰트 기반. 오프라인 우선.
/// [koreanDisplay] / [koreanSubtitle]은 데일리 카드·공유 카드 전용.
abstract final class FangeulTextStyles {
  static const _fontFamily = 'NotoSansKR';

  /// Material 3 TextTheme — 모든 텍스트 역할에 NotoSansKR 적용.
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 32,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 28,
    ),
    displaySmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 24,
    ),
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 22,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 18,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 18,
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    titleSmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 12,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
    labelSmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 10,
    ),
  );

  /// 한글 대형 디스플레이 — 데일리 카드, 공유 카드 중앙 텍스트.
  static const koreanDisplay = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 40,
    height: 1.3,
  );

  /// 한글 서브타이틀 — 발음, 번역 표시.
  static const koreanSubtitle = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
  );
}
```

**Step 2: 정적 분석 확인**

Run: `flutter analyze lib/presentation/theme/fangeul_text_styles.dart`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/presentation/theme/fangeul_text_styles.dart
git commit -m "feat: FangeulTextStyles 텍스트 스타일 토큰 — NotoSansKR 기반"
```

---

## Task 4: 테마 + ThemeMode Provider

**Files:**
- Create: `lib/presentation/theme/fangeul_theme.dart`
- Create: `lib/presentation/providers/theme_providers.dart`
- Create: `test/presentation/providers/theme_providers_test.dart`

**Step 1: FangeulTheme 작성**

`lib/presentation/theme/fangeul_theme.dart`:

```dart
import 'package:flutter/material.dart';

import 'package:fangeul/presentation/theme/fangeul_colors.dart';
import 'package:fangeul/presentation/theme/fangeul_text_styles.dart';

/// Fangeul ThemeData 팩토리.
///
/// M3 ColorScheme을 seed가 아닌 명시적 토큰으로 구성한다.
/// seed-only 생성 시 tonal surface 편차 위험 방지.
abstract final class FangeulTheme {
  /// 다크 테마 (기본값).
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: FangeulColors.primary,
        onPrimary: FangeulColors.darkBackground,
        primaryContainer: FangeulColors.primaryContainerDark,
        onPrimaryContainer: FangeulColors.primary,
        secondary: FangeulColors.secondary,
        onSecondary: FangeulColors.darkBackground,
        tertiary: FangeulColors.tertiary,
        onTertiary: FangeulColors.darkBackground,
        surface: FangeulColors.darkSurface,
        onSurface: FangeulColors.darkOnSurface,
        onSurfaceVariant: FangeulColors.darkOnSurfaceVariant,
        outline: FangeulColors.darkOutline,
        outlineVariant: FangeulColors.darkOutlineVariant,
        surfaceContainerLowest: FangeulColors.darkBackground,
        surfaceContainerLow: FangeulColors.darkBackground,
        surfaceContainer: FangeulColors.darkSurfaceContainer,
        surfaceContainerHigh: FangeulColors.darkSurfaceContainerHigh,
        surfaceContainerHighest: FangeulColors.darkSurfaceContainerHigh,
      ),
      scaffoldBackgroundColor: FangeulColors.darkBackground,
      textTheme: FangeulTextStyles.textTheme,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: FangeulColors.darkSurface,
        indicatorColor: FangeulColors.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStatePropertyAll(
          FangeulTextStyles.textTheme.labelMedium,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FangeulColors.darkBackground,
        foregroundColor: FangeulColors.darkOnSurface,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: FangeulColors.darkSurface,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: FangeulColors.darkSurfaceContainer,
        selectedColor: FangeulColors.primary.withValues(alpha: 0.2),
        labelStyle: FangeulTextStyles.textTheme.labelLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FangeulColors.darkSurfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FangeulColors.primary),
        ),
      ),
    );
  }

  /// 라이트 테마.
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: FangeulColors.primary,
        onPrimary: Colors.white,
        primaryContainer: FangeulColors.primaryContainerLight,
        secondary: FangeulColors.secondary,
        tertiary: FangeulColors.tertiary,
        surface: FangeulColors.lightSurface,
        onSurface: FangeulColors.lightOnSurface,
        onSurfaceVariant: FangeulColors.lightOnSurfaceVariant,
        outline: FangeulColors.lightOutline,
        outlineVariant: FangeulColors.lightOutlineVariant,
        surfaceContainer: FangeulColors.lightSurfaceContainer,
        surfaceContainerHigh: FangeulColors.lightSurfaceContainerHigh,
      ),
      scaffoldBackgroundColor: FangeulColors.lightBackground,
      textTheme: FangeulTextStyles.textTheme,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: FangeulColors.lightSurface,
        indicatorColor: FangeulColors.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStatePropertyAll(
          FangeulTextStyles.textTheme.labelMedium,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FangeulColors.lightBackground,
        foregroundColor: FangeulColors.lightOnSurface,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: FangeulColors.lightSurface,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: FangeulColors.lightSurfaceContainer,
        selectedColor: FangeulColors.primary.withValues(alpha: 0.15),
        labelStyle: FangeulTextStyles.textTheme.labelLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FangeulColors.lightSurfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FangeulColors.primary),
        ),
      ),
    );
  }
}
```

**Step 2: ThemeMode Provider 테스트 작성 (TDD)**

`test/presentation/providers/theme_providers_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/theme_providers.dart';

void main() {
  group('ThemeModeNotifier', () {
    test('should default to dark mode when no saved preference', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
    });

    test('should load saved light mode', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeNotifierProvider), ThemeMode.light);
    });

    test('should load saved system mode', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'system'});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeNotifierProvider), ThemeMode.system);
    });

    test('should fall back to dark for invalid saved value', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'invalid'});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
    });

    test('should persist theme mode change', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      await container
          .read(themeModeNotifierProvider.notifier)
          .setThemeMode(ThemeMode.light);

      expect(container.read(themeModeNotifierProvider), ThemeMode.light);
      expect(prefs.getString('theme_mode'), 'light');
    });
  });
}
```

**Step 3: 테스트 실행 — 실패 확인**

Run: `flutter test test/presentation/providers/theme_providers_test.dart`
Expected: FAIL — `theme_providers.dart` 파일이 아직 없으므로 컴파일 에러.

**Step 4: ThemeMode Provider 구현**

`lib/presentation/providers/theme_providers.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_providers.g.dart';

/// SharedPreferences 인스턴스 — main.dart에서 override 필수.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
}

/// ThemeMode 상태 관리.
///
/// 기본값: [ThemeMode.dark] (패널 결정).
/// SharedPreferences에 'theme_mode' 키로 persist.
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString('theme_mode');
    if (saved == null) return ThemeMode.dark;

    return ThemeMode.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => ThemeMode.dark,
    );
  }

  /// ThemeMode를 변경하고 SharedPreferences에 저장한다.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('theme_mode', mode.name);
  }
}
```

**Step 5: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 성공, `theme_providers.g.dart` 생성.

**Step 6: 테스트 실행 — 통과 확인**

Run: `flutter test test/presentation/providers/theme_providers_test.dart`
Expected: All 5 tests passed

**Step 7: Commit**

```bash
git add lib/presentation/theme/fangeul_theme.dart \
  lib/presentation/providers/theme_providers.dart \
  lib/presentation/providers/theme_providers.g.dart \
  test/presentation/providers/theme_providers_test.dart
git commit -m "feat: 테마 시스템 — FangeulTheme + ThemeModeNotifier (TDD)"
```

---

## Task 5: Converter Provider (TDD)

**Files:**
- Create: `lib/presentation/providers/converter_providers.dart`
- Create: `test/presentation/providers/converter_providers_test.dart`

**Step 1: 테스트 먼저 작성**

`test/presentation/providers/converter_providers_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/providers/converter_providers.dart';

void main() {
  group('ConverterNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should start with initial state', () {
      final state = container.read(converterNotifierProvider);
      expect(state, const ConverterState.initial());
    });

    test('should convert eng to kor', () {
      container
          .read(converterNotifierProvider.notifier)
          .convert('gksrmf', ConvertMode.engToKor);

      final state = container.read(converterNotifierProvider);
      expect(state, isA<ConverterResult>());
      final result = state as ConverterResult;
      expect(result.output, '한글');
      expect(result.mode, ConvertMode.engToKor);
      expect(result.input, 'gksrmf');
    });

    test('should convert kor to eng', () {
      container
          .read(converterNotifierProvider.notifier)
          .convert('한글', ConvertMode.korToEng);

      final state = container.read(converterNotifierProvider);
      expect(state, isA<ConverterResult>());
      expect((state as ConverterResult).output, 'gksrmf');
    });

    test('should romanize korean text', () {
      container
          .read(converterNotifierProvider.notifier)
          .convert('사랑해요', ConvertMode.romanize);

      final state = container.read(converterNotifierProvider);
      expect(state, isA<ConverterResult>());
      expect((state as ConverterResult).output, 'saranghaeyo');
    });

    test('should return initial state for empty input', () {
      container
          .read(converterNotifierProvider.notifier)
          .convert('hello', ConvertMode.engToKor);
      container
          .read(converterNotifierProvider.notifier)
          .convert('', ConvertMode.engToKor);

      expect(
        container.read(converterNotifierProvider),
        const ConverterState.initial(),
      );
    });

    test('should clear state', () {
      container
          .read(converterNotifierProvider.notifier)
          .convert('hello', ConvertMode.engToKor);
      container.read(converterNotifierProvider.notifier).clear();

      expect(
        container.read(converterNotifierProvider),
        const ConverterState.initial(),
      );
    });

    test('should handle non-korean input in romanize mode', () {
      container
          .read(converterNotifierProvider.notifier)
          .convert('hello', ConvertMode.romanize);

      final state = container.read(converterNotifierProvider);
      expect(state, isA<ConverterResult>());
      // Romanizer passes through non-Korean text
      expect((state as ConverterResult).output, 'hello');
    });
  });
}
```

**Step 2: 테스트 실행 — 실패 확인**

Run: `flutter test test/presentation/providers/converter_providers_test.dart`
Expected: FAIL — 파일 없음

**Step 3: ConverterState + ConverterNotifier 구현**

`lib/presentation/providers/converter_providers.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/core/engines/keyboard_converter.dart';
import 'package:fangeul/core/engines/romanizer.dart';

part 'converter_providers.freezed.dart';
part 'converter_providers.g.dart';

/// 변환기 모드.
enum ConvertMode {
  /// 영문 → 한글
  engToKor,

  /// 한글 → 영문
  korToEng,

  /// 한글 → 로마자 발음
  romanize,
}

/// 변환기 상태.
@freezed
sealed class ConverterState with _$ConverterState {
  /// 초기 상태 (입력 없음)
  const factory ConverterState.initial() = ConverterInitial;

  /// 변환 결과
  const factory ConverterState.result({
    required String input,
    required String output,
    required ConvertMode mode,
  }) = ConverterResult;
}

/// 변환기 상태 관리.
///
/// [KeyboardConverter]와 [Romanizer] 엔진을 래핑하여
/// 입력 텍스트를 선택된 모드로 변환한다.
@riverpod
class ConverterNotifier extends _$ConverterNotifier {
  @override
  ConverterState build() => const ConverterState.initial();

  /// [input]을 [mode]에 따라 변환한다.
  void convert(String input, ConvertMode mode) {
    if (input.isEmpty) {
      state = const ConverterState.initial();
      return;
    }

    final output = switch (mode) {
      ConvertMode.engToKor => KeyboardConverter.engToKor(input),
      ConvertMode.korToEng => KeyboardConverter.korToEng(input),
      ConvertMode.romanize => Romanizer.romanize(input),
    };

    state = ConverterState.result(
      input: input,
      output: output,
      mode: mode,
    );
  }

  /// 상태를 초기화한다.
  void clear() {
    state = const ConverterState.initial();
  }
}
```

**Step 4: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 성공, `.freezed.dart` + `.g.dart` 생성.

**Step 5: 테스트 실행 — 통과 확인**

Run: `flutter test test/presentation/providers/converter_providers_test.dart`
Expected: All 7 tests passed

**Step 6: Commit**

```bash
git add lib/presentation/providers/converter_providers.dart \
  lib/presentation/providers/converter_providers.freezed.dart \
  lib/presentation/providers/converter_providers.g.dart \
  test/presentation/providers/converter_providers_test.dart
git commit -m "feat: ConverterNotifier — 영↔한/로마자 변환 상태관리 (TDD)"
```

---

## Task 6: 네비게이션 + Shell + app.dart

**Files:**
- Create: `lib/presentation/router/app_router.dart`
- Create: `lib/presentation/widgets/shell_scaffold.dart`
- Create: `lib/presentation/screens/home_screen.dart` (stub)
- Create: `lib/presentation/screens/converter_screen.dart` (stub)
- Create: `lib/presentation/screens/phrases_screen.dart` (stub)
- Create: `lib/presentation/screens/settings_screen.dart` (stub)
- Modify: `lib/app.dart`
- Modify: `lib/main.dart`

**Step 1: 스텁 화면 4개 생성**

각 화면에 타이틀만 표시하는 스텁. 이후 Task에서 내용 채움.

`lib/presentation/screens/home_screen.dart`:
```dart
import 'package:flutter/material.dart';

/// 홈 화면 — 데일리 카드 + 스트릭.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('홈'));
  }
}
```

`lib/presentation/screens/converter_screen.dart`:
```dart
import 'package:flutter/material.dart';

/// 변환기 화면 — 영↔한 변환 + 로마자 발음.
class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('변환기'));
  }
}
```

`lib/presentation/screens/phrases_screen.dart`:
```dart
import 'package:flutter/material.dart';

/// 문구 화면 — 팬 문구 라이브러리.
class PhrasesScreen extends StatelessWidget {
  const PhrasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('문구'));
  }
}
```

`lib/presentation/screens/settings_screen.dart`:
```dart
import 'package:flutter/material.dart';

/// 설정 화면 — 테마, 언어 등.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: const Center(child: Text('설정')),
    );
  }
}
```

**Step 2: ShellScaffold 작성**

`lib/presentation/widgets/shell_scaffold.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 3탭 BottomNavigationBar 쉘.
///
/// [StatefulShellRoute.indexedStack]의 builder에서 사용.
/// 홈, 변환기, 문구 3개 탭을 제공한다.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.navigationShell});

  /// go_router가 주입하는 네비게이션 쉘.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.translate_outlined),
            selectedIcon: Icon(Icons.translate),
            label: '변환기',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: '문구',
          ),
        ],
      ),
    );
  }
}
```

**Step 3: AppRouter 작성**

`lib/presentation/router/app_router.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/presentation/screens/home_screen.dart';
import 'package:fangeul/presentation/screens/converter_screen.dart';
import 'package:fangeul/presentation/screens/phrases_screen.dart';
import 'package:fangeul/presentation/screens/settings_screen.dart';
import 'package:fangeul/presentation/widgets/shell_scaffold.dart';

part 'app_router.g.dart';

/// 앱 라우터 Provider.
@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ShellScaffold(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/converter',
                builder: (context, state) => const ConverterScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/phrases',
                builder: (context, state) => const PhrasesScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
```

**Step 4: app.dart 수정**

`lib/app.dart`을 **전체 교체**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/router/app_router.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/theme/fangeul_theme.dart';

/// Fangeul 앱의 루트 위젯.
class FangeulApp extends ConsumerWidget {
  /// Creates the root [FangeulApp] widget.
  const FangeulApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp.router(
      title: 'Fangeul',
      debugShowCheckedModeBanner: false,
      theme: FangeulTheme.light(),
      darkTheme: FangeulTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
```

**Step 5: main.dart 수정**

`lib/main.dart`을 **전체 교체**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/app.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';

void main() async {
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
```

**Step 6: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 성공, `app_router.g.dart` 생성.

**Step 7: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 8: 기존 테스트 확인**

Run: `flutter test test/core/`
Expected: 모든 기존 테스트 pass (99 + 40 = 139개)

**Step 9: Commit**

```bash
git add lib/presentation/router/ \
  lib/presentation/widgets/shell_scaffold.dart \
  lib/presentation/screens/ \
  lib/app.dart lib/main.dart
git commit -m "feat: 3탭 네비게이션 — go_router StatefulShellRoute + 테마 연동"
```

---

## Task 7: 홈 화면 (데일리 카드 + 스트릭)

**Files:**
- Create: `lib/presentation/widgets/streak_banner.dart`
- Create: `lib/presentation/widgets/daily_card_widget.dart`
- Modify: `lib/presentation/screens/home_screen.dart`

**Step 1: StreakBanner 위젯 작성**

`lib/presentation/widgets/streak_banner.dart`:
```dart
import 'package:flutter/material.dart';

import 'package:fangeul/presentation/theme/fangeul_colors.dart';

/// 스트릭 배너 — 현재 연속 학습일수 표시.
class StreakBanner extends StatelessWidget {
  const StreakBanner({super.key, required this.streak, this.isCompletedToday = false});

  /// 현재 연속 스트릭 일수.
  final int streak;

  /// 오늘 완료 여부.
  final bool isCompletedToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isCompletedToday ? Icons.local_fire_department : Icons.local_fire_department_outlined,
            color: isCompletedToday ? FangeulColors.secondary : theme.colorScheme.onSurfaceVariant,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            '$streak일 연속',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (isCompletedToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: FangeulColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '완료',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: FangeulColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

**Step 2: DailyCardWidget 작성**

`lib/presentation/widgets/daily_card_widget.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fangeul/core/entities/daily_card.dart';
import 'package:fangeul/presentation/theme/fangeul_colors.dart';
import 'package:fangeul/presentation/theme/fangeul_text_styles.dart';

/// 데일리 카드 — 큰 한글 중앙 배치 + 발음 + 번역.
class DailyCardWidget extends StatelessWidget {
  const DailyCardWidget({
    super.key,
    required this.card,
    required this.translationLang,
    required this.isCompleted,
    this.onComplete,
    this.onShare,
  });

  /// 표시할 데일리 카드.
  final DailyCard card;

  /// 번역 언어 코드 (예: 'en').
  final String translationLang;

  /// 오늘 완료 여부.
  final bool isCompleted;

  /// 완료 콜백.
  final VoidCallback? onComplete;

  /// 공유 콜백.
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translation = card.phrase.translations[translationLang] ?? '';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // 한글 (주인공)
          Text(
            card.phrase.ko,
            style: FangeulTextStyles.koreanDisplay.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // 로마자 발음
          Text(
            card.phrase.roman,
            style: FangeulTextStyles.koreanSubtitle.copyWith(
              color: FangeulColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // 번역
          if (translation.isNotEmpty)
            Text(
              translation,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          const Spacer(flex: 3),
          // 액션 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isCompleted) ...[
                FilledButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('완료'),
                ),
                const SizedBox(width: 12),
              ],
              OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined),
                label: const Text('공유'),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: card.phrase.ko));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('복사되었습니다')),
                  );
                },
                icon: const Icon(Icons.copy_outlined),
                tooltip: '복사',
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
```

**Step 3: HomeScreen 구현**

`lib/presentation/screens/home_screen.dart`을 **전체 교체**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fangeul/presentation/providers/phrase_providers.dart';
import 'package:fangeul/presentation/providers/progress_providers.dart';
import 'package:fangeul/presentation/widgets/daily_card_widget.dart';
import 'package:fangeul/presentation/widgets/streak_banner.dart';

/// 홈 화면 — 데일리 카드 + 스트릭.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _todayString() {
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = _todayString();
    final dailyCard = ref.watch(dailyCardProvider(today));
    final progress = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fangeul'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 스트릭 배너
          progress.when(
            data: (p) => StreakBanner(
              streak: p.streak,
              isCompletedToday: p.lastCompletedDate == today,
            ),
            loading: () => const SizedBox(height: 72),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // 데일리 카드
          Expanded(
            child: dailyCard.when(
              data: (card) {
                if (card == null) {
                  return const Center(child: Text('오늘의 카드를 불러올 수 없습니다'));
                }
                final isCompleted = progress.valueOrNull?.lastCompletedDate == today;
                return DailyCardWidget(
                  card: card,
                  translationLang: 'en',
                  isCompleted: isCompleted,
                  onComplete: isCompleted
                      ? null
                      : () => _completeDailyCard(ref),
                  onShare: () {
                    // TODO(fangeul): Task 10에서 공유 카드 구현
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeDailyCard(WidgetRef ref) async {
    final useCase = ref.read(updateStreakUseCaseProvider);
    await useCase.execute(now: DateTime.now());
    ref.invalidate(userProgressProvider);
  }
}
```

**Step 4: flutter analyze**

Run: `flutter analyze`
Expected: No issues found (TODO 주석은 허용)

**Step 5: Commit**

```bash
git add lib/presentation/widgets/streak_banner.dart \
  lib/presentation/widgets/daily_card_widget.dart \
  lib/presentation/screens/home_screen.dart
git commit -m "feat: 홈 화면 — 데일리 카드 + 스트릭 배너"
```

---

## Task 8: 변환기 화면

**Files:**
- Create: `lib/presentation/widgets/converter_input.dart`
- Modify: `lib/presentation/screens/converter_screen.dart`

**Step 1: ConverterInput 위젯 작성**

`lib/presentation/widgets/converter_input.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fangeul/presentation/theme/fangeul_text_styles.dart';

/// 변환기 입출력 위젯 — 입력 TextField + 결과 표시.
class ConverterInput extends StatelessWidget {
  const ConverterInput({
    super.key,
    required this.controller,
    required this.output,
    required this.hintText,
    required this.onChanged,
  });

  /// 입력 필드 컨트롤러.
  final TextEditingController controller;

  /// 변환 결과 텍스트. 빈 문자열이면 미표시.
  final String output;

  /// 입력 필드 힌트.
  final String hintText;

  /// 텍스트 변경 콜백.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 입력 필드
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 24),
        // 결과 영역
        if (output.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  output,
                  style: FangeulTextStyles.koreanDisplay.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: output));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('복사되었습니다')),
                        );
                      },
                      icon: const Icon(Icons.copy_outlined),
                      tooltip: '복사',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
```

**Step 2: ConverterScreen 구현**

`lib/presentation/screens/converter_screen.dart`을 **전체 교체**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/providers/converter_providers.dart';
import 'package:fangeul/presentation/widgets/converter_input.dart';

/// 변환기 화면 — 영↔한 변환 + 로마자 발음.
///
/// 3개 모드 탭: 영→한, 한→영, 발음(로마자).
/// "차분한 도구" 디자인 — 미니멀, 인지 부하 최소.
class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _textController = TextEditingController();

  static const _modes = ConvertMode.values;
  static const _labels = ['영→한', '한→영', '발음'];
  static const _hints = [
    '영문을 입력하세요 (예: gksrmf)',
    '한글을 입력하세요 (예: 한글)',
    '한글을 입력하세요 (예: 사랑해요)',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _modes.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    // 탭 전환 시 현재 입력으로 재변환
    final input = _textController.text;
    if (input.isNotEmpty) {
      ref
          .read(converterNotifierProvider.notifier)
          .convert(input, _modes[_tabController.index]);
    }
  }

  void _onTextChanged(String value) {
    ref
        .read(converterNotifierProvider.notifier)
        .convert(value, _modes[_tabController.index]);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(converterNotifierProvider);

    final output = switch (state) {
      ConverterInitial() => '',
      ConverterResult(:final output) => output,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('변환기'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ConverterInput(
          controller: _textController,
          output: output,
          hintText: _hints[_tabController.index],
          onChanged: _onTextChanged,
        ),
      ),
    );
  }
}
```

**Step 3: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/presentation/widgets/converter_input.dart \
  lib/presentation/screens/converter_screen.dart
git commit -m "feat: 변환기 화면 — 영↔한/로마자 3탭 변환"
```

---

## Task 9: 문구 화면

**Files:**
- Create: `lib/presentation/widgets/tag_filter_chips.dart`
- Create: `lib/presentation/widgets/phrase_card.dart`
- Modify: `lib/presentation/screens/phrases_screen.dart`

**Step 1: TagFilterChips 작성**

`lib/presentation/widgets/tag_filter_chips.dart`:
```dart
import 'package:flutter/material.dart';

/// 태그 필터 칩 — 문구 카테고리 필터링.
class TagFilterChips extends StatelessWidget {
  const TagFilterChips({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
  });

  /// 사용 가능한 태그 목록.
  final List<String> tags;

  /// 현재 선택된 태그. null이면 '전체' 선택.
  final String? selectedTag;

  /// 태그 선택 콜백. null을 전달하면 '전체' 선택.
  final ValueChanged<String?> onTagSelected;

  static const _tagLabels = {
    'love': '사랑',
    'cheer': '응원',
    'daily': '일상',
    'greeting': '인사',
    'emotional': '감정',
    'praise': '칭찬',
    'fandom': '팬덤',
    'birthday': '생일',
    'comeback': '컴백',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('전체'),
              selected: selectedTag == null,
              onSelected: (_) => onTagSelected(null),
            ),
          ),
          ...tags.map((tag) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_tagLabels[tag] ?? tag),
                  selected: selectedTag == tag,
                  onSelected: (_) => onTagSelected(tag),
                ),
              )),
        ],
      ),
    );
  }
}
```

**Step 2: PhraseCard 작성**

`lib/presentation/widgets/phrase_card.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/theme/fangeul_colors.dart';

/// 문구 카드 — 한글 원문 + 발음 + 번역.
class PhraseCard extends StatelessWidget {
  const PhraseCard({
    super.key,
    required this.phrase,
    required this.translationLang,
  });

  /// 표시할 문구.
  final Phrase phrase;

  /// 번역 언어 코드.
  final String translationLang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translation = phrase.translations[translationLang] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 한글 원문
          Text(
            phrase.ko,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          // 로마자 발음
          Text(
            phrase.roman,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: FangeulColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          // 번역
          if (translation.isNotEmpty)
            Text(
              translation,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 8),
          // 액션 버튼
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: phrase.ko));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('복사되었습니다')),
                  );
                },
                tooltip: '복사',
                visualDensity: VisualDensity.compact,
              ),
              // TODO(fangeul): TTS 버튼 (Phase 5 서비스 연동)
            ],
          ),
        ],
      ),
    );
  }
}
```

**Step 3: PhrasesScreen 구현**

`lib/presentation/screens/phrases_screen.dart`을 **전체 교체**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/providers/phrase_providers.dart';
import 'package:fangeul/presentation/widgets/phrase_card.dart';
import 'package:fangeul/presentation/widgets/tag_filter_chips.dart';

/// 문구 화면 — 팬 문구 라이브러리.
class PhrasesScreen extends ConsumerStatefulWidget {
  const PhrasesScreen({super.key});

  @override
  ConsumerState<PhrasesScreen> createState() => _PhrasesScreenState();
}

class _PhrasesScreenState extends ConsumerState<PhrasesScreen> {
  String? _selectedTag;

  static const _availableTags = [
    'love', 'cheer', 'daily', 'greeting',
    'emotional', 'praise', 'fandom',
  ];

  @override
  Widget build(BuildContext context) {
    final phrasesAsync = _selectedTag == null
        ? ref.watch(allPhrasesProvider)
        : ref.watch(phrasesByTagProvider(_selectedTag!));

    return Scaffold(
      appBar: AppBar(title: const Text('문구')),
      body: Column(
        children: [
          // 태그 필터
          TagFilterChips(
            tags: _availableTags,
            selectedTag: _selectedTag,
            onTagSelected: (tag) => setState(() => _selectedTag = tag),
          ),
          const SizedBox(height: 8),
          // 문구 리스트
          Expanded(
            child: phrasesAsync.when(
              data: (data) {
                final phrases = _extractPhrases(data);
                if (phrases.isEmpty) {
                  return const Center(child: Text('문구가 없습니다'));
                }
                return ListView.builder(
                  itemCount: phrases.length,
                  itemBuilder: (context, index) => PhraseCard(
                    phrase: phrases[index],
                    translationLang: 'en',
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
            ),
          ),
        ],
      ),
    );
  }

  /// Provider 결과를 Phrase 리스트로 변환.
  /// allPhrasesProvider → List<PhrasePack>, phrasesByTagProvider → List<Phrase>
  List<Phrase> _extractPhrases(dynamic data) {
    if (data is List<Phrase>) return data;
    if (data is List) {
      // List<PhrasePack> → 무료 팩의 문구만 평탄화
      return data
          .where((pack) => pack.isFree)
          .expand((pack) => pack.phrases as List<Phrase>)
          .toList();
    }
    return [];
  }
}
```

**Step 4: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 5: Commit**

```bash
git add lib/presentation/widgets/tag_filter_chips.dart \
  lib/presentation/widgets/phrase_card.dart \
  lib/presentation/screens/phrases_screen.dart
git commit -m "feat: 문구 화면 — 태그 필터 + 문구 카드 리스트"
```

---

## Task 10: 설정 화면

**Files:**
- Modify: `lib/presentation/screens/settings_screen.dart`

**Step 1: SettingsScreen 구현**

`lib/presentation/screens/settings_screen.dart`을 **전체 교체**:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/providers/theme_providers.dart';

/// 설정 화면 — 테마 모드 전환, 앱 정보.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          // 테마 모드
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('테마', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('다크'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('라이트'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.settings_suggest_outlined),
                      label: Text('시스템'),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (modes) {
                    ref
                        .read(themeModeNotifierProvider.notifier)
                        .setThemeMode(modes.first);
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          // 앱 정보
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('앱 정보'),
            subtitle: const Text('Fangeul v0.1.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Fangeul',
                applicationVersion: '0.1.0',
                applicationLegalese: '© 2026 Tiger Room',
              );
            },
          ),
        ],
      ),
    );
  }
}
```

**Step 2: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 3: Commit**

```bash
git add lib/presentation/screens/settings_screen.dart
git commit -m "feat: 설정 화면 — 다크/라이트/시스템 테마 토글"
```

---

## Task 11: 공유 카드 (CustomPainter)

**Files:**
- Create: `lib/presentation/widgets/share_card_painter.dart`

**Step 1: ShareCardPainter + 공유 함수 작성**

`lib/presentation/widgets/share_card_painter.dart`:
```dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fangeul/core/entities/daily_card.dart';
import 'package:fangeul/presentation/theme/fangeul_colors.dart';

/// 공유 카드 CustomPainter — 1080x1920 PNG 이미지 생성.
///
/// "절제된 임팩트" — 한글이 주인공, 나머지는 조연.
class ShareCardPainter extends CustomPainter {
  ShareCardPainter({
    required this.card,
    required this.isDark,
    required this.translationLang,
  });

  /// 공유할 카드.
  final DailyCard card;

  /// 다크 모드 여부.
  final bool isDark;

  /// 번역 언어 코드.
  final String translationLang;

  @override
  void paint(Canvas canvas, Size size) {
    final bgColor = isDark
        ? FangeulColors.darkSurface
        : FangeulColors.lightSurface;
    final textColor = isDark
        ? FangeulColors.darkOnSurface
        : FangeulColors.lightOnSurface;
    final subColor = isDark
        ? FangeulColors.darkOnSurfaceVariant
        : FangeulColors.lightOnSurfaceVariant;

    // 배경
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    // 한글 (중앙, 큰 글씨)
    _drawText(
      canvas,
      card.phrase.ko,
      offset: Offset(size.width / 2, size.height * 0.35),
      fontSize: 80,
      color: textColor,
      fontWeight: FontWeight.w700,
      maxWidth: size.width - 120,
      textAlign: TextAlign.center,
    );

    // 로마자 발음
    _drawText(
      canvas,
      card.phrase.roman,
      offset: Offset(size.width / 2, size.height * 0.50),
      fontSize: 32,
      color: FangeulColors.primary,
      fontWeight: FontWeight.w400,
      maxWidth: size.width - 120,
      textAlign: TextAlign.center,
    );

    // 번역
    final translation = card.phrase.translations[translationLang] ?? '';
    if (translation.isNotEmpty) {
      _drawText(
        canvas,
        translation,
        offset: Offset(size.width / 2, size.height * 0.58),
        fontSize: 28,
        color: subColor,
        fontWeight: FontWeight.w400,
        maxWidth: size.width - 120,
        textAlign: TextAlign.center,
      );
    }

    // 브랜딩 (하단)
    _drawText(
      canvas,
      'Fangeul',
      offset: Offset(size.width / 2, size.height * 0.90),
      fontSize: 24,
      color: subColor.withValues(alpha: 0.5),
      fontWeight: FontWeight.w500,
      maxWidth: size.width,
      textAlign: TextAlign.center,
    );
  }

  void _drawText(
    Canvas canvas,
    String text, {
    required Offset offset,
    required double fontSize,
    required Color color,
    required FontWeight fontWeight,
    required double maxWidth,
    TextAlign textAlign = TextAlign.center,
  }) {
    final paragraphStyle = ui.ParagraphStyle(
      textAlign: textAlign,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
    final textStyle = ui.TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight);
    final builder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);
    final paragraph = builder.build()
      ..layout(ui.ParagraphConstraints(width: maxWidth));

    final dx = offset.dx - paragraph.width / 2;
    canvas.drawParagraph(paragraph, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant ShareCardPainter oldDelegate) =>
      card != oldDelegate.card ||
      isDark != oldDelegate.isDark ||
      translationLang != oldDelegate.translationLang;
}

/// 공유 카드를 PNG로 내보내고 시스템 공유를 실행한다.
Future<void> shareCard({
  required DailyCard card,
  required bool isDark,
  required String translationLang,
}) async {
  const width = 1080;
  const height = 1920;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final painter = ShareCardPainter(
    card: card,
    isDark: isDark,
    translationLang: translationLang,
  );
  painter.paint(canvas, const Size(width.toDouble(), height.toDouble()));

  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  if (byteData == null) return;

  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/fangeul_card_${card.date}.png');
  await file.writeAsBytes(byteData.buffer.asUint8List());

  await Share.shareXFiles(
    [XFile(file.path)],
    text: '${card.phrase.ko} — Fangeul',
  );
}
```

**Step 2: HomeScreen에 공유 연결**

`lib/presentation/screens/home_screen.dart`의 `onShare` TODO를 교체:

```dart
// 기존:
onShare: () {
  // TODO(fangeul): Task 10에서 공유 카드 구현
},

// 변경:
onShare: () => shareCard(
  card: card,
  isDark: theme.brightness == Brightness.dark,
  translationLang: 'en',
),
```

`home_screen.dart` 상단에 import 추가:
```dart
import 'package:fangeul/presentation/widgets/share_card_painter.dart';
```

그리고 build 메서드 안에서 theme을 참조해야 하므로:
```dart
final theme = Theme.of(context);
```
를 build 메서드 시작 부분에 추가.

**Step 3: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/presentation/widgets/share_card_painter.dart \
  lib/presentation/screens/home_screen.dart
git commit -m "feat: 공유 카드 — CustomPainter 1080x1920 PNG + share_plus"
```

---

## Task 12: Lottie 축하 애니메이션

**Files:**
- Create: `lib/presentation/widgets/celebration_overlay.dart`
- Modify: `lib/presentation/screens/home_screen.dart`

**Step 1: CelebrationOverlay 위젯 작성**

`lib/presentation/widgets/celebration_overlay.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// 축하 애니메이션 오버레이 — 스트릭 완료 시 confetti 표시.
///
/// 축소 모션 설정 시 Lottie 비활성 (접근성).
/// 애니메이션 완료 후 자동으로 [onComplete] 호출.
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.assetPath,
    required this.onComplete,
  });

  /// Lottie JSON 에셋 경로.
  final String assetPath;

  /// 애니메이션 완료 시 콜백.
  final VoidCallback onComplete;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 접근성: 축소 모션 설정 시 애니메이션 미표시
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      // 바로 완료 처리
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onComplete();
      });
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Lottie.asset(
          widget.assetPath,
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().then((_) => widget.onComplete());
          },
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
```

**Step 2: HomeScreen에 Lottie 연결**

`lib/presentation/screens/home_screen.dart`을 수정하여 축하 애니메이션 추가.

HomeScreen을 `ConsumerStatefulWidget`으로 변경하여 `_showCelebration` 상태 관리:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fangeul/presentation/providers/phrase_providers.dart';
import 'package:fangeul/presentation/providers/progress_providers.dart';
import 'package:fangeul/presentation/widgets/celebration_overlay.dart';
import 'package:fangeul/presentation/widgets/daily_card_widget.dart';
import 'package:fangeul/presentation/widgets/share_card_painter.dart';
import 'package:fangeul/presentation/widgets/streak_banner.dart';

/// 홈 화면 — 데일리 카드 + 스트릭.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showCelebration = false;

  String _todayString() {
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _completeDailyCard() async {
    final useCase = ref.read(updateStreakUseCaseProvider);
    await useCase.execute(now: DateTime.now());
    ref.invalidate(userProgressProvider);
    setState(() => _showCelebration = true);
  }

  @override
  Widget build(BuildContext context) {
    final today = _todayString();
    final dailyCard = ref.watch(dailyCardProvider(today));
    final progress = ref.watch(userProgressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fangeul'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 스트릭 배너
              progress.when(
                data: (p) => StreakBanner(
                  streak: p.streak,
                  isCompletedToday: p.lastCompletedDate == today,
                ),
                loading: () => const SizedBox(height: 72),
                error: (_, __) => const SizedBox.shrink(),
              ),
              // 데일리 카드
              Expanded(
                child: dailyCard.when(
                  data: (card) {
                    if (card == null) {
                      return const Center(
                        child: Text('오늘의 카드를 불러올 수 없습니다'),
                      );
                    }
                    final isCompleted =
                        progress.valueOrNull?.lastCompletedDate == today;
                    return DailyCardWidget(
                      card: card,
                      translationLang: 'en',
                      isCompleted: isCompleted,
                      onComplete: isCompleted ? null : _completeDailyCard,
                      onShare: () => shareCard(
                        card: card,
                        isDark: theme.brightness == Brightness.dark,
                        translationLang: 'en',
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('오류: $e')),
                ),
              ),
            ],
          ),
          // Lottie 축하 오버레이
          if (_showCelebration)
            CelebrationOverlay(
              assetPath: 'assets/lottie/confetti.json',
              onComplete: () => setState(() => _showCelebration = false),
            ),
        ],
      ),
    );
  }
}
```

**Step 3: flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 4: Commit**

```bash
git add lib/presentation/widgets/celebration_overlay.dart \
  lib/presentation/screens/home_screen.dart
git commit -m "feat: Lottie 축하 오버레이 — 스트릭 완료 시 confetti"
```

---

## Task 13: 최종 검증

**Step 1: build_runner 재실행**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 성공, 모든 `.g.dart` + `.freezed.dart` 최신 상태.

**Step 2: 전체 테스트 실행**

Run: `flutter test`
Expected: 모든 테스트 pass.
- core/engines: 99개
- data layer: 40개
- presentation/providers: 12개 (theme 5 + converter 7)
- 총: 151개+

**Step 3: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 4: 포맷 확인**

Run: `dart format --set-exit-if-changed .`
Expected: 변경 필요 없음

**Step 5: 기존 엔진 테스트 무결성 확인**

Run: `flutter test test/core/engines/`
Expected: 99개 all pass

**Step 6: 최종 Commit**

```bash
git add -A
git commit -m "feat: Phase 4 UI 레이어 완성 — 테마, 네비게이션, 4화면, 공유 카드, Lottie"
```

---

## 검증 체크리스트

```
[ ] flutter pub get — 성공
[ ] dart run build_runner build — 성공
[ ] flutter test — 전체 pass
[ ] flutter analyze — No issues
[ ] dart format --set-exit-if-changed . — 변경 없음
[ ] 앱 실행 시 다크 모드 기본
[ ] 3탭 네비게이션 정상 동작
[ ] 홈: 데일리 카드 표시 + 완료 시 스트릭 업데이트
[ ] 변환기: 3모드 변환 동작
[ ] 문구: 태그 필터 + 리스트 표시
[ ] 설정: 다크/라이트/시스템 토글 작동 + persist
[ ] 공유: 카드 PNG 생성 + 시스템 공유
[ ] Lottie: 축하 애니메이션 표시 (축소 모션 시 비표시)
```

---

## 파일 요약

| # | 파일 | 상태 | Task |
|---|------|------|------|
| 1 | `pubspec.yaml` | 수정 | 1 |
| 2 | `assets/fonts/NotoSansKR-*.ttf` | 신규 | 1 |
| 3 | `assets/lottie/confetti.json` | 신규 | 1 |
| 4 | `assets/lottie/star_burst.json` | 신규 | 1 |
| 5 | `lib/presentation/theme/fangeul_colors.dart` | 신규 | 2 |
| 6 | `lib/presentation/theme/fangeul_text_styles.dart` | 신규 | 3 |
| 7 | `lib/presentation/theme/fangeul_theme.dart` | 신규 | 4 |
| 8 | `lib/presentation/providers/theme_providers.dart` | 신규 | 4 |
| 9 | `lib/presentation/providers/converter_providers.dart` | 신규 | 5 |
| 10 | `lib/presentation/router/app_router.dart` | 신규 | 6 |
| 11 | `lib/presentation/widgets/shell_scaffold.dart` | 신규 | 6 |
| 12 | `lib/app.dart` | 수정 | 6 |
| 13 | `lib/main.dart` | 수정 | 6 |
| 14 | `lib/presentation/screens/home_screen.dart` | 신규 | 7,11,12 |
| 15 | `lib/presentation/screens/converter_screen.dart` | 신규 | 8 |
| 16 | `lib/presentation/screens/phrases_screen.dart` | 신규 | 9 |
| 17 | `lib/presentation/screens/settings_screen.dart` | 신규 | 10 |
| 18 | `lib/presentation/widgets/streak_banner.dart` | 신규 | 7 |
| 19 | `lib/presentation/widgets/daily_card_widget.dart` | 신규 | 7 |
| 20 | `lib/presentation/widgets/converter_input.dart` | 신규 | 8 |
| 21 | `lib/presentation/widgets/tag_filter_chips.dart` | 신규 | 9 |
| 22 | `lib/presentation/widgets/phrase_card.dart` | 신규 | 9 |
| 23 | `lib/presentation/widgets/share_card_painter.dart` | 신규 | 11 |
| 24 | `lib/presentation/widgets/celebration_overlay.dart` | 신규 | 12 |
| 25 | `test/presentation/providers/theme_providers_test.dart` | 신규 | 4 |
| 26 | `test/presentation/providers/converter_providers_test.dart` | 신규 | 5 |
