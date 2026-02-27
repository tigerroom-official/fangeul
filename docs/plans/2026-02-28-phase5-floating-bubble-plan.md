# Phase 5: Floating Bubble — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement the floating bubble overlay — Fangeul's core differentiator that lets K-pop fans use Korean conversion tools directly over other apps (Weverse, Twitter, YouTube).

**Architecture:** Hybrid approach — native Kotlin overlay for the bubble (lightweight, stable), Flutter Activity for the popup (reuses existing UI/theme/keyboard). FlutterEngineCache prewarms engine for ~200ms popup startup.

**Tech Stack:** Kotlin (Foreground Service, WindowManager), Flutter (MethodChannel, EventChannel, Riverpod), shared_preferences for persistence.

**Design Document:** `docs/plans/2026-02-28-phase5-floating-bubble-design.md`

---

## Task 1: Android Manifest + TranslucentTheme

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `android/app/src/main/res/values/styles.xml`

**Step 1: Add TranslucentTheme to styles.xml**

Read `android/app/src/main/res/values/styles.xml` and add:

```xml
<style name="TranslucentTheme" parent="Theme.MaterialComponents.DayNight.NoActionBar">
    <item name="android:windowIsTranslucent">true</item>
    <item name="android:windowBackground">@android:color/transparent</item>
    <item name="android:windowNoTitle">true</item>
    <item name="android:backgroundDimEnabled">true</item>
</style>
```

**Step 2: Update AndroidManifest.xml**

Add after existing `<uses-permission>` lines:

```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE"/>
```

Add inside `<application>`, after `</activity>` (MainActivity) and before the `<!-- Don't delete -->` meta-data:

```xml
<service
    android:name=".FloatingBubbleService"
    android:exported="false"
    android:foregroundServiceType="specialUse">
    <property
        android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
        android:value="floating_overlay_for_korean_input"/>
</service>

<activity
    android:name=".MiniConverterActivity"
    android:exported="false"
    android:theme="@style/TranslucentTheme"
    android:launchMode="singleTask"
    android:taskAffinity="com.tigerroom.fangeul.mini"/>
```

**Step 3: Verify build compiles**

Run: `cd android && ./gradlew assembleDebug 2>&1 | tail -5`
Expected: `BUILD SUCCESSFUL`

**Step 4: Commit**

```bash
git add android/app/src/main/AndroidManifest.xml android/app/src/main/res/values/styles.xml
git commit -m "feat(bubble): AndroidManifest + TranslucentTheme 설정"
```

---

## Task 2: BubbleNotificationHelper.kt

**Files:**
- Create: `android/app/src/main/kotlin/com/tigerroom/fangeul/BubbleNotificationHelper.kt`

**Step 1: Write BubbleNotificationHelper**

```kotlin
package com.tigerroom.fangeul

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

/// 버블 Foreground Service 알림 채널/빌더 유틸.
object BubbleNotificationHelper {

    private const val CHANNEL_ID = "fangeul_bubble_channel"
    private const val CHANNEL_NAME = "Fangeul Bubble"
    const val NOTIFICATION_ID = 1001

    /// 알림 채널 생성 (Android 8.0+).
    fun createChannel(context: Context) {
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Fangeul 플로팅 버블 서비스"
            setShowBadge(false)
        }
        val manager = context.getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }

    /// Foreground Service용 알림 빌드.
    fun buildNotification(context: Context): Notification {
        val stopIntent = Intent(context, FloatingBubbleService::class.java).apply {
            action = FloatingBubbleService.ACTION_STOP
        }
        val stopPending = PendingIntent.getService(
            context, 0, stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openPending = PendingIntent.getActivity(
            context, 0, openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(context, CHANNEL_ID)
            .setContentTitle("Fangeul 버블 활성")
            .setContentText("다른 앱 위에서 한글 변환을 사용할 수 있습니다")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(openPending)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "중지", stopPending)
            .setOngoing(true)
            .setSilent(true)
            .build()
    }
}
```

**Step 2: Verify build**

Run: `cd android && ./gradlew assembleDebug 2>&1 | tail -5`
Expected: `BUILD SUCCESSFUL`

**Step 3: Commit**

```bash
git add android/app/src/main/kotlin/com/tigerroom/fangeul/BubbleNotificationHelper.kt
git commit -m "feat(bubble): BubbleNotificationHelper — 알림 채널/빌더"
```

---

## Task 3: FloatingBubbleService.kt — Core Service

**Files:**
- Create: `android/app/src/main/kotlin/com/tigerroom/fangeul/FloatingBubbleService.kt`

**Step 1: Write FloatingBubbleService**

이 파일은 Phase 5에서 가장 핵심적인 Kotlin 파일. 버블 오버레이, 드래그, 닫기 존, 탭 처리를 모두 담당한다.

```kotlin
package com.tigerroom.fangeul

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.graphics.drawable.GradientDrawable
import android.os.IBinder
import android.util.TypedValue
import android.view.*
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import kotlin.math.abs

/// 플로팅 버블 Foreground Service.
///
/// WindowManager 오버레이로 버블을 표시하고,
/// 드래그/스냅/닫기 존/탭 동작을 처리한다.
class FloatingBubbleService : Service() {

    companion object {
        const val ACTION_STOP = "com.tigerroom.fangeul.STOP_BUBBLE"
        const val ACTION_SHOW = "com.tigerroom.fangeul.SHOW_BUBBLE"
        const val ACTION_HIDE = "com.tigerroom.fangeul.HIDE_BUBBLE"

        private const val BUBBLE_SIZE_DP = 56
        private const val SNAP_VELOCITY_THRESHOLD = 200
        private const val CLOSE_ZONE_SIZE_DP = 56
        private const val CLOSE_ZONE_MARGIN_BOTTOM_DP = 80
        private const val TAP_THRESHOLD_PX = 10
    }

    private lateinit var windowManager: WindowManager
    private var bubbleView: View? = null
    private var closeZoneView: View? = null
    private var bubbleParams: WindowManager.LayoutParams? = null
    private var closeZoneParams: WindowManager.LayoutParams? = null

    // 드래그 상태
    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f
    private var isDragging = false
    private var isInCloseZone = false

    // 화면 크기
    private var screenWidth = 0
    private var screenHeight = 0

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        updateScreenSize()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_HIDE -> {
                removeBubble()
                return START_STICKY
            }
        }

        BubbleNotificationHelper.createChannel(this)
        startForeground(
            BubbleNotificationHelper.NOTIFICATION_ID,
            BubbleNotificationHelper.buildNotification(this)
        )

        if (bubbleView == null) {
            createBubbleView()
            createCloseZoneView()
        }

        return START_STICKY
    }

    override fun onDestroy() {
        removeBubble()
        removeCloseZone()
        super.onDestroy()
    }

    // ── 버블 뷰 생성 ──

    private fun createBubbleView() {
        val sizePx = dpToPx(BUBBLE_SIZE_DP)

        // 버블 컨테이너
        val container = FrameLayout(this)

        // 틸 그라데이션 원형 배경
        val bgDrawable = GradientDrawable(
            GradientDrawable.Orientation.TL_BR,
            intArrayOf(0xFF4ECDC4.toInt(), 0xFF3BA8A0.toInt())
        ).apply {
            shape = GradientDrawable.OVAL
            setSize(sizePx, sizePx)
        }
        container.background = bgDrawable
        container.elevation = dpToPx(4).toFloat()

        // "한" 글자
        val textView = TextView(this).apply {
            text = "한"
            setTextColor(Color.WHITE)
            textSize = 22f
            typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
            gravity = Gravity.CENTER
        }
        container.addView(textView, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))

        // 윈도우 파라미터
        val params = WindowManager.LayoutParams(
            sizePx, sizePx,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = screenWidth - sizePx - dpToPx(8)  // 오른쪽 가장자리 기본
            y = screenHeight / 3
        }

        // 터치 리스너
        container.setOnTouchListener(BubbleTouchListener())

        windowManager.addView(container, params)
        bubbleView = container
        bubbleParams = params
    }

    // ── 닫기 존 ──

    private fun createCloseZoneView() {
        val sizePx = dpToPx(CLOSE_ZONE_SIZE_DP)

        val view = FrameLayout(this).apply {
            val bg = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(0xFFFF4444.toInt())
                setSize(sizePx, sizePx)
            }
            background = bg
            alpha = 0f
            visibility = View.GONE

            val icon = TextView(this@FloatingBubbleService).apply {
                text = "\u2715"  // ✕
                setTextColor(Color.WHITE)
                textSize = 20f
                gravity = Gravity.CENTER
            }
            addView(icon, FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            ))
        }

        val params = WindowManager.LayoutParams(
            sizePx, sizePx,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            y = dpToPx(CLOSE_ZONE_MARGIN_BOTTOM_DP)
        }

        windowManager.addView(view, params)
        closeZoneView = view
        closeZoneParams = params
    }

    private fun showCloseZone() {
        closeZoneView?.apply {
            visibility = View.VISIBLE
            animate().alpha(1f).setDuration(200).start()
        }
    }

    private fun hideCloseZone() {
        closeZoneView?.apply {
            animate().alpha(0f).setDuration(150).withEndAction {
                visibility = View.GONE
            }.start()
        }
    }

    // ── 터치 리스너 ──

    private inner class BubbleTouchListener : View.OnTouchListener {
        override fun onTouch(v: View, event: MotionEvent): Boolean {
            val params = bubbleParams ?: return false

            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    isDragging = false
                    return true
                }

                MotionEvent.ACTION_MOVE -> {
                    val dx = event.rawX - initialTouchX
                    val dy = event.rawY - initialTouchY

                    if (!isDragging && (abs(dx) > TAP_THRESHOLD_PX || abs(dy) > TAP_THRESHOLD_PX)) {
                        isDragging = true
                        showCloseZone()
                    }

                    if (isDragging) {
                        params.x = (initialX + dx).toInt()
                        params.y = (initialY + dy).toInt()
                        windowManager.updateViewLayout(bubbleView, params)

                        // 닫기 존 히트 체크
                        val bubbleCenterX = params.x + dpToPx(BUBBLE_SIZE_DP) / 2
                        val bubbleCenterY = params.y + dpToPx(BUBBLE_SIZE_DP) / 2
                        val closeY = screenHeight - dpToPx(CLOSE_ZONE_MARGIN_BOTTOM_DP) - dpToPx(CLOSE_ZONE_SIZE_DP) / 2
                        val closeDist = abs(bubbleCenterX - screenWidth / 2) + abs(bubbleCenterY - closeY)
                        isInCloseZone = closeDist < dpToPx(80)

                        closeZoneView?.apply {
                            scaleX = if (isInCloseZone) 1.3f else 1f
                            scaleY = if (isInCloseZone) 1.3f else 1f
                        }
                    }
                    return true
                }

                MotionEvent.ACTION_UP -> {
                    hideCloseZone()

                    if (isInCloseZone) {
                        // 닫기 존에서 드롭 → 서비스 종료
                        stopSelf()
                        return true
                    }

                    if (!isDragging) {
                        // 탭 → 팝업 열기
                        onBubbleTapped()
                    } else {
                        // 드래그 종료 → 가장자리 스냅
                        snapToEdge()
                    }
                    return true
                }
            }
            return false
        }
    }

    // ── 가장자리 스냅 ──

    private fun snapToEdge() {
        val params = bubbleParams ?: return
        val bubbleCenterX = params.x + dpToPx(BUBBLE_SIZE_DP) / 2
        val targetX = if (bubbleCenterX < screenWidth / 2) {
            dpToPx(8) // 왼쪽 스냅
        } else {
            screenWidth - dpToPx(BUBBLE_SIZE_DP) - dpToPx(8) // 오른쪽 스냅
        }

        // 애니메이션 스냅
        val startX = params.x
        val animator = android.animation.ValueAnimator.ofInt(startX, targetX)
        animator.duration = 200
        animator.addUpdateListener { anim ->
            params.x = anim.animatedValue as Int
            try {
                windowManager.updateViewLayout(bubbleView, params)
            } catch (_: Exception) {
                // View already removed
            }
        }
        animator.start()
    }

    // ── 버블 탭 → 팝업 ──

    private fun onBubbleTapped() {
        val intent = Intent(this, MiniConverterActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    // ── 정리 ──

    private fun removeBubble() {
        bubbleView?.let {
            try { windowManager.removeView(it) } catch (_: Exception) {}
            bubbleView = null
        }
    }

    private fun removeCloseZone() {
        closeZoneView?.let {
            try { windowManager.removeView(it) } catch (_: Exception) {}
            closeZoneView = null
        }
    }

    // ── 유틸 ──

    private fun dpToPx(dp: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP, dp.toFloat(),
            resources.displayMetrics
        ).toInt()
    }

    private fun updateScreenSize() {
        val metrics = resources.displayMetrics
        screenWidth = metrics.widthPixels
        screenHeight = metrics.heightPixels
    }
}
```

**Step 2: Verify build**

Run: `cd android && ./gradlew assembleDebug 2>&1 | tail -5`
Expected: `BUILD SUCCESSFUL`

**Step 3: Commit**

```bash
git add android/app/src/main/kotlin/com/tigerroom/fangeul/FloatingBubbleService.kt
git commit -m "feat(bubble): FloatingBubbleService — 오버레이, 드래그, 스냅, 닫기 존"
```

---

## Task 4: MiniConverterActivity.kt

**Files:**
- Create: `android/app/src/main/kotlin/com/tigerroom/fangeul/MiniConverterActivity.kt`

**Step 1: Write MiniConverterActivity**

```kotlin
package com.tigerroom.fangeul

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

/// 미니 변환기 Flutter Activity.
///
/// FloatingBubbleService에서 버블 탭 시 실행.
/// 캐시된 FlutterEngine을 사용하여 ~200ms 시작.
/// 투명 테마 + singleTask로 구성.
class MiniConverterActivity : FlutterActivity() {

    companion object {
        const val ENGINE_ID = "fangeul_mini_engine"
    }

    override fun provideFlutterEngine(context: android.content.Context): FlutterEngine? {
        return FlutterEngineCache.getInstance().get(ENGINE_ID)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // 엔진은 이미 프리워밍됨. 추가 설정 불필요.
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false
}
```

**Step 2: Verify build**

Run: `cd android && ./gradlew assembleDebug 2>&1 | tail -5`
Expected: `BUILD SUCCESSFUL`

**Step 3: Commit**

```bash
git add android/app/src/main/kotlin/com/tigerroom/fangeul/MiniConverterActivity.kt
git commit -m "feat(bubble): MiniConverterActivity — 캐시 엔진 Flutter Activity"
```

---

## Task 5: MainActivity.kt — FlutterEngine 프리워밍 + MethodChannel

**Files:**
- Modify: `android/app/src/main/kotlin/com/tigerroom/fangeul/MainActivity.kt`

**Step 1: Rewrite MainActivity**

기존 `MainActivity.kt`는 한 줄짜리 빈 FlutterActivity. 여기에 FlutterEngine 프리워밍과 MethodChannel 핸들러를 추가한다.

```kotlin
package com.tigerroom.fangeul

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/// 메인 Activity — FlutterEngine 프리워밍 + Platform Channel 핸들러.
class MainActivity : FlutterActivity() {

    companion object {
        private const val BUBBLE_CHANNEL = "com.tigerroom.fangeul/floating_bubble"
        private const val OVERLAY_PERMISSION_REQUEST = 1001
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        prewarmMiniEngine()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BUBBLE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "showBubble" -> {
                        if (!Settings.canDrawOverlays(this)) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        val intent = Intent(this, FloatingBubbleService::class.java).apply {
                            action = FloatingBubbleService.ACTION_SHOW
                        }
                        startForegroundService(intent)
                        result.success(true)
                    }

                    "hideBubble" -> {
                        val intent = Intent(this, FloatingBubbleService::class.java).apply {
                            action = FloatingBubbleService.ACTION_STOP
                        }
                        stopService(intent)
                        result.success(true)
                    }

                    "isOverlayPermissionGranted" -> {
                        result.success(Settings.canDrawOverlays(this))
                    }

                    "requestOverlayPermission" -> {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivityForResult(intent, OVERLAY_PERMISSION_REQUEST)
                        result.success(null)
                    }

                    "getBubbleState" -> {
                        // 간단한 상태 반환: 서비스 실행 여부로 판단
                        result.success(if (isServiceRunning()) "showing" else "off")
                    }

                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == OVERLAY_PERMISSION_REQUEST) {
            // 권한 결과를 Flutter에 알림 (EventChannel 또는 다음 isOverlayPermissionGranted 호출로 확인)
        }
    }

    /// MiniConverterActivity용 FlutterEngine 프리워밍.
    private fun prewarmMiniEngine() {
        if (FlutterEngineCache.getInstance().get(MiniConverterActivity.ENGINE_ID) != null) {
            return
        }

        val engine = FlutterEngine(this).apply {
            // 초기 라우트를 미니 변환기로 지정
            navigationChannel.setInitialRoute("/mini-converter")
            dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        }

        FlutterEngineCache.getInstance().put(MiniConverterActivity.ENGINE_ID, engine)
    }

    /// FloatingBubbleService 실행 여부 확인.
    private fun isServiceRunning(): Boolean {
        val manager = getSystemService(ACTIVITY_SERVICE) as android.app.ActivityManager
        @Suppress("DEPRECATION")
        return manager.getRunningServices(Int.MAX_VALUE)
            .any { it.service.className == FloatingBubbleService::class.java.name }
    }
}
```

**Step 2: Verify build**

Run: `cd android && ./gradlew assembleDebug 2>&1 | tail -5`
Expected: `BUILD SUCCESSFUL`

**Step 3: Commit**

```bash
git add android/app/src/main/kotlin/com/tigerroom/fangeul/MainActivity.kt
git commit -m "feat(bubble): MainActivity — FlutterEngine 프리워밍 + MethodChannel"
```

---

## Task 6: bubble_state.dart — BubbleState enum (TDD)

**Files:**
- Create: `lib/platform/bubble_state.dart`
- Create: `test/platform/bubble_state_test.dart`

**Step 1: Write the failing test**

```dart
// test/platform/bubble_state_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/platform/bubble_state.dart';

void main() {
  group('BubbleState', () {
    test('should have exactly 3 values', () {
      expect(BubbleState.values, hasLength(3));
    });

    test('should include off, showing, popup', () {
      expect(BubbleState.values, contains(BubbleState.off));
      expect(BubbleState.values, contains(BubbleState.showing));
      expect(BubbleState.values, contains(BubbleState.popup));
    });

    test('should parse from string correctly', () {
      expect(BubbleState.fromString('off'), BubbleState.off);
      expect(BubbleState.fromString('showing'), BubbleState.showing);
      expect(BubbleState.fromString('popup'), BubbleState.popup);
    });

    test('should return off for unknown string', () {
      expect(BubbleState.fromString('unknown'), BubbleState.off);
      expect(BubbleState.fromString(''), BubbleState.off);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/platform/bubble_state_test.dart`
Expected: FAIL — file not found

**Step 3: Write implementation**

```dart
// lib/platform/bubble_state.dart

/// 플로팅 버블 상태.
///
/// Kotlin FloatingBubbleService의 상태를 Dart에서 표현한다.
enum BubbleState {
  /// 버블 비활성
  off,

  /// 버블 화면에 표시 중
  showing,

  /// 팝업(MiniConverter) 열려있음
  popup;

  /// 문자열에서 [BubbleState]로 변환.
  ///
  /// Kotlin MethodChannel에서 전달되는 문자열을 파싱한다.
  /// 알 수 없는 값은 [BubbleState.off]로 기본 처리.
  static BubbleState fromString(String value) {
    return BubbleState.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BubbleState.off,
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/platform/bubble_state_test.dart`
Expected: All tests pass

**Step 5: Commit**

```bash
git add lib/platform/bubble_state.dart test/platform/bubble_state_test.dart
git commit -m "feat(bubble): BubbleState enum — off/showing/popup (TDD)"
```

---

## Task 7: floating_bubble_channel.dart — MethodChannel 래퍼 (TDD)

**Files:**
- Create: `lib/platform/floating_bubble_channel.dart`
- Create: `test/platform/floating_bubble_channel_test.dart`

**Step 1: Write the failing test**

```dart
// test/platform/floating_bubble_channel_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/platform/bubble_state.dart';
import 'package:fangeul/platform/floating_bubble_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FloatingBubbleChannel channel;
  late List<MethodCall> log;

  setUp(() {
    log = [];
    channel = FloatingBubbleChannel();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.tigerroom.fangeul/floating_bubble'),
      (call) async {
        log.add(call);
        switch (call.method) {
          case 'showBubble':
            return true;
          case 'hideBubble':
            return true;
          case 'isOverlayPermissionGranted':
            return true;
          case 'requestOverlayPermission':
            return null;
          case 'getBubbleState':
            return 'showing';
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.tigerroom.fangeul/floating_bubble'),
      null,
    );
  });

  group('FloatingBubbleChannel', () {
    test('showBubble should invoke native method and return result', () async {
      final result = await channel.showBubble();
      expect(result, isTrue);
      expect(log.last.method, 'showBubble');
    });

    test('hideBubble should invoke native method and return result', () async {
      final result = await channel.hideBubble();
      expect(result, isTrue);
      expect(log.last.method, 'hideBubble');
    });

    test('isOverlayPermissionGranted should return bool', () async {
      final result = await channel.isOverlayPermissionGranted();
      expect(result, isTrue);
      expect(log.last.method, 'isOverlayPermissionGranted');
    });

    test('requestOverlayPermission should invoke native method', () async {
      await channel.requestOverlayPermission();
      expect(log.last.method, 'requestOverlayPermission');
    });

    test('getBubbleState should parse response to BubbleState', () async {
      final result = await channel.getBubbleState();
      expect(result, BubbleState.showing);
      expect(log.last.method, 'getBubbleState');
    });

    test('should handle PlatformException gracefully', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.tigerroom.fangeul/floating_bubble'),
        (call) async {
          throw PlatformException(code: 'ERROR', message: 'test');
        },
      );

      final result = await channel.showBubble();
      expect(result, isFalse);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/platform/floating_bubble_channel_test.dart`
Expected: FAIL — file not found

**Step 3: Write implementation**

```dart
// lib/platform/floating_bubble_channel.dart
import 'package:flutter/services.dart';

import 'package:fangeul/platform/bubble_state.dart';

/// 플로팅 버블 Platform Channel 래퍼.
///
/// Kotlin FloatingBubbleService와 MethodChannel로 통신한다.
/// 모든 메서드는 PlatformException을 안전하게 처리한다.
class FloatingBubbleChannel {
  static const _channel = MethodChannel(
    'com.tigerroom.fangeul/floating_bubble',
  );

  /// 버블을 화면에 표시한다.
  ///
  /// 오버레이 권한이 없으면 `false` 반환.
  Future<bool> showBubble() async {
    try {
      final result = await _channel.invokeMethod<bool>('showBubble');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 버블을 화면에서 숨기고 서비스를 중지한다.
  Future<bool> hideBubble() async {
    try {
      final result = await _channel.invokeMethod<bool>('hideBubble');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 오버레이 권한 부여 여부를 확인한다.
  Future<bool> isOverlayPermissionGranted() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isOverlayPermissionGranted',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 시스템 오버레이 권한 설정 화면을 연다.
  Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod<void>('requestOverlayPermission');
    } on PlatformException {
      // 무시 — 설정 화면 열기 실패 시 사용자에게 수동 안내
    }
  }

  /// 현재 버블 상태를 조회한다.
  Future<BubbleState> getBubbleState() async {
    try {
      final result = await _channel.invokeMethod<String>('getBubbleState');
      return BubbleState.fromString(result ?? 'off');
    } on PlatformException {
      return BubbleState.off;
    }
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/platform/floating_bubble_channel_test.dart`
Expected: All tests pass

**Step 5: Commit**

```bash
git add lib/platform/floating_bubble_channel.dart test/platform/floating_bubble_channel_test.dart
git commit -m "feat(bubble): FloatingBubbleChannel — MethodChannel 래퍼 (TDD)"
```

---

## Task 8: copy_history_provider.dart (TDD)

**Files:**
- Create: `lib/presentation/providers/copy_history_provider.dart`
- Create: `test/presentation/providers/copy_history_provider_test.dart`

**Step 1: Write the failing test**

```dart
// test/presentation/providers/copy_history_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/copy_history_provider.dart';

void main() {
  group('CopyHistoryNotifier', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should start with empty list', () {
      final history = container.read(copyHistoryNotifierProvider);
      expect(history, isEmpty);
    });

    test('should add entry to front of list', () {
      final notifier = container.read(copyHistoryNotifierProvider.notifier);
      notifier.addEntry('사랑해요');
      notifier.addEntry('화이팅');

      final history = container.read(copyHistoryNotifierProvider);
      expect(history.first, '화이팅');
      expect(history[1], '사랑해요');
    });

    test('should not add duplicate consecutive entries', () {
      final notifier = container.read(copyHistoryNotifierProvider.notifier);
      notifier.addEntry('사랑해요');
      notifier.addEntry('사랑해요');

      final history = container.read(copyHistoryNotifierProvider);
      expect(history, hasLength(1));
    });

    test('should move existing entry to front on re-add', () {
      final notifier = container.read(copyHistoryNotifierProvider.notifier);
      notifier.addEntry('첫번째');
      notifier.addEntry('두번째');
      notifier.addEntry('첫번째'); // 다시 추가

      final history = container.read(copyHistoryNotifierProvider);
      expect(history.first, '첫번째');
      expect(history, hasLength(2));
    });

    test('should limit to 20 entries', () {
      final notifier = container.read(copyHistoryNotifierProvider.notifier);
      for (var i = 0; i < 25; i++) {
        notifier.addEntry('항목 $i');
      }

      final history = container.read(copyHistoryNotifierProvider);
      expect(history, hasLength(20));
      expect(history.first, '항목 24');
    });

    test('should clear all entries', () {
      final notifier = container.read(copyHistoryNotifierProvider.notifier);
      notifier.addEntry('사랑해요');
      notifier.addEntry('화이팅');
      notifier.clearAll();

      final history = container.read(copyHistoryNotifierProvider);
      expect(history, isEmpty);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/providers/copy_history_provider_test.dart`
Expected: FAIL — file not found

**Step 3: Write implementation**

```dart
// lib/presentation/providers/copy_history_provider.dart
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'copy_history_provider.g.dart';

/// 복사 이력 Provider.
///
/// 최근 복사한 텍스트를 시간순(최신 우선)으로 관리한다.
/// 최대 20개까지 유지하며, shared_preferences에 persist.
@riverpod
class CopyHistoryNotifier extends _$CopyHistoryNotifier {
  static const _key = 'copy_history';
  static const _maxEntries = 20;

  @override
  List<String> build() {
    _loadFromPrefs();
    return [];
  }

  /// 새 항목을 이력 앞에 추가한다.
  ///
  /// 이미 존재하는 항목이면 앞으로 이동.
  /// 최대 [_maxEntries]개 유지.
  void addEntry(String text) {
    if (text.isEmpty) return;

    final current = [...state];
    current.remove(text); // 기존 위치에서 제거 (중복 방지)
    current.insert(0, text); // 맨 앞에 추가

    if (current.length > _maxEntries) {
      state = current.sublist(0, _maxEntries);
    } else {
      state = current;
    }
    _saveToPrefs();
  }

  /// 모든 이력을 삭제한다.
  void clearAll() {
    state = [];
    _saveToPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      final list = (jsonDecode(json) as List).cast<String>();
      state = list;
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }
}
```

**Step 4: Run build_runner for this file**

Run: `dart run build_runner build --delete-conflicting-outputs --build-filter="lib/presentation/providers/copy_history_provider.dart"`

**Step 5: Run test to verify it passes**

Run: `flutter test test/presentation/providers/copy_history_provider_test.dart`
Expected: All tests pass

**Step 6: Commit**

```bash
git add lib/presentation/providers/copy_history_provider.dart lib/presentation/providers/copy_history_provider.g.dart test/presentation/providers/copy_history_provider_test.dart
git commit -m "feat(bubble): CopyHistoryNotifier — 복사 이력 20개 제한 (TDD)"
```

---

## Task 9: favorite_phrases_provider.dart (TDD)

**Files:**
- Create: `lib/presentation/providers/favorite_phrases_provider.dart`
- Create: `test/presentation/providers/favorite_phrases_provider_test.dart`

**Step 1: Write the failing test**

```dart
// test/presentation/providers/favorite_phrases_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';

void main() {
  group('FavoritePhrasesNotifier', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should start with empty set', () {
      final favorites = container.read(favoritePhrasesNotifierProvider);
      expect(favorites, isEmpty);
    });

    test('should add phrase to favorites', () {
      final notifier = container.read(favoritePhrasesNotifierProvider.notifier);
      notifier.toggle('사랑해요');

      final favorites = container.read(favoritePhrasesNotifierProvider);
      expect(favorites, contains('사랑해요'));
    });

    test('should remove phrase when toggled again', () {
      final notifier = container.read(favoritePhrasesNotifierProvider.notifier);
      notifier.toggle('사랑해요');
      notifier.toggle('사랑해요');

      final favorites = container.read(favoritePhrasesNotifierProvider);
      expect(favorites, isEmpty);
    });

    test('should report isFavorite correctly', () {
      final notifier = container.read(favoritePhrasesNotifierProvider.notifier);
      notifier.toggle('사랑해요');

      expect(notifier.isFavorite('사랑해요'), isTrue);
      expect(notifier.isFavorite('화이팅'), isFalse);
    });

    test('should manage multiple favorites', () {
      final notifier = container.read(favoritePhrasesNotifierProvider.notifier);
      notifier.toggle('사랑해요');
      notifier.toggle('화이팅');
      notifier.toggle('보고싶어');

      final favorites = container.read(favoritePhrasesNotifierProvider);
      expect(favorites, hasLength(3));
      expect(favorites, containsAll(['사랑해요', '화이팅', '보고싶어']));
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/providers/favorite_phrases_provider_test.dart`
Expected: FAIL — file not found

**Step 3: Write implementation**

```dart
// lib/presentation/providers/favorite_phrases_provider.dart
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'favorite_phrases_provider.g.dart';

/// 즐겨찾기 문구 Provider.
///
/// 사용자가 ⭐ 탭한 문구의 한글(ko)을 Set으로 관리한다.
/// shared_preferences에 persist.
@riverpod
class FavoritePhrasesNotifier extends _$FavoritePhrasesNotifier {
  static const _key = 'favorite_phrases';

  @override
  Set<String> build() {
    _loadFromPrefs();
    return {};
  }

  /// 즐겨찾기 토글 — 있으면 제거, 없으면 추가.
  void toggle(String phraseKo) {
    final current = {...state};
    if (current.contains(phraseKo)) {
      current.remove(phraseKo);
    } else {
      current.add(phraseKo);
    }
    state = current;
    _saveToPrefs();
  }

  /// 즐겨찾기 여부 확인.
  bool isFavorite(String phraseKo) => state.contains(phraseKo);

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      final list = (jsonDecode(json) as List).cast<String>();
      state = list.toSet();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toList()));
  }
}
```

**Step 4: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs --build-filter="lib/presentation/providers/favorite_phrases_provider.dart"`

**Step 5: Run test to verify it passes**

Run: `flutter test test/presentation/providers/favorite_phrases_provider_test.dart`
Expected: All tests pass

**Step 6: Commit**

```bash
git add lib/presentation/providers/favorite_phrases_provider.dart lib/presentation/providers/favorite_phrases_provider.g.dart test/presentation/providers/favorite_phrases_provider_test.dart
git commit -m "feat(bubble): FavoritePhrasesNotifier — 즐겨찾기 토글/persist (TDD)"
```

---

## Task 10: bubble_providers.dart — 버블 상태 Provider (TDD)

**Files:**
- Create: `lib/presentation/providers/bubble_providers.dart`
- Create: `test/presentation/providers/bubble_providers_test.dart`

**Step 1: Write the failing test**

```dart
// test/presentation/providers/bubble_providers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/platform/bubble_state.dart';
import 'package:fangeul/platform/floating_bubble_channel.dart';
import 'package:fangeul/presentation/providers/bubble_providers.dart';

class MockFloatingBubbleChannel extends Mock
    implements FloatingBubbleChannel {}

void main() {
  group('BubbleNotifier', () {
    late MockFloatingBubbleChannel mockChannel;
    late ProviderContainer container;

    setUp(() {
      mockChannel = MockFloatingBubbleChannel();
      container = ProviderContainer(
        overrides: [
          floatingBubbleChannelProvider.overrideWithValue(mockChannel),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('should start with BubbleState.off', () {
      final state = container.read(bubbleNotifierProvider);
      expect(state, BubbleState.off);
    });

    test('should transition to showing when showBubble succeeds', () async {
      when(() => mockChannel.showBubble()).thenAnswer((_) async => true);

      await container.read(bubbleNotifierProvider.notifier).show();

      expect(container.read(bubbleNotifierProvider), BubbleState.showing);
    });

    test('should stay off when showBubble fails', () async {
      when(() => mockChannel.showBubble()).thenAnswer((_) async => false);

      await container.read(bubbleNotifierProvider.notifier).show();

      expect(container.read(bubbleNotifierProvider), BubbleState.off);
    });

    test('should transition to off when hideBubble called', () async {
      when(() => mockChannel.showBubble()).thenAnswer((_) async => true);
      when(() => mockChannel.hideBubble()).thenAnswer((_) async => true);

      await container.read(bubbleNotifierProvider.notifier).show();
      await container.read(bubbleNotifierProvider.notifier).hide();

      expect(container.read(bubbleNotifierProvider), BubbleState.off);
    });

    test('should check permission', () async {
      when(() => mockChannel.isOverlayPermissionGranted())
          .thenAnswer((_) async => true);

      final result = await container
          .read(bubbleNotifierProvider.notifier)
          .checkPermission();

      expect(result, isTrue);
    });

    test('should request permission', () async {
      when(() => mockChannel.requestOverlayPermission())
          .thenAnswer((_) async {});

      await container
          .read(bubbleNotifierProvider.notifier)
          .requestPermission();

      verify(() => mockChannel.requestOverlayPermission()).called(1);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/providers/bubble_providers_test.dart`
Expected: FAIL — file not found

**Step 3: Write implementation**

```dart
// lib/presentation/providers/bubble_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/platform/bubble_state.dart';
import 'package:fangeul/platform/floating_bubble_channel.dart';

part 'bubble_providers.g.dart';

/// FloatingBubbleChannel Provider.
@riverpod
FloatingBubbleChannel floatingBubbleChannel(FloatingBubbleChannelRef ref) {
  return FloatingBubbleChannel();
}

/// 버블 상태 Notifier.
///
/// [FloatingBubbleChannel]을 통해 네이티브 버블 서비스를 제어하고
/// 현재 상태를 [BubbleState]로 관리한다.
@riverpod
class BubbleNotifier extends _$BubbleNotifier {
  @override
  BubbleState build() => BubbleState.off;

  FloatingBubbleChannel get _channel =>
      ref.read(floatingBubbleChannelProvider);

  /// 버블을 표시한다.
  ///
  /// 오버레이 권한이 없으면 상태 변경 없이 반환.
  Future<void> show() async {
    final success = await _channel.showBubble();
    if (success) {
      state = BubbleState.showing;
    }
  }

  /// 버블을 숨기고 서비스를 중지한다.
  Future<void> hide() async {
    await _channel.hideBubble();
    state = BubbleState.off;
  }

  /// 오버레이 권한 부여 여부를 확인한다.
  Future<bool> checkPermission() {
    return _channel.isOverlayPermissionGranted();
  }

  /// 시스템 오버레이 권한 설정을 요청한다.
  Future<void> requestPermission() {
    return _channel.requestOverlayPermission();
  }

  /// 네이티브에서 상태를 동기화한다.
  Future<void> sync() async {
    state = await _channel.getBubbleState();
  }
}
```

**Step 4: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs --build-filter="lib/presentation/providers/bubble_providers.dart"`

**Step 5: Run test to verify it passes**

Run: `flutter test test/presentation/providers/bubble_providers_test.dart`
Expected: All tests pass

**Step 6: Commit**

```bash
git add lib/presentation/providers/bubble_providers.dart lib/presentation/providers/bubble_providers.g.dart test/presentation/providers/bubble_providers_test.dart
git commit -m "feat(bubble): BubbleNotifier — 상태 관리 Provider (TDD)"
```

---

## Task 11: UI Strings + Compact Widgets

**Files:**
- Modify: `lib/presentation/constants/ui_strings.dart`
- Create: `lib/presentation/widgets/favorite_phrase_tile.dart`
- Create: `lib/presentation/widgets/recent_copy_tile.dart`
- Create: `lib/presentation/widgets/compact_phrase_list.dart`

**Step 1: Add UI strings**

Add to `UiStrings` class in `lib/presentation/constants/ui_strings.dart`:

```dart
  // 플로팅 버블
  static const bubbleLabel = '플로팅 버블';
  static const bubbleDescription = '다른 앱 위에서 한글 변환';
  static const bubblePermissionTitle = '오버레이 권한 필요';
  static const bubblePermissionMessage = '다른 앱 위에서 바로 한글 변환을 사용하려면 오버레이 권한이 필요합니다.';
  static const bubblePermissionAllow = '설정으로 이동';
  static const bubblePermissionDeny = '나중에';
  static const bubblePermissionDenied = '앱 내에서도 모든 기능을 사용할 수 있습니다';

  // 미니 변환기
  static const miniConverterTitle = 'Fangeul';
  static const miniTabFavorites = '즐겨찾기';
  static const miniTabRecent = '최근';
  static const miniOpenConverter = '변환기 열기';
  static const miniBackToCompact = '간편모드';
  static const miniFavoritesEmpty = '문구 화면에서 ⭐ 탭하여\n즐겨찾기를 추가하세요';
  static const miniRecentEmpty = '아직 복사한 텍스트가 없습니다';
```

**Step 2: Write FavoritePhraseTile**

```dart
// lib/presentation/widgets/favorite_phrase_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';

/// 간편모드 즐겨찾기 문구 타일.
///
/// 한글 문구 + 복사 버튼. 탭하면 클립보드에 복사.
class FavoritePhraseTile extends StatelessWidget {
  /// Creates a [FavoritePhraseTile].
  const FavoritePhraseTile({
    super.key,
    required this.text,
    this.subtitle,
    this.onCopied,
  });

  /// 한글 문구 텍스트.
  final String text;

  /// 부제(로마자 발음 등). null이면 미표시.
  final String? subtitle;

  /// 복사 완료 콜백.
  final VoidCallback? onCopied;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      title: Text(
        text,
        style: theme.textTheme.bodyLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.copy_rounded, size: 18),
        tooltip: UiStrings.copyTooltip,
        onPressed: () => _copy(context),
      ),
      onTap: () => _copy(context),
    );
  }

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(UiStrings.copied),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    onCopied?.call();
  }
}
```

**Step 3: Write RecentCopyTile**

```dart
// lib/presentation/widgets/recent_copy_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';

/// 간편모드 최근 복사 타일.
///
/// 최근 복사한 텍스트를 표시. 탭하면 클립보드에 다시 복사.
class RecentCopyTile extends StatelessWidget {
  /// Creates a [RecentCopyTile].
  const RecentCopyTile({
    super.key,
    required this.text,
    this.onCopied,
  });

  /// 복사된 텍스트.
  final String text;

  /// 복사 완료 콜백.
  final VoidCallback? onCopied;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      leading: Icon(
        Icons.history_rounded,
        size: 18,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        text,
        style: theme.textTheme.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.copy_rounded, size: 18),
        tooltip: UiStrings.copyTooltip,
        onPressed: () => _copy(context),
      ),
      onTap: () => _copy(context),
    );
  }

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(UiStrings.copied),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    onCopied?.call();
  }
}
```

**Step 4: Write CompactPhraseList**

```dart
// lib/presentation/widgets/compact_phrase_list.dart
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/copy_history_provider.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/providers/phrase_providers.dart';
import 'package:fangeul/presentation/widgets/favorite_phrase_tile.dart';
import 'package:fangeul/presentation/widgets/recent_copy_tile.dart';

/// 간편모드 문구 리스트 (즐겨찾기 + 최근 탭).
///
/// [TabController]는 부모에서 관리하며,
/// 마지막 선택 탭은 shared_preferences에 저장.
class CompactPhraseList extends ConsumerWidget {
  /// Creates a [CompactPhraseList].
  const CompactPhraseList({
    super.key,
    required this.tabController,
    this.onCopied,
  });

  /// 탭 컨트롤러 (즐겨찾기 / 최근).
  final TabController tabController;

  /// 복사 완료 콜백 (dismiss 트리거용).
  final VoidCallback? onCopied;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritePhrasesNotifierProvider);
    final history = ref.watch(copyHistoryNotifierProvider);
    final phrasesAsync = ref.watch(allPhrasesProvider);

    return Column(
      children: [
        // 탭바
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: UiStrings.miniTabFavorites),
            Tab(text: UiStrings.miniTabRecent),
          ],
        ),
        // 탭 내용
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              // 즐겨찾기 탭
              _buildFavoritesTab(favorites, phrasesAsync, ref),
              // 최근 탭
              _buildRecentTab(history),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab(
    Set<String> favorites,
    AsyncValue<dynamic> phrasesAsync,
    WidgetRef ref,
  ) {
    if (favorites.isEmpty) {
      return Center(
        child: Text(
          UiStrings.miniFavoritesEmpty,
          textAlign: TextAlign.center,
        ),
      );
    }

    final favoritesList = favorites.toList();
    return ListView.builder(
      itemCount: favoritesList.length,
      itemBuilder: (context, index) {
        final ko = favoritesList[index];
        return FavoritePhraseTile(
          text: ko,
          onCopied: () {
            ref.read(copyHistoryNotifierProvider.notifier).addEntry(ko);
            onCopied?.call();
          },
        );
      },
    );
  }

  Widget _buildRecentTab(List<String> history) {
    if (history.isEmpty) {
      return const Center(
        child: Text(UiStrings.miniRecentEmpty),
      );
    }

    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        return RecentCopyTile(
          text: history[index],
          onCopied: onCopied,
        );
      },
    );
  }
}
```

**Step 5: Verify analyze passes**

Run: `flutter analyze lib/presentation/widgets/compact_phrase_list.dart lib/presentation/widgets/favorite_phrase_tile.dart lib/presentation/widgets/recent_copy_tile.dart lib/presentation/constants/ui_strings.dart`
Expected: No issues

**Step 6: Commit**

```bash
git add lib/presentation/constants/ui_strings.dart lib/presentation/widgets/favorite_phrase_tile.dart lib/presentation/widgets/recent_copy_tile.dart lib/presentation/widgets/compact_phrase_list.dart
git commit -m "feat(bubble): UI strings + 간편모드 위젯 (타일, 리스트)"
```

---

## Task 12: mini_converter_screen.dart — 팝업 메인 화면

**Files:**
- Create: `lib/presentation/screens/mini_converter_screen.dart`
- Create: `test/presentation/screens/mini_converter_screen_test.dart`

**Step 1: Write MiniConverterScreen**

```dart
// lib/presentation/screens/mini_converter_screen.dart
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fangeul/core/engines/keyboard_converter.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/converter_providers.dart';
import 'package:fangeul/presentation/providers/copy_history_provider.dart';
import 'package:fangeul/presentation/widgets/compact_phrase_list.dart';
import 'package:fangeul/presentation/widgets/converter_input.dart';
import 'package:fangeul/presentation/widgets/korean_keyboard.dart';

/// 미니 변환기 팝업 화면.
///
/// FloatingBubbleService에서 버블 탭 시 열리는 Flutter Activity 화면.
/// 2단 모드: 간편모드(기본, ~25%) ↔ 확장모드(변환기, ~70%).
class MiniConverterScreen extends ConsumerStatefulWidget {
  /// Creates the [MiniConverterScreen] widget.
  const MiniConverterScreen({super.key});

  @override
  ConsumerState<MiniConverterScreen> createState() =>
      _MiniConverterScreenState();
}

class _MiniConverterScreenState extends ConsumerState<MiniConverterScreen>
    with TickerProviderStateMixin {
  /// 간편모드 (true) / 확장모드 (false).
  bool _isCompact = true;

  // 간편모드 탭
  late final TabController _compactTabController;

  // 확장모드 변환기 탭
  late final TabController _converterTabController;
  final _textController = TextEditingController();
  String _engBuffer = '';
  List<String> _jamoList = [];

  static const _modes = ConvertMode.values;
  static const _modeLabels = [
    UiStrings.converterTabEngToKor,
    UiStrings.converterTabKorToEng,
    UiStrings.converterTabRomanize,
  ];
  static const _modeHints = [
    UiStrings.converterHintEngToKor,
    UiStrings.converterHintKorToEng,
    UiStrings.converterHintRomanize,
  ];

  ConvertMode get _currentMode => _modes[_converterTabController.index];
  bool get _isEngToKor => _currentMode == ConvertMode.engToKor;

  @override
  void initState() {
    super.initState();
    _compactTabController = TabController(length: 2, vsync: this);
    _converterTabController = TabController(length: 3, vsync: this);
    _converterTabController.addListener(_onConverterTabChanged);
  }

  @override
  void dispose() {
    _compactTabController.dispose();
    _converterTabController.removeListener(_onConverterTabChanged);
    _converterTabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onConverterTabChanged() {
    if (_converterTabController.indexIsChanging) return;
    _clearConverter();
  }

  // ── 모드 전환 ──

  void _expandToConverter() {
    setState(() => _isCompact = false);
  }

  void _collapseToCompact() {
    _clearConverter();
    setState(() => _isCompact = true);
  }

  // ── 변환기 입력 핸들러 (ConverterScreen 재활용) ──

  void _updateText(String text) {
    _textController.text = text;
    _textController.selection = TextSelection.collapsed(offset: text.length);
  }

  void _onCharacterTap(String eng, String kor) {
    if (_isEngToKor) {
      _engBuffer += eng;
      _updateText(_engBuffer);
    } else {
      _jamoList = [..._jamoList, kor];
      _updateText(KeyboardConverter.assembleJamos(_jamoList));
    }
    _convert();
  }

  void _onBackspace() {
    if (_isEngToKor) {
      if (_engBuffer.isEmpty) return;
      _engBuffer = _engBuffer.substring(0, _engBuffer.length - 1);
      _updateText(_engBuffer);
    } else {
      if (_jamoList.isEmpty) return;
      _jamoList = _jamoList.sublist(0, _jamoList.length - 1);
      _updateText(KeyboardConverter.assembleJamos(_jamoList));
    }
    _convert();
  }

  void _onSpace() {
    if (_isEngToKor) {
      _engBuffer += ' ';
      _updateText(_engBuffer);
    } else {
      _jamoList = [..._jamoList, ' '];
      _updateText(KeyboardConverter.assembleJamos(_jamoList));
    }
    _convert();
  }

  void _convert() {
    final text = _textController.text;
    if (text.isEmpty) {
      ref.read(converterNotifierProvider.notifier).clear();
    } else {
      ref.read(converterNotifierProvider.notifier).convert(text, _currentMode);
    }
  }

  void _clearConverter() {
    _engBuffer = '';
    _jamoList = [];
    _textController.clear();
    ref.read(converterNotifierProvider.notifier).clear();
  }

  // ── 빌드 ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // 팝업 내부 탭 전파 방지
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isCompact
                  ? MediaQuery.of(context).size.height * 0.30
                  : MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: _isCompact ? _buildCompactMode() : _buildExpandedMode(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── 간편모드 ──

  Widget _buildCompactMode() {
    return Column(
      children: [
        // 핸들바
        _buildDragHandle(),
        // 문구 리스트
        Expanded(
          child: CompactPhraseList(
            tabController: _compactTabController,
            onCopied: () => Navigator.of(context).pop(),
          ),
        ),
        // 변환기 열기 버튼
        _buildOpenConverterButton(),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildOpenConverterButton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _expandToConverter,
          icon: const Icon(Icons.search_rounded, size: 18),
          label: const Text(UiStrings.miniOpenConverter),
        ),
      ),
    );
  }

  // ── 확장모드 ──

  Widget _buildExpandedMode() {
    final converterState = ref.watch(converterNotifierProvider);

    final output = switch (converterState) {
      ConverterInitial() => '',
      ConverterLoading() => '',
      ConverterSuccess(:final output) => output,
      ConverterError(:final message) => message,
    };

    return Column(
      children: [
        // 헤더
        _buildExpandedHeader(),
        // 변환기 탭
        TabBar(
          controller: _converterTabController,
          tabs: _modeLabels.map((l) => Tab(text: l)).toList(),
        ),
        // 입력/출력
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: ConverterInput(
              controller: _textController,
              output: output,
              hintText: _modeHints[_converterTabController.index],
              onClear: _clearConverter,
              onCopied: (text) {
                ref.read(copyHistoryNotifierProvider.notifier).addEntry(text);
              },
            ),
          ),
        ),
        // 커스텀 키보드
        KoreanKeyboard(
          isEngToKor: _isEngToKor,
          onCharacterTap: _onCharacterTap,
          onBackspace: _onBackspace,
          onSpace: _onSpace,
        ),
      ],
    );
  }

  Widget _buildExpandedHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: _collapseToCompact,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text(UiStrings.miniBackToCompact),
          ),
          const Spacer(),
          Text(
            UiStrings.miniConverterTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Write widget test**

```dart
// test/presentation/screens/mini_converter_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/screens/mini_converter_screen.dart';
import 'package:fangeul/presentation/providers/favorite_phrases_provider.dart';
import 'package:fangeul/presentation/providers/copy_history_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        home: const MiniConverterScreen(),
      ),
    );
  }

  group('MiniConverterScreen', () {
    testWidgets('should show compact mode by default', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.miniTabFavorites), findsOneWidget);
      expect(find.text(UiStrings.miniTabRecent), findsOneWidget);
      expect(find.text(UiStrings.miniOpenConverter), findsOneWidget);
    });

    testWidgets('should show empty favorites message', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.miniFavoritesEmpty), findsOneWidget);
    });

    testWidgets('should switch to expanded mode on button tap', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text(UiStrings.miniOpenConverter));
      await tester.pumpAndSettle();

      // 확장모드 헤더
      expect(find.text(UiStrings.miniBackToCompact), findsOneWidget);
      expect(find.text(UiStrings.miniConverterTitle), findsOneWidget);
      // 변환기 탭
      expect(find.text(UiStrings.converterTabEngToKor), findsOneWidget);
    });

    testWidgets('should collapse back to compact mode', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 확장
      await tester.tap(find.text(UiStrings.miniOpenConverter));
      await tester.pumpAndSettle();

      // 접기
      await tester.tap(find.text(UiStrings.miniBackToCompact));
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.miniOpenConverter), findsOneWidget);
    });
  });
}
```

**Step 3: Run test**

Run: `flutter test test/presentation/screens/mini_converter_screen_test.dart`
Expected: All tests pass

**Step 4: Commit**

```bash
git add lib/presentation/screens/mini_converter_screen.dart test/presentation/screens/mini_converter_screen_test.dart
git commit -m "feat(bubble): MiniConverterScreen — 간편모드 + 확장모드 2단 팝업 (TDD)"
```

---

## Task 13: Settings Screen — 버블 토글

**Files:**
- Modify: `lib/presentation/screens/settings_screen.dart`
- Create: `test/presentation/screens/settings_bubble_toggle_test.dart`

**Step 1: Write the widget test**

```dart
// test/presentation/screens/settings_bubble_toggle_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/platform/bubble_state.dart';
import 'package:fangeul/platform/floating_bubble_channel.dart';
import 'package:fangeul/presentation/constants/ui_strings.dart';
import 'package:fangeul/presentation/providers/bubble_providers.dart';
import 'package:fangeul/presentation/screens/settings_screen.dart';

class MockFloatingBubbleChannel extends Mock
    implements FloatingBubbleChannel {}

void main() {
  late MockFloatingBubbleChannel mockChannel;

  setUp(() {
    mockChannel = MockFloatingBubbleChannel();
  });

  Widget buildTestWidget({BubbleState initialState = BubbleState.off}) {
    return ProviderScope(
      overrides: [
        floatingBubbleChannelProvider.overrideWithValue(mockChannel),
      ],
      child: const MaterialApp(
        home: SettingsScreen(),
      ),
    );
  }

  group('Settings Bubble Toggle', () {
    testWidgets('should show bubble toggle', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text(UiStrings.bubbleLabel), findsOneWidget);
      expect(find.text(UiStrings.bubbleDescription), findsOneWidget);
    });

    testWidgets('should show Switch widget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsOneWidget);
    });
  });
}
```

**Step 2: Modify SettingsScreen**

Add bubble toggle section to `settings_screen.dart`, between the theme section divider and app info:

After the `const Divider(),` line (line 57) and before `// 앱 정보` (line 58), insert:

```dart
          // 플로팅 버블
          _BubbleToggleTile(),
          const Divider(),
```

Add the `_BubbleToggleTile` class at the end of the file (private, same file is OK per conventions):

```dart
/// 플로팅 버블 온오프 토글 타일.
class _BubbleToggleTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bubbleState = ref.watch(bubbleNotifierProvider);
    final isOn = bubbleState != BubbleState.off;

    return SwitchListTile(
      secondary: const Icon(Icons.bubble_chart_outlined),
      title: const Text(UiStrings.bubbleLabel),
      subtitle: const Text(UiStrings.bubbleDescription),
      value: isOn,
      onChanged: (value) async {
        if (value) {
          await _enableBubble(context, ref);
        } else {
          await ref.read(bubbleNotifierProvider.notifier).hide();
        }
      },
    );
  }

  Future<void> _enableBubble(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(bubbleNotifierProvider.notifier);
    final hasPermission = await notifier.checkPermission();

    if (hasPermission) {
      await notifier.show();
      return;
    }

    // 권한 없음 → 설명 다이얼로그
    if (!context.mounted) return;
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(UiStrings.bubblePermissionTitle),
        content: const Text(UiStrings.bubblePermissionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(UiStrings.bubblePermissionDeny),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(UiStrings.bubblePermissionAllow),
          ),
        ],
      ),
    );

    if (shouldRequest == true) {
      await notifier.requestPermission();
    }
  }
}
```

Also add the needed imports at the top of `settings_screen.dart`:

```dart
import 'package:fangeul/platform/bubble_state.dart';
import 'package:fangeul/presentation/providers/bubble_providers.dart';
```

**Step 3: Run test**

Run: `flutter test test/presentation/screens/settings_bubble_toggle_test.dart`
Expected: All tests pass

**Step 4: Commit**

```bash
git add lib/presentation/screens/settings_screen.dart test/presentation/screens/settings_bubble_toggle_test.dart
git commit -m "feat(bubble): Settings — 버블 토글 + 권한 다이얼로그"
```

---

## Task 14: App Router — 미니 변환기 라우트

**Files:**
- Modify: `lib/presentation/router/app_router.dart`
- Modify: `lib/app.dart`

**Step 1: Add mini-converter route**

In `app_router.dart`, add a route for `/mini-converter`:

```dart
GoRoute(
  path: '/mini-converter',
  builder: (context, state) => const MiniConverterScreen(),
),
```

Import: `import 'package:fangeul/presentation/screens/mini_converter_screen.dart';`

This route is used by the prewarm FlutterEngine (initial route = `/mini-converter`).

**Step 2: Verify analyze passes**

Run: `flutter analyze`
Expected: No issues

**Step 3: Commit**

```bash
git add lib/presentation/router/app_router.dart
git commit -m "feat(bubble): /mini-converter 라우트 추가"
```

---

## Task 15: ConverterInput onCopied 콜백 추가

**Files:**
- Modify: `lib/presentation/widgets/converter_input.dart`

The existing `ConverterInput` widget needs an optional `onCopied` callback so that the MiniConverterScreen can add copied text to copy history.

**Step 1: Check current ConverterInput**

Read `lib/presentation/widgets/converter_input.dart` and add:

```dart
/// 복사 완료 시 텍스트를 전달하는 콜백.
final void Function(String text)? onCopied;
```

to the constructor parameters, and call `onCopied?.call(output)` when the copy button is pressed.

**Step 2: Verify existing tests still pass**

Run: `flutter test`
Expected: All tests pass (new parameter is optional, existing callers unaffected)

**Step 3: Commit**

```bash
git add lib/presentation/widgets/converter_input.dart
git commit -m "feat(bubble): ConverterInput — onCopied 콜백 추가"
```

---

## Task 16: build_runner + 전체 테스트 + 정적 분석

**Files:** Generated `*.g.dart`, `*.freezed.dart` files

**Step 1: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: No errors

**Step 2: Run full test suite**

Run: `flutter test`
Expected: All existing 179 tests + new tests pass

**Step 3: Run static analysis**

Run: `flutter analyze`
Expected: No issues

**Step 4: Run format check**

Run: `dart format --set-exit-if-changed .`
Expected: No formatting issues

**Step 5: Commit any generated files**

```bash
git add -A
git commit -m "chore(bubble): build_runner 생성 파일 + 전체 테스트 pass"
```

---

## 구현 순서 요약

```
Task  1: AndroidManifest + TranslucentTheme        [독립, Android 인프라]
Task  2: BubbleNotificationHelper.kt               [독립, Kotlin]
Task  3: FloatingBubbleService.kt                  [→ Task 2]
Task  4: MiniConverterActivity.kt                  [독립, Kotlin]
Task  5: MainActivity.kt (프리워밍 + Channel)       [→ Task 3, 4]
Task  6: bubble_state.dart (TDD)                   [독립, 순수 Dart]
Task  7: floating_bubble_channel.dart (TDD)        [→ Task 6]
Task  8: copy_history_provider.dart (TDD)          [독립]
Task  9: favorite_phrases_provider.dart (TDD)      [독립]
Task 10: bubble_providers.dart (TDD)               [→ Task 7]
Task 11: UI strings + compact widgets              [→ Task 8, 9]
Task 12: mini_converter_screen.dart (TDD)          [→ Task 10, 11]
Task 13: settings_screen.dart 버블 토글 (TDD)       [→ Task 10]
Task 14: app_router 라우트 추가                     [→ Task 12]
Task 15: ConverterInput onCopied 콜백              [독립]
Task 16: build_runner + 전체 검증                   [→ 전체]
```

**병렬 가능 그룹:**
- Task 1~5 (Kotlin/Android) 순차
- Task 6~7 (Platform 순수 Dart) 순차
- Task 8, 9 (Provider) 병렬
- Task 11~14 (UI) 순차

---

## 검증 체크리스트

- [ ] `flutter test` — 기존 179개 + 신규 테스트 전부 pass
- [ ] `flutter analyze` — 0 issues
- [ ] `dart format --set-exit-if-changed .` — 0 changes
- [ ] `cd android && ./gradlew assembleDebug` — BUILD SUCCESSFUL
- [ ] 실기기 수동 테스트: 권한 → 버블 표시 → 탭 → 간편모드 → 즐겨찾기/최근 → 변환기 확장 → 변환 → 복사
