package com.example.aira_exam // 🌟 WAJIB: Pastikan ini sama dengan Package ID asli proyekmu

import android.view.WindowManager
import android.os.Bundle
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter/launch"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Satpam Jembatan Penghubung Flutter ke Sistem Android Native
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setWindowSecure") {
                val secure = call.argument<Boolean>("secure") ?: false
                try {
                    if (secure) {
                        // Kunci Layar: Anti Screenshot & Anti Rekam Layar
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        // Lepas Kunci Jendela saat keluar ujian
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Gagal mengatur flag jendela secure", e.message)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    // 🚨 BENTENG ANTI-USAP STATUS BAR (DIAMANKAN DENGAN TRY-CATCH AGAR ANTI-MENTAL / CRASH)
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (!hasFocus) {
            try {
                // Trik taktis menutup paksa laci notifikasi/status bar secara instan saat diusap siswa
                @Suppress("DEPRECATION")
                val closeIntent = Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)
                sendBroadcast(closeIntent)
            } catch (e: Exception) {
                // Jika OS Android baru memblokir broadcast ini, biarkan sistem melewatkannya 
                // tanpa harus membuat aplikasi crash/mental keluar (Aplikasi Tetap Hidup Standby!)
            }
        }
    }
}