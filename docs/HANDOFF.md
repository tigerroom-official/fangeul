# Fangeul — Session Handoff

BASE_COMMIT: 1cbf9b6 (이전 핸드오프)
HANDOFF_COMMIT: 389beee
BRANCH: main

---

## 프로젝트 상태 (누적)

### 완료된 마일스톤
- Phase 1~4: Core 엔진 + 데이터 레이어 + UI 완료
- Phase 5: 플로팅 버블 전체 구현 + 리뷰 수정 + MEDIUM/UX 수정
- Sprint 1 MVP UX: 간편모드 높이 43% + 팩 자동 복원 + 복사 confetti/진동 + OEM 배터리 대응
- Sprint 2: 상황태그 + K-pop 캘린더(69이벤트) + 분석 계측(NoOp) (2026-03-02)
- MVP 통합: 마이아이돌 + 템플릿 문구 + 온보딩 + 크로스엔진 연동 (2026-03-03)
- PhrasesScreen 마이아이돌 개인화 + MyIdolNotifier race condition 수정 (2026-03-03)
- Phase B: 멤버 레벨 개인화 완료 + Codex 리뷰 수정 (2026-03-04)
- Phase 6 수익화 설계+구현: 18 tasks + 2라운드 Claude×Codex 교차 리뷰 (2026-03-04)
- 멀티모드 키보드 + 패널 개선 + 버블 버그 수정 (2026-03-04)
- i18n 인프라 (7개 언어) + Firebase Remote Config 통합 (2026-03-05)
- Firebase Crashlytics/Analytics 통합 + 버블 UX 대폭 개선 (2026-03-05)
- 로케일 자동 감지 + 문구 번역 표시 + edge-to-edge 내비바 수정 (2026-03-05)
- 설정 화면: 언어 변경 + 리뷰/문의 메뉴 + overflow 수정 + 스플래시 깜빡임 수정 + AGP 업그레이드 (2026-03-06)
- 로케일별 번역 표시 수정 + 컨버터 힌트 탭별 전환 + 스마트 기본 필터 + v1.0.0 (2026-03-06)
- AdMob 광고 배치 + 팬 컬러 테마 커스터마이징 13 tasks (2026-03-07)
- **최애색(Choeae Color) UX 오버홀 — 15 tasks + 5 review fixes (2026-03-07)**
  - `FangeulColors` 삭제, 모든 위젯 → `colorScheme` 토큰 사용
  - `CustomSchemeBuilder` HSL→HCT 엔진 교체 + `PaletteRegistry` 10개 수동 팔레트
  - `ChoeaeColorConfig` sealed class: `.palette(packId)` | `.custom(seedColor, textColorOverride?)`
  - 4 UX 이슈: 즐겨찾기 SnackBar, Undo 인라인, 자동 스크롤, 색상 체감 강화
- **HSL→HCT 엔진 교체 (P0 완료) (2026-03-07)**
  - `_SchemeVividTint extends DynamicScheme` — neutral chroma 24 (M3 기본 6의 4배)
  - Hue-only 슬라이더 간소화 (Sat/Light 슬라이더 ~130줄 삭제)
  - 4-domain Codex 병렬 리뷰 + 5개 수정 (누락 슬롯, stale assertion, edge case)
  - 741 tests pass, flutter analyze clean

### 활성 작업
없음. P0 완료, main 머지됨.

### 보류/백로그 — MVP 출시 후
- **v1.1 기능**: 한글 퍼즐(Wordle 스타일), 한글 카드 컬렉션(가챠)
- **v1.1+ 기능**: 푸시 알림(firebase_messaging), 구독 모델
- LOW 이슈 잔여: L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- 리뷰 연기 이슈: I1(IdolSelectScreen setState→Riverpod), I6(즐겨찾기 템플릿 메타데이터)
- todaySuggestedPhrases에 memberName 미전달 (멤버 템플릿 "오늘" 추천 미포함)
- share_card_painter.dart + Provider 내 UiStrings 잔류 (BuildContext 없음)
- P1: 핸들 좌측 멤버 이름 노출 (버블 UX)
- Play Integrity API (서버사이드 검증)
- AdMob SSV (Server-Side Verification)
- converter_screen 배너 = 리텐션 데이터로 결정 (v1.1)
- 즐겨찾기 포화/TTS 한도 FanPassButton 트리거 (v1.1)
- 비영어/비한국어 arb에 테마 피커 l10n 키 번역 추가

---

## 작업 요약

최애색 UX 오버홀 P0 완료: HSL→HCT 엔진 교체(`_SchemeVividTint` neutral chroma 24), hue-only 슬라이더 간소화(Sat/Light 제거), 4-domain Codex 병렬 리뷰. P1(자유 글자색 피커, 팔레트 20-25개 확장)은 미구현 — 논의 범위 대비 구현은 P0 엔진 레벨에 한정.

## 완료된 작업

- [x] 최애색 UX 오버홀 15 tasks + 5 review fixes (이전 세션 전반부)
- [x] HSL→HCT `CustomSchemeBuilder` 리라이트 — `_SchemeVividTint extends DynamicScheme` (4cb5d43)
- [x] Hue-only 슬라이더 간소화 — `_SaturationSlider`, `_LightnessSlider` 삭제 (4cb5d43)
- [x] `fangeul_theme_test.dart` HCT 기반 assertion 갱신 (4cb5d43)
- [x] `custom_scheme_builder_test.dart` 전체 리라이트 — 36 tests (HCT hue fidelity, chroma, WCAG) (4cb5d43)
- [x] Codex 4-domain 병렬 리뷰 → Major 4건 수정 (누락 14 ColorScheme 슬롯, textColorOverride 3개 추가, stale HSL assertion, pubspec `any`) (4cb5d43)
- [x] white/black seed edge case 테스트 추가 (4cb5d43)
- [x] `pubspec.yaml` — `material_color_utilities: any` 추가 (4cb5d43)

## 진행 중인 작업
없음.

## 핵심 교훈

- ★ DynamicScheme 서브클래스에서 `sourceColorHct`를 `super.sourceColorHct`로 변환 불가 — initializer에서 참조하므로 명시적 파라미터 필수 (`use_super_parameters` lint 무시)
- ★ `Color(s.primary)` 패턴으로 DynamicScheme getter→Color 변환 — `MaterialDynamicColors.primary.getArgb(scheme)` 대신 간결
- ★ HCT 엔진 교체는 내부 품질 개선 (지각균일, hue 보존) — 시각적 드라마틱 변화는 P1(자유 피커, 팔레트 확장)에서 발생
- ★ `Variant.vibrant` 선택: `isFidelity`/`isMonochrome` 분기와 무관하여 커스텀 팔레트 오버라이드 안전
- ★ pubspec에 Flutter SDK 전이 의존성은 `any` 사용 — 버전 고정 시 SDK 업그레이드에서 충돌
- ★ 4-domain 병렬 Codex 리뷰: 누락된 14개 ColorScheme 슬롯(surfaceDim, shadow, scrim 등) 독립 발견 — 단일 리뷰로는 놓칠 수 있는 완성도 이슈

## 다음 단계

### 1순위: 최애색 P1 — 시각적 체감 개선 (논의 문서의 미구현 부분)
1. **자유 글자색 피커 + 자동 추천** — 배경 HCT 기반 WCAG 4.5:1 필터 3-5색 자동 제안, "+" 버튼 → hue wheel + tone slider
2. **PaletteRegistry 20-25개 확장** — 웜톤/쿨톤 균형, K-pop 감성 네이밍 (라벤더 무드, 선셋 바이브, 민트 서머 등)
3. **프리뷰 UI** — 실제 화면 미리보기 (키보드 레이아웃 등)
4. 참조: `docs/discussions/2026-03-07-picker-ux-redesign.md`, `docs/discussions/2026-03-07-theme-ux-supplementary.md`

### 2순위: Phase 7 릴리즈 BLOCK 항목 (출시 필수)
1. **릴리즈 서명 설정** — keystore 생성 + `android/app/build.gradle` signingConfigs.release 구성
2. **프로덕션 AdMob ID** — `lib/services/ad_ids.dart`의 placeholder(`ca-app-pub-XXXX`) 교체
3. **ProGuard/R8 활성화** — `minifyEnabled true` + `shrinkResources true` + `proguard-rules.pro`
4. **Google Play Console** — 앱 등록 + IAP 상품 가격 설정 + 스크린샷/리스팅

### 3순위: 출시 후 빠른 개선
- 비영어 arb에 테마 피커 l10n 키 번역 (es/id/pt/th/vi)
- P1: 핸들 좌측 멤버 이름 노출
- share_card_painter.dart UiStrings → l10n
- Firebase Analytics 이벤트 대시보드 구성
- 테마 피커에 보상형 광고 팔레트 해금 연동 (FanPassButton)

### 4순위: v1.1 로드맵
- 한글 퍼즐 (Wordle 스타일)
- 한글 카드 컬렉션 (가챠)
- 푸시 알림 (firebase_messaging)
- 구독 모델 (Phase 7+)

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| `_SchemeVividTint` neutral chroma 24 | M3 기본 6의 4배 — surface에 seed hue를 강하게 반영하여 색 체감 |
| `Variant.vibrant` 베이스 | `isFidelity`/`isMonochrome` 분기와 무관, 커스텀 팔레트 오버라이드 안전 |
| `material_color_utilities: any` | Flutter SDK 전이 의존성 — 버전 고정 시 SDK 업그레이드 충돌 |
| Hue-only 슬라이더 (Sat/Light 제거) | HSL 극단값으로 검정/흰색/회색 생성 문제 제거 + 진입장벽 낮춤 |
| P0/P1 분리 실행 | 엔진 교체(P0)를 먼저 안정화 후 시각적 UX(P1) 진행 |

## 참고 컨텍스트

- 전문가 패널 토론 (HSL→HCT 결정): `docs/discussions/2026-03-07-picker-ux-redesign.md`
- 최애색 시스템 근본 재설계: `docs/discussions/2026-03-07-theme-ux-supplementary.md`
- 표면 틴팅 + IAP 차별화: `docs/discussions/2026-03-07-theme-ux-differentiation.md`
- 구현 계획서: `docs/plans/2026-03-07-choeae-color-ux-overhaul.md`

## 커밋 히스토리 (이번 세션)

```
4cb5d43 feat: replace HSL theme engine with HCT (material_color_utilities)
6f1fccb fix: app_test nav bar assertion matches real wiring (surfaceContainerLowest)
4b638ba fix: Color.fromARGB float misuse + preview restore undo pollution
75b17a9 fix: ref.watch in build() + surfaceContainerLowest for nav bar (Claude review)
d5ddd28 fix: validate palette ID in selectPalette (Codex review)
5421b18 chore: fix unused import warnings in test files
3bcc193 refactor: remove legacy theme code (ThemeColorNotifier, ThemePalettes, FangeulColors)
2c67bd3 feat: add choeae color palette l10n keys for 7 languages
72d67f8 refactor: replace keyboard_key hardcoded colors with theme tokens
c7cd2fb refactor: migrate theme_picker_sheet to ChoeaeColorNotifier + PaletteRegistry
198bbd3 refactor: migrate settings_screen to ChoeaeColorNotifier
7190408 refactor: migrate app.dart to FangeulTheme.build() + ChoeaeColorNotifier
0a07e5d fix: Codex review — auto-contrast on* colors, threshold, scroll guard
ee50461 feat: add ChoeaeColorNotifier — palette/custom state management with undo
84bd248 refactor: FangeulTheme.build() single entry point
841922d feat: add ChoeaeColorConfig freezed sealed class
a6cdaf8 feat: add PalettePack + PaletteRegistry — 10 manual ColorScheme palettes
0da472c feat: add CustomSchemeBuilder — fromSeed() bypass for choeae color
3fb40fa feat: auto-scroll to custom picker on expand
6a0c555 fix: inline undo icon in title row — zero layout shift
623163f fix: show snackbar when favorite slot limit reached
d5865b1 feat: theme UX overhaul — component themes, permanent unlock, preview, undo
a6e3664 feat: add debug monetization panel in settings (kDebugMode only)
e3abc80 fix: Codex review fixes + l10n translations + FanPass palette wiring
89ef7a0 docs: update HANDOFF.md — AdMob wiring + fan color theme customization complete
```

## 수정한 파일

```
docs/HANDOFF.md
docs/discussions/2026-03-07-theme-ux-differentiation.md (NEW)
lib/app.dart
lib/core/entities/monetization_state.dart
lib/core/entities/monetization_state.freezed.dart
lib/core/entities/monetization_state.g.dart
lib/l10n/app_en.arb, app_es.arb, app_id.arb, app_ko.arb, app_pt.arb, app_th.arb, app_vi.arb
lib/l10n/app_localizations*.dart (7개 언어)
lib/main.dart
lib/presentation/providers/choeae_color_provider.dart (NEW)
lib/presentation/providers/choeae_color_provider.g.dart (NEW)
lib/presentation/providers/monetization_provider.dart
lib/presentation/providers/theme_providers.dart
lib/presentation/screens/home_screen.dart
lib/presentation/screens/mini_converter_screen.dart
lib/presentation/screens/settings_screen.dart
lib/presentation/theme/choeae_color_config.dart (NEW)
lib/presentation/theme/choeae_color_config.freezed.dart (NEW)
lib/presentation/theme/custom_scheme_builder.dart (NEW — HCT engine)
lib/presentation/theme/fangeul_colors.dart (DELETED)
lib/presentation/theme/fangeul_theme.dart (simplified)
lib/presentation/theme/palette_pack.dart (NEW)
lib/presentation/theme/palette_registry.dart (NEW)
lib/presentation/theme/theme_palettes.dart (DELETED)
lib/presentation/widgets/banner_ad_widget.dart
lib/presentation/widgets/compact_phrase_list.dart
lib/presentation/widgets/compact_phrase_tile.dart
lib/presentation/widgets/keyboard_key.dart
lib/presentation/widgets/korean_keyboard.dart
lib/presentation/widgets/multi_mode_keyboard.dart
lib/presentation/widgets/phrase_card.dart
lib/presentation/widgets/share_card_painter.dart
lib/presentation/widgets/theme_picker_sheet.dart
pubspec.lock, pubspec.yaml
test/app_test.dart (NEW)
test/core/entities/monetization_state_test.dart
test/presentation/providers/choeae_color_provider_test.dart (NEW)
test/presentation/providers/monetization_provider_test.dart
test/presentation/providers/theme_providers_test.dart
test/presentation/theme/choeae_color_config_test.dart (NEW)
test/presentation/theme/custom_scheme_builder_test.dart (NEW)
test/presentation/theme/fangeul_theme_dynamic_test.dart (DELETED)
test/presentation/theme/fangeul_theme_test.dart (NEW)
test/presentation/theme/palette_registry_test.dart (NEW)
```

## 세션 히스토리

| 세션 | 요약 |
|------|------|
| P1~P3 | Core 엔진 + 데이터 레이어 완료 |
| P4 | UI 화면 구현 (홈, 변환기, 문구, 설정) |
| P5-구현 | Phase 5 플로팅 버블 16 tasks 구현 |
| P5-리뷰 | C1~C3/H1~H4 리뷰 수정 → 215 tests |
| P5.1-MEDIUM | M1/M3/M4/M5 수정 |
| P5.2-UX | 팩 문구 탐색 + AsyncNotifier 전환 + 버블/키보드 UX 수정 → 247 tests |
| Sprint 1 | MVP UX 기반 다듬기 → 252 tests |
| Sprint 2 | 상황태그 + K-pop 캘린더 + 분석 계측 → 280 tests |
| MVP 통합 | 마이아이돌 + 템플릿 문구 + 온보딩 + 교차리뷰 → 314 tests |
| PhrasesScreen 아이돌 | MyIdolNotifier race fix + 아이돌 칩 + 태그 뷰 버그 수정 → 337 tests |
| Phase B 멤버 | 멤버 개인화 7 tasks + Codex 리뷰 Critical 수정 → 383 tests |
| Phase 6 설계 | 전문가 패널 5토픽 토론 + Claude×Codex 교차 리뷰 → 수익화 합의 문서 |
| Phase 6 구현 | 18 tasks + 2라운드 교차 리뷰 19건 수정 → 573 tests |
| 키보드+패널+버블 | 멀티모드 키보드 + 패널 UX 개선 + 버블 버그 4건 수정 → 616 tests |
| i18n+Firebase RC | 7개 언어 i18n + Firebase Remote Config + 3인 번역 QA → 627 tests |
| Crashlytics+버블UX | Firebase Crashlytics/Analytics + 버블 헤더 UX 통일 → 627 tests |
| 로케일+번역+내비바 | 시스템 로케일 자동 감지 + 문구 번역 표시 + edge-to-edge 내비바 수정 → 627 tests |
| 설정+UX수정 | 언어 변경/리뷰/문의 메뉴 + overflow 수정 + 스플래시 깜빡임 수정 + AGP 업그레이드 → 627 tests |
| 번역+필터+실기기 | 로케일별 번역 수정 + 스마트 필터 + 간편모드 번역 + 실기기 테스트 → 624 tests |
| AdMob+테마 | AdMob 배치 + 팬 컬러 테마 커스터마이징 13 tasks → 641 tests |
| **최애색+HCT** | 최애색 UX 오버홀 15 tasks + HSL→HCT P0 엔진 교체 + Codex 4-domain 리뷰 → 741 tests |
