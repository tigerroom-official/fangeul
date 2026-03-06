# AdMob 배치 + 팬 컬러 테마 커스터마이징 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fangeul v1.0.0에 AdMob 광고 배치(배너+보상형) + 팬 컬러 테마 커스터마이징(추천 팔레트 + 자유 피커 IAP)을 구현한다.

**Architecture:** AdService 초기화 -> BannerAdWidget/FanPassButton UI 배치 -> 퍼널 조건 연동. 테마는 `ColorScheme.fromSeed()` 기반 전체 컬러 스킴 생성 + ThemeColorNotifier로 SharedPreferences 영속화. 기본 틸 테마만 수동 튜닝 유지, 유저 선택 시 fromSeed 전체 교체(배경 포함). 자유 피커 IAP 구매자는 글자색(onPrimary/onSurface)도 커스터마이징 가능 -- 프리미엄 차별화.

**Tech Stack:** Flutter 3.41.2, Riverpod (annotation), freezed, google_mobile_ads (기구현), SharedPreferences, ColorScheme.fromSeed() (M3 내장)

**설계 문서:** `docs/discussions/2026-03-06-admob-placement-and-theme-monetization.md`

---

## 의존성 그래프

```
Task 1 (문구 무료화)          -- 독립
Task 2 (잠금 표시 제거)       -- Task 1 후
Task 3 (AdService 초기화)     -- 독립
Task 4 (preloadRewarded)      -- Task 3 후
Task 5 (BannerAdWidget 배치)  -- Task 3 후
  |
Task 6 (팔레트 정의)          -- 독립
Task 7 (ThemeColorNotifier)   -- Task 6 후
Task 8 (동적 테마 생성)       -- Task 7 후
Task 9 (app.dart 연결)        -- Task 8 후
Task 10 (테마 피커 바텀시트)   -- Task 9 후
Task 11 (설정에 진입점)       -- Task 10 후
Task 12 (팔레트 잠금 분기)    -- Task 7, 11 후
Task 13 (버블 테마 동기화)    -- Task 9 후
```

---

## Task 1: 문구팩 무료 전환

**Files:**
- Modify: `assets/phrases/birthday_pack.json:5`
- Modify: `assets/phrases/comeback_pack.json:5`

**Step 1: birthday_pack.json 수정**

`"is_free": false` -> `"is_free": true`, `"unlock_type": "rewarded_ad"` -> `"unlock_type": null`

**Step 2: comeback_pack.json 수정**

동일하게 `"is_free": true`, `"unlock_type": null`

**Step 3: 기존 테스트 실행**

Run: `flutter test test/data/`
Expected: PASS (팩 로딩 테스트는 is_free 값에 의존하지 않음)

**Step 4: Commit**

```bash
git add assets/phrases/birthday_pack.json assets/phrases/comeback_pack.json
git commit -m "feat: unlock birthday and comeback phrase packs for free"
```

---

## Task 2: 잠금 표시 제거 (pack_filter_chips)

**Files:**
- Modify: `lib/presentation/widgets/pack_filter_chips.dart:177`

**Step 1: 잠금 로직 제거**

현재 (라인 177):
```dart
final label = pack.isFree ? pack.nameKo : '${pack.nameKo}🔒';
```

변경:
```dart
final label = pack.nameKo;
```

**Step 2: 관련 테스트 확인**

Run: `flutter test test/presentation/widgets/`
Expected: PASS

**Step 3: Commit**

```bash
git add lib/presentation/widgets/pack_filter_chips.dart
git commit -m "feat: remove lock indicator from phrase pack chips"
```

---

## Task 3: AdService SDK 초기화

**Files:**
- Modify: `lib/main.dart:20` (Firebase 초기화 이후 삽입)

**Step 1: main.dart에 AdService 초기화 추가**

Firebase 초기화 직후(라인 20 이후)에 fire-and-forget 호출 추가:

```dart
import 'package:fangeul/services/ad_service.dart';

// Firebase 초기화 이후, 다른 서비스 이전에:
AdService().initialize(); // fire-and-forget, await 하지 않음
```

주의: `await`를 붙이지 않는다. 앱 시작 크리티컬 패스에 포함하지 않음.

**Step 2: 실행 확인**

Run: `flutter test test/` (기존 테스트 깨지지 않음 확인)
Expected: PASS (AdService.initialize는 실기기에서만 동작, 테스트에서는 no-op)

**Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: initialize AdMob SDK on app start (fire-and-forget)"
```

---

## Task 4: home_screen에서 보상형 광고 프리로드

**Files:**
- Modify: `lib/presentation/screens/home_screen.dart:34`

**Step 1: build() 초반에 preloadRewarded 호출**

`home_screen.dart` build() 메서드 초반(라인 34 근처)에 추가:

```dart
// 보상형 광고 프리로드 (1회, 결과 무시)
ref.read(adServiceProvider).preloadRewarded();
```

import 추가:
```dart
import 'package:fangeul/presentation/providers/ad_service_provider.dart';
```

**Step 2: 기존 테스트 확인**

Run: `flutter test test/presentation/screens/`
Expected: PASS (home_screen 테스트에서 adServiceProvider를 override하지 않아도 기본 AdService는 no-op)

**Step 3: Commit**

```bash
git add lib/presentation/screens/home_screen.dart
git commit -m "feat: preload rewarded ad on home screen build"
```

---

## Task 5: phrases_screen 하단 BannerAdWidget 배치

**Files:**
- Modify: `lib/presentation/screens/phrases_screen.dart:69` (Scaffold 구조)
- Modify: `lib/presentation/widgets/banner_ad_widget.dart:66` (Day 7+ 조건 추가)

**Step 1: BannerAdWidget에 Day 7+ 조건 추가**

`banner_ad_widget.dart` build() 메서드(라인 66)에서 기존 숨김 조건에 daysSinceInstall 추가:

```dart
final monState = ref.watch(monetizationNotifierProvider).valueOrNull;
final daysSince = monState?.installDate != null
    ? DateTime.now()
          .difference(DateTime.parse(monState!.installDate!))
          .inDays
    : 0;

// Day 7 미만이면 배너 숨김
if (daysSince < 7) {
  return const SizedBox.shrink();
}
```

기존 허니문/해금/구매 조건은 그대로 유지.

**Step 2: phrases_screen에 BannerAdWidget 배치**

`phrases_screen.dart` Scaffold body의 Column 맨 아래에 BannerAdWidget 추가:

```dart
import 'package:fangeul/presentation/widgets/banner_ad_widget.dart';

// Column 자식 맨 마지막에:
const BannerAdWidget(),
```

**Step 3: 기존 테스트 확인**

Run: `flutter test test/presentation/widgets/banner_ad_widget_test.dart`
Expected: PASS (기존 hide condition 테스트 유지)

Run: `flutter test test/presentation/screens/`
Expected: PASS

**Step 4: Commit**

```bash
git add lib/presentation/widgets/banner_ad_widget.dart lib/presentation/screens/phrases_screen.dart
git commit -m "feat: place banner ad at phrases screen bottom with Day 7+ condition"
```

---

## Task 6: 추천 팔레트 정의

**Files:**
- Create: `lib/presentation/theme/theme_palettes.dart`

**Step 1: 팔레트 데이터 클래스 및 8개 추천 팔레트 정의**

```dart
import 'package:flutter/material.dart';

/// 추천 테마 팔레트 정의.
///
/// 자연 테마 이름으로 IP 리스크 없이 팬 감성 표현.
class ThemePalette {
  const ThemePalette({
    required this.id,
    required this.nameKey,
    required this.seedColor,
    required this.isFree,
  });

  /// 팔레트 고유 ID.
  final String id;

  /// l10n 키 (예: 'paletteCherryBlossom').
  final String nameKey;

  /// seed color for ColorScheme.fromSeed().
  final Color seedColor;

  /// 무료 여부 (false면 보상형/IAP 필요).
  final bool isFree;
}

/// 추천 팔레트 목록. 무료 3개 + 보상형 5개.
abstract final class ThemePalettes {
  static const cherryBlossom = ThemePalette(
    id: 'cherry_blossom',
    nameKey: 'paletteCherryBlossom',
    seedColor: Color(0xFFF8BBD0),
    isFree: true,
  );

  static const ocean = ThemePalette(
    id: 'ocean',
    nameKey: 'paletteOcean',
    seedColor: Color(0xFF1565C0),
    isFree: true,
  );

  static const forest = ThemePalette(
    id: 'forest',
    nameKey: 'paletteForest',
    seedColor: Color(0xFF2E7D32),
    isFree: true,
  );

  static const sunset = ThemePalette(
    id: 'sunset',
    nameKey: 'paletteSunset',
    seedColor: Color(0xFFE65100),
    isFree: false,
  );

  static const starryNight = ThemePalette(
    id: 'starry_night',
    nameKey: 'paletteStarryNight',
    seedColor: Color(0xFF4527A0),
    isFree: false,
  );

  static const dawn = ThemePalette(
    id: 'dawn',
    nameKey: 'paletteDawn',
    seedColor: Color(0xFFFF8A65),
    isFree: false,
  );

  static const dusk = ThemePalette(
    id: 'dusk',
    nameKey: 'paletteDusk',
    seedColor: Color(0xFFAD1457),
    isFree: false,
  );

  static const jewel = ThemePalette(
    id: 'jewel',
    nameKey: 'paletteJewel',
    seedColor: Color(0xFF00897B),
    isFree: false,
  );

  /// 전체 팔레트 목록 (무료 우선 정렬).
  static const all = [
    cherryBlossom, ocean, forest,
    sunset, starryNight, dawn, dusk, jewel,
  ];

  /// 무료 팔레트만.
  static List<ThemePalette> get free => all.where((p) => p.isFree).toList();
}
```

**Step 2: Commit**

```bash
git add lib/presentation/theme/theme_palettes.dart
git commit -m "feat: define 8 theme palettes with natural names"
```

---

## Task 7: ThemeColorNotifier (SharedPreferences 영속화)

**Files:**
- Modify: `lib/presentation/providers/theme_providers.dart`

**Step 1: ThemeColorNotifier 추가**

`theme_providers.dart`에 ThemeColorNotifier를 추가. seed color의 hex 값을 SharedPreferences에 저장/로드:

```dart
import 'package:fangeul/presentation/theme/theme_palettes.dart';

/// 테마 seed color + 커스텀 글자색 선택 상태.
///
/// null이면 기본 틸 테마(수동 튜닝), non-null이면 fromSeed() 동적 생성.
/// 자유 피커 IAP 구매자는 customTextColor도 설정 가능 (프리미엄 차별화).
@riverpod
class ThemeColorNotifier extends _$ThemeColorNotifier {
  static const _seedKey = 'theme_seed_color';
  static const _textKey = 'theme_custom_text_color';

  @override
  Color? build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final hex = prefs.getString(_seedKey);
    if (hex == null) return null;
    return Color(int.parse(hex, radix: 16));
  }

  /// 커스텀 글자색 (자유 피커 IAP 전용). null이면 자동 대비.
  Color? get customTextColor {
    final prefs = ref.read(sharedPreferencesProvider);
    final hex = prefs.getString(_textKey);
    if (hex == null) return null;
    return Color(int.parse(hex, radix: 16));
  }

  /// seed color 설정. null이면 기본 틸 테마로 복원.
  Future<void> setSeedColor(Color? color) async {
    state = color;
    final prefs = ref.read(sharedPreferencesProvider);
    if (color == null) {
      await prefs.remove(_seedKey);
      await prefs.remove(_textKey); // 글자색도 초기화
    } else {
      await prefs.setString(
        _seedKey,
        color.value.toRadixString(16).padLeft(8, '0'),
      );
    }
  }

  /// 커스텀 글자색 설정 (자유 피커 IAP 전용). null이면 자동 대비로 복원.
  Future<void> setCustomTextColor(Color? color) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (color == null) {
      await prefs.remove(_textKey);
    } else {
      await prefs.setString(
        _textKey,
        color.value.toRadixString(16).padLeft(8, '0'),
      );
    }
    // seed는 그대로, 테마 재빌드 트리거를 위해 state 재설정
    ref.invalidateSelf();
  }

  /// 추천 팔레트 적용 (글자색 자동 대비).
  Future<void> applyPalette(ThemePalette palette) async {
    await setSeedColor(palette.seedColor);
  }

  /// 기본 테마로 복원.
  Future<void> resetToDefault() async {
    await setSeedColor(null);
  }
}
```

**Step 2: build_runner 실행**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `theme_providers.g.dart` 재생성

**Step 3: 테스트 작성**

Create: `test/presentation/providers/theme_color_notifier_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/theme_providers.dart';

void main() {
  group('ThemeColorNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
    });

    tearDown(() => container.dispose());

    test('should return null by default (teal theme)', () {
      container.listen(themeColorNotifierProvider, (_, __) {});
      final color = container.read(themeColorNotifierProvider);
      expect(color, isNull);
    });

    test('should save and restore seed color', () async {
      container.listen(themeColorNotifierProvider, (_, __) {});
      final notifier = container.read(themeColorNotifierProvider.notifier);

      await notifier.setSeedColor(const Color(0xFF4527A0));
      expect(container.read(themeColorNotifierProvider), const Color(0xFF4527A0));

      // SharedPreferences에 저장 확인
      final prefs = container.read(sharedPreferencesProvider);
      expect(prefs.getString('theme_seed_color'), '004527a0');
    });

    test('should reset to null when resetToDefault called', () async {
      container.listen(themeColorNotifierProvider, (_, __) {});
      final notifier = container.read(themeColorNotifierProvider.notifier);

      await notifier.setSeedColor(const Color(0xFF4527A0));
      await notifier.resetToDefault();
      expect(container.read(themeColorNotifierProvider), isNull);
    });
  });
}
```

**Step 4: 테스트 실행**

Run: `flutter test test/presentation/providers/theme_color_notifier_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/presentation/providers/theme_providers.dart lib/presentation/providers/theme_providers.g.dart test/presentation/providers/theme_color_notifier_test.dart
git commit -m "feat: add ThemeColorNotifier with SharedPreferences persistence"
```

---

## Task 8: 동적 테마 생성 함수

**Files:**
- Modify: `lib/presentation/theme/fangeul_theme.dart`

**Step 1: fromSeed 기반 동적 테마 생성 메서드 추가**

`FangeulTheme`에 `dynamicDark(Color seedColor)`와 `dynamicLight(Color seedColor)` 추가:

```dart
/// seed color 기반 동적 다크 테마.
///
/// ColorScheme.fromSeed()가 배경/surface/on* 색상 전부 자동 생성.
/// [customTextColor] 지정 시 onSurface/onPrimary를 해당 색으로 override.
/// 자유 피커 IAP 구매자 전용 프리미엄 차별화.
static ThemeData dynamicDark(Color seedColor, {Color? customTextColor}) {
  var colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );
  if (customTextColor != null) {
    colorScheme = colorScheme.copyWith(
      onSurface: customTextColor,
      onSurfaceVariant: customTextColor.withValues(alpha: 0.7),
      onPrimary: customTextColor,
    );
  }
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: FangeulTextStyles.textTheme,
  );
}

/// seed color 기반 동적 라이트 테마.
static ThemeData dynamicLight(Color seedColor, {Color? customTextColor}) {
  var colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );
  if (customTextColor != null) {
    colorScheme = colorScheme.copyWith(
      onSurface: customTextColor,
      onSurfaceVariant: customTextColor.withValues(alpha: 0.7),
      onPrimary: customTextColor,
    );
  }
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: FangeulTextStyles.textTheme,
  );
}
```

**Step 2: 테스트 작성**

Create: `test/presentation/theme/fangeul_theme_dynamic_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/presentation/theme/fangeul_theme.dart';

void main() {
  group('FangeulTheme dynamic', () {
    test('should generate dark theme from seed with correct brightness', () {
      final theme = FangeulTheme.dynamicDark(const Color(0xFF4527A0));
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('should generate light theme from seed with correct brightness', () {
      final theme = FangeulTheme.dynamicLight(const Color(0xFF4527A0));
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('should produce different themes for different seeds', () {
      final purple = FangeulTheme.dynamicDark(const Color(0xFF4527A0));
      final pink = FangeulTheme.dynamicDark(const Color(0xFFF8BBD0));
      expect(purple.colorScheme.primary, isNot(pink.colorScheme.primary));
    });

    test('should ensure text contrast on primary', () {
      final theme = FangeulTheme.dynamicDark(const Color(0xFFFFFF00));
      // onPrimary should have sufficient contrast with primary
      expect(theme.colorScheme.onPrimary, isNotNull);
      expect(
        theme.colorScheme.onPrimary,
        isNot(theme.colorScheme.primary),
      );
    });
  });
}
```

**Step 3: 테스트 실행**

Run: `flutter test test/presentation/theme/fangeul_theme_dynamic_test.dart`
Expected: PASS

**Step 4: Commit**

```bash
git add lib/presentation/theme/fangeul_theme.dart test/presentation/theme/fangeul_theme_dynamic_test.dart
git commit -m "feat: add dynamic theme generation with ColorScheme.fromSeed"
```

---

## Task 9: app.dart에 동적 테마 연결

**Files:**
- Modify: `lib/app.dart:40-67`

**Step 1: ThemeColorNotifier 감시 + 조건부 테마 적용**

`app.dart` build() 메서드에서:

```dart
import 'package:fangeul/presentation/theme/fangeul_theme.dart';

// 기존 providers 감시 (라인 40-42) 아래에 추가:
final seedColor = ref.watch(themeColorNotifierProvider);
final textColor = seedColor != null
    ? ref.read(themeColorNotifierProvider.notifier).customTextColor
    : null;

// 기존 theme/darkTheme (라인 65-66) 변경:
theme: seedColor != null
    ? FangeulTheme.dynamicLight(seedColor, customTextColor: textColor)
    : FangeulTheme.light(),
darkTheme: seedColor != null
    ? FangeulTheme.dynamicDark(seedColor, customTextColor: textColor)
    : FangeulTheme.dark(),
```

import 추가:
```dart
import 'package:fangeul/presentation/providers/theme_providers.dart';
```

**Step 2: 기존 테스트 확인**

Run: `flutter test`
Expected: PASS (기존 테스트에서 themeColorNotifierProvider를 override하지 않으면 null -> 기본 테마)

**Step 3: Commit**

```bash
git add lib/app.dart
git commit -m "feat: connect dynamic theme to MaterialApp based on seed color"
```

---

## Task 10: 테마 피커 바텀시트 UI

**Files:**
- Create: `lib/presentation/widgets/theme_picker_sheet.dart`

**Step 1: 바텀시트 위젯 구현**

2단계 UX: 추천 팔레트 그리드 + "직접 고르기" 토글 -> 컬러 슬라이더.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/l10n/app_localizations.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/theme/theme_palettes.dart';

/// 테마 컬러 피커 바텀시트.
///
/// Step 1: 추천 팔레트 그리드 (8개).
/// Step 2: 토글 -> HSL 슬라이더 + 미리보기 카드.
/// 잠금/해금 로직은 별도 Task에서 연동.
class ThemePickerSheet extends ConsumerStatefulWidget {
  const ThemePickerSheet({super.key});

  @override
  ConsumerState<ThemePickerSheet> createState() => _ThemePickerSheetState();

  /// 바텀시트를 표시한다.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ThemePickerSheet(),
    );
  }
}

class _ThemePickerSheetState extends ConsumerState<ThemePickerSheet> {
  bool _showCustomPicker = false;
  double _hue = 0;
  double _saturation = 0.7;
  double _lightness = 0.4;

  Color get _customColor =>
      HSLColor.fromAHSL(1, _hue, _saturation, _lightness).toColor();

  @override
  void initState() {
    super.initState();
    // 현재 설정된 seed color가 있으면 HSL로 변환
    final current = ref.read(themeColorNotifierProvider);
    if (current != null) {
      final hsl = HSLColor.fromColor(current);
      _hue = hsl.hue;
      _saturation = hsl.saturation;
      _lightness = hsl.lightness;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = L.of(context);
    final currentSeed = ref.watch(themeColorNotifierProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 타이틀
              Text(l.themePickerTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(l.themePickerSubtitle, style: theme.textTheme.bodySmall),
              const SizedBox(height: 20),

              // 기본 틸 복원 버튼
              _DefaultThemeChip(
                isSelected: currentSeed == null,
                onTap: () {
                  ref.read(themeColorNotifierProvider.notifier).resetToDefault();
                },
              ),
              const SizedBox(height: 16),

              // 추천 팔레트 그리드
              _PaletteGrid(
                currentSeed: currentSeed,
                onSelect: (palette) {
                  ref.read(themeColorNotifierProvider.notifier)
                      .applyPalette(palette);
                },
              ),
              const SizedBox(height: 16),

              // "직접 고르기" 토글
              _CustomPickerToggle(
                isExpanded: _showCustomPicker,
                onToggle: () => setState(() => _showCustomPicker = !_showCustomPicker),
              ),

              // 자유 컬러 피커 (토글 시)
              if (_showCustomPicker) ...[
                const SizedBox(height: 16),
                // -- 테마 색상 슬라이더 --
                Text(l.themePickerThemeColor, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                _HueSlider(
                  hue: _hue,
                  onChanged: (v) {
                    setState(() => _hue = v);
                    ref.read(themeColorNotifierProvider.notifier)
                        .setSeedColor(_customColor);
                  },
                ),
                const SizedBox(height: 12),
                _SaturationSlider(
                  saturation: _saturation,
                  hue: _hue,
                  onChanged: (v) {
                    setState(() => _saturation = v);
                    ref.read(themeColorNotifierProvider.notifier)
                        .setSeedColor(_customColor);
                  },
                ),
                const SizedBox(height: 12),
                _LightnessSlider(
                  lightness: _lightness,
                  hue: _hue,
                  saturation: _saturation,
                  onChanged: (v) {
                    setState(() => _lightness = v);
                    ref.read(themeColorNotifierProvider.notifier)
                        .setSeedColor(_customColor);
                  },
                ),
                const SizedBox(height: 20),
                // -- 글자색 커스터마이징 (자유 피커 IAP 전용) --
                // hasThemePicker == true 일 때만 표시
                Text(l.themePickerTextColor, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(l.themePickerTextColorDesc, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                _TextColorSelector(
                  currentTextColor: ref.read(themeColorNotifierProvider.notifier).customTextColor,
                  seedColor: _customColor,
                  onChanged: (color) {
                    ref.read(themeColorNotifierProvider.notifier)
                        .setCustomTextColor(color);
                  },
                  onReset: () {
                    ref.read(themeColorNotifierProvider.notifier)
                        .setCustomTextColor(null); // 자동 대비로 복원
                  },
                ),
                const SizedBox(height: 16),
                // 미리보기 카드
                _PreviewCard(seedColor: _customColor),
              ],
            ],
          ),
        );
      },
    );
  }
}
```

서브 위젯들(`_DefaultThemeChip`, `_PaletteGrid`, `_CustomPickerToggle`, `_HueSlider`, `_SaturationSlider`, `_LightnessSlider`, `_PreviewCard`)은 같은 파일 내 private 클래스로 구현.

**핵심 서브 위젯:**

- `_PaletteGrid`: 4x2 그리드, 각 팔레트 seed color로 원형 칩 표시 + 이름
- `_HueSlider`: 0~360 리니어 그래디언트 슬라이더 (무지개 스펙트럼)
- `_SaturationSlider`: 0~1 그래디언트 (회색 -> 풍부한 색)
- `_LightnessSlider`: 0~1 그래디언트 (검정 -> 선택색 -> 흰색)
- `_TextColorSelector`: 글자색 선택 (자유 피커 IAP 전용). 밝은/어두운 프리셋 6개 + "자동 대비" 리셋 버튼. 프리셋: 순백, 크림, 연회색, 연하늘, 연라벤더, 연민트.
- `_PreviewCard`: seed color + customTextColor 기반 미리보기 (버튼, 칩, **본문 텍스트, 보조 텍스트** 표시 -- 글자 가독성 즉시 확인)

**Step 2: l10n 키 추가**

`lib/l10n/app_en.arb`, `app_ko.arb` 등에 추가:
- `themePickerTitle`, `themePickerSubtitle`
- `paletteDefault`, `paletteCherryBlossom`, `paletteOcean`, `paletteForest`
- `paletteSunset`, `paletteStarryNight`, `paletteDawn`, `paletteDusk`, `paletteJewel`
- `themePickerCustom`, `themePickerThemeColor`, `themePickerHue`, `themePickerSaturation`, `themePickerLightness`
- `themePickerTextColor`, `themePickerTextColorDesc`, `themePickerTextColorAuto`

**Step 3: 테스트 작성**

기본 렌더링 + 팔레트 선택 + 커스텀 피커 토글 테스트.

**Step 4: Commit**

```bash
git add lib/presentation/widgets/theme_picker_sheet.dart lib/l10n/ test/
git commit -m "feat: add theme picker bottom sheet with palette grid and custom color picker"
```

---

## Task 11: 설정 화면에 테마 피커 진입점

**Files:**
- Modify: `lib/presentation/screens/settings_screen.dart`

**Step 1: "테마 색상" 메뉴 항목 추가**

기존 "테마 모드" (다크/라이트/시스템) 메뉴 근처에 "테마 색상" 항목 추가:

```dart
ListTile(
  leading: Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
  title: Text(l.settingsThemeColor),
  subtitle: Text(l.settingsThemeColorDesc),
  trailing: Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: seedColor ?? theme.colorScheme.primary,
      shape: BoxShape.circle,
    ),
  ),
  onTap: () => ThemePickerSheet.show(context),
),
```

**Step 2: 기존 테스트 확인**

Run: `flutter test test/presentation/screens/settings_screen_test.dart`
Expected: PASS (새 ListTile 추가만이므로 기존 테스트 불영향)

**Step 3: Commit**

```bash
git add lib/presentation/screens/settings_screen.dart
git commit -m "feat: add theme color picker entry in settings screen"
```

---

## Task 12: 팔레트 잠금/해금 분기 (MonetizationState 연동)

**Files:**
- Modify: `lib/presentation/widgets/theme_picker_sheet.dart`
- Modify: `lib/core/entities/monetization_state.dart`
- Modify: `lib/presentation/providers/monetization_provider.dart`

**Step 1: MonetizationState에 테마 관련 필드 추가**

```dart
// monetization_state.dart에 추가:
@Default(false) bool hasThemePicker,  // 자유 피커 IAP 구매 여부
```

**Step 2: MonetizationNotifier에 해금 메서드 추가**

```dart
/// 자유 피커 해금 (IAP 구매 후).
Future<void> unlockThemePicker() async {
  final current = state.valueOrNull;
  if (current == null) return;
  await _updateState(current.copyWith(hasThemePicker: true));
}
```

**Step 3: 테마 피커에 잠금 로직 적용**

`_PaletteGrid`에서:
- `palette.isFree == true` -> 즉시 적용
- `palette.isFree == false` && 보상형 해금 활성 -> 적용
- `palette.isFree == false` && 미해금 -> 잠금 아이콘 + "팬 패스로 해금" 안내

`_CustomPickerToggle`에서:
- `hasThemePicker == true` -> 직접 고르기 활성
- `hasThemePicker == false` -> "W990으로 영구 해금" 버튼 표시

**Step 4: build_runner + 테스트**

Run: `dart run build_runner build --delete-conflicting-outputs`
Run: `flutter test`

**Step 5: Commit**

```bash
git add lib/core/entities/monetization_state.dart lib/core/entities/monetization_state.freezed.dart lib/core/entities/monetization_state.g.dart lib/presentation/providers/monetization_provider.dart lib/presentation/widgets/theme_picker_sheet.dart
git commit -m "feat: integrate palette lock/unlock with monetization state"
```

---

## Task 13: 버블 테마 동기화

**Files:**
- Modify: `lib/presentation/screens/mini_converter_screen.dart`

**Step 1: `_syncFromMainEngine()`에 themeColorNotifier invalidate 추가**

기존 패턴(localeNotifierProvider invalidate)과 동일:

```dart
// _syncFromMainEngine() 내부에 추가:
ref.invalidate(themeColorNotifierProvider);
```

SharedPreferences.reload()는 이미 호출되고 있으므로, invalidate만 추가하면 새 seed color를 읽어옴.

**Step 2: 기존 테스트 확인**

Run: `flutter test test/presentation/screens/mini_converter_screen_test.dart`
Expected: PASS

**Step 3: Commit**

```bash
git add lib/presentation/screens/mini_converter_screen.dart
git commit -m "feat: sync theme color to bubble engine via SharedPreferences"
```

---

## 전체 테스트 최종 확인

Run: `flutter test`
Expected: 624+ tests PASS (새 테스트 포함)

Run: `flutter analyze`
Expected: No issues

---

## 최종 커밋 요약

```
1. feat: unlock birthday and comeback phrase packs for free
2. feat: remove lock indicator from phrase pack chips
3. feat: initialize AdMob SDK on app start (fire-and-forget)
4. feat: preload rewarded ad on home screen build
5. feat: place banner ad at phrases screen bottom with Day 7+ condition
6. feat: define 8 theme palettes with natural names
7. feat: add ThemeColorNotifier with SharedPreferences persistence
8. feat: add dynamic theme generation with ColorScheme.fromSeed
9. feat: connect dynamic theme to MaterialApp based on seed color
10. feat: add theme picker bottom sheet with palette grid and custom color picker
11. feat: add theme color picker entry in settings screen
12. feat: integrate palette lock/unlock with monetization state
13. feat: sync theme color to bubble engine via SharedPreferences
```
