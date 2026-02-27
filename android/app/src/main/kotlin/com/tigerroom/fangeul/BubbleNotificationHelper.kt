package com.tigerroom.fangeul

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
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
