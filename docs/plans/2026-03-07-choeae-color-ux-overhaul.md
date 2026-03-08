# Choeae Color UX Overhaul Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 4가지 UX 이슈 수정 + "최애색" 시스템 근본 리디자인 — 즐겨찾기 피드백, Undo 레이아웃 시프트 제거, 피커 자동 스크롤, fromSeed() 우회 테마 시스템.

**Architecture:** `ChoeaeColorConfig` sealed class가 `PalettePack` (수동 ColorScheme) 또는 `Custom` (HSL 기반 `CustomSchemeBuilder`)을 감싸고, `FangeulTheme.build(brightness, choeaeColor)` 단일 진입점으로 합성. 기존 `ThemeColorNotifier` + `theme_palettes.dart` + `dynamicDark()/dynamicLight()` 전체 교체.

**Tech Stack:** Flutter 3.41.2 / Dart 3.11.0, Riverpod + freezed, SharedPreferences, HSLColor

**Reference:** `docs/discussions/2026-03-07-theme-ux-supplementary.md` (전문가 패널 합의 + 코드 레벨 설계)

---

## Task 1: 즐겨찾기 5슬롯 제한 피드백

즐겨찾기 추가 실패 시 사용자에게 피드백 제공 (현재: 무반응).

**Files:**
- Modify: `lib/presentation/widgets/phrase_card.dart:83-87`
- Modify: `lib/presentation/widgets/compact_phrase_tile.dart:71-75`
- Modify: `lib/presentation/widgets/compact_phrase_list.dart:384-388`
- Test: `test/presentation/widgets/phrase_card_test.dart` (기존 파일 수정)

**Step 1: Write the failing widget test**

3개 call site 중 `phrase_card.dart`를 대표로 테스트. `toggle()` 반환값 `false` 시 SnackBar 표시 확인.

```dart
// test/presentation/widgets/phrase_card_test.dart 에 추가
testWidgets('should show snackbar when favorite limit reached', (tester) async {
  // FavoritePhrasesNotifier.toggle()이 false를 반환하도록 mock
  // 별 아이콘 탭 → SnackBar 표시 확인
  // L.of(context).favoriteLimitReached 텍스트 포함 확인
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/widgets/phrase_card_test.dart -v`
Expected: FAIL — snackbar not shown on false return.

**Step 3: Implement feedback in all 3 call sites**

모든 call site에서 `toggle()` 반환값을 `await`로 받고, `false`이면 SnackBar 표시.

`lib/presentation/widgets/phrase_card.dart:83-87`:
```dart
onPressed: () async {
  final added = await ref
      .read(favoritePhrasesNotifierProvider.notifier)
      .toggle(phrase.ko);
  if (!added && context.mounted) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(L.of(context).favoriteLimitReached),
          duration: const Duration(seconds: 2),
        ),
      );
  }
},
```

`lib/presentation/widgets/compact_phrase_tile.dart:71-75`: 동일 패턴 적용.

`lib/presentation/widgets/compact_phrase_list.dart:384-388`: 동일 패턴 적용.

**Step 4: Add l10n key**

`lib/l10n/app_en.arb`:
```json
"favoriteLimitReached": "Favorite limit reached (max {limit})",
"@favoriteLimitReached": {
  "placeholders": {
    "limit": { "type": "int" }
  }
}
```

`lib/l10n/app_ko.arb`:
```json
"favoriteLimitReached": "즐겨찾기 한도에 도달했어요 (최대 {limit}개)"
```

나머지 5개 언어에도 추가 (ja/es/id/pt/th/vi).

**Step 5: Run test to verify it passes**

Run: `flutter test test/presentation/widgets/phrase_card_test.dart -v`
Expected: PASS

**Step 6: Commit**

```bash
git add -A
git commit -m "fix: show snackbar when favorite slot limit reached"
```

---

## Task 2: Undo 인라인 — 레이아웃 시프트 제거

타이틀 행 오른쪽에 Undo 아이콘 인라인 배치. AnimatedOpacity로 활성/비활성. 기존 별도 ActionChip 행 완전 제거.

**Files:**
- Modify: `lib/presentation/widgets/theme_picker_sheet.dart:127-151` (Undo ActionChip 제거)
- Modify: `lib/presentation/widgets/theme_picker_sheet.dart:348-371` (`_TitleSection` 리디자인)

**Step 1: Modify `_TitleSection` to accept undo params**

```dart
class _TitleSection extends StatelessWidget {
  const _TitleSection({
    required this.canUndo,
    this.onUndo,
  });

  final bool canUndo;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.themePickerTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                l.themePickerSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AnimatedOpacity(
          opacity: canUndo ? 1.0 : 0.25,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: IconButton(
            icon: const Icon(Icons.undo_rounded, size: 20),
            color: canUndo
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            onPressed: canUndo ? onUndo : null,
            tooltip: l.themePickerUndo,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ),
      ],
    );
  }
}
```

**Step 2: Remove old Undo ActionChip block**

`theme_picker_sheet.dart:128-151` 의 `if (ref.read(...).canUndo) ...` 블록 전체 삭제.

**Step 3: Update `_TitleSection` call site**

```dart
_TitleSection(
  canUndo: ref.read(themeColorNotifierProvider.notifier).canUndo,
  onUndo: () {
    ref.read(themeColorNotifierProvider.notifier).undo();
    setState(() => _slidersInitialized = false);
  },
),
```

**Step 4: Run tests**

Run: `flutter test test/presentation/providers/theme_providers_test.dart -v`
Expected: PASS (undo 로직 변경 없음, UI만 변경)

**Step 5: Commit**

```bash
git add -A
git commit -m "fix: inline undo icon in title row — zero layout shift"
```

---

## Task 3: Pick Your Own 자동 스크롤

커스텀 피커 펼칠 때 `DraggableScrollableController.animateTo(0.85)` + `Scrollable.ensureVisible()`.

**Files:**
- Modify: `lib/presentation/widgets/theme_picker_sheet.dart:35-37` (controller 추가)
- Modify: `lib/presentation/widgets/theme_picker_sheet.dart:106-109` (controller 연결)
- Modify: `lib/presentation/widgets/theme_picker_sheet.dart:181-188` (onToggle 자동 스크롤)

**Step 1: Add controllers and GlobalKey**

`_ThemePickerSheetState`에 추가:
```dart
final _sheetController = DraggableScrollableController();
final _customPickerKey = GlobalKey();
```

**Step 2: Connect DraggableScrollableController**

```dart
DraggableScrollableSheet(
  controller: _sheetController,
  initialChildSize: 0.6,
  minChildSize: 0.4,
  maxChildSize: 0.85,
  // ...
)
```

**Step 3: Add auto-scroll logic in onToggle**

```dart
onToggle: () {
  if (!hasPickerIap && !_customPickerExpanded) {
    _enterPreviewMode();
  }
  setState(() {
    _customPickerExpanded = !_customPickerExpanded;
  });
  if (_customPickerExpanded) {
    // 시트 확장 → 커스텀 피커 영역으로 스크롤
    Future.delayed(const Duration(milliseconds: 100), () {
      _sheetController.animateTo(
        0.85,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      Future.delayed(const Duration(milliseconds: 150), () {
        final ctx = _customPickerKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }
},
```

**Step 4: Attach GlobalKey to custom picker section**

HSL sliders 시작점에 `key: _customPickerKey` 부여:
```dart
if (_customPickerExpanded) ...[
  SizedBox(key: _customPickerKey, height: 16),
  _HueSlider(...),
  // ...
]
```

**Step 5: Dispose controller**

`_ThemePickerSheetState`에 dispose 추가:
```dart
@override
void dispose() {
  _sheetController.dispose();
  super.dispose();
}
```

**Step 6: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 7: Commit**

```bash
git add -A
git commit -m "feat: auto-scroll to custom picker on expand"
```

---

## Task 4: `CustomSchemeBuilder` — fromSeed() 우회

HSL 기반으로 seed hue를 surface 전체에 전파하는 빌더. Auto contrast 포함.

**Files:**
- Create: `lib/presentation/theme/custom_scheme_builder.dart`
- Create: `test/presentation/theme/custom_scheme_builder_test.dart`

**Step 1: Write the failing tests**

```dart
// test/presentation/theme/custom_scheme_builder_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fangeul/presentation/theme/custom_scheme_builder.dart';

void main() {
  group('CustomSchemeBuilder', () {
    test('should preserve seed hue in dark surface', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0), // deep purple
        brightness: Brightness.dark,
      );
      final surfaceHsl = HSLColor.fromColor(scheme.surface);
      final seedHsl = HSLColor.fromColor(const Color(0xFF4527A0));
      // surface hue should be within 5 degrees of seed hue
      expect((surfaceHsl.hue - seedHsl.hue).abs(), lessThan(5));
    });

    test('should have higher surface saturation than fromSeed', () {
      const seed = Color(0xFF4527A0);
      final custom = CustomSchemeBuilder.build(
        seedColor: seed,
        brightness: Brightness.dark,
      );
      final fromSeed = ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      );
      final customSat = HSLColor.fromColor(custom.surface).saturation;
      final fromSeedSat = HSLColor.fromColor(fromSeed.surface).saturation;
      expect(customSat, greaterThan(fromSeedSat));
    });

    test('should auto-contrast to white on dark surface', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.dark,
      );
      expect(scheme.onSurface, Colors.white);
    });

    test('should auto-contrast to black87 on light surface', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.light,
      );
      expect(scheme.onSurface, Colors.black87);
    });

    test('should apply text color override', () {
      const textColor = Color(0xFFFFF8E1);
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF4527A0),
        brightness: Brightness.dark,
        textColorOverride: textColor,
      );
      expect(scheme.onSurface, textColor);
    });

    test('should include all required ColorScheme fields', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFF1565C0),
        brightness: Brightness.dark,
      );
      // Verify essential fields are non-null via construction
      expect(scheme.primary, isNotNull);
      expect(scheme.surface, isNotNull);
      expect(scheme.surfaceContainer, isNotNull);
      expect(scheme.surfaceContainerHigh, isNotNull);
      expect(scheme.outline, isNotNull);
      expect(scheme.outlineVariant, isNotNull);
    });

    test('should generate light scheme correctly', () {
      final scheme = CustomSchemeBuilder.build(
        seedColor: const Color(0xFFF8BBD0), // pink
        brightness: Brightness.light,
      );
      expect(scheme.brightness, Brightness.light);
      // Light surface should be very light
      expect(HSLColor.fromColor(scheme.surface).lightness, greaterThan(0.9));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/theme/custom_scheme_builder_test.dart -v`
Expected: FAIL — file not found

**Step 3: Implement CustomSchemeBuilder**

Create `lib/presentation/theme/custom_scheme_builder.dart` with the code from the design doc (lines 510-641 of supplementary doc). Key points:
- Dark: surface lightness 0.10, saturation ratio 0.25
- Light: surface lightness 0.96, saturation ratio 0.12
- Auto contrast: `computeLuminance() > 0.179 → black87, else white`
- 6 surface container variants with graduated lightness + saturation
- Secondary hue offset +30 degrees

**Step 4: Run test to verify it passes**

Run: `flutter test test/presentation/theme/custom_scheme_builder_test.dart -v`
Expected: PASS

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add CustomSchemeBuilder — fromSeed() bypass for choeae color"
```

---

## Task 5: `PalettePack` + `PaletteRegistry` — 수동 ColorScheme 팔레트

디자이너 수동 튜닝 ColorScheme 풀셋 팔레트. 무료 4개 + 프리미엄 6개.

**Files:**
- Create: `lib/presentation/theme/palette_pack.dart`
- Create: `lib/presentation/theme/palette_registry.dart`
- Create: `test/presentation/theme/palette_registry_test.dart`
- Delete contents of: `lib/presentation/theme/theme_palettes.dart` (Task 10에서 참조 제거 후 삭제)

**Step 1: Write the failing tests**

```dart
// test/presentation/theme/palette_registry_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fangeul/presentation/theme/palette_pack.dart';
import 'package:fangeul/presentation/theme/palette_registry.dart';

void main() {
  group('PaletteRegistry', () {
    test('should have exactly 10 palettes', () {
      expect(PaletteRegistry.all.length, 10);
    });

    test('should have 4 free and 6 premium', () {
      expect(PaletteRegistry.free.length, 4);
      expect(PaletteRegistry.premium.length, 6);
    });

    test('should find palette by id', () {
      final pack = PaletteRegistry.get('midnight');
      expect(pack.id, 'midnight');
    });

    test('should throw on unknown id', () {
      expect(() => PaletteRegistry.get('unknown'), throwsArgumentError);
    });

    test('each palette should have valid light and dark schemes', () {
      for (final pack in PaletteRegistry.all) {
        expect(pack.darkScheme.brightness, Brightness.dark,
            reason: '${pack.id} dark scheme brightness');
        expect(pack.lightScheme.brightness, Brightness.light,
            reason: '${pack.id} light scheme brightness');
      }
    });

    test('default palette should be midnight', () {
      expect(PaletteRegistry.defaultId, 'midnight');
    });

    test('schemeFor should return correct brightness', () {
      final pack = PaletteRegistry.get('purple_dream');
      expect(
          pack.schemeFor(Brightness.dark).brightness, Brightness.dark);
      expect(
          pack.schemeFor(Brightness.light).brightness, Brightness.light);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/theme/palette_registry_test.dart -v`
Expected: FAIL — file not found

**Step 3: Implement PalettePack**

Create `lib/presentation/theme/palette_pack.dart`:
```dart
import 'package:flutter/material.dart';

/// 미리 디자인된 팔레트팩. fromSeed() 미사용 — 모든 색상 수동 지정.
class PalettePack {
  const PalettePack({
    required this.id,
    required this.nameKey,
    required this.lightScheme,
    required this.darkScheme,
    required this.isPremium,
    required this.previewColor,
  });

  final String id;
  final String nameKey;
  final ColorScheme lightScheme;
  final ColorScheme darkScheme;
  final bool isPremium;
  final Color previewColor;

  ColorScheme schemeFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkScheme : lightScheme;
}
```

**Step 4: Implement PaletteRegistry**

Create `lib/presentation/theme/palette_registry.dart` with 10 palettes:

무료 4개: `midnight` (기본 틸-네이비, 현재 FangeulColors 토큰 재활용), `purple_dream`, `ocean_blue`, `rose_gold`
프리미엄 6개: `concert_encore`, `golden_hour`, `cherry_blossom`, `neon_night`, `mint_breeze`, `sunset_cafe`

각 팔레트마다 `const ColorScheme(brightness: ..., primary: ..., onPrimary: ..., ...)` 수동 지정.
`midnight` 팔레트는 기존 `FangeulColors` 토큰값 그대로 사용 (기본 테마 보존).

**Step 5: Run test to verify it passes**

Run: `flutter test test/presentation/theme/palette_registry_test.dart -v`
Expected: PASS

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: add PalettePack + PaletteRegistry — 10 manual ColorScheme palettes"
```

---

## Task 6: `ChoeaeColorConfig` sealed class

freezed sealed class — `palette(packId)` or `custom(seedColor, textColorOverride?)`.

**Files:**
- Create: `lib/presentation/theme/choeae_color_config.dart`
- Create: `lib/presentation/theme/choeae_color_config.freezed.dart` (build_runner)
- Create: `test/presentation/theme/choeae_color_config_test.dart`

**Step 1: Write the failing tests**

```dart
// test/presentation/theme/choeae_color_config_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fangeul/presentation/theme/choeae_color_config.dart';

void main() {
  group('ChoeaeColorConfig', () {
    test('palette variant should hold packId', () {
      const config = ChoeaeColorConfig.palette('purple_dream');
      expect(config, isA<ChoeaeColorConfig>());
    });

    test('custom variant should hold seedColor', () {
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF4527A0),
      );
      expect(config, isA<ChoeaeColorConfig>());
    });

    test('custom variant with textColorOverride', () {
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF4527A0),
        textColorOverride: Color(0xFFFFFFFF),
      );
      expect(config, isA<ChoeaeColorConfig>());
    });

    test('buildColorScheme for palette returns correct brightness', () {
      const config = ChoeaeColorConfig.palette('midnight');
      final dark = config.buildColorScheme(Brightness.dark);
      final light = config.buildColorScheme(Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.brightness, Brightness.light);
    });

    test('buildColorScheme for custom uses CustomSchemeBuilder', () {
      const config = ChoeaeColorConfig.custom(
        seedColor: Color(0xFF4527A0),
      );
      final scheme = config.buildColorScheme(Brightness.dark);
      expect(scheme.brightness, Brightness.dark);
      // Surface should have seed hue preserved (custom builder)
      final surfaceHsl = HSLColor.fromColor(scheme.surface);
      expect(surfaceHsl.saturation, greaterThan(0.05));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/theme/choeae_color_config_test.dart -v`
Expected: FAIL — file not found

**Step 3: Implement ChoeaeColorConfig**

Create `lib/presentation/theme/choeae_color_config.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:fangeul/presentation/theme/custom_scheme_builder.dart';
import 'package:fangeul/presentation/theme/palette_registry.dart';

part 'choeae_color_config.freezed.dart';

/// 최애색 설정 — 팔레트팩 선택 or 유저 커스텀.
@freezed
sealed class ChoeaeColorConfig with _$ChoeaeColorConfig {
  const factory ChoeaeColorConfig.palette(String packId) = ChoeaeColorPalette;
  const factory ChoeaeColorConfig.custom({
    required Color seedColor,
    Color? textColorOverride,
  }) = ChoeaeColorCustom;

  const ChoeaeColorConfig._();

  /// brightness에 따라 최종 ColorScheme 생성.
  ColorScheme buildColorScheme(Brightness brightness) {
    return switch (this) {
      ChoeaeColorPalette(:final packId) =>
        PaletteRegistry.get(packId).schemeFor(brightness),
      ChoeaeColorCustom(:final seedColor, :final textColorOverride) =>
        CustomSchemeBuilder.build(
          seedColor: seedColor,
          brightness: brightness,
          textColorOverride: textColorOverride,
        ),
    };
  }
}
```

**Step 4: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `choeae_color_config.freezed.dart` generated

**Step 5: Run test to verify it passes**

Run: `flutter test test/presentation/theme/choeae_color_config_test.dart -v`
Expected: PASS

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: add ChoeaeColorConfig freezed sealed class"
```

---

## Task 7: `FangeulTheme.build()` 리팩토링

기존 `dark()`, `light()`, `dynamicDark()`, `dynamicLight()` 4개 메서드를 `build(brightness, choeaeColor)` 단일 진입점으로 교체. `_withComponentThemes()` 유지.

**Files:**
- Modify: `lib/presentation/theme/fangeul_theme.dart` (전체 리팩토링)
- Modify: `test/presentation/theme/fangeul_theme_test.dart` (기존 테스트 업데이트 — Task 1 plan에서 생성된 파일)
- Create: `test/presentation/theme/fangeul_theme_test.dart` (없으면 생성)

**Step 1: Write the failing tests**

```dart
// test/presentation/theme/fangeul_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fangeul/presentation/theme/choeae_color_config.dart';
import 'package:fangeul/presentation/theme/fangeul_theme.dart';

void main() {
  group('FangeulTheme.build', () {
    test('should produce dark theme with palette', () {
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: const ChoeaeColorConfig.palette('midnight'),
      );
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, true);
    });

    test('should produce light theme with palette', () {
      final theme = FangeulTheme.build(
        brightness: Brightness.light,
        choeaeColor: const ChoeaeColorConfig.palette('midnight'),
      );
      expect(theme.brightness, Brightness.light);
    });

    test('should include component themes', () {
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: const ChoeaeColorConfig.palette('midnight'),
      );
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.navigationBarTheme.backgroundColor, isNotNull);
      expect(theme.chipTheme.showCheckmark, false);
      expect(theme.inputDecorationTheme.filled, true);
    });

    test('should work with custom config', () {
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: const ChoeaeColorConfig.custom(
          seedColor: Color(0xFF4527A0),
        ),
      );
      expect(theme.brightness, Brightness.dark);
      // Surface should reflect seed hue
      final hsl = HSLColor.fromColor(theme.colorScheme.surface);
      expect(hsl.saturation, greaterThan(0.05));
    });

    test('should apply custom text color override', () {
      const textColor = Color(0xFFFFF8E1);
      final theme = FangeulTheme.build(
        brightness: Brightness.dark,
        choeaeColor: const ChoeaeColorConfig.custom(
          seedColor: Color(0xFF4527A0),
          textColorOverride: textColor,
        ),
      );
      expect(theme.colorScheme.onSurface, textColor);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/theme/fangeul_theme_test.dart -v`
Expected: FAIL — `FangeulTheme.build` not found

**Step 3: Refactor FangeulTheme**

Replace `lib/presentation/theme/fangeul_theme.dart`:
```dart
import 'package:flutter/material.dart';

import 'package:fangeul/presentation/theme/choeae_color_config.dart';
import 'package:fangeul/presentation/theme/fangeul_text_styles.dart';

/// Fangeul ThemeData 팩토리.
///
/// 단일 진입점 [build]가 brightness + 최애색 설정으로 ThemeData를 합성한다.
/// 최애색 레이어가 ColorScheme 전체를 공급 (덧대기 아님, override).
abstract final class FangeulTheme {
  /// 앱 전체 ThemeData 생성.
  static ThemeData build({
    required Brightness brightness,
    required ChoeaeColorConfig choeaeColor,
  }) {
    final colorScheme = choeaeColor.buildColorScheme(brightness);
    final isDark = brightness == Brightness.dark;

    return _withComponentThemes(
      ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: colorScheme,
        scaffoldBackgroundColor:
            colorScheme.surfaceContainerLowest,
        textTheme: FangeulTextStyles.textTheme,
      ),
    );
  }

  // _withComponentThemes() 기존 코드 유지 (lines 120-160)
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/presentation/theme/fangeul_theme_test.dart -v`
Expected: PASS

**Step 5: Commit**

```bash
git add -A
git commit -m "refactor: FangeulTheme.build() single entry point — remove dark/light/dynamic"
```

---

## Task 8: `ChoeaeColorNotifier` — 기존 ThemeColorNotifier 교체

`ChoeaeColorConfig`를 상태로 관리. SharedPreferences에 type + value 형태로 persist. Undo 로직 유지.

**Files:**
- Create: `lib/presentation/providers/choeae_color_provider.dart`
- Create: `lib/presentation/providers/choeae_color_provider.g.dart` (build_runner)
- Create: `test/presentation/providers/choeae_color_provider_test.dart`

**Step 1: Write the failing tests**

```dart
// test/presentation/providers/choeae_color_provider_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/choeae_color_provider.dart';
import 'package:fangeul/presentation/providers/theme_providers.dart'
    show sharedPreferencesProvider;
import 'package:fangeul/presentation/theme/choeae_color_config.dart';

void main() {
  group('ChoeaeColorNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
    });

    tearDown(() => container.dispose());

    test('should default to midnight palette', () {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final config = container.read(choeaeColorNotifierProvider);
      expect(config, const ChoeaeColorConfig.palette('midnight'));
    });

    test('should switch palette', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final notifier =
          container.read(choeaeColorNotifierProvider.notifier);
      await notifier.selectPalette('purple_dream');
      expect(container.read(choeaeColorNotifierProvider),
          const ChoeaeColorConfig.palette('purple_dream'));
    });

    test('should set custom color', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final notifier =
          container.read(choeaeColorNotifierProvider.notifier);
      await notifier.setCustomColor(const Color(0xFF4527A0));
      final config = container.read(choeaeColorNotifierProvider);
      expect(config, isA<ChoeaeColorCustom>());
    });

    test('should persist and restore palette', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      await container
          .read(choeaeColorNotifierProvider.notifier)
          .selectPalette('ocean_blue');

      // New container with same prefs
      final prefs = await SharedPreferences.getInstance();
      final container2 = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ]);
      container2.listen(choeaeColorNotifierProvider, (_, __) {});
      expect(container2.read(choeaeColorNotifierProvider),
          const ChoeaeColorConfig.palette('ocean_blue'));
      container2.dispose();
    });

    test('should support undo', () async {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      final notifier =
          container.read(choeaeColorNotifierProvider.notifier);
      await notifier.selectPalette('purple_dream');
      await notifier.selectPalette('ocean_blue');
      expect(notifier.canUndo, true);
      await notifier.undo();
      expect(container.read(choeaeColorNotifierProvider),
          const ChoeaeColorConfig.palette('purple_dream'));
    });

    test('canUndo should be false initially', () {
      container.listen(choeaeColorNotifierProvider, (_, __) {});
      expect(
          container
              .read(choeaeColorNotifierProvider.notifier)
              .canUndo,
          false);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/providers/choeae_color_provider_test.dart -v`
Expected: FAIL

**Step 3: Implement ChoeaeColorNotifier**

Create `lib/presentation/providers/choeae_color_provider.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/theme_providers.dart';
import 'package:fangeul/presentation/theme/choeae_color_config.dart';

part 'choeae_color_provider.g.dart';

/// 최애색 상태 관리.
///
/// `ChoeaeColorConfig.palette('midnight')`이 기본값.
/// SharedPreferences에 `choeae_type` + `choeae_value` + `choeae_text_override` 저장.
@Riverpod(keepAlive: true)
class ChoeaeColorNotifier extends _$ChoeaeColorNotifier {
  static const _typeKey = 'choeae_type';
  static const _valueKey = 'choeae_value';
  static const _textKey = 'choeae_text_override';

  ChoeaeColorConfig? _previousConfig;
  bool _canUndo = false;

  bool get canUndo => _canUndo;

  @override
  ChoeaeColorConfig build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final type = prefs.getString(_typeKey);
    final value = prefs.getString(_valueKey);

    if (type == 'custom' && value != null) {
      final seedInt = int.tryParse(value, radix: 16);
      if (seedInt != null) {
        return ChoeaeColorConfig.custom(
          seedColor: Color(seedInt),
          textColorOverride: _loadTextOverride(prefs),
        );
      }
    }

    if (type == 'palette' && value != null) {
      return ChoeaeColorConfig.palette(value);
    }

    return const ChoeaeColorConfig.palette('midnight');
  }

  Future<void> selectPalette(String packId) async {
    _previousConfig = state;
    _canUndo = true;
    state = ChoeaeColorConfig.palette(packId);
    await _save('palette', packId);
    await _removeTextOverride();
  }

  Future<void> setCustomColor(Color seed, {Color? textColor}) async {
    _previousConfig = state;
    _canUndo = true;
    state = ChoeaeColorConfig.custom(
      seedColor: seed,
      textColorOverride: textColor,
    );
    final hex = seed.toARGB32().toRadixString(16).padLeft(8, '0');
    await _save('custom', hex);
    if (textColor != null) {
      await _saveTextOverride(textColor);
    } else {
      await _removeTextOverride();
    }
  }

  Future<void> setTextColorOverride(Color? color) async {
    final current = state;
    if (current is! ChoeaeColorCustom) return;
    _previousConfig = state;
    _canUndo = true;
    state = ChoeaeColorConfig.custom(
      seedColor: current.seedColor,
      textColorOverride: color,
    );
    if (color != null) {
      await _saveTextOverride(color);
    } else {
      await _removeTextOverride();
    }
  }

  Future<void> undo() async {
    if (!_canUndo || _previousConfig == null) return;
    _canUndo = false;
    state = _previousConfig!;
    // Persist restored state
    switch (_previousConfig!) {
      case ChoeaeColorPalette(:final packId):
        await _save('palette', packId);
        await _removeTextOverride();
      case ChoeaeColorCustom(:final seedColor, :final textColorOverride):
        final hex = seedColor.toARGB32().toRadixString(16).padLeft(8, '0');
        await _save('custom', hex);
        if (textColorOverride != null) {
          await _saveTextOverride(textColorOverride);
        } else {
          await _removeTextOverride();
        }
    }
  }

  Future<void> _save(String type, String value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_typeKey, type);
    await prefs.setString(_valueKey, value);
  }

  Color? _loadTextOverride(SharedPreferences prefs) {
    final hex = prefs.getString(_textKey);
    if (hex == null) return null;
    final value = int.tryParse(hex, radix: 16);
    return value != null ? Color(value) : null;
  }

  Future<void> _saveTextOverride(Color color) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(
      _textKey,
      color.toARGB32().toRadixString(16).padLeft(8, '0'),
    );
  }

  Future<void> _removeTextOverride() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_textKey);
  }
}
```

**Step 4: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 5: Run test to verify it passes**

Run: `flutter test test/presentation/providers/choeae_color_provider_test.dart -v`
Expected: PASS

**Step 6: Commit**

```bash
git add -A
git commit -m "feat: add ChoeaeColorNotifier — palette/custom state management with undo"
```

---

## Task 9: `app.dart` 마이그레이션

`FangeulTheme.build()` + `ChoeaeColorNotifier`로 전환. 기존 branching 제거.

**Files:**
- Modify: `lib/app.dart` (전체 리팩토링)

**Step 1: Refactor app.dart**

```dart
// Key changes in FangeulApp.build():
final choeaeColor = ref.watch(choeaeColorNotifierProvider);
// Remove: seedColor, textColor, branching
// Replace theme/darkTheme with:
final darkTheme = FangeulTheme.build(
  brightness: Brightness.dark,
  choeaeColor: choeaeColor,
);
final lightTheme = FangeulTheme.build(
  brightness: Brightness.light,
  choeaeColor: choeaeColor,
);
// SystemUiOverlayStyle: use darkTheme.colorScheme.surface directly
```

Full implementation:
- Remove `themeColorNotifierProvider` import
- Import `choeaeColorNotifierProvider` + `ChoeaeColorConfig`
- Remove `seedColor` variable and all null-branching
- `systemNavigationBarColor` = `isDark ? darkTheme.colorScheme.surfaceContainerLowest : lightTheme.colorScheme.surfaceContainerLowest`

**Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues (may have unused import warnings from old providers)

**Step 3: Commit**

```bash
git add -A
git commit -m "refactor: app.dart — use FangeulTheme.build() + ChoeaeColorNotifier"
```

---

## Task 10: Theme Picker Sheet 리디자인

피커 시트에서 `PaletteRegistry` + `ChoeaeColorNotifier` 사용. 기존 `ThemeColorNotifier` / `ThemePalettes` 참조 전체 교체.

**Files:**
- Modify: `lib/presentation/widgets/theme_picker_sheet.dart` (대규모 리팩토링)

**Key Changes:**

1. **Import 교체**: `theme_palettes.dart` → `palette_registry.dart` + `palette_pack.dart` + `choeae_color_provider.dart`
2. **`_PaletteGrid`**: `ThemePalettes.all` → `PaletteRegistry.all`, `ThemePalette` → `PalettePack`
3. **Default 칩**: `seedColor == null` → `choeaeColor is ChoeaeColorPalette && packId == 'midnight'` (또는 midnight 팔레트를 그리드에 포함)
4. **팔레트 탭**: `applyPalette()` → `notifier.selectPalette(pack.id)`
5. **HSL 슬라이더**: `setSeedColor(_hslColor)` → `notifier.setCustomColor(_hslColor, textColor: ...)`
6. **텍스트 색상**: `setCustomTextColor()` → `notifier.setTextColorOverride()`
7. **Undo**: `themeColorNotifierProvider.notifier.canUndo` → `choeaeColorNotifierProvider.notifier.canUndo`
8. **프리뷰**: `ColorScheme.fromSeed()` → `CustomSchemeBuilder.build()` (피커 프리뷰용)
9. **프리뷰 모드**: seedColor 백업 → `ChoeaeColorConfig` 백업으로 변경
10. **해금 체크**: `isThemeUnlockedProvider` 유지 (프리미엄 팔레트 잠금)
11. **l10n 키 변경**: `themePickerTitle` → `choeaeColor` (최애색)

**Step 1: Implement all changes**

(이 태스크는 UI 리팩토링이 주이므로 테스트는 기존 위젯 테스트가 있다면 업데이트, 없으면 flutter analyze로 검증)

**Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 3: Commit**

```bash
git add -A
git commit -m "refactor: theme picker sheet — PaletteRegistry + ChoeaeColorNotifier"
```

---

## Task 11: Settings Screen "최애색" 섹션

"Theme Color" → "최애색" 리브랜딩. 밝기 섹션 위에 배치. 색상 미리보기 원형.

**Files:**
- Modify: `lib/presentation/screens/settings_screen.dart:50-110`
- Modify: `lib/presentation/screens/settings_screen.dart:330-535` (디버그 패널 마이그레이션)

**Step 1: Reorder sections and update labels**

1. "최애색" ListTile을 "테마 모드" 위로 이동
2. `settingsThemeColor` → `choeaeColor` l10n 키
3. `leading`: 현재 팔레트의 `previewColor` or custom seed color 원형
4. 디버그 패널: `themeColorNotifierProvider` → `choeaeColorNotifierProvider` 교체

**Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 3: Commit**

```bash
git add -A
git commit -m "feat: settings — choeae color section with preview circle"
```

---

## Task 12: 하드코딩 색상 제거 — keyboard_key.dart

**Files:**
- Modify: `lib/presentation/widgets/keyboard_key.dart:122-125`

**Step 1: Replace hardcoded colors with theme tokens**

```dart
// Before:
final bgColor = isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF3F4F6);
final subColor = isDark
    ? FangeulColors.darkOnSurfaceVariant
    : FangeulColors.lightOnSurfaceVariant;

// After:
final bgColor = theme.colorScheme.surfaceContainer;
final subColor = theme.colorScheme.onSurfaceVariant;
```

**Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 3: Commit**

```bash
git add -A
git commit -m "fix: keyboard_key — use theme tokens instead of hardcoded colors"
```

---

## Task 13: l10n 키 추가 + 기존 키 마이그레이션

**Files:**
- Modify: `lib/l10n/app_ko.arb`
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_ja.arb`
- Modify: `lib/l10n/app_es.arb`
- Modify: `lib/l10n/app_id.arb`
- Modify: `lib/l10n/app_pt.arb`
- Modify: `lib/l10n/app_th.arb`
- Modify: `lib/l10n/app_vi.arb`

**새 l10n 키:**

| Key | ko | en | ja |
|---|---|---|---|
| `choeaeColor` | 최애색 | My Color | 推し色 |
| `choeaeColorDesc` | 최애의 색으로 앱을 물들여보세요 | Color your app with your bias | 推しの色でアプリを染めよう |
| `favoriteLimitReached` | 즐겨찾기 한도에 도달했어요 (최대 {limit}개) | Favorite limit reached (max {limit}) | お気に入りの上限に達しました (最大{limit}個) |
| `palettePurpleDream` | 보라빛 꿈 | Purple Dream | パープルドリーム |
| `paletteOceanBlue` | 깊은 바다 | Ocean Blue | オーシャンブルー |
| `paletteRoseGold` | 로즈 골드 | Rose Gold | ローズゴールド |
| `paletteMidnight` | 미드나이트 | Midnight | ミッドナイト |
| `paletteConcertEncore` | 콘서트 앙코르 | Concert Encore | コンサートアンコール |
| `paletteGoldenHour` | 골든 아워 | Golden Hour | ゴールデンアワー |
| `paletteNeonNight` | 네온 나이트 | Neon Night | ネオンナイト |
| `paletteMintBreeze` | 민트 브리즈 | Mint Breeze | ミントブリーズ |
| `paletteSunsetCafe` | 생카 노을 | Sunset Cafe | サンセットカフェ |

나머지 5개 언어(es/id/pt/th/vi)에도 번역 추가.

기존 `settingsThemeColor` / `settingsThemeColorDesc` / `themePickerTitle` / `themePickerSubtitle` 키는 새 키로 교체 후 제거 (또는 유지하고 redirect — 호출 위치 모두 업데이트 확인 후 제거).

**Step 1: Add all keys to all 8 arb files**

**Step 2: Run flutter gen-l10n**

Run: `flutter gen-l10n`
Expected: No errors

**Step 3: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: l10n — choeae color keys + palette names + favorite limit message"
```

---

## Task 14: 레거시 코드 정리

기존 `ThemeColorNotifier`, `ThemePalettes`, `dynamicDark()/dynamicLight()` 참조 전체 제거.

**Files:**
- Delete or clear: `lib/presentation/theme/theme_palettes.dart`
- Modify: `lib/presentation/providers/theme_providers.dart` (ThemeColorNotifier 제거)
- Modify: `test/presentation/providers/theme_providers_test.dart` (ThemeColorNotifier 테스트 → ChoeaeColor 테스트로 이전 확인)
- Grep all remaining references to old providers and fix

**Step 1: Search for remaining old references**

```bash
grep -r "themeColorNotifier\|ThemeColorNotifier\|ThemePalettes\|ThemePalette\|dynamicDark\|dynamicLight\|theme_palettes" lib/ test/
```

**Step 2: Fix all references**

- `theme_providers.dart`: `ThemeColorNotifier` 클래스 + `contrastRatio()` 함수 → `contrastRatio()`만 유지, `ThemeColorNotifier` 삭제
- `theme_palettes.dart`: 파일 삭제 (PaletteRegistry로 교체됨)
- 버블 엔진 동기화 코드에서 old provider 참조 교체

**Step 3: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Clean regeneration

**Step 4: Run full tests**

Run: `flutter test`
Expected: All tests pass

**Step 5: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 6: Commit**

```bash
git add -A
git commit -m "chore: remove legacy ThemeColorNotifier + ThemePalettes + dynamicDark/Light"
```

---

## Task 15: 통합 검증 + 버블 동기화

**Files:**
- Check: `lib/platform/` — 버블 엔진 테마 동기화
- Check: `lib/presentation/screens/` — 모든 화면에서 테마 적용 확인

**Step 1: Search for bubble theme sync**

```bash
grep -r "themeColor\|seedColor\|theme_seed" lib/platform/ lib/services/
```

교체 필요한 부분을 `choeaeColor` 기반으로 업데이트.

**Step 2: Run full test suite**

Run: `flutter test`
Expected: All tests pass (641+ existing + new tests)

**Step 3: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues

**Step 4: Final commit**

```bash
git add -A
git commit -m "test: full integration verification — choeae color system complete"
```

---

## Task 순서 및 의존성

```
Task 1 (즐겨찾기 피드백)   ── 독립
Task 2 (Undo 인라인)       ── 독립
Task 3 (자동 스크롤)        ── 독립
         |
Task 4 (CustomSchemeBuilder) ──┐
Task 5 (PalettePack)         ──┤── 독립, 병렬 가능
Task 6 (ChoeaeColorConfig)   ──┘  (4,5에 의존)
         |
Task 7 (FangeulTheme.build)  ── 6에 의존
Task 8 (ChoeaeColorNotifier) ── 6에 의존 (7과 병렬 가능)
         |
Task 9  (app.dart)           ── 7,8에 의존
Task 10 (피커 시트)           ── 5,8에 의존
Task 11 (설정 화면)           ── 8에 의존
Task 12 (키보드 하드코딩)      ── 독립
Task 13 (l10n)               ── 독립 (다른 Task와 병렬, 마지막에 통합)
Task 14 (레거시 정리)         ── 9,10,11 완료 후
Task 15 (통합 검증)           ── 모든 Task 완료 후
```

**추천 실행 순서:**
- Batch 1: Tasks 1, 2, 3, 4, 5 (독립, 병렬)
- Batch 2: Task 6 → Tasks 7, 8 (순차)
- Batch 3: Tasks 9, 10, 11, 12, 13 (순차/병렬 혼합)
- Batch 4: Tasks 14, 15 (최종 정리)

---

## 전체 수정 파일 목록

| 파일 | 액션 | Task |
|------|------|------|
| `lib/presentation/theme/custom_scheme_builder.dart` | 생성 | 4 |
| `lib/presentation/theme/palette_pack.dart` | 생성 | 5 |
| `lib/presentation/theme/palette_registry.dart` | 생성 | 5 |
| `lib/presentation/theme/choeae_color_config.dart` | 생성 | 6 |
| `lib/presentation/theme/choeae_color_config.freezed.dart` | 생성(빌드) | 6 |
| `lib/presentation/theme/fangeul_theme.dart` | 수정 | 7 |
| `lib/presentation/providers/choeae_color_provider.dart` | 생성 | 8 |
| `lib/presentation/providers/choeae_color_provider.g.dart` | 생성(빌드) | 8 |
| `lib/presentation/providers/theme_providers.dart` | 수정(정리) | 14 |
| `lib/presentation/providers/theme_providers.g.dart` | 재생성 | 14 |
| `lib/presentation/theme/theme_palettes.dart` | 삭제 | 14 |
| `lib/app.dart` | 수정 | 9 |
| `lib/presentation/widgets/theme_picker_sheet.dart` | 수정 | 2,3,10 |
| `lib/presentation/screens/settings_screen.dart` | 수정 | 11 |
| `lib/presentation/widgets/keyboard_key.dart` | 수정 | 12 |
| `lib/presentation/widgets/phrase_card.dart` | 수정 | 1 |
| `lib/presentation/widgets/compact_phrase_tile.dart` | 수정 | 1 |
| `lib/presentation/widgets/compact_phrase_list.dart` | 수정 | 1 |
| `lib/l10n/app_*.arb` (8 files) | 수정 | 1,13 |
| `test/presentation/theme/custom_scheme_builder_test.dart` | 생성 | 4 |
| `test/presentation/theme/palette_registry_test.dart` | 생성 | 5 |
| `test/presentation/theme/choeae_color_config_test.dart` | 생성 | 6 |
| `test/presentation/theme/fangeul_theme_test.dart` | 생성/수정 | 7 |
| `test/presentation/providers/choeae_color_provider_test.dart` | 생성 | 8 |

## Verification

1. `dart run build_runner build --delete-conflicting-outputs` — freezed 재생성
2. `flutter gen-l10n` — l10n 코드 생성
3. `flutter test` — 전체 테스트 통과
4. `flutter analyze` — 정적 분석 클린
5. 디바이스 테스트:
   - 즐겨찾기 5개 도달 → 별 탭 → SnackBar 표시 확인
   - 테마 피커 Undo → 레이아웃 시프트 없음 확인
   - Pick Your Own 펼침 → 자동 스크롤 확인
   - midnight/purple_dream/ocean_blue/rose_gold → 앱 전체 색상 "장악" 확인
   - 커스텀 피커: 보라색 선택 → surface까지 보라 틴트 확인 (fromSeed 대비)
   - 설정에서 "최애색" 섹션 위치 + 미리보기 원형 확인
   - 키보드 자판색이 테마에 맞게 변경 확인
