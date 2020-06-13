package com.cc.hybrid

import android.app.Application
import com.cc.hybrid.v8.V8Manager
import io.flutter.view.FlutterMain

class MFlutterApplication: Application() {

    override fun onCreate() {
        super.onCreate()
        FlutterMain.startInitialization(this)
        V8Manager.initV8(this)
    }

}