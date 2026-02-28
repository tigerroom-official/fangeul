package com.tigerroom.fangeul

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/// 버블 상태 이벤트를 Dart EventChannel로 전송하는 싱글턴.
///
/// [FloatingBubbleService]에서 상태 변경 시 [send]를 호출하면
/// [EventChannel.EventSink]를 통해 Dart 스트림으로 전달된다.
object BubbleEventBroadcaster : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    /// 버블 상태를 Dart로 전송한다.
    ///
    /// 메인 스레드에서 실행을 보장한다.
    fun send(state: String) {
        mainHandler.post {
            eventSink?.success(state)
        }
    }
}
