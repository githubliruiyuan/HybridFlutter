package com.cc.hybrid.event

import android.os.Handler
import android.os.Message
import org.json.JSONObject

class EventManager {

    companion object {
        const val TYPE_SOCKET = 0
        const val TYPE_REFRESH = 1
        const val TYPE_NAVIGATION_BAR_TITLE = 2
        const val TYPE_NAVIGATE_TO = 3
        const val TYPE_NAVIGATION_BAR_COLOR = 4
        const val TYPE_BACKGROUND_COLOR = 5
        const val TYPE_START_PULL_DOWN_REFRESH = 6
        const val TYPE_STOP_PULL_DOWN_REFRESH = 7
        var instance = EventManager()
    }

    private var handler: Handler? = null

    fun initHandler(handler: Handler) {
        this.handler = handler
    }

    fun sendMessage(what: Int, pageId: String, obj: Any) {
        val jsonObject = JSONObject()
        jsonObject.put("pageId", pageId)
        jsonObject.put("obj", obj)
        val msg = Message.obtain()
        msg.what = what
        msg.obj = jsonObject
        handler?.sendMessage(msg)
    }

    fun destroy(){
        handler?.removeCallbacksAndMessages(null)
        handler = null
    }


}