# Fangeul — Session Handoff

BASE_COMMIT: 8405004 (main, i18n+Firebase RC 완료)
HANDOFF_COMMIT: 8fd4221
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
- **Firebase Crashlytics/Analytics 통합 + 버블 UX 대폭 개선 (2026-03-05)**

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

Firebase Crashlytics/Analytics 실제 서비스 연동 + 미니 컨버터 버블 헤더 UX 대폭 개선. 전문가 패널 3차 토론(4:0 만장일치)으로 두 모드(간편/상세) 헤더를 `[핸들바(틸)] + [···]`로 완전 통일. `[← 간편모드]` 버튼, `[X]` 닫기 버튼, "버블 닫기" 메뉴 모두 제거. "팝업 숨기기"(SystemNavigator.pop, 버블 유지)로 대체. 33파일 변경, 627 tests pass.

## 완료된 작업

### Track A: Firebase Crashlytics + Analytics
- [x] `firebase_crashlytics: ^4.3.1` 추가 + gradle 설정
- [x] `lib/main.dart` — Crashlytics 에러 핸들러 설정 (FlutterError + PlatformDispatcher)
- [x] 디버그 모드 Crashlytics 수집 비활성화
- [x] `lib/services/firebase_analytics_service.dart` 신규 — AnalyticsService 인터페이스 실제 구현
- [x] main.dart에 FirebaseAnalyticsService provider override 연결

### Track B: 버블 UX 대폭 개선 (전문가 패널 3차 토론)
- [x] 간편모드 헤더: Stack→Row 레이아웃, 핸들 pill 틸(#4ECDC4) 브랜딩
- [x] `open_in_new` 아이콘 → `PopupMenuButton(···)` 교체 (간편+상세 모두)
- [x] "Fangeul" TextButton 제거 (유틸리티 팝업에 앱 이름 불필요)
- [x] `[← 간편모드]` 버튼 제거 — 핸들 아래 드래그로 대체 (바텀시트 표준)
- [x] `[X]` 닫기 버튼 제거 — `···` "팝업 숨기기"가 대체
- [x] "버블 닫기"(stopService) 메뉴 제거 → "팝업 숨기기"(SystemNavigator.pop, 버블 유지)로 교체
- [x] 상세모드 핸들 드래그(아래→간편모드 복귀) 추가
- [x] Kotlin `closeBubble` MethodChannel 핸들러 제거 (불필요)
- [x] 7개 ARB 파일 `miniMenuCloseBubble` → "팝업 숨기기" 번역 갱신
- [x] 테스트 갱신 — 제거된 UI 요소 반영, 627/627 통과

### Track C: 버블/키보드 버그 수정
- [x] `MiniConverterActivity.kt` — showBubble()에 `MainActivity.isResumed` 가드 (레이스 컨디션 수정)
- [x] `MainActivity.kt` — `isResumed` static 플래그 추가
- [x] `korean_keyboard.dart` — viewPadding.bottom으로 3행 잘림 수정

### Track D: 문서
- [x] `docs/discussions/2026-03-05-bubble-ux-panel.md` — 전문가 패널 토론 기록
- [x] `docs/guides/firebase-guide.md` — Firebase 학습 가이드
- [x] 이전 세션 토론/계획/원본 문서 정리

## 진행 중인 작업
없음.

## 핵심 교훈

- ★ 버블 "닫기" 동작 구분: `SystemNavigator.pop()` = 팝업만 닫힘(버블 유지) vs `stopService()` = 버블 서비스 완전 종료. 미니 컨버터에서 서비스 종료 경로는 불필요 — 재시작 비용(설정→토글) 높아 DAU 이탈 위험 (2026-03-05)
- ★ PopupMenuButton 컴팩트 설정: `iconSize: 20, tapTargetSize: shrinkWrap, constraints: BoxConstraints(minWidth: 28, minHeight: 28)` — 좁은 헤더에 적합 (2026-03-05)
- ★ 바텀시트 패턴: 핸들 위/아래 드래그만으로 모드 전환 (Google Maps, Instagram, 카카오톡 등과 일치) — 상세모드 진입자 = 100% 핸들 학습 완료 상태 (2026-03-05)
- ★ Kotlin 네이티브 변경은 `flutter run` 풀 리빌드 필수 — 핫 리로드 시 MissingPluginException (2026-03-05)

## 다음 단계

### 1순위: Firebase 콘솔 설정 + 학습
- Firebase Remote Config 콘솔에서 7개 매개변수 추가 (honeymoonDays, defaultSlotLimit, dailyAdLimit, adCooldownMinutes, unlockDurationHours, dailyTtsLimit, conversionTriggerAdCount)
- Firebase Analytics 이벤트 계측 학습 (사용자 요청 — 백엔드 개발자로서 앱 분석 스킬 부족)
- 에뮬레이터에서 로케일별 동작 확인 (ko→en→id→th→pt→es→vi + 미지원 로케일 fallback)

### 2순위: Phase 7 릴리즈 준비
- ProGuard/R8 설정 + 릴리즈 빌드 검증
- Play Store 리스팅 + 스크린샷
- signing config 설정

### 3순위: 실기기 통합 테스트
- AdMob 실제 광고 단위 ID 연결
- IAP Play Console 설정 + 테스트 결제
- 플로팅 버블 + 수익화 교차 동작 확인

### 4순위: 백로그 정리
- P1: 핸들 좌측 멤버 이름 노출 (버블 UX)
- share_card_painter.dart + Provider 파일 UiStrings → l10n 전환 (BuildContext 전달 방법 설계)
- LOW 이슈 (L3, L4, L5)
- IdolSelectScreen setState→Riverpod (I1)
- 즐겨찾기 템플릿 메타데이터 (I6)

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| 간편/상세모드 헤더 완전 통일 (`[핸들(틸)] + [···]`) | 일관성 향상 + 바텀시트 표준 패턴 |
| `[← 간편모드]` 버튼 제거 | 핸들 드래그로 대체 — 상세모드 진입자 = 100% 핸들 학습 완료 |
| `[X]` 닫기 버튼 제거 | `···` "팝업 숨기기"가 대체 |
| "버블 닫기"(stopService) 메뉴 제거 | 실수로 서비스 종료 → 재시작 비용 큼 → DAU 이탈 위험 |
| 서비스 종료 경로 = 노티피케이션 액션 / 메인앱 설정만 유지 | 미니 컨버터는 "잠깐 쓰고 닫는" 도구 |

## 커밋 히스토리 (이번 세션)

```
77955bf feat: Firebase Analytics service + Crashlytics integration
9a75655 feat: bubble UX overhaul — unified header, handle-driven navigation
8d1b979 docs: add Firebase guide, bubble UX panel discussion, and prior session docs
```

## 수정한 파일

```
수정 (코드):
  android/app/build.gradle                           — Crashlytics gradle 플러그인
  android/settings.gradle                            — Crashlytics 플러그인 선언
  android/.../MainActivity.kt                        — isResumed static 플래그 추가
  android/.../MiniConverterActivity.kt               — closeBubble 핸들러 제거, showBubble 레이스 수정
  lib/main.dart                                      — Crashlytics 에러 핸들러 + Analytics 서비스
  lib/presentation/screens/mini_converter_screen.dart — 헤더 완전 통일 (핵심 변경)
  lib/presentation/widgets/korean_keyboard.dart      — viewPadding.bottom 수정
  lib/l10n/app_*.arb (7개)                           — miniMenuCloseBubble → "팝업 숨기기"
  lib/l10n/app_localizations*.dart (8개)              — gen-l10n 재생성
  pubspec.yaml / pubspec.lock                        — firebase_crashlytics 추가
  test/.../mini_converter_screen_test.dart            — 제거된 UI 요소 반영

신규:
  lib/services/firebase_analytics_service.dart       — Analytics 실제 구현
  docs/discussions/2026-03-05-bubble-ux-panel.md     — 전문가 패널 토론 기록
  docs/guides/firebase-guide.md                      — Firebase 학습 가이드
```

## 참고 컨텍스트

- **버블 UX 최종 설계**: `docs/discussions/2026-03-05-bubble-ux-panel.md` — 전문가 패널 3차 토론 기록 (4:0 만장일치)
- **Firebase 학습**: `docs/guides/firebase-guide.md` — RC 매개변수 설정 + Analytics 계측 가이드
- **사용자 학습 요청**: Firebase Analytics 이벤트 계측, Remote Config 콘솔 설정을 차근차근 가르쳐달라고 요청함
- **미니 컨버터 최종 구조**:
  ```
  간편모드: [핸들바(틸)] ............ [···]
  상세모드: [핸들바(틸)] ............ [···]
  ··· 메뉴: Fangeul 앱 열기 / 팝업 숨기기 (버블 유지)
  ```

## 리뷰 연기 이슈 (post-MVP)

| ID | 내용 | 심각도 | 이유 |
|----|------|--------|------|
| I1 | IdolSelectScreen에서 setState 사용 | LOW | 순수 ephemeral UI 상태 |
| I6 | 즐겨찾기 템플릿 메타데이터 손실 | LOW | ko 텍스트는 정상 표시 |
| I10 | todaySuggestedPhrases 멤버 미지원 | LOW | MVP known limitation |
| I11 | share_card_painter.dart UiStrings 잔류 | LOW | BuildContext 없음, Phase 7 |
| I12 | Provider 파일 UiStrings 잔류 | LOW | BuildContext 없음, Phase 7 |

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
| **Crashlytics+버블UX** | Firebase Crashlytics/Analytics + 버블 헤더 UX 통일 (패널 3차 4:0) → 627 tests |
