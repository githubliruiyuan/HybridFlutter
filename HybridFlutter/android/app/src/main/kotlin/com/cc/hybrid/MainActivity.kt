package com.cc.hybrid

import android.os.Bundle
import android.os.Handler
import android.os.Message
import com.cc.hybrid.bridge.flutter.FlutterPluginMethodChannel
import com.cc.hybrid.debug.PPDebugger
import com.cc.hybrid.event.EventManager
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.StringCodec
import io.flutter.plugins.GeneratedPluginRegistrant
import org.json.JSONObject
import java.lang.ref.WeakReference


class MainActivity : FlutterActivity() {

    private lateinit var handler: MHandler
    private lateinit var debug: PPDebugger
    private lateinit var channel: BasicMessageChannel<String>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        registerCustomPlugin(this)
        registerMessageChannel()
        initHandler()
        debug()
    }

    private fun registerCustomPlugin(registrar: PluginRegistry) {
        FlutterPluginMethodChannel.registerWith(registrar.registrarFor(FlutterPluginMethodChannel.CHANNEL))
    }

    private fun registerMessageChannel() {
        channel = BasicMessageChannel<String>(flutterView, "com.cc.hybrid/basic", StringCodec.INSTANCE)
    }

    private fun initHandler() {
        handler = MHandler(this)
        EventManager.instance.handler = handler
    }

    private fun debug() {
        debug = PPDebugger("192.168.12.170", 9999, handler)
        debug.startSocket()
    }

    private fun sendMessage2Flutter(type: Int, content: String) {
        val jsonObject = JSONObject()
        jsonObject.put("type", type)
        jsonObject.put("message", content)
        channel.send(jsonObject.toString())
    }

    override fun onDestroy() {
        super.onDestroy()
        debug.release()
    }

    class MHandler(activity: MainActivity) : Handler() {
        private val mActivity: WeakReference<MainActivity> = WeakReference(activity)
        override fun handleMessage(msg: Message?) {
            super.handleMessage(msg)
            when (msg?.what) {
                EventManager.TYPE_SOCKET -> {
                    val json = msg.obj.toString()
                    mActivity.get()?.sendMessage2Flutter(EventManager.TYPE_SOCKET, json)
                }
                EventManager.TYPE_ONCLICK -> {
                    mActivity.get()?.sendMessage2Flutter(EventManager.TYPE_ONCLICK, "")
                }
            }
        }
    }

}