package com.epic.aprecture

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.epic.aprecture/package_events"
    private var packageReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    packageReceiver = object : BroadcastReceiver() {
                        override fun onReceive(context: Context?, intent: Intent?) {
                            if (intent == null || events == null) return

                            // Extract the package name (e.g., "package:com.example.otherapp")
                            val packageName = intent.data?.schemeSpecificPart ?: ""
                            val action = intent.action ?: ""

                            val eventType = when (action) {
                                Intent.ACTION_PACKAGE_ADDED -> "installed"
                                Intent.ACTION_PACKAGE_REMOVED -> "uninstalled"
                                Intent.ACTION_PACKAGE_REPLACED -> "updated"
                                else -> "unknown"
                            }

                            // Pass map payload to Flutter
                            val data = mapOf(
                                "eventType" to eventType,
                                "packageName" to packageName
                            )
                            events.success(data)
                        }
                    }

                    // Register listener for package modification intents
                    val filter = IntentFilter().apply {
                        addAction(Intent.ACTION_PACKAGE_ADDED)
                        addAction(Intent.ACTION_PACKAGE_REMOVED)
                        addAction(Intent.ACTION_PACKAGE_REPLACED)
                        addDataScheme("package")
                    }

                    context.registerReceiver(packageReceiver, filter)
                }

                override fun onCancel(arguments: Any?) {
                    // Unregister receiver to prevent memory leaks when Flutter stops listening
                    packageReceiver?.let {
                        context.unregisterReceiver(it)
                        packageReceiver = null
                    }
                }
            })
    }
}
