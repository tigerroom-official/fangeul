package com.tigerroom.fangeul

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import androidx.core.view.WindowCompat
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/// 메인 Activity — FlutterEngine 프리워밍 + Platform Channel 핸들러.
class MainActivity : FlutterActivity() {

    companion object {
        private const val BUBBLE_CHANNEL = "com.tigerroom.fangeul/floating_bubble"
        private const val BUBBLE_EVENT_CHANNEL = "com.tigerroom.fangeul/floating_bubble_events"
        private const val OVERLAY_PERMISSION_REQUEST = 1001

        /// 메인 앱이 포그라운드인지 여부.
        /// MiniConverterActivity.onDestroy()에서 버블 복원 시 참조하여 레이스 컨디션 방지.
        var isResumed: Boolean = false
            private set
    }

    private var pendingPermissionResult: MethodChannel.Result? = null

    /// onResume에서 우리가 버블을 숨겼는지 여부.
    /// onStop에서 복원 시 "우리가 숨긴 경우"에만 다시 표시하기 위해 기록.
    /// 사용자가 hideBubble로 명시 종료하면 false로 리셋.
    private var bubbleHiddenByUs = false

    /// 버블 복원 지연 핸들러 — 최근 앱 화면에서 버블 깜빡임 방지.
    private val mainHandler = Handler(Looper.getMainLooper())
    private var showBubbleRunnable: Runnable? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        prewarmMiniEngine()
    }

    override fun onResume() {
        super.onResume()
        isResumed = true
        // 대기 중인 버블 복원을 취소 (최근 앱에서 빠르게 복귀 시).
        cancelPendingBubbleShow()

        // 메인 앱이 포그라운드이면 버블을 일시적으로 숨긴다.
        // silent = true → Dart에 "off" 이벤트 안 보냄 (설정 토글 유지).
        //
        // isBubbleShowing 대신 isServiceActive를 체크한다:
        // onStop()의 startForegroundService(ACTION_SHOW)는 비동기이므로,
        // 앱 전환이 빠르면 onResume 시점에 isBubbleShowing이 아직 false일 수 있다.
        // isServiceActive는 silent hide 중에도 true이므로 레이스 컨디션을 방지한다.
        if (FloatingBubbleService.isServiceActive) {
            bubbleHiddenByUs = true
            val intent = Intent(this, FloatingBubbleService::class.java).apply {
                action = FloatingBubbleService.ACTION_HIDE
                putExtra(FloatingBubbleService.EXTRA_SILENT, true)
            }
            startService(intent)
        }
    }

    override fun onPause() {
        super.onPause()
        isResumed = false
    }

    override fun onStop() {
        super.onStop()
        // 메인 앱이 백그라운드로 가면, 우리가 숨긴 버블만 복원한다.
        // 사용자가 명시적으로 끈 경우(hideBubble)는 복원하지 않음.
        //
        // 500ms 지연: 최근 앱 화면에서 버블이 깜빡이는 것을 방지.
        // onResume()이 빠르게 호출되면(최근 앱→메인 앱 복귀) 복원을 취소한다.
        if (bubbleHiddenByUs) {
            showBubbleRunnable = Runnable {
                showBubbleRunnable = null
                bubbleHiddenByUs = false
                // 500ms 사이에 사용자가 알림 "중지"(ACTION_STOP)로 서비스를 종료한 경우
                // 버블을 다시 살리지 않는다.
                if (!FloatingBubbleService.isServiceActive) return@Runnable
                val intent = Intent(this, FloatingBubbleService::class.java).apply {
                    action = FloatingBubbleService.ACTION_SHOW
                }
                startForegroundService(intent)
            }
            mainHandler.postDelayed(showBubbleRunnable!!, 500)
        }
    }

    override fun onDestroy() {
        // 대기 중인 복원 취소.
        cancelPendingBubbleShow()
        // Activity 종료 시 (뒤로가기 등) 버블 즉시 복원.
        if (bubbleHiddenByUs && isFinishing && FloatingBubbleService.isServiceActive) {
            bubbleHiddenByUs = false
            val intent = Intent(this, FloatingBubbleService::class.java).apply {
                action = FloatingBubbleService.ACTION_SHOW
            }
            startForegroundService(intent)
        }
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, BUBBLE_EVENT_CHANNEL)
            .setStreamHandler(BubbleEventBroadcaster)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BUBBLE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "showBubble" -> {
                        if (!Settings.canDrawOverlays(this)) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        // 메인 앱 포그라운드 시 서비스만 시작, 버블 뷰 생성 건너뜀.
                        // onStop()에서 백그라운드 전환 시 버블 표시.
                        val isForeground =
                            lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED)
                        val showIntent = Intent(this, FloatingBubbleService::class.java).apply {
                            action = FloatingBubbleService.ACTION_SHOW
                            if (isForeground) {
                                putExtra(FloatingBubbleService.EXTRA_START_HIDDEN, true)
                            }
                        }
                        startForegroundService(showIntent)
                        if (isForeground) bubbleHiddenByUs = true
                        result.success(true)
                    }

                    "hideBubble" -> {
                        // 사용자가 명시적으로 버블을 끔 → 복원 방지.
                        cancelPendingBubbleShow()
                        bubbleHiddenByUs = false
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
                        pendingPermissionResult = result
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName"),
                        )
                        @Suppress("DEPRECATION")
                        startActivityForResult(intent, OVERLAY_PERMISSION_REQUEST)
                    }

                    "getBubbleState" -> {
                        // 임시 hide 중에도 "showing" 반환 (뷰 숨김과 서비스 활성은 별개).
                        result.success(
                            if (FloatingBubbleService.isServiceActive) "showing" else "off"
                        )
                    }

                    "isBatteryOptimizationDisabled" -> {
                        try {
                            val pm = getSystemService(POWER_SERVICE) as PowerManager
                            result.success(pm.isIgnoringBatteryOptimizations(packageName))
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }

                    "requestIgnoreBatteryOptimization" -> {
                        try {
                            val intent = Intent(
                                Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                                Uri.parse("package:$packageName"),
                            )
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            // OEM ROM에서 ActivityNotFoundException/SecurityException 가능
                            result.success(false)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == OVERLAY_PERMISSION_REQUEST) {
            val granted = Settings.canDrawOverlays(this)
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }

    private fun cancelPendingBubbleShow() {
        showBubbleRunnable?.let { mainHandler.removeCallbacks(it) }
        showBubbleRunnable = null
    }

    /// MiniConverterActivity용 FlutterEngine 프리워밍.
    private fun prewarmMiniEngine() {
        if (FlutterEngineCache.getInstance().get(MiniConverterActivity.ENGINE_ID) != null) {
            return
        }

        val engine = FlutterEngine(this).apply {
            navigationChannel.setInitialRoute("/mini-converter")
            dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        }

        FlutterEngineCache.getInstance().put(MiniConverterActivity.ENGINE_ID, engine)
    }

}
