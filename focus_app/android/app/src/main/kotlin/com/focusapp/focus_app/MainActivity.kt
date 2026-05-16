package com.focusapp.focus_app

import android.app.ActivityManager
import android.app.NotificationManager
import android.content.Context
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.os.Build
import android.graphics.Paint
import android.view.View
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "focus_garden/lock"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLock" -> {
                    val durationMinutes = call.argument<Int>("durationMinutes") ?: 30
                    applyGrayscale(true)
                    suppressNotifications(true)
                    result.success(true)
                }
                "stopLock" -> {
                    applyGrayscale(false)
                    suppressNotifications(false)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun applyGrayscale(enabled: Boolean) {
        val view = window.decorView
        if (enabled) {
            val matrix = ColorMatrix().apply { setSaturation(0f) }
            val filter = ColorMatrixColorFilter(matrix)
            val paint = Paint().apply { colorFilter = filter }
            view.setLayerType(View.LAYER_TYPE_HARDWARE, paint)
        } else {
            view.setLayerType(View.LAYER_TYPE_HARDWARE, null)
        }
    }

    private fun suppressNotifications(suppress: Boolean) {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            manager.setInterruptionFilter(
                if (suppress) NotificationManager.INTERRUPTION_FILTER_NONE
                else NotificationManager.INTERRUPTION_FILTER_ALL
            )
        }
    }
}
