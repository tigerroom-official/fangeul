package com.tigerroom.fangeul

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/// 미니 변환기 Flutter Activity.
///
/// FloatingBubbleService에서 버블 탭 시 실행.
/// 캐시된 FlutterEngine을 사용하여 ~200ms 시작.
/// 투명 배경 + singleTask로 구성.
class MiniConverterActivity : FlutterActivity() {

    companion object {
        const val ENGINE_ID = "fangeul_mini_engine"
        private const val MINI_CHANNEL = "com.tigerroom.fangeul/mini_converter"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        // 팝업 표시 중 버블 숨김 — 시각 중복 방지.
        hideBubble()
    }

    override fun onDestroy() {
        // 팝업 닫힘 → 버블 다시 표시.
        showBubble()
        super.onDestroy()
    }

    override fun getBackgroundMode(): BackgroundMode = BackgroundMode.transparent

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return FlutterEngineCache.getInstance().get(ENGINE_ID)
            ?: createAndCacheEngine(context)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MINI_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openMainApp" -> {
                        val intent = Intent(this, MainActivity::class.java).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                        }
                        startActivity(intent)
                        finish()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false

    /** 프로세스 재시작 등으로 캐시가 비었을 때 엔진을 새로 생성한다. */
    private fun createAndCacheEngine(context: Context): FlutterEngine {
        val engine = FlutterEngine(context).apply {
            navigationChannel.setInitialRoute("/mini-converter")
            dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        }
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        return engine
    }

    /** 버블을 임시 숨김 (서비스 활성 상태 유지). */
    private fun hideBubble() {
        if (!FloatingBubbleService.isServiceActive) return
        val intent = Intent(this, FloatingBubbleService::class.java).apply {
            action = FloatingBubbleService.ACTION_HIDE
            putExtra(FloatingBubbleService.EXTRA_SILENT, true)
        }
        startService(intent)
    }

    /** 버블을 다시 표시. */
    ///
    /// 메인 앱이 포그라운드이면 버블 복원을 건너뛴다.
    /// 이유: onDestroy()는 MainActivity.onResume() 이후에 실행될 수 있어
    /// onResume이 숨긴 버블을 다시 표시하는 레이스 컨디션이 발생한다.
    /// 메인 앱의 onStop()이 나중에 버블을 복원한다.
    private fun showBubble() {
        if (!FloatingBubbleService.isServiceActive) return
        if (MainActivity.isResumed) return
        val intent = Intent(this, FloatingBubbleService::class.java).apply {
            action = FloatingBubbleService.ACTION_SHOW
        }
        startService(intent)
    }
}
