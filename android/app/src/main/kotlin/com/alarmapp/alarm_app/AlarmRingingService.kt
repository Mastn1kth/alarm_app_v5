package com.alarmapp.alarm_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.core.app.NotificationCompat
import org.json.JSONObject

class AlarmRingingService : Service() {
    private var player: MediaPlayer? = null
    private var vibrator: Vibrator? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val alarmJson = intent?.getStringExtra(NativeAlarmScheduler.EXTRA_ALARM_JSON)
            ?: return START_NOT_STICKY
        val alarm = JSONObject(alarmJson)
        startForeground(NOTIFICATION_ID, buildNotification(alarm))
        startSound(alarm)
        startVibration(alarm)
        return START_STICKY
    }

    override fun onDestroy() {
        player?.stop()
        player?.release()
        player = null
        vibrator?.cancel()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun buildNotification(alarm: JSONObject): Notification {
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Alarm ringing",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Full-screen alarm notifications"
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                setSound(null, null)
                enableVibration(false)
            }
        )

        val alarmId = alarm.getString("id")
        val fullScreenIntent = PendingIntent.getActivity(
            this,
            alarmId.hashCode(),
            Intent(this, MainActivity::class.java).apply {
                putExtra(NativeAlarmScheduler.EXTRA_ALARM_ID, alarmId)
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                )
            },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(alarm.optString("title", "Alarm"))
            .setContentText("Complete the mission to stop the alarm")
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setContentIntent(fullScreenIntent)
            .setFullScreenIntent(fullScreenIntent, true)
            .build()
    }

    private fun startSound(alarm: JSONObject) {
        player?.release()
        val resource = when (alarm.optString("soundPack", "default_")) {
            "classic" -> R.raw.classic_alarm
            "military" -> R.raw.military_alarm
            "nature" -> R.raw.nature_alarm
            "emergency" -> R.raw.emergency_alarm
            "sciFi" -> R.raw.scifi_alarm
            else -> R.raw.default_alarm
        }
        val descriptor = resources.openRawResourceFd(resource)
        player = MediaPlayer().apply {
            setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            setDataSource(
                descriptor.fileDescriptor,
                descriptor.startOffset,
                descriptor.length,
            )
            isLooping = true
            val volume = alarm.optDouble("soundVolume", 1.0).toFloat().coerceIn(0f, 1f)
            setVolume(volume, volume)
            prepare()
            start()
        }
        descriptor.close()
        val audioManager = getSystemService(AudioManager::class.java)
        audioManager.requestAudioFocus(null, AudioManager.STREAM_ALARM, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
    }

    private fun startVibration(alarm: JSONObject) {
        if (!alarm.optBoolean("vibrationEnabled", true)) return
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            getSystemService(VibratorManager::class.java).defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(VIBRATOR_SERVICE) as Vibrator
        }
        val pattern = longArrayOf(0, 700, 300, 700, 300)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(pattern, 0)
        }
    }

    companion object {
        private const val CHANNEL_ID = "alarm_ringing"
        private const val NOTIFICATION_ID = 9001
    }
}
