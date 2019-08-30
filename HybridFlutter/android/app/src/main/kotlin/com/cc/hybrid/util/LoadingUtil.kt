package com.cc.hybrid.util

import android.content.Context
import android.support.v7.app.AlertDialog
import android.text.TextUtils
import com.cc.hybrid.R
import com.eclipsesource.v8.V8Object

object LoadingUtil {

    private lateinit var dialog: AlertDialog

    fun initDialog(context: Context) {
        dialog = AlertDialog
                .Builder(context, R.style.Alert)
                .setView(R.layout.dialog_loading)
                .create()
        dialog.setCancelable(true)
        dialog.window?.decorView?.setBackgroundResource(android.R.color.transparent)
    }

    fun showLoading(obj: V8Object?) {
        if (null != obj && !obj.isUndefined) {
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