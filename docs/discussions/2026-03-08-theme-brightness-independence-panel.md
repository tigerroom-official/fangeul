# IAP 커스텀 테마의 시스템 다크/라이트 모드 완전 독립

> Date: 2026-03-08
> Topic: 커스텀(IAP) 테마가 시스템 brightness 설정에 영향받지 않고 일관된 색상을 유지해야 하는가
> Participants: 민재(PM), 소영(M3 엔지니어), 하은(접근성), 준서(Flutter 개발자), 유리(UX 디자이너)
> Status: **Consensus reached**

## 현재 코드 구조 (문제의 근원)

```
app.dart:
  theme: FangeulTheme.build(brightness: Brightness.light, choeaeColor)
  darkTheme: FangeulTheme.build(brightness: Brightness.dark, choeaeColor)
  themeMode: themeModeNotifier  ← 다크/라이트/시스템

FangeulTheme.build(brightness, choeaeColor)
  → choeaeColor.buildColorScheme(brightness)  ← brightness가 외부에서 주입됨
    → CustomSchemeBuilder.build(seedColor, brightness, textOverride)
      → _SchemeVividTint(sourceColorHct, isDark: brightness == Brightness.dark)
```

유저가 W990 IAP로 seed color를 고르고 글자색까지 세팅했는데, 설정에서 다크→라이트로 바꾸면 surface/primary/secondary 전부 뒤집힌다. "내가 산 색이 아니다"라는 불만이 예상되는 구조.

## 쟁점 옵션 정리

| 옵션 | 설명 | 핵심 트레이드오프 |
|------|------|------------------|
| A | seed의 HCT tone으로 brightness 자동 결정 (tone<50→dark, >=50→light) | 유저 제어권 없음, tone 경계값 혼란 |
| B | 커스텀 테마에 자체 brightness toggle 제공 | 가장 유연, UI 복잡도 증가 |
| C | 커스텀 테마는 항상 dark 고정 | 단순, 밝은 테마 원하는 유저 배제 |
| D | tone 기반 + dark 편향 (50~65도 dark) | A의 변형, 여전히 예측 불가 |

---

## 라운드 1: A조 선공 (지지)

### 민재 (PM)

자, 이건 사실 매출의 문제예요. 유저가 천 원 내고 "이 색이 내 앱"이라고 느끼는 건 — 그 색이 항상 그 색이어야 한다는 거예요. 아침에 핸드폰 라이트 모드로 전환했더니 내가 고른 딥 네이비가 하늘색 파스텔이 돼 있으면? 환불 요청이요.

실데이터로 볼게요. 저희 타겟 SEA 10대~20대, 이 층은 폰 설정을 거의 안 건드려요. 한 번 다크 모드 켜면 그대로 쓰는 거죠. 근데 간혹 배터리 절약 모드에서 라이트로 튀거나, 시스템 자동 전환 걸어놓은 유저도 있거든요. 그때마다 내가 산 테마가 흔들리면 perceived value가 폭락합니다.

저는 **옵션 B를 기본으로 하되, 기본값은 dark**로 가야 한다고 봐요. 이유는:

1. W990의 체감 가치 — "나만의 설정" 하나가 더 있다는 것 자체가 프리미엄
2. 슬롯 시스템과 시너지 — 슬롯별로 brightness가 다를 수 있으면 "콘서트용(dark) / 카페용(light)" 유즈케이스가 열림
3. 유저 제어권 = 불만 감소 — 자동 결정(옵션 A/D)은 "왜 내가 고른 색이 어두운 거예요?" 문의 유발

### 소영 (M3 엔지니어)

민재 님 의견에 기술적으로 동의합니다. 제가 코드를 까봤는데, `_SchemeVividTint`는 `DynamicScheme`을 상속해서 `isDark` 파라미터 하나로 36슬롯 ColorScheme 전체가 뒤집혀요.

```dart
// custom_scheme_builder.dart:22
final scheme = _SchemeVividTint(
  sourceColorHct: src,
  isDark: isDark,  // ← 이 한 줄이 surface/primary/on* 전부 결정
);
```

`isDark`가 `true`면 tone 80→primary, tone 20→surface. `false`면 정반대. 같은 seed hue 270(보라)이어도 dark에서는 연보라 primary + 짙은 보라 surface, light에서는 짙은 보라 primary + 흰보라 surface가 돼요. 완전히 다른 앱처럼 보입니다.

**옵션 A(tone 자동 결정)의 기술적 문제점** 한 가지 짚을게요. HCT tone은 seed color의 lightness인데, 유저가 피커에서 tone 50 근처를 골랐다고 해 봐요. 손가락이 1px 움직이면 dark↔light가 왔다 갔다 합니다. UX 재앙이에요. 옵션 D(dark 편향)도 경계선을 옮겼을 뿐 같은 문제가 있어요.

**옵션 C(dark 고정)는** 공학적으로는 가장 깔끔한데, 밝은 핑크 seed + 밝은 배경을 원하는 유저를 완전히 차단합니다. 체리블로썸 팔레트의 light scheme이 인기 있는 걸 보면 무시 못 할 세그먼트예요.

결론: **옵션 B — 커스텀 테마 내에 brightness toggle, 기본값 dark**. 구현은 `ChoeaeColorConfig.custom`에 `Brightness? overrideBrightness` 필드 하나 추가로 끝나요.

---

## 라운드 2: B조 반론 (우려)

### 하은 (접근성)

잠깐만요, 여기 접근성 관점에서 심각한 이슈 세 가지 올릴게요.

**첫째, StatusBar/NavigationBar 가독성.** 현재 `app.dart`에서 `isDark` 판별로 statusBarIconBrightness를 결정해요:

```dart
statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
```

근데 커스텀 테마가 시스템과 독립적으로 brightness를 가지면, 시스템은 라이트 모드(→ status bar 아이콘 dark)인데 앱 배경은 dark scheme(→ 짙은 배경)이 될 수 있어요. 짙은 배경에 짙은 아이콘 = **아무것도 안 보임**. 이건 WCAG 1.4.3 위반이에요.

**둘째, 시스템 접근성 설정 무시 문제.** Android 접근성 서비스 중 "강제 다크 모드"가 있어요. 저시력 유저가 이걸 켜놨는데 앱이 light scheme을 강제하면 — 눈이 아파서 앱을 삭제합니다. Google Play 접근성 가이드라인에도 "시스템 테마 설정 존중"이 권장 사항이에요.

**셋째, `textColorOverride` + brightness 교차 문제.** 유저가 dark 모드에서 밝은 글자색을 골랐는데, 나중에 brightness를 light로 바꾸면 밝은 배경 + 밝은 글자 = 대비율 2:1 이하, 완전히 읽을 수 없어요. `contrastRatio()` 검증이 brightness 전환 시점에도 돌아야 하는데, 이거 놓치기 굉장히 쉬워요.

솔직히 **옵션 C(dark 고정)**이 이런 엣지 케이스를 전부 없애요. K-pop 앱은 야간/콘서트 사용이 주 유즈케이스고, SEA 유저 70%+ 가 이미 다크 모드 사용자예요. 밝은 테마를 원하는 10% 유저를 위해 90% 유저의 접근성 리스크를 감수하는 건 비율이 안 맞아요.

### 준서 (Flutter 개발자)

하은 님 StatusBar 이슈는 진짜 크리티컬합니다. 거기에 더해서 **구현 복잡도** 올릴게요.

현재 `app.dart`의 `MaterialApp.router`는 `theme` + `darkTheme` + `themeMode` 3종 세트로 Flutter 프레임워크에 brightness 결정을 위임해요. 이게 Flutter의 정석이에요.

```dart
// app.dart:66-74 — 현재 구조
theme: FangeulTheme.build(brightness: Brightness.light, choeaeColor: choeaeColor),
darkTheme: FangeulTheme.build(brightness: Brightness.dark, choeaeColor: choeaeColor),
themeMode: themeMode,
```

옵션 B를 넣으면 이 구조가 깨져요. 커스텀 테마가 자체 brightness를 가지면:

1. **`theme`과 `darkTheme`에 같은 ThemeData를 넣어야** 합니다 — 커스텀 모드일 때 `FangeulTheme.build(brightness: overrideBrightness, ...)`를 양쪽에 동일하게. 이러면 `themeMode`가 무의미해져요.

2. **팔레트 선택 시에는 원래대로 시스템 모드를 따라야** 해요 — 팔레트는 dark/light scheme 쌍이 수동 디자인되어 있으니까요. 즉 "커스텀이면 독립, 팔레트면 시스템 추종" 분기가 `app.dart`에 들어갑니다.

3. **슬롯 전환 시 brightness도 함께 전환**돼야 하는데, 슬롯 A(dark)에서 슬롯 B(light)로 바꿀 때 StatusBar 아이콘도 즉시 바뀌어야 합니다. `AnnotatedRegion` 업데이트 타이밍 이슈가 생겨요.

4. **미니 컨버터(버블)**도 영향받아요. 캐시 FlutterEngine이 메인과 별도 Dart isolate인데, brightness override를 `SharedPreferences`로 동기해야 하고, `didChangeAppLifecycleState(resumed)`에서 invalidate하는 기존 패턴에 brightness도 추가해야 합니다.

한 마디로, 옵션 B는 "필드 하나 추가"가 아니라 **앱 전체 테마 배관의 구조 변경**이에요.

옵션 C(dark 고정)면 변경점이 명확합니다:
- `buildColorScheme()`에서 custom일 때 brightness 파라미터 무시, `Brightness.dark` 하드코딩
- StatusBar는 custom일 때 항상 `Brightness.light` (밝은 아이콘)
- 끝이에요

---

## 라운드 3: A조 재반론

### 민재 (PM)

하은 님, 준서 님 포인트 다 유효해요. 특히 StatusBar 문제는 제가 간과했네요.

근데 옵션 C(dark 고정)의 비즈니스 리스크 하나만. 유저가 피커에서 파스텔 핑크(tone 75, chroma 30)를 골랐다고 해 봐요. dark scheme에서 이 색은 primary가 되는데, surface는 짙은 핑크-갈색이 되거든요. "이 색이 아닌데?" 하는 유저가 반드시 나와요. 밝은 seed + dark scheme 조합은 유저 의도와 결과 사이에 갭이 생기는 경우가 있어요.

그래서 제가 **수정 제안**을 하겠습니다.

**옵션 B-lite**: 커스텀 테마는 **기본 dark + 유저가 light로 전환 가능**하되, 다음 가드레일을 건다:

1. brightness 전환 시 `contrastRatio()` 재검증 → AA 미달이면 `textColorOverride`를 자동 리셋 (auto contrast 복귀)
2. StatusBar/NavigationBar 색상은 커스텀 테마의 brightness를 따르되, `AnnotatedRegion`을 `FangeulApp` 레벨이 아니라 실질적 brightness 기반으로 결정
3. 시스템 접근성 "강제 다크" 활성 시 커스텀 brightness override 무시 (시스템 우선)

이렇게 하면 하은 님 우려 세 가지가 전부 커버돼요.

### 소영 (M3 엔지니어)

준서 님이 말한 구현 복잡도 문제, 제가 구체적 설계로 해소해 볼게요.

**핵심 변경: `ChoeaeColorConfig.custom`이 brightness를 내부에서 결정하게 만든다.**

```dart
// 변경 후 choeae_color_config.dart
@freezed
sealed class ChoeaeColorConfig with _$ChoeaeColorConfig {
  const factory ChoeaeColorConfig.palette(String packId) = ChoeaeColorPalette;
  const factory ChoeaeColorConfig.custom({
    required Color seedColor,
    Color? textColorOverride,
    @Default(Brightness.dark) Brightness brightnessOverride,  // 추가
  }) = ChoeaeColorCustom;

  const ChoeaeColorConfig._();

  ColorScheme buildColorScheme(Brightness systemBrightness) {
    return switch (this) {
      ChoeaeColorPalette(:final packId) =>
        PaletteRegistry.get(packId).schemeFor(systemBrightness),  // 시스템 추종
      ChoeaeColorCustom(:final seedColor, :final textColorOverride,
                         :final brightnessOverride) =>
        CustomSchemeBuilder.build(
          seedColor: seedColor,
          brightness: brightnessOverride,  // 시스템 무시, 자체 brightness 사용
          textColorOverride: textColorOverride,
        ),
    };
  }

  /// 이 config가 사용하는 실제 brightness.
  Brightness effectiveBrightness(Brightness systemBrightness) {
    return switch (this) {
      ChoeaeColorPalette() => systemBrightness,
      ChoeaeColorCustom(:final brightnessOverride) => brightnessOverride,
    };
  }
}
```

이제 `app.dart`의 변경:

```dart
// app.dart — 변경 후
final effectiveBrightness = choeaeColor.effectiveBrightness(
  themeMode == ThemeMode.dark ||
  (themeMode == ThemeMode.system && platformBrightness == Brightness.dark)
    ? Brightness.dark : Brightness.light
);

// theme과 darkTheme에 동일한 effectiveBrightness 기반 ThemeData
final themeData = FangeulTheme.build(
  brightness: effectiveBrightness,
  choeaeColor: choeaeColor,
);

// MaterialApp.router
theme: themeData,
darkTheme: themeData,  // 둘 다 같은 값 — themeMode는 형식상 유지
themeMode: ThemeMode.dark,  // 항상 darkTheme 사용 (실제 brightness는 내부 결정)
```

아, 잠깐 — 이렇게 하면 **팔레트 모드에서도 `themeMode` 무시**되는 문제가 생기네요.

수정합니다. 팔레트/커스텀 분기:

```dart
final isCustom = choeaeColor is ChoeaeColorCustom;

if (isCustom) {
  // 커스텀: 자체 brightness로 단일 ThemeData
  final b = (choeaeColor as ChoeaeColorCustom).brightnessOverride;
  final td = FangeulTheme.build(brightness: b, choeaeColor: choeaeColor);
  // theme=td, darkTheme=td, themeMode=ThemeMode.dark
} else {
  // 팔레트: 기존 구조 유지
  // theme=light, darkTheme=dark, themeMode=themeModeNotifier
}
```

이건 `MaterialApp.router`의 빌드 파라미터가 런타임에 바뀌는 거라 정상 동작해요. Flutter는 `themeMode` 변경 시 리빌드하니까요.

### 준서 (Flutter 개발자)

(끼어들며) 소영 님, 그 분기 자체는 동작은 하는데요, `MaterialApp.router`에 조건부로 `theme`/`darkTheme`을 넣는 건... 관리 포인트가 좀 불편하긴 합니다. 근데 솔직히 다른 방법이 있나 하면 — 없어요. Flutter의 `MaterialApp`이 `ThemeMode` enum 3개로만 brightness를 결정하는 구조니까, 앱이 자체 brightness를 가지려면 결국 이 수준의 오버라이드가 필요합니다.

StatusBar 문제는 `effectiveBrightness`를 `AnnotatedRegion`에도 적용하면 해결돼요:

```dart
statusBarIconBrightness: effectiveBrightness == Brightness.dark
    ? Brightness.light : Brightness.dark,
```

미니 컨버터도 같은 `choeaeColorNotifierProvider`를 쓰니까, `effectiveBrightness`만 같이 따라가면 됩니다. SharedPreferences에 `brightnessOverride`를 추가로 persist하면 되고, 기존 `choeae_type`/`choeae_value` 패턴에 `choeae_brightness` 키 하나 추가 수준이에요.

인정합니다 — 옵션 C보다 복잡하지만, "필드 하나 + `app.dart` 분기 + StatusBar 연동 + SharedPreferences 키 1개"면 관리 가능한 수준이에요.

---

## 라운드 4: 중립 참여

### 유리 (UX 디자이너)

다 들었어요. UX 관점에서 정리하겠습니다.

**유저 심리 모델**: "내가 고른 색 = 내 최애색 = 변하면 안 됨." 이건 단순한 기능 요구가 아니라 **정체성 표현**이에요. 우리 앱의 UVP가 "팬 정체성 인프라"인데, 그 인프라의 색이 시스템 설정에 따라 흔들리면 신뢰가 깨져요.

그래서 **모드 독립은 해야 합니다**. 문제는 "어떻게"인데.

**옵션 C(dark 고정)의 UX 한계:**
피커에서 유저가 밝은 파스텔을 골라도 dark scheme 결과만 볼 수 있으면, 피커의 "맛보기"와 실제 적용 결과 사이에 불일치가 생겨요. 특히 tone 70+ 영역을 터치했는데 앱이 어둡게 나오면 — "이 피커가 고장 났나?" 싶은 거예요.

**옵션 B-lite에 대한 UX 제안:**

1. **피커 안에 dark/light 프리뷰 토글**을 넣어요. 2D HCT 피커 상단에 태양/달 아이콘 토글 하나. 유저가 색을 고르면서 "이 색이 dark에서 이렇고, light에서 이렇다"를 즉시 확인할 수 있게.

2. **기본값은 dark** — 첫 진입 시 달 아이콘 활성. K-pop 앱 컨텍스트에서 자연스럽고, 대부분의 유저가 전환할 필요 없음.

3. **전환 시 경고 UX**: brightness 전환할 때 글자색이 AA 미달이면, "글자색을 자동으로 조정할까요?" SnackBar 한 줄. 강제가 아니라 제안.

4. **슬롯에 brightness 저장**: `ThemeSlot`에 brightness 필드 추가. 슬롯 이름 옆에 태양/달 뱃지. 슬롯 전환 = 색 + brightness 한 번에 전환.

**팔레트는 시스템 추종 유지**: 팔레트는 디자이너(우리)가 dark/light 쌍을 수동 튜닝한 거예요. 시스템 모드에 맞춰 보여주는 게 디자인 의도대로입니다. 독립시키면 오히려 "왜 이 팔레트는 모드가 안 바뀌죠?" 혼란이 와요.

---

## 사회자 정리 및 합의

### 합의 1: 커스텀(IAP) 테마는 시스템 brightness와 독립 (옵션 B-lite)

**만장일치.**

- 커스텀 테마는 자체 `brightnessOverride` 필드를 가진다
- 기본값: `Brightness.dark`
- 팔레트 테마는 기존대로 시스템 ThemeMode를 추종한다

| 측면 | 팔레트 (무료/보상형) | 커스텀 (IAP) |
|------|---------------------|-------------|
| brightness 결정 | 시스템 ThemeMode 추종 | 자체 brightnessOverride |
| 기본값 | N/A (시스템 따름) | dark |
| 유저 전환 | 설정 > 테마 모드 | 피커 내 dark/light 토글 |
| 슬롯 저장 | type + packId | type + seed + text + brightness |

### 합의 2: StatusBar/NavigationBar는 effectiveBrightness 기반

**만장일치.**

```
effectiveBrightness = custom ? brightnessOverride : systemBrightness
statusBarIconBrightness = effectiveBrightness.dark → Brightness.light (밝은 아이콘)
systemNavigationBarColor = colorScheme.surfaceContainerLowest (effectiveBrightness 기반)
```

### 합의 3: brightness 전환 시 대비율 가드레일

**만장일치 (하은 제안).**

- brightness 전환 시 `contrastRatio(textColorOverride, newSurface)` 검증
- AA 미달(< 4.5)이면 `textColorOverride`를 `null`로 리셋 (auto contrast 복귀)
- SnackBar로 "글자색이 자동 조정되었습니다" 알림 (유리 제안)

### 합의 4: 시스템 접근성 "강제 다크" 존중

**4:1 (민재 제안, 하은 강력 지지. 준서 "구현 가능하나 Android API 확인 필요" 조건부 동의).**

- `AccessibilityManager.isRequestedForceDarkMode` 또는 동등 API 확인
- 활성 시 커스텀 `brightnessOverride` 무시, `Brightness.dark` 강제
- 해당 API가 Flutter에서 직접 접근 불가할 경우 Phase 7+ 후속 작업

### 합의 5: 설정 화면의 ThemeMode 세그먼트 동작 변경

**만장일치.**

- 커스텀 테마 활성 시: ThemeMode 세그먼트를 비활성(dimmed) 표시
- 하단에 "커스텀 테마가 적용 중입니다. 테마 피커에서 변경하세요." 안내 문구
- 팔레트 전환 시 ThemeMode 세그먼트 재활성

### 합의 6: 팔레트는 모드 독립 적용 안 함

**만장일치.**

- 팔레트 dark/light scheme은 디자이너 수동 튜닝 → 시스템 모드 추종이 디자인 의도
- 모드 독립은 IAP 차별화 포인트로 활용 ("내가 고른 색은 흔들리지 않는다")
- 이 차이를 피커 UI에서 명시: "프리미엄: 시스템 모드와 독립적으로 유지됩니다"

## 기술 구현 체크리스트

### 변경 파일 및 예상 영향

| 파일 | 변경 내용 | 난이도 |
|------|----------|--------|
| `choeae_color_config.dart` | `ChoeaeColorCustom`에 `brightnessOverride` 필드 추가, `effectiveBrightness()` 메서드 | Low |
| `choeae_color_config.freezed.dart` | 재생성 | Auto |
| `choeae_color_provider.dart` | `setBrightnessOverride()` 메서드, SharedPreferences `choeae_brightness` 키 | Low |
| `app.dart` | 커스텀/팔레트 분기 brightness 결정, `AnnotatedRegion` effectiveBrightness 기반 | Medium |
| `theme_picker_sheet.dart` | dark/light 토글 UI, brightness 전환 시 대비율 검증 | Medium |
| `theme_slot.dart` | `brightness` 필드 추가, JSON 직렬화 | Low |
| `theme_slot_provider.dart` | 슬롯 전환 시 brightness 반영 | Low |
| `settings_screen.dart` | 커스텀 활성 시 ThemeMode 세그먼트 비활성 + 안내 | Low |
| `fangeul_theme.dart` | 변경 없음 (brightness는 상위에서 결정) | None |
| `custom_scheme_builder.dart` | 변경 없음 (brightness 파라미터 그대로 수신) | None |

### StatusBar 통합 의사코드

```dart
// app.dart build() 내
final systemBrightness = /* themeMode + platformBrightness 기반 */;
final effectiveBrightness = choeaeColor.effectiveBrightness(systemBrightness);
final effectiveColorScheme = choeaeColor.buildColorScheme(systemBrightness);
// → custom이면 내부에서 brightnessOverride 사용, palette이면 systemBrightness 사용

AnnotatedRegion<SystemUiOverlayStyle>(
  value: SystemUiOverlayStyle(
    statusBarIconBrightness: effectiveBrightness == Brightness.dark
        ? Brightness.light : Brightness.dark,
    systemNavigationBarColor: effectiveColorScheme.surfaceContainerLowest,
    systemNavigationBarIconBrightness: effectiveBrightness == Brightness.dark
        ? Brightness.light : Brightness.dark,
  ),
  // ...
)
```

### 대비율 가드레일 의사코드

```dart
// theme_picker_sheet.dart — brightness 토글 시
void _onBrightnessToggle(Brightness newBrightness) {
  final testScheme = CustomSchemeBuilder.build(
    seedColor: currentSeed,
    brightness: newBrightness,
    textColorOverride: currentTextOverride,
  );
  if (currentTextOverride != null) {
    final ratio = contrastRatio(currentTextOverride, testScheme.surface);
    if (ratio < 4.5) {
      // AA 미달 → textColorOverride 리셋
      currentTextOverride = null;
      _showContrastResetSnackBar();
    }
  }
  ref.read(choeaeColorNotifierProvider.notifier).setBrightnessOverride(newBrightness);
}
```

## 측정 지표

| 이벤트 | 의미 |
|--------|------|
| `theme_brightness_toggle` | dark↔light 전환 횟수 |
| `theme_brightness_distribution` | 유저별 최종 brightness 분포 |
| `theme_contrast_auto_reset` | 대비율 자동 리셋 발생 횟수 (가드레일 트리거) |
| `theme_custom_mode_active` | 커스텀 테마 활성 유저 비율 (독립 모드 체감) |

## 참조

- 이전 합의: `docs/discussions/2026-03-08-theme-iap-structure-panel.md`
- HCT 엔진: `lib/presentation/theme/custom_scheme_builder.dart`
- 현재 brightness 체인: `lib/app.dart` L45-58
- WCAG 대비율: `lib/presentation/providers/theme_providers.dart` `contrastRatio()`
