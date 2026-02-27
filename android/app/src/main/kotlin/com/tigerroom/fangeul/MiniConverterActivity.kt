package com.tigerroom.fangeul

import android.content.Context
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

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return FlutterEngineCache.getInstance().get(ENGINE_ID)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // 엔진은 이미 프리워밍됨. 추가 설정 불필요.
    }

    override fun shouldDestroyEngineWithHost(): Boolean = false
}
