package com.focusapp.focus_app

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Paint
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "focus_garden/lock"
    private val APP_CHANNEL = "focus_garden/apps"
    private var overlayView: View? = null
    private var isHardLock = false
    private var focusLockActive = false
    private var overlayManager: OverlayManager? = null
    private var currentBlacklist: Set<String> = emptySet()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    try {
                        val packages = packageManager.getInstalledApplications(0)
                        val appList = packages
                            .filter { app ->
                                app.packageName != "com.focusapp.focus_app" &&
                                (app.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) == 0
                            }
                            .map { app ->
                                mapOf(
                                    "packageName" to app.packageName,
                                    "name" to packageManager.getApplicationLabel(app).toString()
                                )
                            }
                        result.success(appList)
                    } catch (e: Exception) {
                        result.success(emptyList<Map<String, String>>())
                    }
                }
                "hasOverlayPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        result.success(Settings.canDrawOverlays(this))
                    } else {
                        result.success(true)
                    }
                }
                "openOverlaySettings" -> {
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName")
                    )
                    startActivity(intent)
                    result.success(true)
                }
                "isAccessibilityServiceEnabled" -> {
                    val serviceName = "$packageName/.FocusAccessibilityService"
                    val enabledServices = try {
                        val enabled = Settings.Secure.getString(
                            contentResolver,
                            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
                        )
                        enabled?.split(":") ?: emptyList()
                    } catch (e: Exception) {
                        emptyList()
                    }
                    result.success(enabledServices.any { it.endsWith(".FocusAccessibilityService") })
                }
                "openAccessibilitySettings" -> {
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    startActivity(intent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLock" -> {
                    val durationMinutes = call.argument<Int>("durationMinutes") ?: 30
                    isHardLock = call.argument<Boolean>("hardLock") ?: false
                    val blacklistArg = call.argument<List<String>>("blacklist") ?: emptyList()
                    currentBlacklist = blacklistArg.toSet()

                    applyGrayscale(true)
                    showFocusOverlay()

                    if (isHardLock) {
                        setSecure(true)
                        suppressNotifications(true)
                        enableImmersiveMode()
                        startForegroundService()
                        FocusAccessibilityService.instance?.apply {
                            setBlacklistedPackages(currentBlacklist)
                            activate()
                        }
                    }

                    result.success(true)
                }
                "stopLock" -> {
                    applyGrayscale(false)
                    hideFocusOverlay()
                    setSecure(false)
                    suppressNotifications(false)
                    disableImmersiveMode()
                    stopForegroundService()
                    overlayManager?.hide()
                    FocusAccessibilityService.instance?.deactivate()
                    isHardLock = false
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val blacklistedApp = intent.getStringExtra("blacklisted_app")
        if (blacklistedApp != null && Settings.canDrawOverlays(this)) {
            if (overlayManager == null) {
                overlayManager = OverlayManager(this)
            }
            overlayManager?.show()
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

    private fun showFocusOverlay() {
        if (overlayView != null) return

        val contentParent = findViewById<FrameLayout>(android.R.id.content)
        val overlay = layoutInflater.inflate(R.layout.focus_overlay, contentParent, false)
        contentParent.addView(overlay)
        overlayView = overlay
    }

    private fun hideFocusOverlay() {
        overlayView?.let {
            try {
                val contentParent = findViewById<FrameLayout>(android.R.id.content)
                contentParent.removeView(it)
            } catch (_: Exception) {}
            overlayView = null
        }
    }

    private fun setSecure(enabled: Boolean) {
        if (enabled) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    private fun enableImmersiveMode() {
        focusLockActive = true
        window.decorView.setOnSystemUiVisibilityChangeListener { visibility ->
            if (focusLockActive && visibility and View.SYSTEM_UI_FLAG_FULLSCREEN == 0) {
                window.decorView.systemUiVisibility = (
                    View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                    or View.SYSTEM_UI_FLAG_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                )
            }
        }
        window.decorView.systemUiVisibility = (
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            or View.SYSTEM_UI_FLAG_FULLSCREEN
            or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
        )
    }

    private fun disableImmersiveMode() {
        focusLockActive = false
        window.decorView.setOnSystemUiVisibilityChangeListener(null)
        window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (focusLockActive && hasFocus) {
            window.decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                or View.SYSTEM_UI_FLAG_FULLSCREEN
                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
            )
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

    private fun startForegroundService() {
        val intent = Intent(this, FocusForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopForegroundService() {
        val intent = Intent(this, FocusForegroundService::class.java)
        stopService(intent)
    }

    override fun onDestroy() {
        hideFocusOverlay()
        disableImmersiveMode()
        super.onDestroy()
    }
}
