package com.tigerroom.fangeul

import android.animation.ValueAnimator
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
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
        private const val CLOSE_ZONE_SIZE_DP = 56
        private const val CLOSE_ZONE_MARGIN_BOTTOM_DP = 80
        private const val TAP_THRESHOLD_PX = 10

        /// 버블 표시 상태. MainActivity에서 참조.
        var isBubbleShowing: Boolean = false
            private set
    }

    private lateinit var windowManager: WindowManager
    private var bubbleView: View? = null
    private var closeZoneView: View? = null
    private var bubbleParams: WindowManager.LayoutParams? = null

    // 드래그 상태
    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f
    private var isDragging = false
    private var isInCloseZone = false

    // 화면 회전 감지
    private var configReceiver: BroadcastReceiver? = null

    // 화면 크기
    private var screenWidth = 0
    private var screenHeight = 0

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        updateScreenSize()
        registerConfigReceiver()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_HIDE -> {
                removeBubble()
                removeCloseZone()
                isBubbleShowing = false
                BubbleEventBroadcaster.send("off")
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

        isBubbleShowing = true
        BubbleEventBroadcaster.send("showing")
        return START_STICKY
    }

    override fun onDestroy() {
        configReceiver?.let { unregisterReceiver(it) }
        configReceiver = null
        isBubbleShowing = false
        removeBubble()
        removeCloseZone()
        BubbleEventBroadcaster.send("off")
        super.onDestroy()
    }

    // ── 버블 뷰 생성 ──

    private fun createBubbleView() {
        val sizePx = dpToPx(BUBBLE_SIZE_DP)

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
        container.addView(
            textView,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )

        val params = WindowManager.LayoutParams(
            sizePx,
            sizePx,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = screenWidth - sizePx - dpToPx(8)
            y = screenHeight / 3
        }

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
                text = "\u2715"
                setTextColor(Color.WHITE)
                textSize = 20f
                gravity = Gravity.CENTER
            }
            addView(
                icon,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT,
                ),
            )
        }

        val params = WindowManager.LayoutParams(
            sizePx,
            sizePx,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            y = dpToPx(CLOSE_ZONE_MARGIN_BOTTOM_DP)
        }

        windowManager.addView(view, params)
        closeZoneView = view
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

                    if (!isDragging &&
                        (abs(dx) > TAP_THRESHOLD_PX || abs(dy) > TAP_THRESHOLD_PX)
                    ) {
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
                        val closeY =
                            screenHeight -
                                dpToPx(CLOSE_ZONE_MARGIN_BOTTOM_DP) -
                                dpToPx(CLOSE_ZONE_SIZE_DP) / 2
                        val closeDist =
                            abs(bubbleCenterX - screenWidth / 2) +
                                abs(bubbleCenterY - closeY)
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
                        stopSelf()
                        return true
                    }

                    if (!isDragging) {
                        onBubbleTapped()
                    } else {
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
        val bubbleSize = dpToPx(BUBBLE_SIZE_DP)
        val margin = dpToPx(8)

        // Y좌표 클램핑 — 화면 회전 후 버블이 화면 밖으로 나가지 않도록
        val maxY = screenHeight - bubbleSize - margin
        if (params.y > maxY) params.y = maxY
        if (params.y < margin) params.y = margin

        // X좌표 가장 가까운 가장자리로 스냅
        val bubbleCenterX = params.x + bubbleSize / 2
        val targetX =
            if (bubbleCenterX < screenWidth / 2) {
                margin
            } else {
                screenWidth - bubbleSize - margin
            }

        val animator = ValueAnimator.ofInt(params.x, targetX)
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
            try {
                windowManager.removeView(it)
            } catch (_: Exception) {}
            bubbleView = null
        }
    }

    private fun removeCloseZone() {
        closeZoneView?.let {
            try {
                windowManager.removeView(it)
            } catch (_: Exception) {}
            closeZoneView = null
        }
    }

    // ── 유틸 ──

    private fun dpToPx(dp: Int): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp.toFloat(),
            resources.displayMetrics,
        ).toInt()
    }

    private fun updateScreenSize() {
        val metrics = resources.displayMetrics
        screenWidth = metrics.widthPixels
        screenHeight = metrics.heightPixels
    }

    /// 화면 회전 시 screenWidth/screenHeight를 갱신하고 버블을 재스냅한다.
    private fun registerConfigReceiver() {
        configReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                // post로 지연 — 일부 OEM에서 metrics 갱신이 브로드캐스트보다 늦을 수 있음
                Handler(Looper.getMainLooper()).post {
                    val oldWidth = screenWidth
                    updateScreenSize()
                    if (oldWidth != screenWidth) {
                        snapToEdge()
                    }
                }
            }
        }
        registerReceiver(
            configReceiver,
            IntentFilter(Intent.ACTION_CONFIGURATION_CHANGED),
            Context.RECEIVER_NOT_EXPORTED,
        )
    }
}
