package com.cc.hybrid.bridge.flutter

import android.app.Activity
import com.cc.hybrid.Logger
import com.cc.hybrid.bridge.js.JSPageManager
import com.cc.hybrid.util.TimerManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class FlutterPluginMethodChannel(activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {

        const val CHANNEL = "com.cc.hybrid/method"
        private lateinit var channel: MethodChannel

        fun registerWith(registrar: PluginRegistry.Registrar) {
            channel = MethodChannel(registrar.messenger(), CHANNEL)
            val instance = FlutterPluginMethodChannel(registrar.activity())
            channel.setMethodCallHandler(instance)
        }
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            Methods.ATTACH_PAGE -> {
                if (methodCall.hasArgument("pageId") && methodCall.hasArgument("script")) {
                    val pageId = methodCall.argument<String>("pageId")
                    val script = methodCall.argument<String>("script")
                    JSPageManager.attachPageScriptToJsCore(pageId!!, script!!)
                    result.success("success")
                }
            }
            Methods.ON_LOAD -> {
                if (methodCall.hasArgument("pageId")) {
                    val pageId = methodCall.argument<String>("pageId")
                    val args = methodCall.argument<String>("args")
                    JSPageManager.callMethodInPage(pageId!!, Methods.ON_LOAD, args)
                    result.success("success")
                }
            }
            Methods.ON_UNLOAD -> {
                if (methodCall.hasArgument("pageId")) {
                    val pageId = methodCall.argument<String>("pageId")
                    TimerManager.delTimerByPageId(pageId!!)
                    JSPageManager.callMethodInPage(pageId, Methods.ON_UNLOAD)
                    JSPageManager.removePage(pageId)
                    result.success("success")
                }
            }
            Methods.EVENT -> {
                if (methodCall.hasArgument("pageId") && methodCall.hasArgument("event") && methodCall.hasArgument("data")) {
                    val pageId = methodCall.argument<String>("pageId")
                    val event = methodCall.argument<String>("event")
                    val data = methodCall.argument<String>("data")
                    JSPageManager.callMethodInPage(pageId!!, event!!, data)
                    result.success("success")
                }
            }
            Methods.ON_PULL_DOWN_REFRESH -> {
                if (methodCall.hasArgument("pageId")) {
                    val pageId = methodCall.argument<String>("pageId")
                    JSPageManager.callMethodInPage(pageId!!, Methods.ON_PULL_DOWN_REFRESH, null)
                    result.success("success")
                }
            }
            //以下是__native__内部函数回调
            Methods.INIT_COMPLETE -> {
                if (methodCall.hasArgument("pageId")) {
                    val pageId = methodCall.argument<String>("pageId")
                    JSPageManager.onInitComplete(pageId!!)
                    result.success("success")
                }
            }
            Methods.HANDLE_EXPRESSION -> {
                if (methodCall.hasArgument("pageId") && methodCall.hasArgument("id") && methodCall.hasArgument("type") && methodCall.hasArgument("key") && methodCall.hasArgument("expression")) {
                    val pageId = methodCall.argument<String>("pageId")
                    val id = methodCall.argument<String>("id")
                    val type = methodCall.argument<String>("type")
                    val key = methodCall.argument<String>("key")
                    val watch = methodCall.argument<Boolean>("watch")
                    val expression = methodCall.argument<String>("expression")
                    val obj = JSPageManager.handleExpression(pageId!!, id!!, type!!, key!!, watch!!, expression!!)
                    result.success(obj)
                }
            }
            Methods.HANDLE_REPEAT -> {
                if (methodCall.hasArgument("pageId") && methodCall.hasArgument("id") && methodCall.hasArgument("type") && methodCall.hasArgument("key") && methodCall.hasArgument("expression")) {
                    val pageId = methodCall.argument<String>("pageId")
                    val id = methodCall.argument<String>("id")
                    val type = methodCall.argument<String>("type")
                    val key = methodCall.argument<String>("key")
                    val watch = methodCall.argument<Boolean>("watch")
                    val expression = methodCall.argument<String>("expression")
                    val obj = JSPageManager.handleRepeat(pageId!!, id!!, type!!, key!!, watch!!, expression!!)
                    result.success(obj)
                }
            }
            Methods.REMOVE_OBSERVER -> {
                if (methodCall.hasArgument("pageId") && methodCall.hasArgument("ids")) {
                    val pageId = methodCall.argument<String>("pageId")
                    val ids = methodCall.argument<List<String>>("ids")
                    try {
                        JSPageManager.removeObserver(pageId!!, ids!!)
                    } catch (e: Exception) {
                        Logger.printError(e)
                    }
                    result.success("success")
                }
            }
        }
    }
}