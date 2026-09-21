package com.alarmapp.alarm_app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.EventChannel

class StepDetectorStreamHandler(
    private val context: Context,
) : EventChannel.StreamHandler, SensorEventListener {
    private val sensorManager =
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private var events: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACTIVITY_RECOGNITION,
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            eventSink.error(
                "ACTIVITY_RECOGNITION_DENIED",
                "Activity recognition permission is required for step detection.",
                null,
            )
            return
        }

        val detector = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        if (detector == null) {
            eventSink.error(
                "STEP_DETECTOR_UNAVAILABLE",
                "This device has no hardware step detector.",
                null,
            )
            return
        }

        events = eventSink
        sensorManager.registerListener(
            this,
            detector,
            SensorManager.SENSOR_DELAY_NORMAL,
        )
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
        events = null
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type == Sensor.TYPE_STEP_DETECTOR && event.values[0] > 0f) {
            events?.success(1)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit
}
