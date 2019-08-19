package com.cc.hybrid.event

import android.os.Handler

class EventManager {

    companion object {
        const val TYPE_SOCKET = 0
        const val TYPE_ONCLICK = 1
        var instance = EventManager()
    }

    var handler: Handler? = null

}