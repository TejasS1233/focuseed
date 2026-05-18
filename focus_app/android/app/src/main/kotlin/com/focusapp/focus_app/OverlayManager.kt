package com.focusapp.focus_app

import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.view.Gravity
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.graphics.Color

class OverlayManager(private val context: Context) {
    private val windowManager: WindowManager =
        context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private var overlayView: android.view.View? = null

    fun show() {
        if (overlayView != null) return

        val layout = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setBackgroundColor(Color.parseColor("#CC000000"))
            setOnTouchListener { _, _ -> true }
        }

        val title = TextView(context).apply {
            text = "Focus Mode Active"
            setTextColor(Color.WHITE)
            textSize = 24f
            gravity = Gravity.CENTER
        }

        val message = TextView(context).apply {
            text = "You're in a hard lock session.\nBlacklisted apps are blocked."
            setTextColor(Color.parseColor("#CCCCCC"))
            textSize = 16f
            gravity = Gravity.CENTER
        }

        val button = Button(context).apply {
            text = "Return to Focus"
            setOnClickListener {
                hide()
            }
        }

        layout.addView(title)
        layout.addView(message)
        layout.addView(button)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
            PixelFormat.TRANSLUCENT
        )

        windowManager.addView(layout, params)
        overlayView = layout
    }

    fun hide() {
        overlayView?.let {
            windowManager.removeView(it)
            overlayView = null
        }
    }

    fun isShowing(): Boolean = overlayView != null
}
