package com.cc.hybrid.v8

import android.content.Context
import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Object
import com.cc.hybrid.Logger
import com.cc.hybrid.bridge.js.JSConsole
import okio.Okio
import java.io.IOException

object V8Manager {

    lateinit var v8: V8

    fun initV8(context: Context) {
        v8 = V8.createV8Runtime()
        executeScript("var global = this;")
        evaluateJsFileFromAsset(context, "framework.js")
        registerFunc()
    }

    private fun registerFunc() {
        val v8Console = V8Object(v8)
        v8.add("console", v8Console)
        val jsConsole = JSConsole()
        v8Console.registerJavaMethod(jsConsole, "log", "log", arrayOf<Class<*>>(java.lang.Object::class.java))
        v8Console.release()
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