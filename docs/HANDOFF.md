# Fangeul — Session Handoff

BASE_COMMIT: b056869 (이전 핸드오프)
HANDOFF_COMMIT: 1cbf9b6
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
- **AdMob 광고 배치 + 팬 컬러 테마 커스터마이징 13 tasks (2026-03-07)**

### 활성 작업
없음. 이번 세션 작업 모두 완료, main 커밋됨.

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

AdMob 광고 UI 배치(배너+보상형 프리로드) + 팬 컬러 테마 커스터마이징(추천 팔레트 8개 + HSL 자유 피커 + 글자색 커스터마이징) 전체 구현. 13 tasks 완료. 문구팩 무료 전환(birthday/comeback), 배너 Day 7+ 조건, 동적 테마(ColorScheme.fromSeed), 테마 피커 바텀시트, 설정 진입점, 수익화 연동(hasThemePicker), 버블 테마 동기화. 641 tests pass, 0 failures.

## 완료된 작업

- [x] Task 1: birthday_pack/comeback_pack → is_free: true (b2205e5)
- [x] Task 2: pack_filter_chips 잠금 표시 제거 (b2205e5)
- [x] Task 3: AdService.initialize() main.dart fire-and-forget (b2205e5)
- [x] Task 4: home_screen preloadRewarded (b2205e5)
- [x] Task 5: phrases_screen 하단 BannerAdWidget + Day 7+ 조건 (b2205e5)
- [x] Task 6: ThemePalettes 8개 정의 (21cdf7e)
- [x] Task 7: ThemeColorNotifier + customTextColor (21cdf7e)
- [x] Task 8: FangeulTheme.dynamicDark/dynamicLight (21cdf7e)
- [x] Task 9: app.dart 동적 테마 연결 + 내비바 색상 (21cdf7e)
- [x] Task 10: ThemePickerSheet 바텀시트 (1cbf9b6)
- [x] Task 11: 설정 화면 테마 색상 진입점 (1cbf9b6)
- [x] Task 12: MonetizationState.hasThemePicker + unlockThemePicker (1cbf9b6)
- [x] Task 13: 버블 테마 동기화 (themeColorNotifierProvider invalidate) (1cbf9b6)

## 진행 중인 작업
없음.

## 핵심 교훈

- ★ BannerAdWidget Day 7+ 조건: `isHoneymoon` (Day 14) 대신 `installDate` 기반 `daysSince < 7` 직접 계산 — 기능 허니문(14일)과 광고 허니문(7일) 분리 (2026-03-07)
- ★ `Color.value` deprecated in Flutter 3.41.2 → `color.toARGB32().toRadixString(16)` 사용 (2026-03-07)
- ★ `ColorScheme.fromSeed()` 전체 교체 방식: 배경/surface/on* 모두 자동 생성. 하이브리드(배경 고정+액센트만)보다 사용자 기대에 부합 (2026-03-07)
- ★ 자유 피커 IAP 차별화: customTextColor(onSurface/onPrimary override) — 무료 팔레트는 자동 대비만, IAP 구매자만 글자색 커스터마이징 가능 (2026-03-07)
- ★ 스마트 기본 필터 테스트: favorites 기본값이 아닌 first pack 기본값으로 변경되었는데 테스트 미업데이트 → 3건 stale test 수정 (2026-03-07)

## 다음 단계

### 1순위: Phase 7 릴리즈 BLOCK 항목 (출시 필수)
1. **릴리즈 서명 설정** — keystore 생성 + `android/app/build.gradle` signingConfigs.release 구성
2. **프로덕션 AdMob ID** — `lib/services/ad_ids.dart`의 placeholder(`ca-app-pub-XXXX`) 교체
3. **ProGuard/R8 활성화** — `minifyEnabled true` + `shrinkResources true` + `proguard-rules.pro`
4. **Google Play Console** — 앱 등록 + IAP 상품(피커 W990 / 번들 W1,900) 가격 설정 + 스크린샷/리스팅

### 2순위: 출시 후 빠른 개선
- 비영어 arb에 테마 피커 l10n 키 번역 (es/id/pt/th/vi)
- P1: 핸들 좌측 멤버 이름 노출
- share_card_painter.dart UiStrings → l10n
- Firebase Analytics 이벤트 대시보드 구성
- 테마 피커에 보상형 광고 팔레트 해금 연동 (FanPassButton)

### 3순위: v1.1 로드맵
- 한글 퍼즐 (Wordle 스타일)
- 한글 카드 컬렉션 (가챠)
- 푸시 알림 (firebase_messaging)
- 구독 모델 (Phase 7+)

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| 문구팩 전부 무료 전환 | 텍스트 문구의 perceived value 낮음 — 테마 커스터마이징이 새 IAP 엣지 |
| 배너 Day 7+ (Day 21에서 앞당김) | AdMob 학습 기간 확보 + 보상형 세션 숨김으로 UX 보호 |
| 자유 피커 > 사전 정의 팩 | 법적 리스크 구조적 제거 (팬 컬러 IP 문제 없음) + IKEA 효과 |
| 전체 fromSeed (하이브리드 아님) | 사용자가 배경색 변경을 기대함 — 액센트만 바꾸면 반쪽짜리 |
| IAP 글자색 커스터마이징 | 무료 = 자동대비만, IAP = 글자색도 선택 → 프리미엄 차별화 |

## 참고 컨텍스트

- 수익화 최종 합의: `docs/discussions/2026-03-06-admob-placement-and-theme-monetization.md`
- 구현 계획: `docs/plans/2026-03-06-admob-and-theme-customization.md`
- UX 패널 토의: `docs/discussions/2026-03-05-ux-detail-panel.md`

## 미구현 기능 현황

| 기능 | 상태 | MVP 필수 | 비고 |
|------|------|----------|------|
| AdMob 배너 + 보상형 프리로드 | ✅ 구현 | YES | Day 7+ 조건, phrases_screen |
| 팬 컬러 테마 커스터마이징 | ✅ 구현 | YES | 8팔레트 + HSL피커 + 글자색 |
| 테마 피커 UI | ✅ 구현 | YES | 바텀시트, 설정 진입점 |
| MonetizationState.hasThemePicker | ✅ 구현 | YES | IAP 연동 준비 |
| 릴리즈 서명 | ❌ 미구현 | YES | keystore 생성 필요 |
| ProGuard/R8 | ❌ 미구현 | YES | 난독화 + 코드 축소 |
| 프로덕션 AdMob ID | ❌ placeholder | YES | AdMob 콘솔에서 생성 |
| Play Store 등록 | ❌ 미구현 | YES | 리스팅 + 스크린샷 |
| IAP 상품 등록 | ❌ 미구현 | YES | 피커 W990 / 번들 W1,900 |
| 비영어 l10n 테마 키 | ❌ fallback EN | NO | 출시 후 번역 |
| 푸시 알림 | ❌ 미구현 | NO | v1.1 |
| 한글 퍼즐 | ❌ 미구현 | NO | v1.1 |
| 카드 컬렉션 | ❌ 미구현 | NO | v1.1 |
| 구독 모델 | ❌ 미구현 | NO | v1.1+ |

## 커밋 히스토리 (이번 세션)

```
1cbf9b6 feat: theme picker UI + settings entry + monetization integration + bubble sync (Tasks 10-13)
21cdf7e feat: theme color system — palettes, notifier, dynamic theme, app wiring (Tasks 6-9)
b2205e5 feat: AdMob wiring + phrase pack unlock (Tasks 1-5)
```

## 수정한 파일

```
assets/phrases/birthday_pack.json               — is_free: true
assets/phrases/comeback_pack.json               — is_free: true
lib/main.dart                                    — AdService.initialize() fire-and-forget
lib/presentation/screens/home_screen.dart        — preloadRewarded()
lib/presentation/screens/phrases_screen.dart     — BannerAdWidget 하단 배치
lib/presentation/widgets/banner_ad_widget.dart   — Day 7+ 조건 (isHoneymoon 대체)
lib/presentation/widgets/pack_filter_chips.dart  — 잠금 표시 제거
lib/presentation/theme/theme_palettes.dart       — 8개 팔레트 정의 (NEW)
lib/presentation/providers/theme_providers.dart  — ThemeColorNotifier 추가
lib/presentation/theme/fangeul_theme.dart        — dynamicDark/dynamicLight 추가
lib/app.dart                                      — 동적 테마 + 내비바 색상 연결
lib/presentation/widgets/theme_picker_sheet.dart  — 테마 피커 바텀시트 (NEW)
lib/presentation/screens/settings_screen.dart    — 테마 색상 진입점
lib/core/entities/monetization_state.dart        — hasThemePicker 필드
lib/presentation/providers/monetization_provider.dart — unlockThemePicker()
lib/presentation/screens/mini_converter_screen.dart — themeColorNotifier invalidate
lib/l10n/app_ko.arb, app_en.arb                  — 테마 피커 l10n 키
test/presentation/providers/theme_providers_test.dart — ThemeColorNotifier 테스트 6건
test/presentation/theme/fangeul_theme_dynamic_test.dart — 동적 테마 테스트 7건 (NEW)
test/presentation/widgets/banner_ad_widget_test.dart — Day 7+ 조건 테스트 업데이트
test/presentation/widgets/pack_filter_chips_test.dart — 잠금 표시 테스트 업데이트
test/presentation/providers/compact_phrase_filter_provider_test.dart — 스마트 기본값 테스트 수정
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
| **AdMob+테마** | AdMob 배치 + 팬 컬러 테마 커스터마이징 13 tasks → 641 tests |
