package com.example.coreflow

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingReceiver

class CoreflowFirebaseMessagingReceiver : FlutterFirebaseMessagingReceiver() {
    companion object {
        private const val TAG = "CoreFlowFcmReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        updateBadgeFromExtras(context, intent.extras)
        super.onReceive(context, intent)
    }

    private fun updateBadgeFromExtras(context: Context, extras: Bundle?) {
        val badgeCount = parseBadgeCount(extras) ?: return
        val sent = CoreflowBadgeHelper.setBadge(context, badgeCount)
        Log.d(TAG, "Native background badge update count=$badgeCount sent=$sent")
    }

    private fun parseBadgeCount(extras: Bundle?): Int? {
        if (extras == null) return null

        for (key in listOf("badge", "badgeCount", "unreadCount", "notificationCount")) {
            val value = extras.get(key) ?: continue
            when (value) {
                is Int -> return value.coerceAtLeast(0)
                is Long -> return value.toInt().coerceAtLeast(0)
                is Number -> return value.toInt().coerceAtLeast(0)
                else -> value.toString().trim().toIntOrNull()?.let {
                    return it.coerceAtLeast(0)
                }
            }
        }

        return null
    }
}
