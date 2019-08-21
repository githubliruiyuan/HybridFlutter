package com.cc.hybrid.debug

import com.cc.hybrid.event.EventManager
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.InputStream
import java.lang.ref.WeakReference
import java.net.Socket
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.Executors

// Thread to read content from Socket
class Debugger(host: String, port: Int) : Thread() {

    var socket: WeakReference<Socket>? = null
    var host: String? = null
    var port: Int? = null
    private val mThreadPool = Executors.newCachedThreadPool()

    init {
        this.host = host
        this.port = port
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
                    val totalLength = readLength(inputStream)
                    val baos = ByteArrayOutputStream()
                    var i = 0
                    while (baos.size() != totalLength) {
                        i = inputStream.read()
                        baos.write(i)
                    }
                    val json = baos.toString()
                    EventManager.instance.sendMessage(EventManager.TYPE_SOCKET, "", json)
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