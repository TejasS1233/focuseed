package com.focusapp.focus_app

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class FocusAccessibilityService : AccessibilityService() {
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
    }
}
