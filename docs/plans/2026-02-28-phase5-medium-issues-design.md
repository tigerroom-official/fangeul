# Phase 5.1 — MEDIUM Issues Fix Design

> 승인: 2026-02-28 | 총 4건

## M1: Provider build() async race condition

**파일:** `favorite_phrases_provider.dart`, `copy_history_provider.dart`

**문제:** `build()`에서 fire-and-forget `_loadFromPrefs()` 호출 → 로드 완료 전 mutation 시 상태 덮어쓰기.

**수정 (merge 전략):**
- `_loadFromPrefs()`에서 `state = saved`(교체) → `state = {...saved, ...state}`(merge)로 변경
- CopyHistory는 리스트이므로: 저장된 데이터를 기저로, 현재 state의 신규 항목을 앞에 merge
- 동기 API 유지 (toggle/addEntry 변경 없음)

**테스트 추가:**
- SharedPreferences에 mock 데이터 세팅 → build 후 `Future.delayed(Duration.zero)` → 로드 검증
- persistence round-trip 테스트 (save → rebuild → verify)

## M3: ACTION_HIDE close-zone overlay leak

**파일:** `FloatingBubbleService.kt`

**문제:** `ACTION_HIDE` 핸들러에서 `removeBubble()`만 호출, `removeCloseZone()` 누락.

**수정:** `ACTION_HIDE` 블록에 `removeCloseZone()` 추가.

## M4: 화면 회전 시 bubble 위치 초기화

**파일:** `FloatingBubbleService.kt`

**문제:** `screenWidth`/`screenHeight`가 `onCreate()` 1회만 갱신. 회전 후 스냅/닫기존 좌표 부정확.

**수정:**
- `ACTION_CONFIGURATION_CHANGED` BroadcastReceiver 등록 (onCreate → onDestroy 라이프사이클)
- 수신 시 `updateScreenSize()` + 버블이 화면 밖이면 `snapToEdge()` 재호출
- `onDestroy()`에서 `unregisterReceiver()` 정리

## M5: getRunningServices() deprecated API

**파일:** `MainActivity.kt`, `FloatingBubbleService.kt`

**문제:** `ActivityManager.getRunningServices()` → API 26+ deprecated, 프라이버시/성능 이슈.

**수정:**
- `FloatingBubbleService.companion`에 `var isRunning: Boolean = false` 추가
- `onStartCommand` 시작부에서 `isRunning = true`, `onDestroy()`에서 `isRunning = false`
- `ACTION_HIDE`에서도 `isRunning = false` (서비스는 살아있지만 버블은 숨김)
- `MainActivity.isServiceRunning()` → `FloatingBubbleService.isRunning` 직접 참조
- `ActivityManager` import 제거

## 수정 파일 목록

| 파일 | 이슈 | 변경 |
|------|------|------|
| `lib/presentation/providers/favorite_phrases_provider.dart` | M1 | _loadFromPrefs merge |
| `lib/presentation/providers/copy_history_provider.dart` | M1 | _loadFromPrefs merge |
| `android/.../FloatingBubbleService.kt` | M3, M4, M5 | closeZone 정리, BroadcastReceiver, isRunning flag |
| `android/.../MainActivity.kt` | M5 | isServiceRunning → companion flag |
| `test/.../favorite_phrases_provider_test.dart` | M1 | persistence 테스트 추가 |
| `test/.../copy_history_provider_test.dart` | M1 | persistence 테스트 추가 |
