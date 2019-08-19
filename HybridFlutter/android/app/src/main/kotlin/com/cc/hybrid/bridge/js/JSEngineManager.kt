package com.cc.hybrid.bridge.js

import com.eclipsesource.v8.JavaCallback
import com.eclipsesource.v8.V8Array
import com.eclipsesource.v8.V8Function
import com.eclipsesource.v8.V8Object
import com.cc.hybrid.Logger
import com.cc.hybrid.event.EventManager
import com.cc.hybrid.v8.V8Manager
import java.util.*

object JSEngineManager {

    private val v8PageDictionary: MutableMap<String, V8Object> = mutableMapOf()

    private fun prepareScriptContent(content: String): String {
        return content.replace("\n", "")
    }

    /**
     * 把page的Script注入到JSCore中对应的page下
     * @param script html生成json文件中script的节点
     * */
    fun attachPageScriptToJsCore(pageId: String, script: String) {
        attachPage(pageId, prepareScriptContent(script))
    }

    /**
     * 保存模块信息到JsCore，作为上下文维护在应用中，存在整个应用的生命周期
     */
    private fun attachPage(pageId: String, script: String) {
        try {
            V8Manager.executeScript("global.loadPage('$pageId')")
            val realPageObject = getV8Page(pageId)
            if (realPageObject is V8Object) {
                realPageObject.executeJSFunction("evalInPage", script)

                // 将临时page添加到RealPage里面
                val page = V8Manager.v8.getObject("page")
                page.setPrototype(realPageObject)
                page.keys.forEach {
                    realPageObject.add(it, page.getObject(it))
                    realPageObject.setPrototype(page.getObject(it))
                }

                val cc = V8Manager.v8.getObject("cc")
                cc.registerJavaMethod(JavaCallback { p0, p1 ->
                    val data = p1?.getObject(0)
                    data?.add("requestId", UUID.randomUUID().toString())
                    cc.getObject("requestData").add(data?.getString("requestId"), data)
                    JSNetwork().request(data!!)
                    p0 as Any
                }, "request")
                realPageObject.setPrototype(cc)
                realPageObject.add("cc", cc)

                realPageObject.registerJavaMethod(JavaCallback { p0, p1 ->
                    onRefresh(pageId)
                    p0 as Any
                }, "refresh")
            }
        } catch (e: Exception) {
            Logger.printError(e)
        }
    }

    @Synchronized
    fun onNetworkResult(requestId: String, success: String, json: String) {
        try {
            V8Manager.v8.getObject("cc")?.executeJSFunction("onNetworkResult", requestId, success, json)
        } catch (e: Exception) {
            Logger.printError(e)
        }
    }

    @Synchronized
    fun onRefresh(pageId: String) {
        Logger.d("JSEngineManager", "onRefresh pageId = $pageId")
        EventManager.instance.handler?.sendEmptyMessage(EventManager.TYPE_ONCLICK)
    }

    private fun getV8Page(pageId: String): V8Object? {
        val cache = v8PageDictionary[pageId]
        if (null != cache && !cache.isReleased && !cache.isUndefined) {
            return cache
        } else {
            v8PageDictionary.remove(pageId)
        }
        val page = getPage(pageId)
        return if (page is V8Object && !page.isUndefined && !page.isReleased) {
            v8PageDictionary[pageId] = page
            page
        } else {
            null
        }
    }

    private fun getPage(pageId: String): Any? {
        return V8Manager.executeScript("this.getPage('$pageId')")
    }

    fun callMethodInPage(pageId: String, method: String, vararg args: String?, executeListener: ((Throwable?) -> Unit)? = null) {
        if (method.isNotEmpty()) {
            val page = getV8Page(pageId)
            if (null != page && !page.isUndefined) {
                val params = V8Array(page.runtime)
                args.forEach {
                    val json = V8Manager.v8.getObject("JSON")
                    val param = json.executeJSFunction("parse", it)
                    when (param) {
                        is V8Array -> params.push(param)
                        is V8Object -> params.push(param)
                        is String -> params.push(param)
                        is Int -> params.push(param)
                        is Double -> params.push(param)
                        is Boolean -> params.push(param)
                    }
                }
                if (page.contains(method)) {
                    (page.get(method) as V8Function).call(page, params)
                }
            }
        }
        if (executeListener != null) {
            executeListener(null)
        }
    }

    fun handleRepeat(pageId: String, expression: String): Int? {
        val page = getV8Page(pageId)
        return page?.executeIntegerFunction("handleRepeat", V8Array(V8Manager.v8).push(expression))
    }

    fun handleExpression(pageId: String, expression: String): String? {
        val page = getV8Page(pageId)
        return page?.executeFunction("getExpValue", V8Array(V8Manager.v8).push(expression)).toString()
    }
}