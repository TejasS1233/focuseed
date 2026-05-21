package com.focusapp.focus_app

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class FocusAccessibilityService : AccessibilityService() {
    companion object {
        var instance: FocusAccessibilityService? = null
        private const val PREFS_NAME = "focus_lock_prefs"
        private const val KEY_ACTIVE = "service_active"
        private const val KEY_BLACKLIST = "service_blacklist"
    }

    private var blacklistedPackages: Set<String> = emptySet()
    private var isActive = false

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (!isActive) return

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                val packageName = event.packageName?.toString()
                if (packageName != null && blacklistedPackages.contains(packageName)) {
                    val intent = Intent(this, MainActivity::class.java).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        putExtra("blacklisted_app", packageName)
                    }
                    startActivity(intent)
                }
            }
        }
    }

    fun setBlacklistedPackages(packages: Set<String>) {
        blacklistedPackages = packages
    }

    fun activate() {
        isActive = true
    }

    fun deactivate() {
        isActive = false
    }

    override fun onInterrupt() {}

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        if (prefs.getBoolean(KEY_ACTIVE, false)) {
            val saved = prefs.getStringSet(KEY_BLACKLIST, emptySet())
            blacklistedPackages = saved ?: emptySet()
            isActive = true
        }
    }

    override fun onDestroy() {
        instance = null
        super.onDestroy()
    }
}
