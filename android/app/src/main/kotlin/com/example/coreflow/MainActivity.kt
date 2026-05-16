package com.example.coreflow

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val BADGE_CHANNEL = "coreflow/badge"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BADGE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setBadge" -> {
                        val count = call.argument<Int>("count") ?: 0
                        result.success(CoreflowBadgeHelper.setBadge(this, count))
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
