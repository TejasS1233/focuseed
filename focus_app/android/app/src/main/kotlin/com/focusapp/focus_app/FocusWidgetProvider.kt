package com.focusapp.focus_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.widget.RemoteViews

class FocusWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFS_NAME = "home_widget_prefs"
        private const val KEY_STREAK = "streak"
        private const val KEY_TODAY = "today_minutes"

        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val prefs: SharedPreferences =
                context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val streak = prefs.getInt(KEY_STREAK, 0)
            val todayMinutes = prefs.getInt(KEY_TODAY, 0)

            val views = RemoteViews(context.packageName, R.layout.focus_widget)
            views.setTextViewText(R.id.widget_streak, "$streak")
            views.setTextViewText(R.id.widget_streak_label,
                if (streak == 1) "DAY STREAK" else "DAY STREAK")
            views.setTextViewText(R.id.widget_today, "$todayMinutes MIN TODAY")

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                views.setFloat(R.id.widget_title, "setLetterSpacing", 0.18f)
                views.setFloat(R.id.widget_streak, "setLetterSpacing", 0.03f)
                views.setFloat(R.id.widget_button, "setLetterSpacing", 0.12f)
            }

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
