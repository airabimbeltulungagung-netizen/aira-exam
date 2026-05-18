package com.example.aira_exam // SESUAIKAN dengan Application ID asli milikmu jika berbeda

import android.view.WindowManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter/launch"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setWindowSecure") {
                val secure = call.argument<Boolean>("secure") ?: false
                if (secure) {
                    // Kunci Layar agar tidak bisa di-screenshot / rekam layar
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    // Lepas kunci saat keluar ujian
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    // 🚨 BENTENG UTAMA: JIKA SISWA NEKAT MENGUSAP STATUS BAR (NOTIFIKASI) DOWN, PAKSA TUTUP KEMBALI INSTAN!
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (!hasFocus) {
            // Sinyal bahwa ada usapan laci notifikasi masuk, paksa tutup kembali panelnya!
            val closeIntent = android.content.Intent(android.content.Intent.ACTION_CLOSE_SYSTEM_DIALOGS)
            sendBroadcast(closeIntent)
        }
    }
}