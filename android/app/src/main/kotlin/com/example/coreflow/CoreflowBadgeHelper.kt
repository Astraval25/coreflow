package com.example.coreflow

import android.content.Context
import android.content.Intent
import android.util.Log

object CoreflowBadgeHelper {
    private const val TAG = "CoreFlowBadge"

    fun setBadge(context: Context, count: Int): Boolean {
        val safeCount = count.coerceAtLeast(0)
        val appContext = context.applicationContext ?: context
        val launchIntent = appContext.packageManager.getLaunchIntentForPackage(appContext.packageName)
        val className = launchIntent?.component?.className ?: return false

        var sent = false
        sent = sendVivoBadge(appContext, className, safeCount) || sent
        sent = sendDefaultBadge(appContext, className, safeCount) || sent
        return sent
    }

    private fun sendVivoBadge(context: Context, className: String, count: Int): Boolean {
        return sendBadgeBroadcast(
            context,
            Intent("launcher.action.CHANGE_APPLICATION_NOTIFICATION_NUM").apply {
                putExtra("packageName", context.packageName)
                putExtra("className", className)
                putExtra("notificationNum", count)
                addIncludeBackgroundFlag()
            },
        )
    }

    private fun sendDefaultBadge(context: Context, className: String, count: Int): Boolean {
        val sentModern = sendBadgeBroadcast(
            context,
            Intent("me.hacket.launcherbadge.BADGE_COUNT_UPDATE").apply {
                putExtra("badge_count", count)
                putExtra("badge_count_package_name", context.packageName)
                putExtra("badge_count_class_name", className)
                addIncludeBackgroundFlag()
            },
        )

        val sentLegacy = sendBadgeBroadcast(
            context,
            Intent("android.intent.action.BADGE_COUNT_UPDATE").apply {
                putExtra("badge_count", count)
                putExtra("badge_count_package_name", context.packageName)
                putExtra("badge_count_class_name", className)
                addIncludeBackgroundFlag()
            },
        )

        return sentModern || sentLegacy
    }

    private fun sendBadgeBroadcast(context: Context, intent: Intent): Boolean {
        return try {
            context.sendBroadcast(intent)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Badge broadcast failed for ${intent.action}", e)
            false
        }
    }

    private fun Intent.addIncludeBackgroundFlag() {
        val includeBackgroundFlag = getIntentFlag("FLAG_RECEIVER_INCLUDE_BACKGROUND")
        if (includeBackgroundFlag != 0) {
            addFlags(includeBackgroundFlag)
        }
    }

    private fun getIntentFlag(flagName: String): Int {
        return try {
            val field = Intent::class.java.getField(flagName)
            field.getInt(null)
        } catch (_: Exception) {
            0
        }
    }
}
