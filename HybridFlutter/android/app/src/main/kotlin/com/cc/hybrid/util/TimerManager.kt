package com.cc.hybrid.util

import android.os.Handler
import android.os.Message
import com.cc.hybrid.bridge.js.JSPageManager

object TimerManager {

    private const val TYPE_SET_TIME_OUT = 1
    private const val TYPE_TICK = 2

    private val timers = mutableSetOf<String>()
    private val pageTimers = mutableMapOf<String, MutableSet<String>>()

    private var intervalHandler: MHandler? = null

    init {
        intervalHandler = MHandler()
    }

    private fun addTimer(pageId: String, timerId: String) {
        timers.add(timerId)
        var set = pageTimers[pageId]
        if (null == set) {
            set = mutableSetOf()
        }
        set.add(timerId)
        pageTimers[pageId] = set
    }

    fun setTimeout(pageId: String, timerId: String, delayed: Int) {
        val msg = intervalHandler?.obtainMessage()
        msg?.what = timerId.hashCode()
        val intervalEvent = IntervalEvent(timerId, TYPE_SET_TIME_OUT, delayed)
        msg?.obj = intervalEvent
        intervalHandler?.sendMessageDelayed(msg, delayed.toLong())
        addTimer(pageId, timerId)
    }

    fun delTimer(timerId: String) {
        intervalHandler?.removeMessages(timerId.hashCode())
        timers.remove(timerId)
    }

    fun delTimerByPageId(pageId: String) {
        val set = pageTimers[pageId]
        if (null != set) {
            timers.removeAll(set)
        }
    }

    internal class IntervalEvent constructor(val timerId: String, val type: Int, millis: Int)

    internal class MHandler : Handler() {
        override fun handleMessage(msg: Message) {
            val intervalEvent = msg.obj as IntervalEvent
            if (isExist(intervalEvent)) {
                when (intervalEvent.type) {
                    TYPE_SET_TIME_OUT -> {
                        JSPageManager.callback(intervalEvent.timerId)
                        timers.remove(intervalEvent.timerId)
                    }
                    TYPE_TICK -> {
//                        onTick(intervalEvent)
                    }
                }
            }
            super.handleMessage(msg)
        }

        private fun isExist(intervalEvent: IntervalEvent): Boolean {
            return timers.contains(intervalEvent.timerId)
        }

//        private fun onTick(intervalEvent: IntervalEvent) {
//            val msg = this.obtainMessage((intervalEvent.pageId + intervalEvent.timerId).hashCode())
//            msg.obj = intervalEvent
//            this.sendMessageDelayed(msg, intervalEvent.millis)
//        }
    }

}