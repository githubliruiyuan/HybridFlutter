package com.cc.hybrid.bridge.js

import android.os.Handler
import android.os.Looper
import com.alibaba.fastjson.JSON
import com.alibaba.fastjson.JSONObject
import com.eclipsesource.v8.V8Object
import com.cc.hybrid.http.HttpRequest
import com.cc.hybrid.http.HttpRequestUtil
import com.cc.hybrid.v8.V8Util
import okhttp3.Call
import okhttp3.Callback
import okhttp3.Request
import okhttp3.Response
import java.io.IOException

class JSNetwork {

    fun request(request: V8Object) {
        val builder = Request.Builder()
        val url = request.getString(URL)
        builder.url(url)
        val header = request.getObject(HEADER)
        val body = request.getObject(DATA)
        var method = HttpRequest.METHOD_POST
        if (request.contains(METHOD)) {
            method = request.getString(METHOD)
        }
        val headerMap: HashMap<String, String>
        if (null != header && !header.isUndefined) {
            headerMap = HashMap()
            val temp = HashMap(V8Util.toMap(header))
            temp.keys.forEach {
                if (null != temp[it]) {
                    headerMap[it] = temp[it].toString()
                }
            }
        } else {
            headerMap = HashMap()
        }

        for (key in headerMap.keys) {
            if (null != headerMap[key]) {
                builder.addHeader(key, headerMap[key]!!)
            }
        }

        val bodyMap: HashMap<String, Any>
        if (null != body && !body.isUndefined) {
            bodyMap = HashMap()
            val temp = HashMap(V8Util.toMap(body))
            temp.keys.forEach {
                if (null != temp[it]) {
                    bodyMap[it] = temp[it]!!
                }
            }
        } else {
            bodyMap = HashMap()
        }

        for (key in bodyMap.keys) {
            if (null != bodyMap[key]) {
//                builder.(key, bodyObject[key]!!)
            }
        }

        val requestId = request.getString(REQUEST_ID)
        val pageId = request.getString(PAGE_ID)
        val handler = Handler(Looper.getMainLooper())

        HttpRequestUtil.okHttpClient.newCall(builder.build()).enqueue(object : Callback {
            override fun onFailure(call: Call?, e: IOException?) {
                val result = JSONObject()
                result[CODE] = -1
                result[MESSAGE] = e?.message
                handler.post {
                    JSPageManager.onNetworkResult(pageId, requestId, FAIL, result.toJSONString())
                }
            }

            override fun onResponse(call: Call?, response: Response?) {
                val result = JSONObject()
                result[CODE] = -1
                result[MESSAGE] = ""
                try {
                    if (null != response) {
                        result[CODE] = response.code()
                        result[BODY] = JSON.parse(response.body().string())
                        result[MESSAGE] = response.message()
                        result[HEADERS] = response.headers()
                        result[HANDSHAKE] = response.handshake()
                        result[PROTOCOL] = response.protocol()
                        handler.post {
                            JSPageManager.onNetworkResult(pageId, requestId, SUCCESS, result.toJSONString())
                        }
                    }
                } catch (e: Exception) {
                    result[MESSAGE] = e.message
                    handler.post {
                        JSPageManager.onNetworkResult(pageId, requestId, FAIL, result.toJSONString())
                    }
                }
            }
        })
    }

    companion object {
        private val URL = "url"
        private val HEADER = "header"
        private val DATA = "data"
        private val METHOD = "method"
        private val REQUEST_ID = "requestId"
        private val PAGE_ID = "pageId"

        private val SUCCESS = "success"
        private val FAIL = "fail"

        private val RESULT = "result"
        private val CODE = "code"
        private val MESSAGE = "message"
        private val BODY = "body"
        private val HEADERS = "headers"
        private val HANDSHAKE = "Handshake"
        private val PROTOCOL = "protocol"

    }
}
