package com.cc.hybrid.bridge.flutter

import android.app.Activity
import com.cc.hybrid.Logger
import com.cc.hybrid.bridge.js.JSPageManager
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
//        Logger.d("lry", "onMethodCall = ${methodCall.method} result = $result ")
        when (methodCall.method) {
            Methods.ATTACH_PAGE -> {
                if (methodCall.hasArgument("pageId") && methodCall.hasArgument("script")) {
                    val id = methodCall.argument<String>("pageId")
                    val script = methodCall.argument<String>("script")
                    Logger.d("lry", "attach_page pageId = $id script = $script")
                    JSPageManager.attachPageScriptToJsCore(id!!, script!!)
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
            Methods.ONCLICK -> {
                if (methodCall.hasArgument("pageId") && methodCall.hasArgument("event") && methodCall.hasArgument("data")) {
                    val pageId = methodCall.argument<String>("pageId")
                    val event = methodCall.argument<String>("event")
                    val data = methodCall.argument<String>("data")
                    Logger.d("lry", "Methods onclick pageId = $pageId event = $event data = $data")
                    JSPageManager.callMethodInPage(pageId!!, event!!, data)
                    result.success("success")
                }
            }
            Methods.HANDLE_EXPRESSION -> {
                if (methodCall.hasArgument("pageId") && methodCall.hasArgument("expression")) {
                    val pageId = methodCall.argument<String>("pageId")
                    val expression = methodCall.argument<String>("expression")
                    val obj = JSPageManager.handleExpression(pageId!!, expression!!)
                    result.success(obj)
                }
            }
            Methods.HANDLE_REPEAT -> {
                if (methodCall.hasArgument("pageId") && methodCall.hasArgument("expression")) {
                    val pageId = methodCall.argument<String>("pageId")
                    val expression = methodCall.argument<String>("expression")
                    val obj = try {
                        JSPageManager.handleRepeat(pageId!!, expression!!)
                    } catch (e: Exception) {
                        Logger.printError(e)
                        0
                    }
                    result.success(obj)
                }
            }
        }
    }
}