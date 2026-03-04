# Fangeul — Session Handoff

BASE_COMMIT: 88a7c9d (main, Phase B 완료)
HANDOFF_COMMIT: bb27012
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
- Phase 6 수익화 설계: 전문가 패널 토론 + Claude×Codex 교차 리뷰 완료 (2026-03-04)
- Phase 6 수익화 구현: 18 tasks + 2라운드 Claude×Codex 교차 리뷰 수정 완료 (2026-03-04)
- **멀티모드 키보드 + 패널 개선 + 버블 버그 수정 (2026-03-04)**

### 활성 작업
없음. 이번 세션 작업 모두 완료, main 커밋됨.

### 보류/백로그
- LOW 이슈 잔여: L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- 리뷰 연기 이슈: I1(IdolSelectScreen setState→Riverpod), I6(즐겨찾기 템플릿 메타데이터)
- todaySuggestedPhrases에 memberName 미전달 (멤버 템플릿 "오늘" 추천 미포함 — known limitation)
- 관리 대시보드 + R2 동기화 (출시 후 1~2주)

---

## 작업 요약

멀티모드 가상 키보드(한글/ABC/123) 추가, 전문가 패널 합의 기반 UX 개선 3건, PhraseCard roman 색상 구분, 버블 자동 숨김 레이스 컨디션 수정, 최근 앱 깜빡임 방지, MiniConverter 검은 배경/히스토리 노출 수정. 22파일, +2085줄. 616 tests pass.

## 완료된 작업

### 멀티모드 가상 키보드 (Task 1~4)
- [x] MultiModeKeyboard 위젯 생성 (한글/ABC/123 모드) — `lib/presentation/widgets/multi_mode_keyboard.dart`
- [x] IdolSelectScreen 통합 — readOnly TextField + 가상 키보드 연동, 필드 전환 시 텍스트 보존
- [x] 커스텀 입력 시 키보드가 필드를 가리는 문제 수정 (ShellScaffold keyboard-aware layout)
- [x] 완료 버튼 시 jamo flush + 키보드 해제
- [x] 테스트 21개 (multi_mode_keyboard_test 15개 + idol_select_screen_test 6개 추가)

### 전문가 패널 합의 기반 개선 (Task 5~8)
- [x] `collectAndResolveTemplates()` 공유 유틸리티 — 멤버 우선 정렬 지원
- [x] 버블 간편모드 마이아이돌 칩 라벨 동적화 (`♡ {name}`)
- [x] `_buildMyIdolPhrases` 리팩토링 — 공유 유틸리티 사용 + `memberFirst: true`
- [x] 테스트 10개 (template_phrase_provider_test 5개 + compact_phrase_filter_provider_test 5개)

### PhraseCard roman 텍스트 색상 구분
- [x] 메인 앱 PhraseCard에 `_buildRomanText()` + `_splitByNames()` 추가 — 치환된 아이돌/멤버명은 muted, 발음은 primary
- [x] 테스트 4개 (phrase_card_test.dart 신규)

### 버블 버그 수정 (4건)
- [x] **레이스 컨디션 수정**: `onResume()` — `isBubbleShowing` → `isServiceActive` 체크 (비동기 Binder IPC 경쟁 방지)
- [x] **최근 앱 깜빡임 방지**: `onStop()` 버블 복원 500ms 지연 + `onResume()` 취소 + `onDestroy(isFinishing)` 즉시 복원
- [x] **MiniConverter 검은 배경**: dark mode TranslucentTheme 부모 `Theme.Black.NoTitleBar` → `Theme.Translucent.NoTitleBar`
- [x] **MiniConverter 히스토리 제외**: `excludeFromRecents="true"` + `noHistory="true"` 추가
- [x] **Confetti 딜레이**: 오버레이 제거 타이머 1500ms → 700ms (burst 300ms + 낙하 300ms + 버퍼 100ms)

## 핵심 교훈

- ★ 버블 auto-hide: `isBubbleShowing`은 비동기 intent 처리 전 stale할 수 있음 → `isServiceActive` 사용 (2026-03-04)
- ★ 최근 앱 화면에서 오버레이 깜빡임: `onStop()` 즉시 복원 대신 500ms 지연 + `onResume()` 취소 패턴 (2026-03-04)
- ★ Android TranslucentTheme: dark mode 부모 `Theme.Black.NoTitleBar`는 decor view에 검은 배경 유발 → `Theme.Translucent.NoTitleBar` 사용 (2026-03-04)
- ★ Text.rich의 TextSpan은 내부적으로 한 레벨 더 감싸짐 — `root.children[0].children`으로 접근 (2026-03-04)
- ★ 멀티모드 키보드: 모드 전환 시 한글 자모 버퍼를 반드시 flush 후 committedText에 추가 (2026-03-04)

## 다음 단계

### 1순위: Phase 7 릴리즈 준비
- Play Store 리스팅 + 스크린샷
- Firebase Analytics 연동 (NoOp → real)
- 크래시 리포팅 (Crashlytics)
- ProGuard/R8 설정 + 릴리즈 빌드 검증

### 2순위: 실기기 통합 테스트
- AdMob 실제 광고 단위 ID 연결
- IAP Play Console 설정 + 테스트 결제
- 플로팅 버블 + 수익화 교차 동작 확인

### 3순위: 백로그 정리
- LOW 이슈 (L3, L4, L5)
- IdolSelectScreen setState→Riverpod (I1)
- 즐겨찾기 템플릿 메타데이터 (I6)

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| 멀티모드 키보드 직접 구현 | KoreanKeyboard embed 시 Container 중첩, KeyboardKey 재사용으로 스타일 일관성 |
| 버블 복원 500ms 지연 | 최근 앱 화면 깜빡임 vs 실제 앱 전환 지연 트레이드오프 — 500ms는 사용자 인지 불가 |
| TranslucentTheme parent 통일 | light/dark 양쪽 모두 `Theme.Translucent.NoTitleBar`로 통일 — 투명 Activity 전용 |
| MiniConverter excludeFromRecents+noHistory | 유틸리티 팝업이 히스토리에 잔류하면 혼란 |

## 커밋 히스토리 (이번 세션)

```
5ea3045 feat: multi-mode keyboard, panel improvements, and bubble bugfixes
```

## 수정한 파일

```
신규:
  lib/presentation/widgets/multi_mode_keyboard.dart    — 한글/ABC/123 가상 키보드 (+610)
  test/presentation/widgets/multi_mode_keyboard_test.dart — 키보드 테스트 15개 (+381)
  test/presentation/widgets/phrase_card_test.dart       — PhraseCard roman 색상 테스트 4개 (+133)

수정 (lib):
  lib/presentation/screens/idol_select_screen.dart     — readOnly + 가상 키보드 통합 (+141)
  lib/presentation/widgets/phrase_card.dart             — roman 이름 색상 구분 (+80)
  lib/presentation/widgets/compact_phrase_tile.dart     — 스와이프 복사 + 이름 색상 (+100)
  lib/presentation/widgets/shell_scaffold.dart          — keyboard-aware layout (+57)
  lib/presentation/providers/template_phrase_provider.dart — collectAndResolveTemplates (+35)
  lib/presentation/providers/compact_phrase_filter_provider.dart — 리팩토링 (+34)
  lib/presentation/widgets/compact_phrase_list.dart     — 동적 idol 라벨 (+10)
  lib/presentation/widgets/pack_filter_chips.dart       — myIdolLabel 파라미터 (+6)
  lib/presentation/widgets/copy_feedback_overlay.dart   — confetti 타이머 1500→700ms
  lib/presentation/constants/ui_strings.dart            — 키보드 모드 문자열 (+4)

수정 (android):
  android/app/src/main/kotlin/.../MainActivity.kt      — 레이스 컨디션 + 500ms 지연 복원 (+43)
  android/app/src/main/AndroidManifest.xml              — excludeFromRecents + noHistory
  android/app/src/main/res/values-night/styles.xml      — Theme.Translucent.NoTitleBar
  android/app/src/main/res/values/styles.xml            — Theme.Translucent.NoTitleBar

수정 (test):
  test/presentation/screens/idol_select_screen_test.dart — 키보드 통합 테스트 (+257)
  test/presentation/providers/template_phrase_provider_test.dart — collectAndResolve 테스트 (+87)
  test/presentation/providers/compact_phrase_filter_provider_test.dart — 멤버 우선 정렬 (+85)
  test/presentation/widgets/compact_phrase_tile_test.dart — 이름 색상 테스트 (+84)
```

## 리뷰 연기 이슈 (post-MVP)

| ID | 내용 | 심각도 | 이유 |
|----|------|--------|------|
| I1 | IdolSelectScreen에서 setState 사용 | LOW | 순수 ephemeral UI 상태 |
| I6 | 즐겨찾기 템플릿 메타데이터 손실 | LOW | ko 텍스트는 정상 표시 |
| I10 | todaySuggestedPhrases 멤버 미지원 | LOW | MVP known limitation |

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
| **키보드+패널+버블** | 멀티모드 키보드 + 패널 UX 개선 + 버블 버그 4건 수정 → 616 tests |
