package com.alarmapp.alarm_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

object NativeAlarmScheduler {
    const val EXTRA_ALARM_ID = "alarm_id"
    const val EXTRA_ALARM_JSON = "alarm_json"

    fun schedule(context: Context, alarm: JSONObject, overrideTriggerAt: Long? = null) {
        if (!alarm.optBoolean("enabled", true)) {
            cancel(context, alarm.getString("id"))
            return
        }

        val triggerAt = overrideTriggerAt ?: nextTriggerAt(alarm)
        val operation = alarmPendingIntent(context, alarm)
        val manager = context.getSystemService(AlarmManager::class.java)
        val showIntent = PendingIntent.getActivity(
            context,
            alarm.getString("id").hashCode(),
            Intent(context, MainActivity::class.java).apply {
                putExtra(EXTRA_ALARM_ID, alarm.getString("id"))
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S || manager.canScheduleExactAlarms()) {
            manager.setAlarmClock(AlarmManager.AlarmClockInfo(triggerAt, showIntent), operation)
        } else {
            manager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, operation)
        }
    }

    fun cancel(context: Context, alarmId: String) {
        context.getSystemService(AlarmManager::class.java).cancel(
            PendingIntent.getBroadcast(
                context,
                alarmId.hashCode(),
                Intent(context, AlarmReceiver::class.java),
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
            ) ?: return
        )
    }

    fun rescheduleAll(context: Context) {
        val preferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val stored = preferences.getString("flutter.alarms_v2", null) ?: return
        val alarms = JSONArray(stored)
        for (index in 0 until alarms.length()) {
            val alarm = alarms.getJSONObject(index)
            if (alarm.optBoolean("enabled", true)) schedule(context, alarm)
        }
    }

    fun scheduleNextOccurrence(context: Context, alarm: JSONObject) {
        val repeats = alarm.optBoolean("repeatDaily", false) ||
            alarm.optJSONArray("daysOfWeek")?.length()?.let { it > 0 } == true
        if (repeats) schedule(context, alarm)
    }

    private fun alarmPendingIntent(context: Context, alarm: JSONObject): PendingIntent {
        return PendingIntent.getBroadcast(
            context,
            alarm.getString("id").hashCode(),
            Intent(context, AlarmReceiver::class.java).apply {
                putExtra(EXTRA_ALARM_ID, alarm.getString("id"))
                putExtra(EXTRA_ALARM_JSON, alarm.toString())
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun nextTriggerAt(alarm: JSONObject): Long {
        val now = Calendar.getInstance()
        val target = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, alarm.getInt("hour"))
            set(Calendar.MINUTE, alarm.getInt("minute"))
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        val repeatDaily = alarm.optBoolean("repeatDaily", false)
        val days = alarm.optJSONArray("daysOfWeek")
        if (!target.after(now)) target.add(Calendar.DAY_OF_YEAR, 1)

        if (!repeatDaily && days != null && days.length() > 0) {
            val allowedDays = mutableSetOf<Int>()
            for (index in 0 until days.length()) {
                allowedDays.add(dayNameToCalendar(days.getString(index)))
            }
            repeat(7) {
                if (target.get(Calendar.DAY_OF_WEEK) in allowedDays && target.after(now)) {
                    return target.timeInMillis
                }
                target.add(Calendar.DAY_OF_YEAR, 1)
            }
        }

        return target.timeInMillis
    }

    private fun dayNameToCalendar(day: String): Int {
        return when (day) {
            "monday" -> Calendar.MONDAY
            "tuesday" -> Calendar.TUESDAY
            "wednesday" -> Calendar.WEDNESDAY
            "thursday" -> Calendar.THURSDAY
            "friday" -> Calendar.FRIDAY
            "saturday" -> Calendar.SATURDAY
            "sunday" -> Calendar.SUNDAY
            else -> Calendar.MONDAY
        }
    }
}
