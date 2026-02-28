# Fangeul — Session Handoff

BASE_COMMIT: c3f7167e2c035827195fdd5a92a74b358bffa862
HANDOFF_COMMIT: 5934a20
BRANCH: main

---

## 작업 요약

Phase 5 플로팅 버블 구현 완료 후, Claude+Codex 통합 코드 리뷰를 수행하고
CRITICAL 3건 + HIGH 4건 이슈를 수정했다. 215개 테스트 전체 통과.

## 완료된 작업

- [x] Phase 5 플로팅 버블 전체 구현 (16 tasks) — `86b39a0`~`15a0260`
- [x] 코드 리뷰: Claude 자체 리뷰 + Codex GPT-5.3 독립 리뷰 + 에뮬레이터 앱 테스트
- [x] **C1** GoRouter + setInitialRoute 충돌 수정 — `d263360`
  - `app_router.dart`: `PlatformDispatcher.defaultRouteName` 읽어 미니 엔진 → `/mini-converter` 라우팅
- [x] **C2** MiniConverterActivity `super.configureFlutterEngine()` 추가 — `d263360`
- [x] **C3** PhraseCard 즐겨찾기 토글 버튼 추가 — `d263360`
  - `phrase_card.dart`: StatelessWidget → ConsumerWidget, 별 아이콘 + FavoritePhrasesNotifier 연동
- [x] **H1** EventChannel 구현 — `5934a20`
  - `BubbleEventBroadcaster.kt` (싱글턴), `FloatingBubbleService` → send(), `floating_bubble_channel.dart` stateStream
- [x] **H2** MiniConverterActivity 엔진 캐시 null 폴백 — `5934a20`
- [x] **H3** `requestOverlayPermission` → `startActivityForResult` + 권한 복귀 시 자동 버블 표시 — `5934a20`
- [x] **H4** BubbleNotifier.build()에서 `_syncFromNative()` + `_listenToEvents()` — `5934a20`
- [x] 리뷰 반영: setState 제거 + 권한 거부 피드백 — `3849f56`

## 진행 중인 작업

없음. CRITICAL/HIGH 이슈 모두 수정 완료.

## 다음 단계

### 1순위: MEDIUM 이슈 수정 (Phase 5.1)
- **M1** Provider `build()`에서 async `_loadFromPrefs()` 호출 레이스 컨디션 — `favorite_phrases_provider.dart`, `copy_history_provider.dart`
- **M3** `ACTION_HIDE`에서 close-zone 오버레이 리크 — `FloatingBubbleService.kt` `removeBubble()` 시 `removeCloseZone()`도 호출
- **M4** 화면 회전 시 bubble 위치 초기화 — `FloatingBubbleService.kt` `onConfigurationChanged`
- **M5** `getRunningServices()` deprecated API → `ActivityManager.getRunningServiceControlPanel()` 또는 바인드 패턴

### 2순위: LOW/UX 이슈
- **L1** 간편/확장 모드 비율 30%/75% → 25%/70% (설계서 기준)
- **L2** 탭 선택 persistence
- **L3** 자동 닫기 타이밍 하드코딩 → 설정 가능하게
- **L4** 버블 펄스 애니메이션
- **L5** 복사 기록 평문 저장 → 프라이버시 고려

### 3순위: Phase 4 UI 진행
- 홈 화면 데일리 카드 공유 기능
- 스트릭 배너 비주얼 개선
- celebration_overlay.dart (이미 파일 존재, 내용 구현 필요)

## 핵심 교훈

- ★ GoRouter는 `initialLocation` 파라미터만 사용하고 `window.defaultRouteName`을 무시한다. 별도 FlutterEngine에서 `setInitialRoute()`를 쓰려면 `PlatformDispatcher.instance.defaultRouteName`을 직접 읽어 GoRouter에 전달해야 한다.
- ★ FlutterActivity의 `configureFlutterEngine()`을 override할 때 반드시 `super` 호출. 안 하면 플러그인 미등록 → `MissingPluginException`.
- ★ Kotlin Service → Dart 이벤트 전송: `EventChannel.StreamHandler`를 싱글턴 object로 구현하고, Service에서 `mainHandler.post { eventSink?.success() }`로 메인 스레드 보장.
- ★ Riverpod auto-dispose provider 테스트 시 `container.read()`가 아닌 `container.listen()`으로 provider를 유지해야 비동기 상태 변경이 반영된다.
- `requestOverlayPermission`에서 `startActivityForResult` 사용 시 `@Suppress("DEPRECATION")` 필요 (Activity Result API 대안 있지만 FlutterActivity에서는 이 방식이 간단).

## 커밋 히스토리

```
5934a20 fix: HIGH 리뷰 이슈 4건 수정 (H1~H4)
d263360 fix: 크리티컬 리뷰 이슈 3건 수정 (C1~C3)
3849f56 fix: 리뷰 반영 — setState() 제거 + 권한 거부 피드백 추가
15a0260 chore: Phase 5 최종 검증 — 포맷 수정 + unnecessary_import 제거
6cc3842 feat(bubble): MiniConverterScreen — 간편모드 + 확장모드 2단 팝업 (TDD)
2011bc8 feat(bubble): /mini-converter 라우트 추가
da5600e feat(bubble): Settings — 버블 토글 + 권한 다이얼로그
7f29583 feat(bubble): UI strings + 간편모드 위젯 (타일, 리스트)
a8e7c32 feat(bubble): BubbleNotifier — 상태 관리 Provider (TDD)
4488628 feat(bubble): ConverterInput — onCopied 콜백 추가
5728480 feat(bubble): FavoritePhrasesNotifier — 즐겨찾기 토글/persist (TDD)
ceb91cb feat(bubble): CopyHistoryNotifier — 복사 이력 20개 제한 (TDD)
d008c80 feat(bubble): FloatingBubbleChannel — MethodChannel 래퍼 (TDD)
b6aa1c2 feat(bubble): MainActivity — FlutterEngine 프리워밍 + MethodChannel
0bdcd51 feat(bubble): BubbleState enum — off/showing/popup (TDD)
3e1a6f6 feat(bubble): MiniConverterActivity — 캐시 엔진 Flutter Activity
42a76c8 feat(bubble): FloatingBubbleService — 오버레이, 드래그, 스냅, 닫기 존
7d6ae72 feat(bubble): BubbleNotificationHelper — 알림 채널/빌더
86b39a0 feat(bubble): AndroidManifest + TranslucentTheme 설정
```

## 수정한 파일 (이번 세션)

```
android/.../BubbleEventBroadcaster.kt     (NEW) — EventChannel 싱글턴
android/.../FloatingBubbleService.kt      — 이벤트 전송 추가
android/.../MainActivity.kt              — EventChannel 등록, startActivityForResult
android/.../MiniConverterActivity.kt      — super 호출 + null 폴백
lib/platform/floating_bubble_channel.dart — stateStream, requestOverlayPermission 반환
lib/presentation/constants/ui_strings.dart — favoriteTooltip
lib/presentation/providers/bubble_providers.dart — syncFromNative, listenToEvents
lib/presentation/router/app_router.dart   — PlatformDispatcher.defaultRouteName
lib/presentation/screens/settings_screen.dart — 권한 허용 시 자동 버블 표시
lib/presentation/widgets/phrase_card.dart — ConsumerWidget + 즐겨찾기 토글
test/.../bubble_providers_test.dart       — EventChannel 스트림 테스트
test/.../settings_bubble_toggle_test.dart — stateStream mock 추가
test_driver/driver_main.dart              — lib/에서 이동
```

## 핵심 결정사항

| 결정 | 이유 |
|------|------|
| GoRouter에서 `PlatformDispatcher.defaultRouteName` 사용 | `setInitialRoute()`와 GoRouter 호환을 위해. 유효한 경로만 허용하는 allowlist 방식 |
| EventChannel을 싱글턴 object로 구현 | Service는 Activity와 생명주기가 다르므로, static EventSink로 브릿지 |
| `startActivityForResult` 사용 (deprecated지만) | FlutterActivity에서 Activity Result API 적용이 복잡. MVP에서는 충분 |
| PhraseCard를 ConsumerWidget으로 전환 | 즐겨찾기 상태를 실시간 반영하려면 ref.watch 필요 |

## 참고 컨텍스트

- 리뷰 기준 문서: `docs/plans/2026-02-28-phase5-floating-bubble-design.md`
- 수익화 패널 토론: `docs/discussions/2026-02-28-bubble-monetization.md`
- 에뮬레이터 테스트: Home/Converter/Phrases 정상, Settings는 Driver 접근 실패 (IconButton tooltip 없음)
- 전체 테스트: 215개 통과 (기존 214 + EventChannel 1)

## 세션 히스토리

| 세션 | 요약 |
|------|------|
| P1~P3 | Core 엔진 + 데이터 레이어 완료 |
| P5-구현 | Phase 5 플로팅 버블 16 tasks 구현 (86b39a0~15a0260) |
| P5-리뷰 (이전) | Claude+Codex 통합 리뷰, setState 수정 |
| **P5-수정 (이번)** | C1~C3 크리티컬 + H1~H4 하이 이슈 수정 → 215 tests |
