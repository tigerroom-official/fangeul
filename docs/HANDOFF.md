# Fangeul — Session Handoff

BASE_COMMIT: 5a027cc (이전 핸드오프)
HANDOFF_COMMIT: 922c7e6
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
- **로케일별 번역 표시 수정 + 컨버터 힌트 탭별 전환 + 스마트 기본 필터 + 간편모드 번역 표시 + 아이돌 선택 스크롤 + v1.0.0 (2026-03-06)**

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

---

## 작업 요약

로케일별 문구 번역 수정(arb `defaultTranslationLang` 하드코딩→각 언어코드), 버블 팝업 언어 전파(`localeNotifierProvider` invalidate), 컨버터 힌트 탭별 전환(ListenableBuilder), 스마트 기본 필터(즐찾→마이아이돌→첫 팩), 간편모드 번역 3번째줄 추가, 아이돌 선택 화면 키보드 스크롤 개선, Java 17 강제, v1.0.0 버전 업. Galaxy 실기기 테스트 완료. 624 tests pass (3 pre-existing tts_provider 실패).

## 완료된 작업

- [x] `app_es/id/pt/th/vi.arb` — `defaultTranslationLang` 각 언어코드로 수정 (bfef6d4)
- [x] `mini_converter_screen.dart` — `_syncFromMainEngine()`에 `localeNotifierProvider` invalidate 추가 (bfef6d4)
- [x] `converter_screen.dart` + `mini_converter_screen.dart` — ConverterInput을 `ListenableBuilder`로 감싸서 탭별 힌트 전환 (bfef6d4)
- [x] `compact_phrase_filter_provider.dart` — 스마트 기본값: 즐찾→마이아이돌→첫 팩 (c93a0d9)
- [x] `my_idol_provider.dart` — 아이돌 변경 시 `compact_phrase_filter` 초기화 (c93a0d9)
- [x] `compact_phrase_list.dart` — `_PhraseCard` 번역을 `defaultTranslationLang` 기반으로 변경 (c93a0d9)
- [x] `compact_phrase_tile.dart` — 세로 리스트에 번역줄 추가 (c93a0d9)
- [x] `idol_select_screen.dart` — 키보드 올라올 때 `Scrollable.ensureVisible()` 자동 스크롤 (c93a0d9)
- [x] `android/build.gradle` — `afterEvaluate` Java 17 강제 (c93a0d9)
- [x] `pubspec.yaml` — 버전 0.1.0+1 → 1.0.0+1 (c93a0d9)
- [x] `mini_converter_screen_test.dart` — 스마트 기본값 반영 테스트 수정 (c93a0d9)

## 진행 중인 작업
없음.

## 핵심 교훈

- ★ `defaultTranslationLang` arb 키: 각 arb 파일이 자기 언어코드를 반환해야 함 — 모두 `"en"`으로 하드코딩하면 비영어권에서도 영어 번역만 표시 (2026-03-06)
- ★ 듀얼 FlutterEngine 로케일 전파: `_syncFromMainEngine()`에서 `localeNotifierProvider`도 invalidate 필수 — 버블 팝업이 메인앱 언어 설정을 상속하지 못함 (2026-03-06)
- ★ `ListenableBuilder(listenable: tabController)`로 감싸야 탭 전환 시 위젯 리빌드 — `tabController.index`를 직접 읽는 것만으로는 리빌드 트리거 안됨 (2026-03-06)
- ★ 아이돌 설정 변경 시 `compact_phrase_filter` SharedPreferences 키 제거 필수 — 이전 세션의 stale 필터가 스마트 기본값을 가로챔 (2026-03-06)
- ★ `adb install -r`은 앱 데이터 유지 → 테스트 시 SharedPreferences stale 데이터 주의. `pm clear`로 초기화 필요할 수 있음 (2026-03-06)
- ★ `Scrollable.ensureVisible()` + `ScrollPositionAlignmentPolicy.keepVisibleAtEnd` — 커스텀 키보드가 가리는 필드 자동 스크롤에 효과적. GlobalKey는 TextField가 아니라 감싸는 카드(Padding)에 부여해야 전체 카드 노출 (2026-03-06)

## 다음 단계

### 1순위: Phase 7 릴리즈 BLOCK 항목 (출시 필수)
1. **릴리즈 서명 설정** — keystore 생성 + `android/app/build.gradle` signingConfigs.release 구성
2. **프로덕션 AdMob ID** — `lib/services/ad_ids.dart`의 placeholder(`ca-app-pub-XXXX`) 교체
3. **ProGuard/R8 활성화** — `minifyEnabled true` + `shrinkResources true` + `proguard-rules.pro`
4. **Google Play Console** — 앱 등록 + IAP 상품(5개 컬러팩) 가격 설정 + 스크린샷/리스팅

### 2순위: 출시 후 빠른 개선
- P1: 핸들 좌측 멤버 이름 노출
- share_card_painter.dart UiStrings → l10n
- tts_provider_test 3건 수정
- Firebase Analytics 이벤트 대시보드 구성

### 3순위: v1.1 로드맵
- 한글 퍼즐 (Wordle 스타일)
- 한글 카드 컬렉션 (가챠)
- 푸시 알림 (firebase_messaging)
- 구독 모델 (Phase 7+)

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| 스마트 기본 필터: 즐찾→마이아이돌→첫팩 | 사용자 설정 존중 — 아이돌 설정한 유저에게 빈 즐겨찾기 대신 관련 콘텐츠 표시 |
| 아이돌 변경 시 필터 초기화 | stale 필터 방지 — 새 아이돌 설정 후 스마트 기본값 재평가 |
| 번역 표시: `defaultTranslationLang` 통일 | 메인앱과 동일 로직 — ko→en, en→en, es→es 등. 로케일 기반보다 명시적 |
| v1.0.0 출시 결정 | MVP 기능 완료 — 수익화/i18n/UX 모두 구현, Galaxy 실기기 테스트 통과 |

## 참고 컨텍스트

- 릴리즈 점검 결과: Codex + Explore 에이전트 리뷰 (이번 세션) — BLOCK 3건(서명/ProGuard/AdMob ID)
- 실기기 테스트: Galaxy R3CY207GNMD에서 release APK 설치 검증 완료
- UX 패널 토의: `docs/discussions/2026-03-05-ux-detail-panel.md`
- 수익화 합의: `docs/discussions/2026-03-04-phase6-monetization-consensus.md`

## 미구현 기능 현황

| 기능 | 상태 | MVP 필수 | 비고 |
|------|------|----------|------|
| 릴리즈 서명 | ❌ 미구현 | YES | keystore 생성 필요 |
| ProGuard/R8 | ❌ 미구현 | YES | 난독화 + 코드 축소 |
| 프로덕션 AdMob ID | ❌ placeholder | YES | AdMob 콘솔에서 생성 |
| Play Store 등록 | ❌ 미구현 | YES | 리스팅 + 스크린샷 |
| IAP 상품 등록 | ❌ 미구현 | YES | 5개 컬러팩 가격 설정 |
| 푸시 알림 | ❌ 미구현 | NO | v1.1 |
| 한글 퍼즐 | ❌ 미구현 | NO | v1.1 |
| 카드 컬렉션 | ❌ 미구현 | NO | v1.1 |
| 구독 모델 | ❌ 미구현 | NO | v1.1+ |
| Play Integrity API | ❌ 미구현 | NO | 서버사이드 검증 |
| AdMob SSV | ❌ 미구현 | NO | 서버사이드 검증 |

## 커밋 히스토리 (이번 세션)

```
c93a0d9 fix: smart default filter + compact mode translation + idol select scroll + v1.0.0
bfef6d4 fix: locale-aware phrase translations + converter hint per tab
```

## 수정한 파일

```
android/build.gradle                               — afterEvaluate Java 17 강제
lib/l10n/app_es.arb, app_id.arb, app_pt.arb,
        app_th.arb, app_vi.arb                     — defaultTranslationLang 수정
lib/l10n/app_localizations_es/id/pt/th/vi.dart     — gen-l10n 재생성
lib/presentation/providers/compact_phrase_filter_provider.dart — 스마트 기본 필터
lib/presentation/providers/my_idol_provider.dart    — 아이돌 변경 시 필터 초기화
lib/presentation/screens/converter_screen.dart      — ListenableBuilder 힌트
lib/presentation/screens/idol_select_screen.dart    — 키보드 자동 스크롤
lib/presentation/screens/mini_converter_screen.dart — locale invalidate + 힌트
lib/presentation/widgets/compact_phrase_list.dart   — defaultTranslationLang 통일
lib/presentation/widgets/compact_phrase_tile.dart   — 번역줄 추가
pubspec.yaml                                        — v1.0.0+1
test/presentation/screens/mini_converter_screen_test.dart — 테스트 수정
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
| **번역+필터+실기기** | 로케일별 번역 수정 + 스마트 필터 + 간편모드 번역 + 실기기 테스트 → 624 tests |
