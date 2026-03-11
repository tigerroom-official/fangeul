# Fangeul — Session Handoff

BASE_COMMIT: 09c8cae (이전 핸드오프)
HANDOFF_COMMIT: b421e53
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
- 최애색(Choeae Color) UX 오버홀 — 15 tasks + 5 review fixes (2026-03-07)
- HSL→HCT 엔진 교체 P0 완료 (2026-03-07)
- 테마 커스터마이징 전면 업그레이드 (2026-03-08): 2D HCT 피커, 슬롯, 3-SKU IAP, brightnessOverride, chroma 85%, 804 tests
- 보상형 광고 피벗 (2026-03-09): TTS/즐겨찾기 시간제 해금 폐지 → 프리미엄 테마 24h 체험 전용
- IAP UI 마무리 (2026-03-09): subtitle 설명 추가, 번들 "추천" 뱃지, Codex 리뷰 수정
- 즐겨찾기 제한 UX 개선 (2026-03-09): 다이얼로그 직접적 메시지, SnackBar CTA 개선, 버블 해결 경로 추가
- **릴리즈 준비 (2026-03-11)**: AdMob 프로덕션 ID + T-rating + targetSdk 35 + ProGuard + privacy/terms + 서명 설정
- **변환기 UX 개선 (2026-03-11)**: autofocus + paste + 중앙 space bar + empty state 예시 + "Key Swap" 영문 리네이밍
- **릴리즈 버그 수정 (2026-03-11)**: Done 버튼 silent failure (FlutterSecureStorage try-catch) + debug progress panel
- **v1.0.0+4 AAB 빌드 완료** (2026-03-11): 내부 테스트용 릴리즈 번들

### 활성 작업
없음. main 브랜치에 전체 작업 머지 완료.

### 보류/백로그 — MVP 출시 후
- **v1.1 기능**: 한글 퍼즐(Wordle 스타일), 한글 카드 컬렉션(가챠)
- **v1.1+ 기능**: 푸시 알림(firebase_messaging), 구독 모델
- LOW 이슈 잔여: L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- 리뷰 연기 이슈: I1(IdolSelectScreen setState→Riverpod), I6(즐겨찾기 템플릿 메타데이터)
- todaySuggestedPhrases에 memberName 미전달 (멤버 템플릿 "오늘" 추천 미포함)
- share_card_painter.dart + Provider 내 UiStrings 잔류 (BuildContext 없음)
- P1: 핸들 좌측 멤버 이름 노출 (버블 UX)
- **P1: 버블 딥링크** — openMainApp 시 ThemePickerSheet 자동 오픈 (intent extra `open_theme_picker`)
- Play Integrity API (서버사이드 검증)
- AdMob SSV (Server-Side Verification)
- converter_screen 배너 = 리텐션 데이터로 결정 (v1.1)
- 즐겨찾기 포화/TTS 한도 FanPassButton 트리거 (v1.1)
- IAP "테마 슬롯 3개" → "최애 테마 3개 저장" 문구 리프레이밍 (P2)
- P2: "팬글 서포터" 리프레이밍 — IAP를 "응원" 프레이밍으로 (Phase 7.1)

---

## 작업 요약

릴리즈 준비(AdMob prod ID, T-rating, ProGuard, privacy/terms, 서명) + 변환기 UX 개선(autofocus, paste, Key Swap 리네이밍) + 릴리즈 빌드 Done 버튼 silent failure 수정 + debug progress panel 추가 + Codex 리뷰 수정. v1.0.0+4 AAB 빌드 완료. 812 tests pass.

## 완료된 작업

- [x] 릴리즈 준비: AdMob 프로덕션 ID 교체 + T-rating + targetSdk 35 + ProGuard rules + privacy/terms HTML (fec087b)
- [x] 변환기 UX: autofocus + paste 버튼 + 중앙 space bar + empty state 예시 (3594385)
- [x] Codex 리뷰 수정: compound jamo decomposition + mounted guard + l10n (1618e8d)
- [x] "Converter" → "Key Swap" 영문 리네이밍 + 탭 진입 시 autofocus + empty suffixIcon cleanup (84a05de)
- [x] Done 버튼 silent failure 수정: FlutterSecureStorage try-catch + home_screen onComplete try-catch (a839781)
- [x] Debug progress panel: settings_screen에 streak/progress 제어 패널 추가 (a839781)
- [x] v1.0.0+4 AAB 빌드 → Play Console 내부 테스트 업로드 준비 완료
- [x] 812 tests pass + flutter analyze clean

## 진행 중인 작업
없음.

## 핵심 교훈

- ★ `StatefulShellRoute.indexedStack`는 전체 탭을 alive 유지 — `initState`는 앱 시작 시 1회 실행, 탭 전환 시 미실행. 탭 진입 감지 → `StateProvider<int>` + `ref.listen` 패턴 사용
- ★ `FlutterSecureStorage`는 릴리즈 빌드에서 `PlatformException` throw 가능 (keystore 초기화, 기기별 이슈) — `read()`/`write()` try-catch + 안전 기본값 반환 필수
- ★ async 콜백에 error handling 없으면 릴리즈 빌드에서 예외 무음 삼킴 — 항상 try-catch 추가
- ★ `kDebugMode` 가드로 debug 패널 보호 — 릴리즈에서 tree-shaken, 프로덕션 오버헤드 0
- ★ suffixIcon에 빈 Row(children 없음) 렌더링 → null 반환으로 공간 낭비 방지

## 다음 단계

### 1순위: Phase 7 릴리즈 남은 항목
1. **Google Play Console** — 앱 등록 + IAP 상품 가격 설정 (₩990/₩990/₩1,500 + 동남아 현지가)
2. **v1.0.0+4 내부 테스트 배포** — AAB 이미 빌드됨, Play Console 업로드
3. **실기기 QA** — 내부 테스트 빌드로 전체 기능 검증
4. **프로덕션 트랙 출시** — 내부 테스트 통과 후

### 2순위: 출시 후 빠른 개선
- P1: 버블 딥링크 — openMainApp → ThemePickerSheet 자동 오픈 (intent extra)
- P1: 핸들 좌측 멤버 이름 노출
- PaletteRegistry 20-25개 확장 (웜톤/쿨톤 균형)
- 프리뷰 UI — 실제 화면 미리보기
- share_card_painter.dart UiStrings → l10n
- Firebase Analytics 이벤트 대시보드 구성

### 3순위: v1.1 로드맵
- IAP "테마 슬롯 3개" → "최애 테마 3개 저장" 리프레이밍 (P2)
- P2: "팬글 서포터" 리프레이밍
- 한글 퍼즐 (Wordle 스타일)
- 한글 카드 컬렉션 (가챠)
- 푸시 알림 (firebase_messaging)
- 구독 모델 (Phase 7+)

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| "Key Swap" 영문 리네이밍 | "Converter"는 일반적, K-pop 팬 타겟에 직관적인 "Key Swap"으로 |
| 탭 진입 autofocus에 StateProvider | IndexedStack에서 initState는 1회 — 탭 전환 감지에 provider가 유일한 해법 |
| FlutterSecureStorage 방어적 try-catch | 릴리즈 빌드에서 PlatformException silent failure → 사용자에게 Done 버튼 먹통 |
| Debug progress panel 추가 | 일일카드/스트릭 테스트에 매번 `pm clear` 불필요 — 장기 개발 효율 |
| suffixIcon null 조건부 | Codex 리뷰: 빈 Row 렌더링은 불필요한 공간 차지 |

## 참고 컨텍스트

- 보상형 광고 피벗: `docs/discussions/2026-03-08-rewarded-ad-strategy-pivot.md`
- 테마 커스터마이징 오버홀 계획: `docs/plans/2026-03-07-choeae-color-ux-overhaul.md`
- Surface 계층 + 슬롯 패널: `docs/discussions/2026-03-08-theme-surface-hierarchy-slots.md`
- IAP 3-SKU 구조 패널: `docs/discussions/2026-03-08-theme-iap-structure-panel.md`

## 커밋 히스토리 (이번 세션)

```
a839781 fix: Done button silent failure + debug progress panel
84a05de fix: Key Swap rename, tab autofocus, empty suffixIcon cleanup (v1.0.0+4)
1618e8d fix: Codex review — compound jamo decomposition, mounted guard, l10n
3594385 feat: converter UX — autofocus, paste, centered space bar, empty state examples
fec087b feat: release prep — AdMob prod IDs, T-rating, targetSdk 35, privacy/terms
```

## 수정한 파일

```
32 files changed, 1043 insertions(+), 78 deletions(-)

주요 수정:
 android/app/build.gradle (서명, targetSdk 35, ProGuard)
 android/app/proguard-rules.pro (NEW)
 android/app/src/main/AndroidManifest.xml (AdMob ID)
 docs/privacy-policy.html (NEW)
 docs/terms.html (NEW)
 lib/data/datasources/user_progress_local_datasource.dart (try-catch 방어)
 lib/l10n/app_*.arb (7개 언어 — Key Swap, converter 관련 키)
 lib/presentation/screens/converter_screen.dart (autofocus, paste, UX)
 lib/presentation/screens/home_screen.dart (onComplete try-catch)
 lib/presentation/screens/settings_screen.dart (debug progress panel)
 lib/presentation/widgets/converter_input.dart (suffixIcon, paste)
 lib/presentation/widgets/korean_keyboard.dart (centered space bar)
 lib/presentation/widgets/shell_scaffold.dart (activeShellTabProvider)
 lib/services/ad_ids.dart (프로덕션 AdMob ID)
 pubspec.yaml (v1.0.0+4)
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
| 테마 오버홀 | 2D HCT 피커 + 슬롯 + 3-SKU IAP + brightnessOverride + chroma 85% + hex 크래시 수정 → 804 tests |
| 보상형피벗+즐겨찾기UX | 보상형→테마 체험 전용 + IAP subtitle/추천 + 즐겨찾기 UX 개선 + Codex 리뷰 → 812 tests |
| **릴리즈준비+UX수정** | AdMob prod + ProGuard + Key Swap + autofocus + Done 버튼 수정 + debug panel → 812 tests, v1.0.0+4 |
