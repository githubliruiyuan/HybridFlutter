package com.cc.hybrid.util

import android.content.Context
import android.content.SharedPreferences

object SpUtil {
    private lateinit var sp: SharedPreferences

    fun initSp(context: Context) {
        sp = context.getSharedPreferences("cc", Context.MODE_PRIVATE)
    }

    fun put(key: String, value: Any) {
        when (value) {
            is Boolean -> sp.edit().putBoolean(key, value).apply()
            is Int -> sp.edit().putInt(key, value).apply()
            is String -> sp.edit().putString(key, value).apply()
            is Long -> sp.edit().putLong(key, value).apply()
            is Float -> sp.edit().putFloat(key, value).apply()
        }
    }

    fun get(key: String): Any? {
        return sp.all[key]
    }

}