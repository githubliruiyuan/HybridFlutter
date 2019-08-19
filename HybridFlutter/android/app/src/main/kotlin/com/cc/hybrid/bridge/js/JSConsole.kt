package com.cc.hybrid.bridge.js

import android.util.Log

class JSConsole {
    fun log(string: Any) {
        Log.d("js", string.toString())
    }
}