package com.cc.hybrid.http

import com.cc.hybrid.http.exception.HttpParamsException


/**
 * Created by zhouwenliang on 2018/4/24.
 * Http访问的实体类
 */
internal class HttpRequest {
    companion object {
        val METHOD_POST = "post"
        val METHOD_GET = "get"
    }
    val paramsMap = HashMap<String, Any>()
    val headerMap = HashMap<String, Any>()
    var url: String? = null
    var errorRetryTime = 0
    var securiryTransfer = false
    var isBusinessInterface = false
    var method: String = METHOD_POST

    class Builder {
        private val request = HttpRequest()
        fun addParams(key: String, value: Any): Builder {
            request.paramsMap[key] = value
            return this
        }

        fun addHeader(key: String, value: Any): Builder {
            request.headerMap.put(key, value)
            return this
        }

        fun url(url: String): Builder {
            request.url = url
            return this
        }

        fun securityTransfer(boolean: Boolean): Builder {
            request.securiryTransfer = boolean
            return this
        }

        fun isBusinessInterface(boolean: Boolean): Builder {
            request.isBusinessInterface = boolean
            return this
        }

        fun method(method: String): Builder {
            request.method = method;
            return this
        }

        fun build(): HttpRequest {
            if (null == request.url) {
                throw HttpParamsException("url can not be null")
            }
            return request
        }
    }
}