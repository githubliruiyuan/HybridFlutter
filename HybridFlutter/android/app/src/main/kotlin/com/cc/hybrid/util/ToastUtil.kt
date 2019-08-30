package com.cc.hybrid.util

import android.content.Context
import android.text.TextUtils
import android.widget.Toast
import com.eclipsesource.v8.V8Object

object ToastUtil {

    private lateinit var context: Context

    private var toast: Toast? = null

    fun initToast(context: Context) {
        this.context = context
    }

    fun showToast(obj: V8Object?) {
        if (null != obj && !obj.isUndefined) {
            if (obj.contains("title")) {
                val title = obj.getString("title")
                if (!TextUtils.isEmpty(title)) {
                    toast = Toast.makeText(context, title, Toast.LENGTH_SHORT)
                    toast?.show()
                }
            }
        }
    }

    fun hideToast() {
        toast?.cancel()
    }

}