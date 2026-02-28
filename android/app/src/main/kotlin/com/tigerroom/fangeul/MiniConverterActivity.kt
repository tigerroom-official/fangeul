package com.tigerroom.fangeul

import android.content.Context
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
