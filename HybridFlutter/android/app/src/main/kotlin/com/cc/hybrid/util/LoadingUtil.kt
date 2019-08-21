package com.cc.hybrid.util

import android.app.ProgressDialog
import android.content.Context
import android.text.TextUtils
import com.eclipsesource.v8.V8Object

object LoadingUtil {

    private lateinit var dialog: ProgressDialog

    fun initDialog(context: Context) {
        dialog = ProgressDialog(context)
        dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER)
        dialog.setCancelable(true)
    }

    fun showLoading(obj: V8Object?) {
        if (null != obj) {
            if (obj.contains("title")) {
                val title = obj.getString("title")
                if (!TextUtils.isEmpty(title)) {
                    dialog.setTitle(title)
                }
            }
            if (obj.contains("message")) {
                val message = obj.getString("message")
                if (!TextUtils.isEmpty(message)) {
                    dialog.setMessage(message)
                }
            }
        }
        if (!dialog.isShowing) {
            dialog.show()
        }
    }

    fun hideLoading() {
        dialog.dismiss()
    }

    fun destroy() {
        if(dialog.isShowing) {
            dialog.dismiss()
        }
    }

}