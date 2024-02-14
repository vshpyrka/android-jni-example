package com.example.nativelib

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import com.example.nativelib.databinding.FragmentImageProcessBinding

class ImageMagicProcessFragment : Fragment(R.layout.fragment_image_process) {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val binding = FragmentImageProcessBinding.bind(view)

        val message = "ImageMagick Image Blur"
        binding.title.text = message

        val file = copyFile(requireContext(), "studio.jpg")
        val bitmap = decodeBitmap(file)
        val bytes = NativeLib().blurImage(file.path)
        val options = BitmapFactory.Options().apply {
            inJustDecodeBounds = true
        }
        BitmapFactory.decodeFile(file.path, options)
        val width = options.outWidth
        val height = options.outHeight

        val newBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        newBitmap.setPixels(bytes, 0, width, 0, 0, width, height)

        binding.image.setImageBitmap(bitmap)
        binding.image.updateSize(400, 400)
        binding.nativeImage.setImageBitmap(newBitmap)
        binding.nativeImage.updateSize(400, 400)
    }
}
