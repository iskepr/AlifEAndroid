package org.aliflang.editor

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "alif/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "prepareAlifRuntime" -> {
                        try {
                            val soPath = prepareAlifRuntime()
                            result.success(soPath)
                        } catch (e: Exception) {
                            result.error("COPY_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun prepareAlifRuntime(): String {
        val baseDir = File(applicationContext.filesDir, "alif")
        if (!baseDir.exists()) baseDir.mkdirs()
    
        // نسخ libalif.so
        val soSrc = File(applicationContext.applicationInfo.nativeLibraryDir, "libalif.so")
        val soDest = File(baseDir, "libalif.so")
        soSrc.copyTo(soDest, overwrite = true)
    
        // نسخ libc++_shared.so
        val cppSrc = File(applicationContext.applicationInfo.nativeLibraryDir, "libc++_shared.so")
        val cppDest = File(baseDir, "libc++_shared.so")
        if (cppSrc.exists()) {
            cppSrc.copyTo(cppDest, overwrite = true)
        } else {
            throw Exception("libc++_shared.so not found in nativeLibraryDir: ${cppSrc.absolutePath}")
        }
    
        // نسخ ملفات مجلد library/
        val libDir = File(baseDir, "library")
        if (!libDir.exists()) libDir.mkdirs()
    
        val libFiles = applicationContext.assets.list("library") ?: arrayOf()
        for (name in libFiles) {
            applicationContext.assets.open("library/$name").use { input ->
                val outFile = File(libDir, name)
                FileOutputStream(outFile).use { output ->
                    input.copyTo(output)
                }
            }
        }
    
        return soDest.absolutePath
    }
}
