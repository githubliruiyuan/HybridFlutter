package com.cc.hybrid

import android.os.Bundle
import android.os.Handler
import android.os.Message
import com.cc.hybrid.bridge.flutter.FlutterPluginMethodChannel
import com.cc.hybrid.debug.Debugger
import com.cc.hybrid.event.EventManager
import com.cc.hybrid.util.LoadingUtil
import com.cc.hybrid.util.SpUtil
import com.cc.hybrid.util.ToastUtil
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.StringCodec
import io.flutter.plugins.GeneratedPluginRegistrant
import org.json.JSONObject
import java.lang.ref.WeakReference


class MainActivity : FlutterActivity() {

    private lateinit var debug: Debugger
    private lateinit var channel: BasicMessageChannel<String>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        registerCustomPlugin(this)
        registerMessageChannel()
        SpUtil.initSp(this)
        ToastUtil.initToast(this)
        LoadingUtil.initDialog(this)
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
        EventManager.instance.initHandler(MHandler(this))
    }

    private fun debug() {
        debug = Debugger("192.168.12.170", 9999)
        debug.startSocket()
    }

    private fun sendMessage2Flutter(type: Int, pageId: String, content: String) {
        val jsonObject = JSONObject()
        jsonObject.put("type", type)
        jsonObject.put("pageId", pageId)
        jsonObject.put("message", content)
        channel.send(jsonObject.toString())
    }

    override fun onDestroy() {
        super.onDestroy()
        LoadingUtil.destroy()
        EventManager.instance.destroy()
        debug.release()
    }

    class MHandler(activity: MainActivity) : Handler() {
        private val mActivity: WeakReference<MainActivity> = WeakReference(activity)
        override fun handleMessage(msg: Message?) {
            super.handleMessage(msg)
            if (null == msg) return
            val jsonObject = msg.obj as JSONObject
            val pageId = jsonObject.getString("pageId")
            val json = jsonObject.get("obj").toString()
            when (msg.what) {
                EventManager.TYPE_SOCKET -> {
                    mActivity.get()?.sendMessage2Flutter(EventManager.TYPE_SOCKET, pageId, json)
                }
                EventManager.TYPE_REFRESH -> {
                    mActivity.get()?.sendMessage2Flutter(EventManager.TYPE_REFRESH, pageId, json)
                }
                EventManager.TYPE_NAVIGATION_BAR_TITLE -> {
                    mActivity.get()?.sendMessage2Flutter(EventManager.TYPE_NAVIGATION_BAR_TITLE, pageId, json)
                }
                EventManager.TYPE_NAVIGATE_TO -> {
                    mActivity.get()?.sendMessage2Flutter(EventManager.TYPE_NAVIGATE_TO, pageId, json)
                }
                EventManager.TYPE_NAVIGATION_BAR_COLOR -> {
                    mActivity.get()?.sendMessage2Flutter(EventManager.TYPE_NAVIGATION_BAR_COLOR, pageId, json)
                }
                EventManager.TYPE_BACKGROUND_COLOR -> {
                    mActivity.get()?.sendMessage2Flutter(EventManager.TYPE_BACKGROUND_COLOR, pageId, json)
                }
                EventManager.TYPE_START_PULL_DOWN_REFRESH -> {
                    mActivity.get()?.sendMessage2Flutter(EventManager.TYPE_START_PULL_DOWN_REFRESH, pageId, json)
                }
                EventManager.TYPE_STOP_PULL_DOWN_REFRESH -> {
                    mActivity.get()?.sendMessage2Flutter(EventManager.TYPE_STOP_PULL_DOWN_REFRESH, pageId, json)
                }
            }
        }
    }
}