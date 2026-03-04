# Phase 5.1 MEDIUM Issues Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** MEDIUM 리뷰 이슈 4건(M1/M3/M4/M5) 수정 + 테스트 보강

**Architecture:** M1은 Dart Provider merge 전략, M3/M4/M5는 Kotlin Service/Activity 수정. TDD로 Dart 테스트 먼저 작성.

**Tech Stack:** Flutter/Dart (Riverpod, SharedPreferences), Kotlin (Android Service, BroadcastReceiver)

---

### Task 1: M1 — FavoritePhrasesNotifier persistence 테스트 작성 (RED)

**Files:**
- Modify: `test/presentation/providers/favorite_phrases_provider_test.dart`

**Step 1: Write failing persistence test**

`test/presentation/providers/favorite_phrases_provider_test.dart`에 persistence 그룹 추가:

```dart
import 'dart:convert';

// ... 기존 import 유지

void main() {
  group('FavoritePhrasesNotifier', () {
    // ... 기존 테스트 유지 ...

    group('persistence', () {
      test('should load saved favorites on build', () async {
        SharedPreferences.setMockInitialValues({
          'favorite_phrases': jsonEncode(['사랑해요', '화이팅']),
        });
        final c = ProviderContainer();
        addTearDown(c.dispose);

        // listen()으로 auto-dispose 방지
        c.listen(favoritePhrasesNotifierProvider, (_, __) {});
        // microtask 대기 — async _loadFromPrefs 완료
        await Future<void>.delayed(Duration.zero);

        final favorites = c.read(favoritePhrasesNotifierProvider);
        expect(favorites, containsAll(['사랑해요', '화이팅']));
        expect(favorites, hasLength(2));
      });

      test('should merge loaded data with in-flight toggles', () async {
        SharedPreferences.setMockInitialValues({
          'favorite_phrases': jsonEncode(['사랑해요']),
        });
        final c = ProviderContainer();
        addTearDown(c.dispose);

        c.listen(favoritePhrasesNotifierProvider, (_, __) {});

        // 로드 완료 전에 toggle 호출
        final notifier = c.read(favoritePhrasesNotifierProvider.notifier);
        notifier.toggle('화이팅');

        // 로드 완료 대기
        await Future<void>.delayed(Duration.zero);

        final favorites = c.read(favoritePhrasesNotifierProvider);
        // 저장된 '사랑해요' + 새로 추가된 '화이팅' 모두 존재해야 함
        expect(favorites, containsAll(['사랑해요', '화이팅']));
      });
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/providers/favorite_phrases_provider_test.dart -v`
Expected: 두 번째 테스트('should merge loaded data with in-flight toggles') FAIL — `_loadFromPrefs`가 state를 교체하므로 '화이팅'이 유실됨

---

### Task 2: M1 — FavoritePhrasesNotifier merge 전략 구현 (GREEN)

**Files:**
- Modify: `lib/presentation/providers/favorite_phrases_provider.dart:37-44`

**Step 1: Fix _loadFromPrefs to merge**

```dart
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      final saved = (jsonDecode(json) as List).cast<String>().toSet();
      // merge: 저장된 데이터 + 로드 중 발생한 mutation 보존
      state = {...saved, ...state};
    }
  }
```

**Step 2: Run tests to verify all pass**

Run: `flutter test test/presentation/providers/favorite_phrases_provider_test.dart -v`
Expected: ALL PASS (기존 5 + 신규 2 = 7개)

**Step 3: Commit**

```
test: FavoritePhrasesNotifier persistence 테스트 추가
fix(M1): _loadFromPrefs merge 전략으로 race condition 해결
```

---

### Task 3: M1 — CopyHistoryNotifier persistence 테스트 작성 (RED)

**Files:**
- Modify: `test/presentation/providers/copy_history_provider_test.dart`

**Step 1: Write failing persistence test**

```dart
import 'dart:convert';

// ... 기존 import 유지

void main() {
  group('CopyHistoryNotifier', () {
    // ... 기존 테스트 유지 ...

    group('persistence', () {
      test('should load saved history on build', () async {
        SharedPreferences.setMockInitialValues({
          'copy_history': jsonEncode(['최근1', '최근2', '최근3']),
        });
        final c = ProviderContainer();
        addTearDown(c.dispose);

        c.listen(copyHistoryNotifierProvider, (_, __) {});
        await Future<void>.delayed(Duration.zero);

        final history = c.read(copyHistoryNotifierProvider);
        expect(history, ['최근1', '최근2', '최근3']);
      });

      test('should merge loaded data with in-flight entries', () async {
        SharedPreferences.setMockInitialValues({
          'copy_history': jsonEncode(['저장1', '저장2']),
        });
        final c = ProviderContainer();
        addTearDown(c.dispose);

        c.listen(copyHistoryNotifierProvider, (_, __) {});

        // 로드 완료 전에 addEntry 호출
        final notifier = c.read(copyHistoryNotifierProvider.notifier);
        notifier.addEntry('신규항목');

        // 로드 완료 대기
        await Future<void>.delayed(Duration.zero);

        final history = c.read(copyHistoryNotifierProvider);
        // 신규항목이 앞에, 저장된 항목이 뒤에 (중복 제거)
        expect(history.first, '신규항목');
        expect(history, contains('저장1'));
        expect(history, contains('저장2'));
      });
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/providers/copy_history_provider_test.dart -v`
Expected: merge 테스트 FAIL

---

### Task 4: M1 — CopyHistoryNotifier merge 전략 구현 (GREEN)

**Files:**
- Modify: `lib/presentation/providers/copy_history_provider.dart:48-55`

**Step 1: Fix _loadFromPrefs to merge**

```dart
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      final saved = (jsonDecode(json) as List).cast<String>();
      // merge: 현재 state(로드 중 추가된 항목)를 앞에, 저장 데이터를 뒤에
      // 중복 제거 + _maxEntries 제한
      final merged = [...state];
      for (final item in saved) {
        if (!merged.contains(item)) {
          merged.add(item);
        }
      }
      state = merged.length > _maxEntries
          ? merged.sublist(0, _maxEntries)
          : merged;
    }
  }
```

**Step 2: Run tests**

Run: `flutter test test/presentation/providers/copy_history_provider_test.dart -v`
Expected: ALL PASS (기존 6 + 신규 2 = 8개)

**Step 3: Commit**

```
test: CopyHistoryNotifier persistence 테스트 추가
fix(M1): _loadFromPrefs merge 전략으로 race condition 해결
```

---

### Task 5: M3+M4+M5 — Kotlin Service/Activity 수정

**Files:**
- Modify: `android/app/src/main/kotlin/com/tigerroom/fangeul/FloatingBubbleService.kt`
- Modify: `android/app/src/main/kotlin/com/tigerroom/fangeul/MainActivity.kt`

**Step 1: M5 — FloatingBubbleService companion에 isRunning 플래그 추가**

`FloatingBubbleService.kt` companion object에 추가:

```kotlin
companion object {
    const val ACTION_STOP = "com.tigerroom.fangeul.STOP_BUBBLE"
    const val ACTION_SHOW = "com.tigerroom.fangeul.SHOW_BUBBLE"
    const val ACTION_HIDE = "com.tigerroom.fangeul.HIDE_BUBBLE"

    private const val BUBBLE_SIZE_DP = 56
    private const val CLOSE_ZONE_SIZE_DP = 56
    private const val CLOSE_ZONE_MARGIN_BOTTOM_DP = 80
    private const val TAP_THRESHOLD_PX = 10

    /// 버블 서비스 실행 상태. MainActivity에서 참조.
    var isRunning: Boolean = false
        private set
}
```

`onStartCommand`에서 ACTION_SHOW 경로(bubbleView 생성 직후)에 `isRunning = true` 설정.
`onDestroy()`에서 `isRunning = false` 설정.
`ACTION_HIDE`에서 `isRunning = false` 설정 (버블 숨김 = off 상태).

**Step 2: M3 — ACTION_HIDE에서 removeCloseZone() 추가**

```kotlin
ACTION_HIDE -> {
    removeBubble()
    removeCloseZone()  // M3: 오버레이 리크 수정
    isRunning = false   // M5
    BubbleEventBroadcaster.send("off")
    return START_STICKY
}
```

**Step 3: M4 — BroadcastReceiver 등록**

import 추가:
```kotlin
import android.content.BroadcastReceiver
import android.content.Context
import android.content.IntentFilter
```

필드 추가:
```kotlin
private var configReceiver: BroadcastReceiver? = null
```

`onCreate()`에 등록:
```kotlin
override fun onCreate() {
    super.onCreate()
    windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    updateScreenSize()
    registerConfigReceiver()
}

private fun registerConfigReceiver() {
    configReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val oldWidth = screenWidth
            updateScreenSize()
            if (oldWidth != screenWidth) {
                snapToEdge()
            }
        }
    }
    registerReceiver(
        configReceiver,
        IntentFilter(Intent.ACTION_CONFIGURATION_CHANGED),
    )
}
```

`onDestroy()`에 해제:
```kotlin
override fun onDestroy() {
    configReceiver?.let { unregisterReceiver(it) }
    configReceiver = null
    isRunning = false  // M5
    removeBubble()
    removeCloseZone()
    BubbleEventBroadcaster.send("off")
    super.onDestroy()
}
```

**Step 4: M5 — MainActivity isServiceRunning() 교체**

`MainActivity.kt`에서:

```kotlin
// 삭제: import android.app.ActivityManager

/// FloatingBubbleService 실행 여부 확인.
private fun isServiceRunning(): Boolean = FloatingBubbleService.isRunning
```

**Step 5: Commit**

```
fix(M3): ACTION_HIDE에서 removeCloseZone() 호출 — 오버레이 리크 수정
fix(M4): BroadcastReceiver로 화면 회전 시 bubble 위치 재조정
fix(M5): getRunningServices() → companion object 플래그로 교체
```

---

### Task 6: 전체 검증

**Step 1: 전체 테스트 실행**

Run: `flutter test`
Expected: 217+ tests PASS (기존 215 + persistence 테스트 추가분)

**Step 2: 정적 분석**

Run: `flutter analyze`
Expected: No issues found

**Step 3: 포맷 검증**

Run: `dart format --set-exit-if-changed .`
Expected: No changed files

---

## 수정 요약

| 이슈 | Task | 파일 | 변경 |
|------|------|------|------|
| M1 | 1-4 | favorite_phrases_provider, copy_history_provider + 테스트 | merge 전략 + persistence 테스트 |
| M3 | 5 | FloatingBubbleService.kt | `removeCloseZone()` 1줄 추가 |
| M4 | 5 | FloatingBubbleService.kt | BroadcastReceiver 등록/해제 + snapToEdge |
| M5 | 5 | FloatingBubbleService.kt, MainActivity.kt | companion `isRunning` 플래그 |
