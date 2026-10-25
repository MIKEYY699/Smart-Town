package com.example.mohallaconnect

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "high_importance_channel",
                "Smart Town alerts",
                NotificationManager.IMPORTANCE_HIGH
            )
            channel.description = "Request updates and messages"
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }
}