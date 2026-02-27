package com.tigerroom.fangeul

import android.app.ActivityManager
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
                            Uri.parse("package:$packageName"),
                        )
                        startActivity(intent)
                        result.success(null)
                    }

                    "getBubbleState" -> {
                        result.success(if (isServiceRunning()) "showing" else "off")
                    }

                    else -> result.notImplemented()
                }
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

    /// FloatingBubbleService 실행 여부 확인.
    private fun isServiceRunning(): Boolean {
        val manager = getSystemService(ACTIVITY_SERVICE) as ActivityManager
        @Suppress("DEPRECATION")
        return manager.getRunningServices(Int.MAX_VALUE)
            .any { it.service.className == FloatingBubbleService::class.java.name }
    }
}
