package com.cc.hybrid.util

import android.content.Context
import androidx.appcompat.app.AppCompatDialog
import android.text.TextUtils
import com.cc.hybrid.R
import com.eclipsesource.v8.V8Object

object LoadingUtil {

    private lateinit var dialog: AppCompatDialog

    fun initDialog(context: Context) {
        dialog = AppCompatDialog(context, R.style.Alert)
        dialog.apply {
            setContentView(R.layout.dialog_loading)
            setCancelable(true)
            window?.decorView?.setBackgroundResource(android.R.color.transparent)
        }
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
                    dialog.setTitle(message)
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