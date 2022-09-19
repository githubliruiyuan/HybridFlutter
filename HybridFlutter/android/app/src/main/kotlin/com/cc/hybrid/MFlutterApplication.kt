package com.cc.hybrid

import android.app.Application
import com.cc.hybrid.v8.V8Manager

class MFlutterApplication: Application() {

    override fun onCreate() {
        super.onCreate()
        V8Manager.initV8(this)
    }

}