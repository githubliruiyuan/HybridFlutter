package com.cc.hybrid.v8

import android.content.Context
import android.os.Message
import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Object
import com.cc.hybrid.Logger
import com.cc.hybrid.bridge.js.JSConsole
import com.cc.hybrid.bridge.js.JSNetwork
import com.cc.hybrid.util.LoadingUtil
import com.cc.hybrid.event.EventManager
import com.eclipsesource.v8.JavaCallback
import okio.Okio
import org.json.JSONObject
import java.io.IOException
import java.util.*

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

        val cc = V8Manager.v8.getObject("cc")
        cc.registerJavaMethod(JavaCallback { p0, p1 ->
            val data = p1?.getObject(0)
            if (null != data && data.contains("title")) {
                val msg = Message.obtain()
                msg.what = EventManager.TYPE_NAVIGATION_BAR_TITLE
                msg.obj = data.getString("title")
                EventManager.instance.handler?.sendMessage(msg)
            }
            p0 as Any
        }, "setNavigationBarTitle")
        cc.registerJavaMethod(JavaCallback { p0, p1 ->
            val data = p1?.getObject(0)
            if (null != data) {
                val jsonObject = JSONObject()
                data.keys.forEach {
                    jsonObject.put(it, data.get(it))
                }
                val msg = Message.obtain()
                msg.what = EventManager.TYPE_NAVIGATE_TO
                msg.obj = jsonObject.toString()
                EventManager.instance.handler?.sendMessage(msg)
            }
            p0 as Any
        }, "navigateTo")
        cc.registerJavaMethod(JavaCallback { p0, p1 ->
            val data = p1?.getObject(0)
            data?.add("requestId", UUID.randomUUID().toString())
            cc.getObject("requestData").add(data?.getString("requestId"), data)
            JSNetwork().request(data!!)
            p0 as Any
        }, "request")

        cc.registerJavaMethod(JavaCallback { p0, p1 ->
            val data = p1?.getObject(0)
            LoadingUtil.showLoading(data)
            p0 as Any
        }, "showLoading")

        cc.registerJavaMethod(JavaCallback { p0, p1 ->
            LoadingUtil.hideLoading()
            p0 as Any
        }, "hideLoading")
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