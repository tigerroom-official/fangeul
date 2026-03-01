package com.tigerroom.fangeul

import android.content.Context
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

/// 미니 변환기 Flutter Activity.
///
/// FloatingBubbleService에서 버블 탭 시 실행.
/// 캐시된 FlutterEngine을 사용하여 ~200ms 시작.
/// 투명 배경 + singleTask로 구성.
class MiniConverterActivity : FlutterActivity() {

    companion object {
        const val ENGINE_ID = "fangeul_mini_engine"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 상태바·내비게이션바를 완전 투명으로 설정.
        // XML theme 속성만으로는 일부 OEM/API에서 회색이 남을 수 있어
        // 프로그래밍 방식으로 강제한다.
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
        window.statusBarColor = Color.TRANSPARENT
        window.navigationBarColor = Color.TRANSPARENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility =
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
        }
    }

    override fun getBackgroundMode(): BackgroundMode = BackgroundMode.transparent

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return FlutterEngineCache.getInstance().get(ENGINE_ID)
            ?: createAndCacheEngine(context)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 엔진은 이미 프리워밍됨. super 호출로 플러그인 등록만 수행.
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false

    /// 프로세스 재시작 등으로 캐시가 비었을 때 엔진을 새로 생성한다.
    private fun createAndCacheEngine(context: Context): FlutterEngine {
        val engine = FlutterEngine(context).apply {
            navigationChannel.setInitialRoute("/mini-converter")
            dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        }
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        return engine
    }
}
