# Fangeul — Session Handoff

BASE_COMMIT: ae5eeb7 (main, bubble icon/app icon/splash 교체)
HANDOFF_COMMIT: 5a027cc
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
- **설정 화면: 언어 변경 + 리뷰/문의 메뉴 + 미니 컨버터 overflow 수정 + 스플래시→앱 전환 깜빡임 수정 + AGP/Gradle 업그레이드 (2026-03-06)**

### 활성 작업
없음. 이번 세션 작업 모두 완료, main 커밋됨.

### 보류/백로그
- LOW 이슈 잔여: L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- 리뷰 연기 이슈: I1(IdolSelectScreen setState→Riverpod), I6(즐겨찾기 템플릿 메타데이터)
- todaySuggestedPhrases에 memberName 미전달 (멤버 템플릿 "오늘" 추천 미포함 — known limitation)
- 관리 대시보드 + R2 동기화 (출시 후 1~2주)
- share_card_painter.dart UiStrings 잔류 (BuildContext 없음, Phase 7에서 처리)
- Provider 내 UiStrings 잔류 (BuildContext 없음, Phase 7에서 처리)
- P1: 핸들 좌측 멤버 이름 노출 (버블 UX 패널 후속)

---

## 작업 요약

설정 화면에 앱 내 언어 변경(LocaleNotifier + 7개 언어 Dropdown), 리뷰하기(InAppReview), 문의하기(url_launcher) 메뉴 추가. 미니 컨버터 RenderFlex overflow 근본 수정(adjustNothing + resizeToAvoidBottomInset:false + 최소높이 가드). 스플래시→앱 전환 시 하얀 깜빡임 수정(NormalTheme windowBackground → splash_background 색상). About 다이얼로그에서 라이선스 버튼 제거. 앱 라벨 "Fangeul" 대문자 교정. AGP 8.9.1 + Gradle 8.11.1 업그레이드. 27 files, 627 tests pass.

## 완료된 작업

- [x] `pubspec.yaml` — `in_app_review: ^2.0.10`, `url_launcher: ^6.3.1` 추가
- [x] `theme_providers.dart` — `LocaleNotifier` 추가 (null=시스템, Locale=명시적, SharedPrefs `user_locale`)
- [x] `app.dart` — `locale: ref.watch(localeNotifierProvider)` 연결
- [x] 7개 arb 파일 — `languageLabel`, `languageSystem`, `reviewLabel`, `reviewSubtitle`, `contactLabel`, `contactSubtitle` l10n 키 추가
- [x] `settings_screen.dart` — 언어 Dropdown, 리뷰하기, 문의하기 ListTile, 커스텀 앱정보 다이얼로그(라이선스 제거)
- [x] `mini_converter_screen.dart` — RenderFlex overflow 3중 방어: `resizeToAvoidBottomInset: false` + `math.max(120, ...)` 최소높이
- [x] `AndroidManifest.xml` — MiniConverterActivity `adjustNothing` 추가, 앱 라벨 "Fangeul" 대문자
- [x] `values/styles.xml` + `values-night/styles.xml` — NormalTheme windowBackground → `@color/splash_background` (하얀 깜빡임 수정)
- [x] `settings.gradle` — AGP 8.7.0 → 8.9.1
- [x] `gradle-wrapper.properties` — Gradle 8.9 → 8.11.1
- [x] 문의 메일 → `tigerroom.official@gmail.com`

## 진행 중인 작업
없음.

## 핵심 교훈

- ★ MiniConverter RenderFlex overflow 근본 원인: `windowSoftInputMode` 미지정 + `resizeToAvoidBottomInset: true`(기본값) → 시스템 IME가 열린 상태에서 Activity 창 축소. 커스텀 키보드만 쓰는 Activity는 `adjustNothing` + `resizeToAvoidBottomInset: false` 필수 (2026-03-06)
- ★ 스플래시→앱 하얀 깜빡임: NormalTheme의 `?android:colorBackground`가 시스템 라이트 모드에서 흰색 반환. 앱 기본이 다크면 `windowBackground`를 스플래시 색상으로 고정 (2026-03-06)
- ★ `url_launcher`가 `androidx.browser:1.9.0` 끌어옴 → AGP 8.9.1+ 요구. AGP 업그레이드 시 Gradle도 함께 올려야 함 (AGP 8.9.1 → Gradle 8.11.1) (2026-03-06)
- ★ Flutter 3.41.2의 `Column`은 `clipBehavior` 파라미터를 super로 전달하지 않음 — Flex에는 있지만 Column 생성자에 미포함 (2026-03-06)
- ★ Codex 교차 리뷰: MiniConverter overflow에서 `resizeToAvoidBottomInset: false` 근본 수정 합의 + `viewPadding.bottom` 이중 적용 지적 (실제는 "공간 확보 + 콘텐츠 패딩" 구조로 의도적) — 외부 리뷰의 지적을 맹목 수용하지 말고 의도 검증 필요 (2026-03-06)

## 다음 단계

### 1순위: 문구 의미 번역 6개국어 (사용자 요청)
- 현재 문구 카드: [한글] + [로마자 발음] + [영어 의미 고정]
- 문제: 비영어권 사용자(es/id/pt/th/vi)가 한글 문구 뜻을 모름
- 작업: phrases JSON의 translations 필드에 6개국어 의미 번역 추가
- **방법: Claude가 6개국어 병렬 번역 → Codex 교차 검수** (사용자 지정)
- 번역 표시: 사용자 설정 언어(LocaleNotifier) 기준으로 해당 언어 번역 노출

### 2순위: Firebase 콘솔 설정 + 학습
- Firebase Remote Config 콘솔에서 7개 매개변수 추가
- Firebase Analytics 이벤트 계측 학습

### 3순위: Phase 7 릴리즈 준비
- ProGuard/R8 설정 + 릴리즈 빌드 검증
- Play Store 리스팅 + 스크린샷

### 4순위: 백로그 정리
- P1: 핸들 좌측 멤버 이름 노출 (버블 UX)
- share_card_painter.dart + Provider 파일 UiStrings → l10n
- LOW 이슈 (L3, L4, L5), I1, I6

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| NormalTheme windowBackground = splash_background 색상 고정 | 다크 기본 테마에서 시스템 라이트 모드일 때 흰색 깜빡임 방지 |
| MiniConverter adjustNothing | 커스텀 키보드만 사용 — 시스템 IME 리사이즈 불필요 |
| AGP 8.9.1 + Gradle 8.11.1 | url_launcher의 transitive dependency 요구 |
| showAboutDialog → 커스텀 AlertDialog | 사용자에게 플러그인 라이선스 목록 불필요 |
| 문의 메일: tigerroom.official@gmail.com | 앱 공식 이메일 |

## 참고 컨텍스트

- 문구 JSON 구조: `assets/phrases/*.json` — 각 문구의 `translations` 필드에 언어 코드별 번역
- 현재 번역 표시 로직: `compact_phrase_list.dart`의 `_PhraseCard` — `phrase.translations[locale]`
- UX 패널 토의: `docs/discussions/2026-03-05-ux-detail-panel.md`
- 문구 스키마: `docs/fangeul-future-reference.md` §1.4

## 커밋 히스토리 (이번 세션)

```
5d96bde feat: settings screen — language switch, review/contact menu, UX fixes
```

## 수정한 파일

```
android/app/src/main/AndroidManifest.xml           — adjustNothing + 앱 라벨 대문자
android/app/src/main/res/values-night/styles.xml   — NormalTheme → splash_background
android/app/src/main/res/values/styles.xml         — NormalTheme → splash_background
android/gradle/wrapper/gradle-wrapper.properties   — Gradle 8.11.1
android/settings.gradle                            — AGP 8.9.1
lib/app.dart                                       — locale provider 연결
lib/l10n/app_*.arb (7개)                           — 6개 l10n 키 추가
lib/l10n/app_localizations*.dart (8개)             — gen-l10n 재생성
lib/presentation/providers/theme_providers.dart     — LocaleNotifier
lib/presentation/providers/theme_providers.g.dart   — codegen
lib/presentation/screens/mini_converter_screen.dart — overflow 3중 방어
lib/presentation/screens/settings_screen.dart       — 언어/리뷰/문의 UI
pubspec.yaml + pubspec.lock                        — in_app_review, url_launcher
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
| **설정+UX수정** | 언어 변경/리뷰/문의 메뉴 + overflow 수정 + 스플래시 깜빡임 수정 + AGP 업그레이드 → 627 tests |
