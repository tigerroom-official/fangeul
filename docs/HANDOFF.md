# Fangeul — Session Handoff

BASE_COMMIT: 389beee (이전 핸드오프)
HANDOFF_COMMIT: 6b6e33b
BRANCH: fix/custom-theme-seed-anchored

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
- 최애색(Choeae Color) UX 오버홀 — 15 tasks + 5 review fixes (2026-03-07)
- HSL→HCT 엔진 교체 P0 완료 (2026-03-07)
- **테마 커스터마이징 전면 업그레이드 (2026-03-08)**
  - 2D HCT 사각형 피커 (hue 바 + chroma×tone 2D 영역)
  - 테마 슬롯 시스템 (4슬롯: 1 기본 + 3 IAP)
  - 3-SKU IAP 구조 (custom_color ₩990 + slots ₩990 + bundle ₩1,500)
  - TextColorPickerDialog: hex 입력 + WCAG 3단계 + chroma 슬라이더
  - brightnessOverride: 커스텀 테마 밝기 토글 (시스템 모드 독립)
  - Surface tone parallel shift + chroma 85% preservation
  - Codex 전체 브랜치 리뷰 + P0/P1/P2 수정
  - 804 tests pass

### 활성 작업
없음. 브랜치 `fix/custom-theme-seed-anchored`에 전체 작업 완료, main 머지 대기.

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
- IAP 구매 UI subtitle 추가 (패널 합의 P0 — 미구현)
- IAP 번들 "추천" 라벨 추가 (패널 합의 P0 — 미구현)
- IAP "테마 슬롯 3개" → "최애 테마 3개 저장" 문구 리프레이밍 (P2)

---

## 작업 요약

테마 커스터마이징 전면 업그레이드: 2D HCT 피커, 테마 슬롯(4개), 3-SKU IAP, TextColorPickerDialog(hex+WCAG+chroma), brightnessOverride(시스템 모드 독립), surface chroma 85% preservation + hex 입력 키보드 크래시 수정 + 팔레트 그리드 간격 축소 + 슬롯 ⋮ 힌트 아이콘. Codex 전체 브랜치 리뷰 완료.

## 완료된 작업

- [x] 2D HCT 사각형 피커 (`hct_color_picker.dart` 신규) — chroma×tone 2D 영역 + hue 바 (d53f6cd)
- [x] 테마 슬롯 시스템 (`theme_slot.dart`, `theme_slot_provider.dart` 신규) — 4슬롯, SharedPrefs JSON 직렬화 (d53f6cd)
- [x] 3-SKU IAP (`iap_products.dart`) — themeCustomColor/themeSlots/themeBundle SKU (d53f6cd)
- [x] MonetizationState `hasThemeSlots` 필드 + provider (d53f6cd)
- [x] `theme_picker_sheet.dart` 대규모 리팩터 — 슬롯 UI, IAP 섹션, 2D 피커 통합 (d53f6cd)
- [x] TextColorPickerDialog — hex 입력 + WCAG 3단계 표시 + chroma 슬라이더 (8566e07)
- [x] brightnessOverride — `ChoeaeColorConfig.custom(brightnessOverride:)` 필드 + 시스템 ThemeMode 분리 (b3bbaec, 7e70bb7)
- [x] Brightness 토글 UI + ThemeMode 비활성화 로직 (1059356)
- [x] Surface tone parallel shift — 밝기 토글 시 tone 범위 전환 (c6049b6)
- [x] Codex 전체 브랜치 리뷰 → P0 3건/P1 3건/P2 1건 수정 (d96a89b)
- [x] Surface chroma 85% preservation — `seedChroma * 0.85` (기존 0.4 capped 28) (fa91675)
- [x] Hex 입력 키보드 크래시 수정 — `TextInputType.visiblePassword` (fa91675)
- [x] 슬롯 rename 다이얼로그 크래시 수정 — `addPostFrameCallback` 타이밍 (fa91675)
- [x] 팔레트 그리드 간격 축소 — `aspectRatio 1.0`, `mainAxisSpacing 2` (fa91675)
- [x] 슬롯 ⋮ 아이콘 힌트 — 롱프레스 발견성 향상 (fa91675)
- [x] l10n 키 추가 — 7개 언어 (테마 슬롯, 밝기 토글, IAP, WCAG 등)
- [x] 테스트 804개 전체 통과 + flutter analyze clean

## 진행 중인 작업
없음.

## 핵심 교훈

- ★ `seedChroma * 0.4` capped at 28은 고채도 seed(금색 chroma~82)를 무채색화 → `seedChroma * 0.85` (min 8.0)로 "내가 고른 색 = 앱 색" 실현
- ★ Uniform chroma (tone-only hierarchy): surface 컨테이너 간 chroma 차이 제거 → 카드 경계는 outlineVariant로 구분
- ★ Flutter `KeyDownEvent` assertion crash: IME composition 모드에서 중복 키 이벤트 → `TextInputType.visiblePassword`로 IME 비활성화
- ★ Bottom sheet pop → dialog show 타이밍 충돌: `WidgetsBinding.instance.addPostFrameCallback`으로 한 프레임 지연
- ★ `double.clamp(lower, upper)` — lower > upper 시 `Invalid argument(s)` → 조건분기 `raw < 8.0 ? 8.0 : raw` 사용
- ★ brightnessOverride 라우팅: 커스텀 테마는 seed tone에서 밝기 자동 유도, `themeMode: ThemeMode.light/dark` 강제 + 동일 테마를 light/dark 양 슬롯에 할당

## 다음 단계

### 1순위: 브랜치 머지 + IAP UI 마무리
1. **`fix/custom-theme-seed-anchored` → main 머지** — 804 tests pass, review 완료
2. **IAP subtitle 추가** — 각 구매 버튼에 기능 설명 한 줄 (패널 합의 P0 미구현)
3. **번들 "추천" 라벨** — `themePickerRecommended` l10n 키 활용

### 2순위: Phase 7 릴리즈 BLOCK 항목 (출시 필수)
1. **릴리즈 서명 설정** — keystore 생성 + signingConfigs.release
2. **프로덕션 AdMob ID** — placeholder 교체
3. **ProGuard/R8 활성화** — minifyEnabled + shrinkResources
4. **Google Play Console** — 앱 등록 + IAP 상품 가격 설정

### 3순위: 출시 후 빠른 개선
- PaletteRegistry 20-25개 확장 (웜톤/쿨톤 균형)
- 프리뷰 UI — 실제 화면 미리보기
- IAP "테마 슬롯 3개" → "최애 테마 3개 저장" 리프레이밍 (P2)
- P1: 핸들 좌측 멤버 이름 노출
- share_card_painter.dart UiStrings → l10n
- Firebase Analytics 이벤트 대시보드 구성

### 4순위: v1.1 로드맵
- 한글 퍼즐 (Wordle 스타일)
- 한글 카드 컬렉션 (가챠)
- 푸시 알림 (firebase_messaging)
- 구독 모델 (Phase 7+)

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| Surface chroma 85% (기존 40%) | 고채도 seed에서 "내가 고른 색 = 앱 색" 체감 불가 → 85%로 상향 |
| Uniform chroma (tone-only) | 컨테이너 간 chroma 차이는 시각적 혼란 → tone만으로 계층 분리 |
| `visiblePassword` 키보드 타입 | IME composition이 Flutter KeyEvent 시스템과 충돌 → composition 비활성화 |
| brightnessOverride 독립 라우팅 | 커스텀 seed tone에서 자동 유도된 밝기를 유저가 반전 가능 (시스템 모드와 독립) |
| 3-SKU IAP 분리 | 피커+슬롯 독립 구매 + 번들 24% 할인 → ARPU 극대화 |
| 슬롯 ⋮ 아이콘만 (텍스트 힌트 없음) | 10대~20대 타겟은 구구절절한 설명보다 직관적 아이콘 선호 |

## 참고 컨텍스트

- 테마 커스터마이징 오버홀 계획: `docs/plans/2026-03-07-choeae-color-ux-overhaul.md`
- Surface 계층 + 슬롯 패널 합의: `docs/discussions/2026-03-08-theme-surface-hierarchy-slots.md`
- IAP 3-SKU 구조 패널: `docs/discussions/2026-03-08-theme-iap-structure-panel.md`
- 밝기 독립 패널: `docs/discussions/2026-03-08-theme-brightness-independence-panel.md`
- 글자색 hex+WCAG 패널: `docs/discussions/2026-03-08-text-color-hex-2d-picker-wcag-panel.md`
- HCT 피커 UX 재설계: `docs/discussions/2026-03-07-picker-ux-redesign.md`
- 최애색 시스템 근본 재설계: `docs/discussions/2026-03-07-theme-ux-supplementary.md`

## 커밋 히스토리 (이번 세션)

```
fa91675 fix: chroma 85% preservation + hex input keyboard crash + palette spacing + slot hints
d96a89b fix: cross-review P0/P1/P2 — dartdoc, contrast guard, write serialization
1059356 feat: brightness toggle in picker + disable ThemeMode when override active
8566e07 feat: TextColorPickerDialog hex input + WCAG 3-level + chroma slider
7e70bb7 feat: brightness override routing in FangeulApp
b3bbaec feat: brightnessOverride — custom theme mode independence
c6049b6 feat: surface tone parallel shift + narrow textColorOverride scope
bbdef5d fix: add theme slots debug toggle + reduce palette grid spacing
d53f6cd feat: theme customization overhaul — 2D HCT picker, slots, 3-SKU IAP
b048ed7 chore: session handoff — HSL→HCT P0 완료, P1 미구현 정리
```

## 수정한 파일

```
 56 files changed, 4162 insertions(+), 617 deletions(-)

주요 신규:
 lib/presentation/widgets/hct_color_picker.dart (NEW — 2D HCT 피커)
 lib/presentation/widgets/text_color_picker_dialog.dart (NEW — hex+WCAG 글자색 피커)
 lib/presentation/models/theme_slot.dart (NEW — 슬롯 모델)
 lib/presentation/providers/theme_slot_provider.dart (NEW — 슬롯 상태관리)
 test/presentation/models/theme_slot_test.dart (NEW — 278줄)
 test/presentation/providers/theme_slot_provider_test.dart (NEW — 189줄)
 test/presentation/widgets/text_color_picker_test.dart (NEW — 117줄)
 test/presentation/widgets/iap_purchase_section_test.dart (NEW — 54줄)

주요 수정:
 lib/presentation/widgets/theme_picker_sheet.dart (1074줄 대규모 리팩터)
 lib/presentation/theme/custom_scheme_builder.dart (chroma 85% + tone shift)
 lib/presentation/theme/choeae_color_config.dart (brightnessOverride 필드)
 lib/presentation/providers/choeae_color_provider.dart (brightness 라우팅)
 lib/app.dart (ThemeMode 분기)
 lib/services/iap_products.dart (3-SKU)
 lib/l10n/app_*.arb (7개 언어 × 18+ 키)
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
| 최애색+HCT | 최애색 UX 오버홀 15 tasks + HSL→HCT P0 엔진 교체 + Codex 4-domain 리뷰 → 741 tests |
| **테마 오버홀** | 2D HCT 피커 + 슬롯 + 3-SKU IAP + brightnessOverride + chroma 85% + hex 크래시 수정 → 804 tests |
