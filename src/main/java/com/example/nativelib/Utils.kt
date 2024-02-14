package com.example.nativelib

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.view.ViewGroup
import android.widget.ImageView
import androidx.core.view.updateLayoutParams
import java.io.File
import java.io.FileOutputStream

fun copyFile(context: Context, filePath: String) = context.assets.open(filePath).use {
    val file = File(context.cacheDir, filePath)
    val outputStream = FileOutputStream(file)
    it.copyTo(outputStream)
    outputStream.close()
    file
}

fun decodeBitmap(file: File): Bitmap {
    val bitmap = BitmapFactory.decodeFile(file.path)
    val width = bitmap.width
    val height = bitmap.height
    val totalPixels = width * height
    val intArray = IntArray(totalPixels)
    bitmap.getPixels(intArray, 0, width, 0, 0, width, height)
    val newBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
    newBitmap.setPixels(intArray, 0, width, 0, 0, width, height)
    return newBitmap
}

fun ImageView.updateSize(width: Int, height: Int) {
    updateLayoutParams<ViewGroup.LayoutParams> {
        this.width = width
        this.height = height
    }
}
