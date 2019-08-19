package com.cc.hybrid

import android.app.Activity
import android.app.Application
import com.cc.hybrid.v8.V8Manager
import io.flutter.view.FlutterMain

class MFlutterApplication: Application() {
    private var mCurrentActivity: Activity? = null

    override fun onCreate() {
        super.onCreate()
        FlutterMain.startInitialization(this)
        V8Manager.initV8(this)
    }

    fun getCurrentActivity(): Activity? {
        return this.mCurrentActivity
    }

    fun setCurrentActivity(mCurrentActivity: Activity) {
        this.mCurrentActivity = mCurrentActivity
    }

}