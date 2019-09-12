package com.cc.hybrid.v8

import android.content.Context
import com.cc.hybrid.Logger
import com.cc.hybrid.bridge.js.JSConsole
import com.cc.hybrid.util.TimerManager
import com.eclipsesource.v8.JavaCallback
import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Array
import com.eclipsesource.v8.V8Object
import okio.Okio
import java.io.IOException

object V8Manager {

    lateinit var v8: V8

    fun initV8(context: Context) {
        v8 = V8.createV8Runtime()
        executeScript("var global = this;")
        registerObj()
        registerFunc()
        evaluateJsFileFromAsset(context, "framework.js")
    }

    private fun registerObj() {
        val v8Console = V8Object(v8)
        v8.add("console", v8Console)
        val jsConsole = JSConsole()
        v8Console.registerJavaMethod(jsConsole, "log", "log", arrayOf<Class<*>>(java.lang.Object::class.java))
        v8Console.release()
    }

    private fun registerFunc() {
        v8.registerJavaMethod(JavaCallback { receiver, parameters ->
            val pageId = parameters.getString(0)
            val timerId = parameters.getString(1)
            val delayed = parameters?.getInteger(2)
            if (null != delayed) {
                TimerManager.setTimeout(pageId, timerId, delayed)
            }
            receiver as Any
        }, "__native__setTimeout")
        v8.registerJavaMethod(JavaCallback { receiver, parameters ->
            val timerId = parameters.getString(0)
            TimerManager.delTimer(timerId)
            receiver as Any
        }, "__native__clearTimeout")
        v8.registerJavaMethod(JavaCallback { receiver, parameters ->
            val pageId = parameters.getString(0)
            val timerId = parameters.getString(1)
            val delayed = parameters?.getInteger(2)
            if (null != delayed) {
                TimerManager.setInterval(pageId, timerId, delayed)
            }
            receiver as Any
        }, "__native__setInterval")
        v8.registerJavaMethod(JavaCallback { receiver, parameters ->
            val timerId = parameters.getString(0)
            TimerManager.delTimer(timerId)
            receiver as Any
        }, "__native__clearInterval")
    }

    @Throws(IOException::class)
    fun evaluateJsFileFromAsset(context: Context, filename: String) {
        val source = Okio.buffer(Okio.source(context.assets.open(filename)))
        var script = source.readUtf8()
        if (null == script) {
            script = ""
        }
        source.close()
        executeScript(script)
    }

    fun executeScript(script: String): Any? {
        try {
            return v8.executeScript(script)
        } catch (e: Exception) {
            Logger.printError(e)
        }
        return null
    }


}