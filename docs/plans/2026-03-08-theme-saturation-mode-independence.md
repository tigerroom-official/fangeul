# Theme Saturation + Mode Independence Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** IAP 커스텀 테마가 surface를 seed color로 "물들이고", 시스템 다크/라이트 모드와 독립적으로 동작하며, 글자색 hex 입력 + WCAG 3단계 경고를 지원하게 한다.

**Architecture:** `CustomSchemeBuilder`의 surface 8개 슬롯을 `Hct.from(hue, chroma, shiftedTone)`으로 직접 생성하여 M3 tone 매핑을 우회한다. `ChoeaeColorConfig.custom`에 non-null `Brightness brightnessOverride` 필드를 추가(기본 dark)하여 시스템 brightness를 무시한다. `TextColorPickerDialog`에 hex 입력을 추가하고 WCAG 3단계 경고를 적용한다. `textColorOverride` 적용 범위를 onSurface + onSurfaceVariant만으로 축소하여 시맨틱 무결성을 보존한다.

**Codex 리뷰 반영 (2026-03-08):**
- Critical: 모든 custom mutation 경로(setCustomColor, setTextColorOverride, undo, restoreConfig)에서 brightnessOverride 보존
- Major: brightnessOverride를 non-null Brightness로 변경 (null "시스템 추종" 제거, UI에서 도달 불가하므로)
- Major: textColorOverride를 onSurface + onSurfaceVariant만 적용 (Container 계열도 제거)
- Major: ThemeSlotNotifier.renameSlot()에서 brightnessOverride 보존
- Major: Task 5/7에 실제 widget test 추가
- Suggestion: 의존성 그래프 수정 (Task 8 → Task 4 의존, Task 6을 Task 8 이후로)

**Tech Stack:** Flutter 3.41.2, material_color_utilities (MCU), Riverpod, freezed

**패널 합의 참조:** `docs/discussions/2026-03-08-theme-iap-structure-panel.md`

---

## Task 1: Surface Tone 평행이동 — CustomSchemeBuilder

**Files:**
- Modify: `lib/presentation/theme/custom_scheme_builder.dart`
- Modify: `test/presentation/theme/custom_scheme_builder_test.dart`

**핵심**: DynamicScheme 상속 유지. `_colorSchemeFromDynamic()`에서 surface 8개 슬롯 + surfaceDim/surfaceBright를 `Hct.from(hue, chroma, shiftedTone)`으로 직접 생성. onSurface/onSurfaceVariant는 auto contrast 유지.

### Step 1: 기존 테스트 실행 확인

Run: `cd /Users/dakhome/Develop/work-flutter/fangeul/.worktrees/theme-iap-overhaul && flutter test test/presentation/theme/custom_scheme_builder_test.dart`
Expected: All 23 tests PASS (기존 baseline)

### Step 2: 테스트 업데이트 — surface tone 상승 검증 추가

`test/presentation/theme/custom_scheme_builder_test.dart`에 추가:

```dart
test('dark surface tone should be higher than M3 default (6)', () {
  const seeds = <Color>[
    Color(0xFFFF0000), // red
    Color(0xFF2196F3), // blue
    Color(0xFF9C27B0), // purple
    Color(0xFF00BCD4), // cyan
  ];
  for (final seed in seeds) {
    final scheme = CustomSchemeBuilder.build(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    final tone = Hct.fromInt(scheme.surface.toARGB32()).tone;
    // M3 default surface tone = 6; shifted should be >= 12
    expect(tone, greaterThanOrEqualTo(12),
        reason: 'seed ${seed.toARGB32().toRadixString(16)} surface tone');
  }
});

test('dark surface hierarchy: lowest < surface < container < high < highest', () {
  final scheme = CustomSchemeBuilder.build(
    seedColor: const Color(0xFF9C27B0),
    brightness: Brightness.dark,
  );
  final lowest = Hct.fromInt(scheme.surfaceContainerLowest.toARGB32()).tone;
  final surface = Hct.fromInt(scheme.surface.toARGB32()).tone;
  final container = Hct.fromInt(scheme.surfaceContainer.toARGB32()).tone;
  final high = Hct.fromInt(scheme.surfaceContainerHigh.toARGB32()).tone;
  final highest = Hct.fromInt(scheme.surfaceContainerHighest.toARGB32()).tone;
  expect(lowest, lessThan(surface));
  expect(surface, lessThan(container));
  expect(container, lessThan(high));
  expect(high, lessThan(highest));
});

test('light surface hierarchy: highest < high < container < surface < lowest', () {
  final scheme = CustomSchemeBuilder.build(
    seedColor: const Color(0xFF9C27B0),
    brightness: Brightness.light,
  );
  final lowest = Hct.fromInt(scheme.surfaceContainerLowest.toARGB32()).tone;
  final surface = Hct.fromInt(scheme.surface.toARGB32()).tone;
  final container = Hct.fromInt(scheme.surfaceContainer.toARGB32()).tone;
  final high = Hct.fromInt(scheme.surfaceContainerHigh.toARGB32()).tone;
  final highest = Hct.fromInt(scheme.surfaceContainerHighest.toARGB32()).tone;
  expect(highest, lessThan(high));
  expect(high, lessThan(container));
  expect(container, lessThan(surface));
  expect(surface, lessThanOrEqualTo(lowest));
});
```

기존 `test('should generate light scheme correctly'...)` 의 assertion `expect(tone, greaterThan(90))` → `expect(tone, greaterThan(85))` 로 변경 (light surface tone이 96으로 내려감).

Run: `flutter test test/presentation/theme/custom_scheme_builder_test.dart`
Expected: 새 테스트 3개 FAIL (surface tone 아직 6), 기존 일부 PASS

### Step 3: CustomSchemeBuilder 구현 — surface tone 평행이동

`lib/presentation/theme/custom_scheme_builder.dart` 수정:

1. `_colorSchemeFromDynamic()`에서 surface 계열 10개 슬롯을 `_buildTintedSurface()` 호출로 교체
2. `_buildTintedSurface()` 함수 추가: M3 tone 배열에 dark +8 / light -3 shift 적용
3. `_hctColor(hue, chroma, tone)` 헬퍼 추가
4. onSurface/onSurfaceVariant는 DynamicScheme에서 가져옴 (auto contrast 유지)

Dark tone 매핑 (M3 기본 → shifted):
```
surfaceContainerLowest:  4 → 8
surfaceDim:              6 → 10
surface:                 6 → 14
surfaceContainerLow:    10 → 16
surfaceContainer:       12 → 20
surfaceContainerHigh:   17 → 25
surfaceContainerHighest:22 → 30
surfaceBright:          24 → 32
```

Light tone 매핑 (M3 기본 → shifted):
```
surfaceContainerLowest: 100 → 99
surfaceBright:           98 → 98
surface:                 98 → 96
surfaceContainerLow:     96 → 93
surfaceDim:              87 → 87
surfaceContainer:        94 → 90
surfaceContainerHigh:    92 → 86
surfaceContainerHighest: 90 → 82
```

Chroma: dark에서는 16→26 계단식, light에서는 4→20 계단식.

### Step 4: 테스트 실행 확인

Run: `flutter test test/presentation/theme/custom_scheme_builder_test.dart`
Expected: ALL PASS (기존 23 + 새 3 = 26)

주의: 기존 WCAG 대비 테스트도 통과해야 함. surface tone이 올라가면 onSurface 대비가 줄지만 여전히 AA(4.5:1) 이상이어야 함. 만약 특정 hue에서 실패하면 tone shift를 미세 조정.

### Step 5: 전체 테스트 실행

Run: `flutter test`
Expected: ALL PASS. `choeae_color_config_test.dart`의 surface tone assertion도 확인.

### Step 6: 커밋

```bash
git add lib/presentation/theme/custom_scheme_builder.dart test/presentation/theme/custom_scheme_builder_test.dart
git commit -m "feat: surface tone parallel shift for vivid tinting

Surface 8개 슬롯을 Hct.from()으로 직접 생성하여 M3 tone 매핑 우회.
Dark +8 / Light -3~16 shift로 seed hue가 surface에 강하게 반영됨.
기존 DynamicScheme의 primary/error 계열은 그대로 유지."
```

---

## Task 2: textColorOverride 적용 범위 축소

**Files:**
- Modify: `lib/presentation/theme/custom_scheme_builder.dart`
- Modify: `test/presentation/theme/custom_scheme_builder_test.dart`

**핵심**: 현재 onPrimary/onSecondary/onTertiary/onError/onErrorContainer까지 덮어쓰는데, onSurface/onSurfaceVariant + Container 계열(onPrimaryContainer, onSecondaryContainer, onTertiaryContainer)만 적용하도록 축소.

### Step 1: 테스트 추가 — onPrimary는 엔진 자동값 유지 확인

```dart
test('textOverride should NOT override onPrimary', () {
  const textColor = Color(0xFFFF0000);
  final withOverride = CustomSchemeBuilder.build(
    seedColor: const Color(0xFF4527A0),
    brightness: Brightness.dark,
    textColorOverride: textColor,
  );
  final without = CustomSchemeBuilder.build(
    seedColor: const Color(0xFF4527A0),
    brightness: Brightness.dark,
  );
  // onPrimary should remain engine-generated
  expect(withOverride.onPrimary, equals(without.onPrimary));
});

test('textOverride should NOT override onError', () {
  const textColor = Color(0xFFFF0000);
  final withOverride = CustomSchemeBuilder.build(
    seedColor: const Color(0xFF4527A0),
    brightness: Brightness.dark,
    textColorOverride: textColor,
  );
  final without = CustomSchemeBuilder.build(
    seedColor: const Color(0xFF4527A0),
    brightness: Brightness.dark,
  );
  expect(withOverride.onError, equals(without.onError));
});
```

Run: `flutter test test/presentation/theme/custom_scheme_builder_test.dart`
Expected: 새 2개 FAIL (현재 onPrimary/onError도 textColor로 덮어쓰므로)

### Step 2: 코드 수정 — copyWith 범위 축소

`custom_scheme_builder.dart` line 33~44의 `cs.copyWith(...)` 수정:
- 제거: `onPrimary`, `onSecondary`, `onTertiary`, `onError`, `onErrorContainer`, `onPrimaryContainer`, `onSecondaryContainer`, `onTertiaryContainer`
- 유지: `onSurface`, `onSurfaceVariant` 만

(Codex 리뷰: Container 계열도 제거. WCAG 경고가 surface만 체크하므로 Container 배경에 대한 대비 불일치 방지)

### Step 3: 기존 테스트 수정

`test('should apply text color override')` — 현재 `expect(scheme.onSurface, textColor)` → 유지.
`test('textOverride onSurfaceVariant should preserve RGB channels')` → 유지.

### Step 4: 테스트 실행

Run: `flutter test test/presentation/theme/custom_scheme_builder_test.dart`
Expected: ALL PASS

### Step 5: 커밋

```bash
git add lib/presentation/theme/custom_scheme_builder.dart test/presentation/theme/custom_scheme_builder_test.dart
git commit -m "fix: narrow textColorOverride scope to surface/container on* slots

onPrimary/onSecondary/onTertiary/onError는 엔진 auto contrast 유지.
onSurface/onSurfaceVariant + Container 계열만 override하여 시맨틱 무결성 보존."
```

---

## Task 3: brightnessOverride — ChoeaeColorConfig + freezed

**Files:**
- Modify: `lib/presentation/theme/choeae_color_config.dart`
- Modify: `lib/presentation/theme/choeae_color_config.freezed.dart` (codegen)
- Modify: `test/presentation/theme/choeae_color_config_test.dart`

**핵심**: `ChoeaeColorConfig.custom`에 non-null `Brightness brightnessOverride` 필드 추가 (기본 `Brightness.dark`). `buildColorScheme()` 에서 custom이면 brightnessOverride를 사용하고 시스템 brightness 무시. (Codex: nullable은 UI에서 도달 불가 → non-null로)

### Step 1: 테스트 추가

```dart
test('custom brightnessOverride should override passed brightness', () {
  const config = ChoeaeColorConfig.custom(
    seedColor: Color(0xFF4527A0),
    brightnessOverride: Brightness.dark,
  );
  // 시스템은 light인데 override가 dark → dark scheme 반환
  final scheme = config.buildColorScheme(Brightness.light);
  expect(scheme.brightness, Brightness.dark);
});

test('custom with light override should produce light scheme', () {
  const config = ChoeaeColorConfig.custom(
    seedColor: Color(0xFF4527A0),
    brightnessOverride: Brightness.light,
  );
  final scheme = config.buildColorScheme(Brightness.dark);
  expect(scheme.brightness, Brightness.light);
});

test('custom default brightnessOverride should be dark', () {
  const config = ChoeaeColorConfig.custom(
    seedColor: Color(0xFF4527A0),
  );
  expect((config as ChoeaeColorCustom).brightnessOverride, Brightness.dark);
});

test('palette should always use passed brightness (no override)', () {
  const config = ChoeaeColorConfig.palette('midnight');
  final scheme = config.buildColorScheme(Brightness.light);
  expect(scheme.brightness, Brightness.light);
});
```

Run: `flutter test test/presentation/theme/choeae_color_config_test.dart`
Expected: FAIL (brightnessOverride 필드 없음)

### Step 2: ChoeaeColorConfig 수정

`lib/presentation/theme/choeae_color_config.dart`:

```dart
const factory ChoeaeColorConfig.custom({
  required Color seedColor,
  Color? textColorOverride,
  @Default(Brightness.dark) Brightness brightnessOverride,  // non-null, 기본 dark
}) = ChoeaeColorCustom;
```

`buildColorScheme()` 수정:
```dart
ChoeaeColorCustom(:final seedColor, :final textColorOverride, :final brightnessOverride) =>
  CustomSchemeBuilder.build(
    seedColor: seedColor,
    brightness: brightnessOverride,  // 항상 override 사용
    textColorOverride: textColorOverride,
  ),
```

**주의**: palette 타입은 기존대로 `brightness` 파라미터를 그대로 사용 (시스템 추종).

### Step 3: freezed codegen

Run: `cd /Users/dakhome/Develop/work-flutter/fangeul/.worktrees/theme-iap-overhaul && dart run build_runner build --delete-conflicting-outputs`
Expected: codegen 성공

### Step 4: 컴파일 에러 수정

`brightnessOverride` 추가로 인해 `ChoeaeColorCustom` 패턴 매칭 사용처 확인. freezed의 optional 필드이므로 기존 코드는 깨지지 않을 것.

### Step 5: 테스트 실행

Run: `flutter test test/presentation/theme/choeae_color_config_test.dart`
Expected: ALL PASS

### Step 6: 커밋

```bash
git add lib/presentation/theme/choeae_color_config.dart lib/presentation/theme/choeae_color_config.freezed.dart test/presentation/theme/choeae_color_config_test.dart
git commit -m "feat: add brightnessOverride to ChoeaeColorConfig.custom

IAP 커스텀 테마가 시스템 다크/라이트 모드와 독립적으로 동작.
brightnessOverride가 null이면 기존 동작(시스템 추종) 유지."
```

---

## Task 4: ChoeaeColorNotifier + ThemeSlot — brightnessOverride 저장/로드

**Files:**
- Modify: `lib/presentation/providers/choeae_color_provider.dart`
- Modify: `lib/presentation/models/theme_slot.dart`
- Modify: `test/presentation/models/theme_slot_test.dart`

**핵심**: SharedPreferences에 `choeae_brightness_override` 키로 저장. ThemeSlot에도 `brightnessOverride` 직렬화 추가.

### Step 1: ThemeSlot 테스트 추가

```dart
test('should serialize and deserialize brightnessOverride', () {
  const slot = ThemeSlot(
    name: 'Dark',
    type: 'custom',
    value: 'ff4527a0',
    brightnessOverride: 'dark',
  );
  final json = slot.toJson();
  expect(json['brightnessOverride'], 'dark');
  final restored = ThemeSlot.fromJson(json);
  expect(restored.brightnessOverride, 'dark');
});

test('should convert brightnessOverride to ChoeaeColorConfig', () {
  const slot = ThemeSlot(
    name: 'Dark',
    type: 'custom',
    value: 'ff4527a0',
    brightnessOverride: 'dark',
  );
  final config = slot.toConfig();
  expect(config, isA<ChoeaeColorCustom>());
  expect((config as ChoeaeColorCustom).brightnessOverride, Brightness.dark);
});
```

### Step 2: ThemeSlot 수정

`lib/presentation/models/theme_slot.dart`:
- `brightnessOverride` 필드 추가 (`String?` — 'dark' | 'light' | null)
- `toJson()` / `fromJson()` 업데이트
- `toConfig()` — `brightnessOverride: br == 'dark' ? Brightness.dark : br == 'light' ? Brightness.light : null`
- `fromConfig()` — `brightnessOverride: config.brightnessOverride?.name`

### Step 3: ChoeaeColorNotifier 수정 (Codex Critical 반영)

`lib/presentation/providers/choeae_color_provider.dart`:
- `_brightnessKey = 'choeae_brightness_override'`
- `build()`: prefs에서 brightness override 읽기 (null → `Brightness.dark` 기본), `ChoeaeColorConfig.custom()` 생성 시 전달
- **모든 custom mutation 경로에서 기존 brightnessOverride 보존:**
  - `setCustomColor()`: 기존 state가 ChoeaeColorCustom이면 기존 brightnessOverride 유지
  - `setTextColorOverride()`: 기존 state의 brightnessOverride 유지
  - `undo()`: _previousConfig에 brightnessOverride 포함 (freezed 자동)
  - `restoreConfig()`: brightnessOverride 저장
- `setBrightnessOverride(Brightness br)`: 전용 메서드 추가 (seed/text 유지, brightness만 변경)
- `_saveBrightnessOverride()` 헬퍼

### Step 3-1: ThemeSlotNotifier.renameSlot() brightnessOverride 보존

`lib/presentation/providers/theme_slot_provider.dart` line 64~77의 `renameSlot()`:
기존 `ThemeSlot` 재구성 시 `brightnessOverride` 필드 복사 추가.

```dart
slots[index] = ThemeSlot(
  name: name,
  type: old.type,
  value: old.value,
  textOverride: old.textOverride,
  brightnessOverride: old.brightnessOverride,  // 추가
);
```

### Step 4: 테스트 실행

Run: `flutter test test/presentation/models/theme_slot_test.dart`
Expected: ALL PASS

### Step 5: 전체 테스트

Run: `flutter test`
Expected: ALL PASS

### Step 6: 커밋

```bash
git add lib/presentation/providers/choeae_color_provider.dart lib/presentation/models/theme_slot.dart test/presentation/models/theme_slot_test.dart
git commit -m "feat: persist brightnessOverride in SharedPrefs + ThemeSlot

커스텀 테마의 brightness override를 SharedPreferences에 저장.
ThemeSlot 직렬화에도 brightnessOverride 필드 추가."
```

---

## Task 5: app.dart — 커스텀 테마 시 brightness 분기

**Files:**
- Modify: `lib/app.dart`
- Modify: `test/app_test.dart` (해당 assertion 업데이트 필요 시)

**핵심**: 커스텀 테마 + brightnessOverride 시 `MaterialApp.router`의 theme/darkTheme/themeMode를 분기.

### Step 1: app.dart 수정

현재: `theme:` light, `darkTheme:` dark, `themeMode:` 시스템설정

변경:
```dart
final choeaeColor = ref.watch(choeaeColorNotifierProvider);

// 커스텀 테마의 brightness override 결정
final Brightness? brightOverride = choeaeColor is ChoeaeColorCustom
    ? choeaeColor.brightnessOverride
    : null;

final bool effectiveDark;
if (brightOverride != null) {
  effectiveDark = brightOverride == Brightness.dark;
} else {
  effectiveDark = themeMode == ThemeMode.dark ||
      (themeMode == ThemeMode.system &&
          MediaQuery.platformBrightnessOf(context) == Brightness.dark);
}

// brightness override 활성 시 theme/darkTheme를 동일 brightness로 설정
final ThemeMode effectiveThemeMode;
final ThemeData lightTheme;
final ThemeData darkTheme;

if (brightOverride != null) {
  final overriddenTheme = FangeulTheme.build(
    brightness: brightOverride,
    choeaeColor: choeaeColor,
  );
  lightTheme = overriddenTheme;
  darkTheme = overriddenTheme;
  effectiveThemeMode = brightOverride == Brightness.dark
      ? ThemeMode.dark
      : ThemeMode.light;
} else {
  lightTheme = FangeulTheme.build(
    brightness: Brightness.light,
    choeaeColor: choeaeColor,
  );
  darkTheme = FangeulTheme.build(
    brightness: Brightness.dark,
    choeaeColor: choeaeColor,
  );
  effectiveThemeMode = themeMode;
}
```

SystemUiOverlayStyle도 `effectiveDark`로 변경.

### Step 2: 테스트 실행

Run: `flutter test test/app_test.dart`
Expected: PASS (혹은 navigation bar color assertion 업데이트)

### Step 3: 전체 테스트

Run: `flutter test`
Expected: ALL PASS

### Step 4: 커밋

```bash
git add lib/app.dart test/app_test.dart
git commit -m "feat: brightness override routing in FangeulApp

커스텀 테마 + brightnessOverride 활성 시 시스템 ThemeMode 무시.
theme/darkTheme를 override brightness로 통일하여 일관된 색상 보장."
```

---

## Task 6: 설정 화면 — 커스텀 테마 시 ThemeMode 비활성화

**Files:**
- Modify: `lib/presentation/screens/settings_screen.dart`

**핵심**: 커스텀 테마 + brightnessOverride 활성 시 ThemeMode SegmentedButton을 비활성화 + 안내 문구 표시.

### Step 1: settings_screen.dart 수정

ThemeMode `SegmentedButton` 영역에 조건 추가:
```dart
final hasOverride = choeaeColor is ChoeaeColorCustom &&
    choeaeColor.brightnessOverride != null;

SegmentedButton<ThemeMode>(
  // ... 기존 segments ...
  selected: {themeMode},
  onSelectionChanged: hasOverride
      ? null  // 비활성화
      : (modes) { ... },
),
if (hasOverride)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      l.themeModeLocked,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    ),
  ),
```

### Step 2: l10n 키 추가

`lib/l10n/app_en.arb`: `"themeModeLocked": "Custom theme controls brightness independently"`
`lib/l10n/app_ko.arb`: `"themeModeLocked": "커스텀 테마가 밝기를 직접 관리합니다"`

### Step 3: 테스트 실행

Run: `flutter test`
Expected: ALL PASS

### Step 4: 커밋

```bash
git add lib/presentation/screens/settings_screen.dart lib/l10n/app_en.arb lib/l10n/app_ko.arb
git commit -m "feat: disable ThemeMode selector when custom brightness override active

커스텀 테마 활성 시 시스템 테마 모드 세그먼트를 비활성화하고 안내 문구 표시."
```

---

## Task 7: TextColorPickerDialog — hex 입력 + WCAG 3단계 경고

**Files:**
- Modify: `lib/presentation/widgets/text_color_picker_dialog.dart`
- Modify: `test/presentation/widgets/text_color_picker_test.dart`

**핵심**: hex TextField 추가 (6자리, `#` prefix 장식), WCAG 3단계 경고 (>=4.5 초록 / 3.0~4.49 주황 / <3.0 빨강+오버레이), chroma 슬라이더 접이식 추가.

### Step 1: 테스트 추가 — hex 파싱

```dart
test('should parse valid 6-digit hex to Color', () {
  // TextColorPickerDialog 내부의 hex 파싱 로직 테스트
  final parsed = int.tryParse('FFD700', radix: 16);
  expect(parsed, isNotNull);
  final color = Color(0xFF000000 | parsed!);
  expect(color, const Color(0xFFFFD700));
});

test('should reject invalid hex input', () {
  expect(int.tryParse('ZZZZZZ', radix: 16), isNull);
  expect(int.tryParse('12345', radix: 16), isNotNull); // 5자리도 파싱은 되지만 UI에서 6자리 강제
});
```

### Step 2: TextColorPickerDialog 수정

주요 변경:
1. `_chroma` → mutable state (`_chroma = 20.0` 기본, 접이식 슬라이더로 조절 가능)
2. `_hexController` TextEditingController 추가
3. hex TextField: `#` prefix Text + 6자리 FilteringTextInputFormatter
4. hex 입력 시 hue/tone/chroma 슬라이더 역방향 동기화
5. 슬라이더 조작 시 hex 필드 정방향 동기화
6. WCAG 3단계: Icon + 색상 분기 (초록/주황/빨강)
7. <3.0 시 프리뷰 영역에 반투명 오버레이
8. chroma 슬라이더: 접이식 (ExpansionTile 또는 AnimatedCrossFade)

### Step 3: WCAG 경고 UI 테스트 업데이트

기존 `text_color_picker_test.dart`의 WCAG 테스트에 3단계 검증 추가:
- ratio >= 4.5 → 초록 아이콘
- 3.0 <= ratio < 4.5 → 주황 아이콘
- ratio < 3.0 → 빨강 아이콘

### Step 4: l10n 키 추가

`app_en.arb`:
```json
"themePickerHexInput": "Hex color",
"themePickerChroma": "Chroma"
```

`app_ko.arb`:
```json
"themePickerHexInput": "색상 코드",
"themePickerChroma": "채도"
```

### Step 5: 테스트 실행

Run: `flutter test test/presentation/widgets/text_color_picker_test.dart`
Expected: ALL PASS

### Step 6: 전체 테스트

Run: `flutter test`
Expected: ALL PASS

### Step 7: 커밋

```bash
git add lib/presentation/widgets/text_color_picker_dialog.dart test/presentation/widgets/text_color_picker_test.dart lib/l10n/app_en.arb lib/l10n/app_ko.arb
git commit -m "feat: hex input + WCAG 3-level warning in TextColorPickerDialog

6자리 hex 입력 + 슬라이더 양방향 동기화.
WCAG 3단계: >=4.5 초록, 3.0~4.49 주황, <3.0 빨강+프리뷰 오버레이.
chroma 접이식 슬라이더 추가 (기본 숨김, 범위 10~100)."
```

---

## Task 8: theme_picker_sheet — brightnessOverride 토글 + surface 프리뷰 연동

**Files:**
- Modify: `lib/presentation/widgets/theme_picker_sheet.dart`

**핵심**: 커스텀 피커 영역에 brightness 토글(dark/light) 추가. `_TextColorSelector`의 backgroundColor를 override brightness 기반으로 계산. `_PreviewCard`도 override brightness 사용.

### Step 1: theme_picker_sheet.dart 수정

1. 커스텀 피커 영역에 brightness 토글 추가:
```dart
// 커스텀 피커 내부, HctColorPicker 아래
_BrightnessToggle(
  current: choeaeColor is ChoeaeColorCustom
      ? choeaeColor.brightnessOverride ?? Brightness.dark
      : Brightness.dark,
  onChanged: (br) {
    ref.read(choeaeColorNotifierProvider.notifier)
        .setBrightnessOverride(br);
  },
),
```

2. `_TextColorSelector` 의 `backgroundColor` 계산을 `effectiveBrightness` 기반으로:
```dart
final effectiveBrightness = choeaeColor is ChoeaeColorCustom
    ? (choeaeColor.brightnessOverride ?? theme.brightness)
    : theme.brightness;
backgroundColor: choeaeColor.buildColorScheme(effectiveBrightness).surface,
```

3. `_PreviewCard`의 brightness도 동일하게 변경.

4. `_BrightnessToggle` private 위젯 추가 (SegmentedButton<Brightness> 래퍼).

### Step 2: 테스트 실행

Run: `flutter test`
Expected: ALL PASS

### Step 3: 커밋

```bash
git add lib/presentation/widgets/theme_picker_sheet.dart
git commit -m "feat: brightness toggle in custom picker + surface preview sync

커스텀 피커에 dark/light 토글 추가.
프리뷰, 글자색 배경, WCAG 대비 계산 모두 effectiveBrightness 사용."
```

---

## Task 9: 최종 검증 + 정적 분석

### Step 1: 전체 테스트

Run: `flutter test`
Expected: ALL PASS

### Step 2: 정적 분석

Run: `flutter analyze`
Expected: No issues

### Step 3: 포맷 검증

Run: `dart format --set-exit-if-changed .`
Expected: No formatting changes

### Step 4: 최종 커밋 (필요시 fix)

---

## Task 순서 및 의존성 (Codex 리뷰 반영)

```
Task 1 (Surface tone shift) ──→ Task 2 (textOverride 축소)
                                    ↓
Task 3 (brightnessOverride freezed) ──→ Task 4 (Notifier+ThemeSlot 저장)
                                           ↓
                                    Task 5 (app.dart 분기)
                                           ↓
Task 7 (TextColorPicker hex+WCAG)   Task 4 ──→ Task 8 (theme_picker_sheet 연동)
                                                    ↓
                                              Task 6 (설정 화면) ← Task 8 이후
                                                    ↓
                                              Task 9 (최종 검증)
```

**배치 계획:**
- Batch 1: Task 1 + Task 2 (CustomSchemeBuilder 변경)
- Batch 2: Task 3 + Task 4 (freezed + provider + slot, 순차)
- Batch 3: Task 5 + Task 7 (app.dart + TextColorPicker, 병렬 가능)
- Batch 4: Task 8 + Task 6 (theme_picker_sheet 연동 → 설정 화면 비활성화)
- Batch 5: Task 9 (최종 검증)

---

## 전체 수정/생성 파일 목록

| 파일 | 액션 | Task |
|------|------|------|
| `lib/presentation/theme/custom_scheme_builder.dart` | 대규모 수정 | 1, 2 |
| `lib/presentation/theme/choeae_color_config.dart` | 필드 추가 | 3 |
| `lib/presentation/theme/choeae_color_config.freezed.dart` | codegen | 3 |
| `lib/presentation/providers/choeae_color_provider.dart` | 메서드 추가 | 4 |
| `lib/presentation/models/theme_slot.dart` | 필드 추가 | 4 |
| `lib/app.dart` | brightness 분기 | 5 |
| `lib/presentation/screens/settings_screen.dart` | ThemeMode 비활성 | 6 |
| `lib/presentation/widgets/text_color_picker_dialog.dart` | hex+WCAG | 7 |
| `lib/presentation/widgets/theme_picker_sheet.dart` | brightness 토글 | 8 |
| `lib/l10n/app_en.arb` + `app_ko.arb` | 키 추가 | 6, 7 |
| 테스트 파일 4개 | 수정 | 1-4, 7 |

**변경 없는 파일:**
- `fangeul_theme.dart` — brightness 파라미터만 다르게 받을 뿐 내부 로직 변경 없음
- `palette_registry.dart` — 무료 팔레트는 기존 동작 유지
- `hct_color_picker.dart` — 배경색 피커는 변경 없음
- `pubspec.yaml` — 신규 패키지 0개
