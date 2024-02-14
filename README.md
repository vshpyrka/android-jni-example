# android-jni-example

Set of examples which compile and use native c++ libraries such as LibPNG, LibJPEG, ImageMagick, OpenSSL

* LibPNG

  [LibPngProcessFragment.kt](https://github.com/vshpyrka/android-jni-example/blob/main/src/main/java/com/example/nativelib/LibPngProcessFragment.kt) - Example of image pixels read using `libpng` c++ library. All four ARGB channels are read into a byte array and then passed to Android Bitmap class as a set of pixels via `Bitmap.setPixels` method.

  [libpng_load.sh](https://github.com/vshpyrka/android-jni-example/blob/main/libpng_load.sh) - Script that helps to unpack and compile `libpng` library to four available architectures(armeabi-v7a/arm64-v8a/x86/x86_64) using CMake tool from Android NDK

  [readPng](https://github.com/vshpyrka/android-jni-example/blob/main/src/main/cpp/nativelib.cpp#L28) - Native method that reads and returns PNG image pixels array

  <img width="300" alt="Screenshot 2024-02-14 at 5 15 56 PM" src="https://github.com/vshpyrka/android-jni-example/assets/2741602/653a00dc-ba57-45e2-945c-d0ee9943f61f">

* LibJPEG

  [LibJpegProcessFragment.kt](https://github.com/vshpyrka/android-jni-example/blob/main/src/main/java/com/example/nativelib/LibJpegProcessFragment.kt) - Example of image pixels read using `libjpeg` c++ library. RGB channels are read into a byte array and then passed to Android Bitmap class as a set of pixels via `Bitmap.setPixels` method.

  [libjpeg_load.sh](https://github.com/vshpyrka/android-jni-example/blob/main/libjpeg_load.sh) - Script that helps to unpack and compile `libjpeg` library to four available architectures(armeabi-v7a/arm64-v8a/x86/x86_64) using CMake tool from Android NDK

  [readJpeg](https://github.com/vshpyrka/android-jni-example/blob/main/src/main/cpp/nativelib.cpp#L277) - Native method that reads and returns PNG image pixels array

  <img width="300" alt="Screenshot 2024-02-14 at 5 15 32 PM" src="https://github.com/vshpyrka/android-jni-example/assets/2741602/b49c51f0-9e43-43d6-ae0d-48b44cbd2f68">

* ImageMagick

  [ImageMagicProcessFragment.kt](https://github.com/vshpyrka/android-jni-example/blob/main/src/main/java/com/example/nativelib/ImageMagicProcessFragment.kt) - Example of blur effect using ImageMagick c++ library. Resulteed image pixels are retrieved from all four(ARGB) channels and retrieved as pixels array and then passed to Android Bitmap class as a set of pixels via `Bitmap.setPixels` method.

  [image_magic_load2.sh](https://github.com/vshpyrka/android-jni-example/blob/main/image_magic_load2.sh) - Script that helps to unpack and compile `imagemagick` library to four available architectures(armeabi-v7a/arm64-v8a/x86/x86_64) using CMake tool from Android NDK

  [blurImage](https://github.com/vshpyrka/android-jni-example/blob/main/src/main/cpp/nativelib.cpp#L317) - Native method that takes a file path and reads it with ImageMagick library and blures the image. All four ARGB channels are read into a byte array and then passed to Android Bitmap class as a set of pixels via `Bitmap.setPixels` method.

  <img width="300" alt="Screenshot 2024-02-14 at 5 15 13 PM" src="https://github.com/vshpyrka/android-jni-example/assets/2741602/49c1bc28-c07f-4bb5-b2c2-3faa04bfb42c">

  
