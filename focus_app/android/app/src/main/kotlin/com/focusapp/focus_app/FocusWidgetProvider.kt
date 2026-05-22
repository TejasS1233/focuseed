package com.focusapp.focus_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.widget.RemoteViews

class FocusWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            try {
                updateWidget(context, appWidgetManager, appWidgetId)
            } catch (e: Exception) {
                Log.e("FocusWidget", "Error updating widget $appWidgetId", e)
            }
        }
    }

    override fun onEnabled(context: Context) {
        try {
            updateAllWidgets(context)
        } catch (e: Exception) {
            Log.e("FocusWidget", "Error in onEnabled", e)
        }
    }

    companion object {
        private const val PREFS_NAME = "HomeWidgetPreferences"
        private const val KEY_STREAK = "streak"
        private const val KEY_TODAY = "today_minutes"
        private const val TAG = "FocusWidget"

        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val prefs: SharedPreferences =
                context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val streak = prefs.getInt(KEY_STREAK, 0)
            val todayMinutes = prefs.getInt(KEY_TODAY, 0)

            val views = RemoteViews(context.packageName, R.layout.focus_widget)
            views.setTextViewText(R.id.widget_streak, "$streak")
            views.setTextViewText(R.id.widget_streak_label, "DAY STREAK")
            views.setTextViewText(R.id.widget_today, "$todayMinutes")
            views.setTextViewText(R.id.widget_today_label, "MIN TODAY")

            val intent = Intent(context, MainActivity::class.java)
            intent.action = Intent.ACTION_MAIN
            intent.addCategory(Intent.CATEGORY_LAUNCHER)
            val pi = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_button, pi)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, FocusWidgetProvider::class.java)
            )
            for (id in ids) {
                updateWidget(context, manager, id)
            }
        }
    }
}
