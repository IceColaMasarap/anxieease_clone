package com.example.ctrlzed

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.graphics.Bitmap
import android.os.Build
import androidx.core.app.NotificationCompat

class NotificationHelper(private val context: Context) {
    companion object {
        const val CHANNEL_ID = "default"
        const val CHANNEL_NAME = "Default Channel"
    }

    init {
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun buildBigPictureStyleNotification(
        title: String,
        content: String,
        bigPicture: Bitmap?,
        largeIcon: Bitmap?
    ): NotificationCompat.Builder {
        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(content)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)

        if (bigPicture != null) {
            val bigPictureStyle = NotificationCompat.BigPictureStyle()
                .bigPicture(bigPicture)
            if (largeIcon != null) {
                bigPictureStyle.bigLargeIcon(largeIcon)
            }
            builder.setStyle(bigPictureStyle)
        }

        return builder
    }
} 