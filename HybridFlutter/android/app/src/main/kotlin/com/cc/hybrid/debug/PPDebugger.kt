package com.cc.hybrid.debug

import android.os.Handler
import android.os.Message
import android.util.Log
import com.cc.hybrid.MainActivity
import com.cc.hybrid.event.EventManager
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.InputStream
import java.lang.ref.WeakReference
import java.net.Socket
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.Executors


/**
 * Created by Lyman on 4/11/18.
 * PPMoney Ltd
 * lyman.liu@PPMoney.com
 */

// Thread to read content from Socket
class PPDebugger(host: String, port: Int, handler: Handler) : Thread() {

    var socket: WeakReference<Socket>? = null
    var handler: Handler? = null
    var host: String? = null
    var port: Int? = null
    private val mThreadPool = Executors.newCachedThreadPool()

    init {
        this.host = host
        this.port = port
        this.handler = handler
    }

    private var isStart = true

    fun release() {
        isStart = false
        releaseSocket()
    }

    private fun readLength(inputStream: InputStream): Int {
        val lengthBuffer = ByteArray(4)
        inputStream.read(lengthBuffer, 0, 4)
        val byteBuffer = ByteBuffer.wrap(lengthBuffer)
        byteBuffer.order(ByteOrder.LITTLE_ENDIAN)
        return byteBuffer.int
    }

    override fun run() {
        super.run()
        val socket = socket?.get()
        if (null != socket) {
            try {
                val inputStream = socket.getInputStream()
                while (!socket.isClosed && !socket.isInputShutdown && isStart) {
                    var totalLength = readLength(inputStream)
                    var baos = ByteArrayOutputStream()
                    var i = 0
                    while (baos.size() != totalLength) {
                        i = inputStream.read()
                        baos.write(i)
                    }
                    val json = baos.toString()
                    val msg = Message.obtain()
                    msg.what = EventManager.TYPE_SOCKET
                    msg.obj = json
                    handler!!.sendMessage(msg)
                }
            } catch (e: IOException) {

            }
        }
    }

    private fun releaseSocket() {
        try {
            if (null != socket) {
                val sk = socket!!.get()
                if (!sk!!.isClosed) {
                    sk.close()
                }
            }
        } catch (e: IOException) {

        }

    }

    fun startSocket() {
        mThreadPool.execute {
            try {
                socket = WeakReference(Socket(host!!, port!!))
                start()
            } catch (e: IOException) {

            }
        }
    }

}