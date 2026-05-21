package com.example.myapp

import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager

import androidx.annotation.NonNull

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "aira.exam/launch"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ANTI SCREENSHOT
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )

        aktifkanFullscreen()
    }

    override fun configureFlutterEngine(
        @NonNull flutterEngine: FlutterEngine
    ) {

        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "setWindowSecure") {

                val secure =
                    call.argument<Boolean>("secure") ?: false

                try {

                    if (secure) {

                        window.addFlags(
                            WindowManager.LayoutParams.FLAG_SECURE
                        )

                    } else {

                        window.clearFlags(
                            WindowManager.LayoutParams.FLAG_SECURE
                        )
                    }

                    result.success(true)

                } catch (e: Exception) {

                    result.error(
                        "ERROR",
                        "Gagal mengatur secure window",
                        e.message
                    )
                }

            } else {

                result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()

        aktifkanFullscreen()
    }

    private fun aktifkanFullscreen() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {

            window.insetsController?.let {

                it.hide(
                    WindowInsets.Type.statusBars() or
                    WindowInsets.Type.navigationBars()
                )

                it.systemBarsBehavior =
                    WindowInsetsController
                        .BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }

        } else {

            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility =
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                View.SYSTEM_UI_FLAG_FULLSCREEN or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
        }
    }
}