package com.alarmapp.alarm_app

import android.Manifest
import android.app.AlarmManager
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val channelName = "com.alarmapp.alarm_app/scheduler"
    private val stepChannelName = "com.alarmapp.alarm_app/steps"
    private var channel: MethodChannel? = null
    private var pendingAlarmId: String? = null
    private var waitingForExactAlarmAccess = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setShowWhenLocked(true)
        setTurnScreenOn(true)
        pendingAlarmId = intent?.getStringExtra(NativeAlarmScheduler.EXTRA_ALARM_ID)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ActivityCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                1001,
            )
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            ActivityCompat.checkSelfPermission(this, Manifest.permission.ACTIVITY_RECOGNITION) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.ACTIVITY_RECOGNITION),
                1002,
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, stepChannelName)
            .setStreamHandler(StepDetectorStreamHandler(this))
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel?.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "initialize" -> {
                        requestExactAlarmAccessIfNeeded()
                        result.success(true)
                    }
                    "scheduleAlarm" -> {
                        val alarm = JSONObject(call.arguments as Map<*, *>)
                        NativeAlarmScheduler.schedule(this, alarm)
                        result.success(true)
                    }
                    "cancelAlarm" -> {
                        NativeAlarmScheduler.cancel(this, call.argument<String>("alarmId")!!)
                        result.success(true)
                    }
                    "snoozeAlarm" -> {
                        val arguments = call.arguments as Map<*, *>
                        val alarm = JSONObject(arguments["alarm"] as Map<*, *>)
                        val durationMs = (arguments["durationMs"] as Number).toLong()
                        NativeAlarmScheduler.schedule(
                            this,
                            alarm,
                            System.currentTimeMillis() + durationMs,
                        )
                        stopService(Intent(this, AlarmRingingService::class.java))
                        result.success(true)
                    }
                    "rescheduleAll" -> {
                        NativeAlarmScheduler.rescheduleAll(this)
                        result.success(true)
                    }
                    "stopRinging" -> {
                        stopService(Intent(this, AlarmRingingService::class.java))
                        result.success(true)
                    }
                    "consumeLaunchAlarmId" -> {
                        val alarmId = pendingAlarmId
                        pendingAlarmId = null
                        result.success(alarmId)
                    }
                    "canScheduleExactAlarms" -> {
                        val manager = getSystemService(AlarmManager::class.java)
                        result.success(
                            Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                                manager.canScheduleExactAlarms()
                        )
                    }
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                result.error("ALARM_PLATFORM_ERROR", error.message, null)
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val alarmId = intent.getStringExtra(NativeAlarmScheduler.EXTRA_ALARM_ID)
        if (alarmId != null) {
            pendingAlarmId = alarmId
            channel?.invokeMethod("alarmTriggered", alarmId)
        }
    }

    override fun onResume() {
        super.onResume()
        if (waitingForExactAlarmAccess &&
            (Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                getSystemService(AlarmManager::class.java).canScheduleExactAlarms())
        ) {
            waitingForExactAlarmAccess = false
            NativeAlarmScheduler.rescheduleAll(this)
        }
    }

    private fun requestExactAlarmAccessIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
        val manager = getSystemService(AlarmManager::class.java)
        if (!manager.canScheduleExactAlarms()) {
            waitingForExactAlarmAccess = true
            startActivity(
                Intent(
                    Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM,
                    Uri.parse("package:$packageName"),
                )
            )
        }
    }
}
