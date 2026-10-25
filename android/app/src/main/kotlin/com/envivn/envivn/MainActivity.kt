package com.envivn.envivn

import android.app.ActivityManager
import android.content.Context
import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "vn.envi.app/disk_space"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAvailableDiskSpaceBytes" -> {
                    try {
                        val stat = StatFs(filesDir.absolutePath)
                        result.success(stat.availableBytes)
                    } catch (e: Exception) {
                        result.error("DISK_SPACE_ERROR", e.message, null)
                    }
                }
                "getAvailableRamBytes" -> {
                    try {
                        val actManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                        val memInfo = ActivityManager.MemoryInfo()
                        actManager.getMemoryInfo(memInfo)
                        result.success(memInfo.availMem)
                    } catch (e: Exception) {
                        result.error("RAM_INFO_ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
