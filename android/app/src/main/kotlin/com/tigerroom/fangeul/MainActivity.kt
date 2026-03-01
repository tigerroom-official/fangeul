package com.tigerroom.fangeul

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
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
    }

    private var pendingPermissionResult: MethodChannel.Result? = null

    /// onResume에서 우리가 버블을 숨겼는지 여부.
    /// onStop에서 복원 시 "우리가 숨긴 경우"에만 다시 표시하기 위해 기록.
    /// 사용자가 hideBubble로 명시 종료하면 false로 리셋.
    private var bubbleHiddenByUs = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        prewarmMiniEngine()
    }

    override fun onResume() {
        super.onResume()
        // 메인 앱이 포그라운드이면 버블을 일시적으로 숨긴다.
        // silent = true → Dart에 "off" 이벤트 안 보냄 (설정 토글 유지).
        if (FloatingBubbleService.isBubbleShowing) {
            bubbleHiddenByUs = true
            val intent = Intent(this, FloatingBubbleService::class.java).apply {
                action = FloatingBubbleService.ACTION_HIDE
                putExtra(FloatingBubbleService.EXTRA_SILENT, true)
            }
            startService(intent)
        }
    }

    override fun onStop() {
        super.onStop()
        // 메인 앱이 백그라운드로 가면, 우리가 숨긴 버블만 복원한다.
        // 사용자가 명시적으로 끈 경우(hideBubble)는 복원하지 않음.
        if (bubbleHiddenByUs) {
            bubbleHiddenByUs = false
            val intent = Intent(this, FloatingBubbleService::class.java).apply {
                action = FloatingBubbleService.ACTION_SHOW
            }
            startForegroundService(intent)
        }
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
