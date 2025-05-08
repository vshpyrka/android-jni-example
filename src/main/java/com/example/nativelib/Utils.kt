package com.example.nativelib

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updateLayoutParams
import androidx.core.view.updatePadding
import java.io.File
import java.io.FileOutputStream
import androidx.core.graphics.createBitmap

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
    val newBitmap = createBitmap(width, height)
    newBitmap.setPixels(intArray, 0, width, 0, 0, width, height)
    return newBitmap
}

fun ImageView.updateSize(width: Int, height: Int) {
    updateLayoutParams<ViewGroup.LayoutParams> {
        this.width = width
        this.height = height
    }
}

fun View.applyWindowInsets() {
    ViewCompat.setOnApplyWindowInsetsListener(this) { v, insets ->
        val bars = insets.getInsets(
            WindowInsetsCompat.Type.systemBars()
                    or WindowInsetsCompat.Type.displayCutout()
        )
        v.updatePadding(
            left = bars.left,
            top = bars.top,
            right = bars.right,
            bottom = bars.bottom,
        )
        WindowInsetsCompat.CONSUMED
    }
}
