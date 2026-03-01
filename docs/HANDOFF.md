# Fangeul — Session Handoff

BASE_COMMIT: c3f7167e2c035827195fdd5a92a74b358bffa862
HANDOFF_COMMIT: 6061864
BRANCH: main

---

## 프로젝트 상태 (누적)

### 완료된 마일스톤
- Phase 1~4: Core 엔진 + 데이터 레이어 + UI 완료
- Phase 5: 플로팅 버블 전체 구현 + C1~C3/H1~H4 리뷰 수정 완료
- Phase 5.1: MEDIUM 이슈 M1/M3/M4/M5 수정 완료
- Phase 5.2: 간편모드 팩 문구 탐색 + 크로스엔진 동기화 + 버블/키보드 UX 수정
- Sprint 1 MVP UX: 간편모드 높이 43% + 팩 자동 복원 + 복사 confetti/진동 + OEM 배터리 대응 (2026-03-02)

### 활성 작업
없음. Sprint 1 구현 + 리뷰 수정 완료.

### 보류/백로그
- LOW 이슈 잔여: L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- Phase 4 UI 마무리: 데일리 카드 공유, 스트릭 배너, celebration_overlay
- Phase 6: 수익화 (감성 컬러 팩 IAP)
- Sprint 1 리뷰 연기 이슈: SharedPreferences provider 일관성, AsyncNotifier build() 경합, requestIgnoreBatteryOptimization 반환값 개선

## 작업 요약

MVP 출시 리뷰 패널 결과 P0 4건을 Sprint 1으로 구현.
간편모드 높이 43%, 마지막 사용 팩 SharedPreferences 복원(AsyncNotifier 전환),
복사 confetti+진동 피드백(confetti 패키지), OEM 배터리 최적화 대응(Platform Channel).
자체/Codex/Silent Failure 3건 리뷰 후 CRITICAL/HIGH 이슈 4건 즉시 수정. 252개 테스트 통과.

## 완료된 작업

- [x] 간편모드 높이 30% → 43% — 필터 칩 전체 노출 + 카드 comfort — `d19a65d`
- [x] 마지막 사용 팩 자동 복원 — CompactPhraseFilterNotifier AsyncNotifier 전환 + SharedPreferences 저장/로드 + cross-engine sync invalidate + 테스트 5개 추가 — `d19a65d`
- [x] 복사 confetti + 진동 피드백 — `confetti` 패키지 + `CopyFeedback` 유틸 (Overlay.maybeOf + mounted 가드 + 쓰로틀링) + 4곳 복사 지점 통합 + 접근성 disableAnimations 존중 — `d19a65d`, `6061864`
- [x] OEM 배터리 최적화 대응 — REQUEST_IGNORE_BATTERY_OPTIMIZATIONS 권한 + Kotlin isBatteryOptimizationDisabled/requestIgnoreBatteryOptimization (try-catch) + Dart Platform Channel + 버블 활성화 시 안내 다이얼로그 — `d19a65d`, `6061864`
- [x] 리뷰 수정 — OverlayEntry mounted 가드, confetti 쓰로틀링, Kotlin startActivity try-catch, PlatformException 로깅 — `6061864`

## 진행 중인 작업

없음.

## 핵심 교훈

- ★ **OverlayEntry 타이머 cleanup은 반드시 `entry.mounted` 가드 필요** — dismiss로 Overlay 해체 후 Timer 콜백 실행 시 크래시. `Overlay.maybeOf` + `entry.mounted` 패턴 사용. (2026-03-02)
- ★ **OEM ROM에서 `startActivity`는 반드시 try-catch** — Xiaomi/Oppo/Vivo의 커스텀 ROM에서 `ActivityNotFoundException`/`SecurityException` 발생 가능. SEA 타겟 시장에서 필수. (2026-03-02)
- ★ **confetti 등 Overlay 기반 피드백은 쓰로틀링 필수** — 빠른 연속 탭 시 OverlayEntry + Controller 스택 누적으로 저사양 디바이스 jank. `_active` 플래그로 중복 방지. (2026-03-02)
- **PlatformChannel 메서드의 PlatformException은 로깅 필수** — silent return false는 디버깅 불가능. `debugPrint`로 최소 로깅.
- **AsyncNotifier로 전환 시 파생 provider는 `.future`로 watch** — `ref.watch(asyncProvider)` → `AsyncValue`, `ref.watch(asyncProvider.future)` → 실제 값 await.

## 다음 단계

### 1순위: Sprint 1 리뷰 연기 이슈 (선택)
- CompactPhraseFilterNotifier에서 `SharedPreferences.getInstance()` → `ref.read(sharedPreferencesProvider)` 일관성 통일
- `requestIgnoreBatteryOptimization` 반환값 → `Future<void>` 또는 `startActivityForResult` 패턴

### 2순위: LOW 이슈 잔여
- **L3** 자동 닫기 타이밍 하드코딩 → 설정 가능
- **L4** 버블 펄스 애니메이션
- **L5** 복사 기록 평문 저장 → 프라이버시 고려

### 3순위: Phase 4 UI 마무리
- 홈 화면 데일리 카드 공유 기능
- 스트릭 배너 비주얼 개선
- celebration_overlay.dart 구현

### 4순위: Phase 6 수익화
- 감성 컬러 팩 IAP 구현
- 보상형 광고 "팬 패스" 시스템
- 전환 퍼널 로직

## 커밋 히스토리 (이번 세션)

```
6061864 fix: Sprint 1 리뷰 수정 — OverlayEntry 안전 처리 + Kotlin try-catch + 로깅
d19a65d feat: Sprint 1 MVP UX — 간편모드 높이 + 팩 복원 + 복사 피드백 + 배터리 대응
```

## 수정한 파일 (이번 세션)

```
android/.../AndroidManifest.xml                — REQUEST_IGNORE_BATTERY_OPTIMIZATIONS 권한
android/.../MainActivity.kt                    — 배터리 최적화 Platform Channel + try-catch
lib/platform/floating_bubble_channel.dart      — 배터리 최적화 Dart 래퍼 + PlatformException 로깅
lib/.../bubble_providers.dart                  — BubbleNotifier 배터리 최적화 API
lib/.../compact_phrase_filter_provider.dart    — AsyncNotifier 전환 + SharedPrefs 저장/로드
lib/.../compact_phrase_filter_provider.g.dart  — 코드 생성 (AsyncNotifier)
lib/.../mini_converter_screen.dart             — 높이 43% + filter invalidate
lib/.../settings_screen.dart                   — 배터리 최적화 안내 다이얼로그
lib/.../compact_phrase_list.dart               — AsyncValue 핸들링 + confetti import
lib/.../compact_phrase_tile.dart               — confetti 피드백
lib/.../converter_input.dart                   — confetti 피드백
lib/.../recent_copy_tile.dart                  — confetti 피드백
lib/.../copy_feedback_overlay.dart        (NEW) — CopyFeedback 유틸 (confetti + 진동)
lib/.../ui_strings.dart                        — 배터리 안내 문자열
pubspec.yaml                                   — confetti: ^0.8.0
test/.../compact_phrase_filter_provider_test.dart — AsyncNotifier 테스트 확장 (+5)
```

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| confetti 패키지 (Lottie 대신) | Canvas 기반으로 저사양 SEA 디바이스 안전. Lottie는 에셋 필요 + 무거움 |
| CompactPhraseFilterNotifier → AsyncNotifier | SharedPreferences 저장/복원 + prefs.reload() cross-engine sync 필요 |
| 복사 후 400ms 딜레이 dismiss | confetti 피드백이 보이도록 SchedulerBinding.addPostFrameCallback → Future.delayed 전환 |
| 배터리 최적화는 startActivity (not startActivityForResult) | 시스템 다이얼로그 결과를 기다리지 않아도 다음 버블 활성화 시 재확인 |
| OverlayEntry 쓰로틀링 (static _active 플래그) | 빠른 연속 탭 시 OverlayEntry 스택 누적 방지 |

## 참고 컨텍스트

- MVP 출시 리뷰: `docs/discussions/2026-03-02-mvp-launch-review.md`
- 수익화 패널: `docs/discussions/2026-02-28-bubble-monetization.md`
- 전체 테스트: 252개 통과 (이전 247 + 신규 5)
- 리뷰: 자체 code-reviewer + silent-failure-hunter + Codex (GPT-5.3-Codex) 3건 합의

## 세션 히스토리

| 세션 | 요약 |
|------|------|
| P1~P3 | Core 엔진 + 데이터 레이어 완료 |
| P4 | UI 화면 구현 (홈, 변환기, 문구, 설정) |
| P5-구현 | Phase 5 플로팅 버블 16 tasks 구현 |
| P5-리뷰 | C1~C3/H1~H4 리뷰 수정 → 215 tests |
| P5.1-MEDIUM | M1/M3/M4/M5 수정 |
| P5.2-UX | 팩 문구 탐색 + AsyncNotifier 전환 + 버블/키보드 UX 수정 → 247 tests |
| **Sprint 1 (이번)** | MVP UX 기반 다듬기 — 높이/팩복원/confetti/배터리 + 3건 리뷰 수정 → 252 tests |
