package com.example.nativelib

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.navigation.findNavController
import com.example.nativelib.databinding.FragmentJniLauncherBinding

class JniLauncherFragment : Fragment(R.layout.fragment_jni_launcher) {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val binding = FragmentJniLauncherBinding.bind(view)
        binding.png.setOnClickListener {
            it.findNavController().navigate(R.id.to_LibPngProcessFragment)
        }
        binding.jpeg.setOnClickListener {
            it.findNavController().navigate(R.id.to_libJpegProcessFragment)
        }
        binding.blur.setOnClickListener {
            it.findNavController().navigate(R.id.to_imageMagicProcessFragment)
        }
    }
}
