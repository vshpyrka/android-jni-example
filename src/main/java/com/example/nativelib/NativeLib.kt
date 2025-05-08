package com.example.nativelib

class NativeLib {

    /**
     * A native method that is implemented by the 'nativelib' native library,
     * which is packaged with this application.
     */
    external fun stringFromJNI(): String

    external fun readPng(path: String): IntArray

    external fun readJpeg(path: String): IntArray

    external fun blurImage(path: String): IntArray

    external fun crash()

    external fun printDeviceInfo()

    companion object {
        // Used to load the 'nativelib' library on application startup.
        init {
            System.loadLibrary("nativelib")
        }
    }
}
