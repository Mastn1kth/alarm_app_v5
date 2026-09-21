package com.alarmapp.alarm_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat
import org.json.JSONObject

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarmJson = intent.getStringExtra(NativeAlarmScheduler.EXTRA_ALARM_JSON) ?: return
        val alarm = JSONObject(alarmJson)
        ContextCompat.startForegroundService(
            context,
            Intent(context, AlarmRingingService::class.java).apply {
                putExtra(NativeAlarmScheduler.EXTRA_ALARM_ID, alarm.getString("id"))
                putExtra(NativeAlarmScheduler.EXTRA_ALARM_JSON, alarmJson)
            },
        )
        NativeAlarmScheduler.scheduleNextOccurrence(context, alarm)
    }
}
