# Fangeul — Session Handoff

BASE_COMMIT: c3f7167e2c035827195fdd5a92a74b358bffa862
HANDOFF_COMMIT: b4e6547
BRANCH: main

---

## 프로젝트 상태 (누적)

### 완료된 마일스톤
- Phase 1~4: Core 엔진 + 데이터 레이어 + UI 완료
- Phase 5: 플로팅 버블 전체 구현 + C1~C3/H1~H4 리뷰 수정 완료
- Phase 5.1: MEDIUM 이슈 M1/M3/M4/M5 수정 완료
- Phase 5.2: 간편모드 팩 문구 탐색 + 크로스엔진 동기화 + 버블/키보드 UX 수정

### 활성 작업
없음. 이번 세션 작업 완료.

### 보류/백로그
- LOW 이슈: L1(비율 조정), L2(탭 persistence), L3(자동닫기 설정), L4(펄스 애니메이션), L5(복사 기록 암호화)
- Phase 4 UI 마무리: 데일리 카드 공유, 스트릭 배너, celebration_overlay
- Phase 6: 수익화 (감성 컬러 팩 IAP)

## 작업 요약

간편모드에 팩별 문구 탐색 기능을 추가하고, 크로스 FlutterEngine 간 SharedPreferences 동기화,
버블 토글 상태, 키보드 언어 전환 등 다수의 UX 버그를 수정했다.
3+ 회 실패한 즐겨찾기 동기화 문제를 AsyncNotifier 아키텍처 전환으로 근본 해결. 247개 테스트 통과.

## 완료된 작업

- [x] 간편모드 팩 문구 탐색 — 필터 칩 바 + 좌우 스와이프 카드(PageView) + 즐겨찾기 세로 리스트
  - 신규: `compact_phrase_filter_provider.dart`, `compact_phrase_tile.dart`, `pack_filter_chips.dart`
  - 수정: `compact_phrase_list.dart` 전면 리팩토링
- [x] FavoritePhrasesNotifier → AsyncNotifier 전환 (근본 아키텍처 수정) — `b4e6547`
  - sync Notifier의 "{}→async load" 갭이 파생 provider에서 빈 데이터 노출하는 근본 문제 해결
  - `toggle()` → `Future<void>` + `await future`로 race condition 방지
- [x] 크로스 엔진 SharedPreferences 동기화 — `prefs.reload()` + `didChangeAppLifecycleState` invalidate
- [x] CopyHistoryNotifier `late final _loaded` → `late _loaded` (invalidate 시 재할당 크래시 수정)
- [x] 버블 임시 hide 시 토글 상태 유지 — `EXTRA_SILENT` 플래그 + `isServiceActive` 분리
- [x] 메인 앱 포그라운드에서 버블 자동 숨김 — `onResume`/`onStop` + `showBubble` handler
- [x] 탭 전환 시 키보드 언어 즉시 반영 — `ListenableBuilder(listenable: _tabController)`
- [x] 상태바 투명 처리 — `MiniConverterActivity.onCreate()` + XML theme 속성
- [x] MEDIUM 이슈 M1/M3/M4/M5 수정 (이전 세션에서 커밋)

## 진행 중인 작업

없음.

## 핵심 교훈

- ★ **듀얼 FlutterEngine = 별도 Dart 격리 = SharedPreferences 캐시 분리**. 크로스엔진 데이터 공유 시 반드시 `prefs.reload()` 호출 필요. (2026-03-01)
- ★ **sync Notifier + async load 패턴은 파생 provider에서 근본적으로 깨짐**. `build()` 동기 반환 `{}` → 비동기 load 완료 전에 파생 provider가 빈 데이터로 평가 → AsyncNotifier로 전환해야 함. 3+ 회 실패 후 아키텍처 문제로 판단. (2026-03-01)
- ★ **`late final` 필드를 Riverpod Notifier.build()에서 초기화하면 안 됨**. `ref.invalidate()` 시 `build()` 재호출 → `late final` 재할당 에러. `late` (non-final) 또는 nullable 사용. (2026-03-01)
- ★ **프리워밍된 FlutterEngine의 provider는 엔진 생성 시 빌드됨** — MiniConverterActivity 열기 시점이 아님. `didChangeAppLifecycleState(resumed)`에서 반드시 invalidate하여 최신 데이터 로드. `_hasInitialized` 가드로 첫 resume를 건너뛰면 안 됨. (2026-03-01)
- ★ **버블 임시 hide vs 영구 stop 구분 필요** — `ACTION_HIDE`에 `EXTRA_SILENT` boolean extra로 이벤트 브로드캐스트 억제. `isServiceActive`(서비스 활성) vs `isBubbleShowing`(뷰 표시) 플래그 분리. (2026-03-01)
- ★ **TabController 변경이 provider 상태 변경 없으면 리빌드 안 됨** — freezed state가 이미 동일 값이면 Riverpod가 리빌드를 건너뜀. `ListenableBuilder(listenable: _tabController)`로 키보드 등 탭 의존 위젯을 감싸야 함. (2026-03-01)
- `AutomaticKeepAliveClientMixin` — TabBarView에서 탭 전환 시 provider auto-dispose 방지
- `ref.listenManual` — build() 내 side-effect 대신 initState()에서 사용 (필터 변경 시 PageView 리셋)

## 다음 단계

### 1순위: LOW 이슈 수정
- **L1** 간편/확장 모드 비율 35%/75% → 설계서 기준 조정
- **L2** 탭 선택 persistence (SharedPreferences)
- **L3** 자동 닫기 타이밍 하드코딩 → 설정 가능
- **L4** 버블 펄스 애니메이션
- **L5** 복사 기록 평문 저장 → 프라이버시 고려

### 2순위: Phase 4 UI 마무리
- 홈 화면 데일리 카드 공유 기능
- 스트릭 배너 비주얼 개선
- celebration_overlay.dart 구현

### 3순위: Phase 6 수익화
- 감성 컬러 팩 IAP 구현
- 보상형 광고 "팬 패스" 시스템
- 전환 퍼널 로직

## 커밋 히스토리

```
b4e6547 feat: 간편모드 팩 문구 탐색 + 버블/키보드 UX 버그 수정
d0945b3 fix: 버블 팝업 UX 수정 — 닫기/스와이프/즐겨찾기 복사
b457ae6 fix: 버블 팝업 투명 배경 + 즐겨찾기 동기화
8d47b3c fix: 버블 팝업 재열기 시 빈 화면 — SystemNavigator.pop()으로 교체
888c046 fix: 다크모드에서 버블 탭 시 검은 화면 — TranslucentTheme 누락 수정
308fb2a fix: removeBubble bubbleParams null + config receiver height 감지 추가
6b59a3c fix: 심층 리뷰 반영 — _loadFromPrefs try-catch, snapToEdge Y클램핑, Handler.post
c95cda7 fix: 코드 리뷰 반영 — isRunning→isBubbleShowing, RECEIVER_NOT_EXPORTED, dart:async 제거
a7f130a style: dart format 적용
2a15b74 fix(M3/M4/M5): close-zone 리크 수정, 화면 회전 대응, deprecated API 교체
8f710d7 fix(M1): CopyHistoryNotifier — merge 전략으로 race condition 해결
c2ecd5c fix(M1): FavoritePhrasesNotifier — merge 전략으로 race condition 해결
8be4f5d chore: session handoff - Phase 5 리뷰 수정 완료
5934a20 fix: HIGH 리뷰 이슈 4건 수정 (H1~H4)
d263360 fix: 크리티컬 리뷰 이슈 3건 수정 (C1~C3)
3849f56 fix: 리뷰 반영 — setState() 제거 + 권한 거부 피드백 추가
15a0260 chore: Phase 5 최종 검증 — 포맷 수정 + unnecessary_import 제거
6cc3842 feat(bubble): MiniConverterScreen — 간편모드 + 확장모드 2단 팝업 (TDD)
```

## 수정한 파일 (이번 세션)

```
android/.../FloatingBubbleService.kt    — EXTRA_SILENT + isServiceActive 플래그
android/.../MainActivity.kt             — onResume/onStop 버블 숨김, showBubble silent hide
android/.../MiniConverterActivity.kt    — onCreate 상태바 투명 처리
android/.../values/styles.xml (x2)      — TranslucentTheme 상태바/네비바 투명
lib/.../compact_phrase_filter_provider.dart  (NEW) — freezed 필터 + 파생 provider
lib/.../compact_phrase_tile.dart         (NEW) — ko + roman + ★토글 + 복사 타일
lib/.../pack_filter_chips.dart          (NEW) — 수평 팩 필터 칩 바
lib/.../copy_history_provider.dart       — late final → late (invalidate 호환)
lib/.../favorite_phrases_provider.dart   — AsyncNotifier 전환 + await future
lib/.../converter_screen.dart            — ListenableBuilder 키보드 감싸기
lib/.../mini_converter_screen.dart       — 전면 리팩토링 (팩 탐색, lifecycle invalidate)
lib/.../compact_phrase_list.dart         — 팩 스와이퍼 + 즐겨찾기 리스트 + AutomaticKeepAlive
lib/.../phrase_card.dart                 — AsyncValue 대응 (.valueOrNull)
test/.../favorite_phrases_provider_test.dart — AsyncNotifier API 대응
test/.../compact_phrase_filter_provider_test.dart (NEW)
test/.../compact_phrase_tile_test.dart    (NEW)
test/.../pack_filter_chips_test.dart     (NEW)
test/.../mini_converter_screen_test.dart — 팩 스와이퍼 테스트 추가
```

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| FavoritePhrasesNotifier: sync → AsyncNotifier | sync Notifier + async load 패턴이 파생 provider에서 근본적으로 깨짐. 3회 실패 후 아키텍처 문제로 판단 |
| 버블 hide에 EXTRA_SILENT 플래그 | 임시 hide(메인 앱 포그라운드)와 영구 stop을 구분하여 Dart 이벤트 브로드캐스트 제어 |
| isServiceActive vs isBubbleShowing 분리 | 뷰 숨김 상태에서도 서비스 활성 상태를 추적하여 getBubbleState/토글 UI 정확성 보장 |
| ListenableBuilder로 키보드 감싸기 | freezed state가 동일하면 Riverpod이 리빌드 건너뜀 → TabController Listenable 직접 구독 |
| didChangeAppLifecycleState에서 무조건 invalidate | 프리워밍 엔진의 provider가 이미 빌드 완료됨 → 첫 resume에서도 invalidate 필요 |

## 참고 컨텍스트

- 설계서: `docs/plans/2026-02-28-phase5-floating-bubble-design.md`
- 수익화 패널: `docs/discussions/2026-02-28-bubble-monetization.md`
- 전체 테스트: 247개 통과 (이전 세션 215 → 이번 세션 +32)
- 에뮬레이터 검증: 즐겨찾기 크로스엔진 동기화, 버블 토글 상태, 키보드 언어 전환 확인 완료

## 세션 히스토리

| 세션 | 요약 |
|------|------|
| P1~P3 | Core 엔진 + 데이터 레이어 완료 |
| P4 | UI 화면 구현 (홈, 변환기, 문구, 설정) |
| P5-구현 | Phase 5 플로팅 버블 16 tasks 구현 |
| P5-리뷰 | C1~C3/H1~H4 리뷰 수정 → 215 tests |
| P5.1-MEDIUM | M1/M3/M4/M5 수정 |
| **P5.2-UX (이번)** | 팩 문구 탐색 + AsyncNotifier 전환 + 버블/키보드 UX 수정 → 247 tests |
