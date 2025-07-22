package org.aliflang.editor

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "alif/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getNativeLibDir") {
                    val libDir = applicationContext.applicationInfo.nativeLibraryDir
                    result.success(libDir)
                } else {
                    result.notImplemented()
                }
            }
    }
}
