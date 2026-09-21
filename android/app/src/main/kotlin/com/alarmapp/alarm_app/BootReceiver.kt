package com.alarmapp.alarm_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        NativeAlarmScheduler.rescheduleAll(context)
    }
}
