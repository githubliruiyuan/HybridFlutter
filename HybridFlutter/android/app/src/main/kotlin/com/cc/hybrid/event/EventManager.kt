package com.cc.hybrid.event

import android.os.Handler

class EventManager {

    companion object {
        const val TYPE_SOCKET = 0
        const val TYPE_ONCLICK = 1
        const val TYPE_NAVIGATION_BAR_TITLE = 2
        const val TYPE_NAVIGATE_TO = 3
        var instance = EventManager()
    }

    var handler: Handler? = null

}