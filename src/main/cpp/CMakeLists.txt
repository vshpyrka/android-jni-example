# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html.
# For more examples on how to use CMake, see https://github.com/android/ndk-samples.

# Sets the minimum CMake version required for this project.
cmake_minimum_required(VERSION 3.22.1)

# Declares the project name. The project name can be accessed via ${ PROJECT_NAME},
# Since this is the top level CMakeLists.txt, the project name is also accessible
# with ${CMAKE_PROJECT_NAME} (both CMake variables are in-sync within the top level
# build script scope).
project("nativelib")

# https://android.googlesource.com/platform/external/icing/+/refs/heads/master/CMakeLists.txt
#set(
#        LIBRARY_LOCATION,
#        ${CMAKE_CURRENT_SOURCE_DIR}/library
#)
#
#file(
#        GLOB_RECURSE library_sources
#        library/*.c
#        library/*.cpp
#)
#
#file(
#        GLOB_RECURSE library_headers
#        library/*.h
#)
#
# message(STATUS "Filter library files")
# Looks like those files are used by main.c/h files, probably a demo app
# list(FILTER library_sources EXCLUDE REGEX ".*main\\.c$")

add_library(libjpeg STATIC IMPORTED)
set_target_properties(libjpeg PROPERTIES IMPORTED_LOCATION
        ${CMAKE_CURRENT_SOURCE_DIR}/libjpeg/${ANDROID_ABI}/libturbojpeg.a)

add_library(zlib STATIC IMPORTED)
set_target_properties(zlib PROPERTIES IMPORTED_LOCATION
        ${CMAKE_CURRENT_SOURCE_DIR}/zlib/${ANDROID_ABI}/libz.a)

add_library(libpng STATIC IMPORTED)
set_target_properties(libpng PROPERTIES IMPORTED_LOCATION
        ${CMAKE_CURRENT_SOURCE_DIR}/libpng/${ANDROID_ABI}/libpng.a)

add_library(libMagic++ STATIC IMPORTED)
set_target_properties(libMagic++ PROPERTIES IMPORTED_LOCATION
        ${CMAKE_CURRENT_SOURCE_DIR}/imagemagick/${ANDROID_ABI}/libMagick++-7.Q16HDRI.a)
add_library(libMagickCore STATIC IMPORTED)
set_target_properties(libMagickCore PROPERTIES IMPORTED_LOCATION
        ${CMAKE_CURRENT_SOURCE_DIR}/imagemagick/${ANDROID_ABI}/libMagickCore-7.Q16HDRI.a)
add_library(libMagickWand STATIC IMPORTED)
set_target_properties(libMagickWand PROPERTIES IMPORTED_LOCATION
        ${CMAKE_CURRENT_SOURCE_DIR}/imagemagick/${ANDROID_ABI}/libMagickWand-7.Q16HDRI.a)

add_library(ssl STATIC IMPORTED)
set_target_properties(ssl PROPERTIES IMPORTED_LOCATION
        ${CMAKE_CURRENT_SOURCE_DIR}/openssl/${ANDROID_ABI}/libssl.a)
add_library(crypto STATIC IMPORTED)
set_target_properties(crypto PROPERTIES IMPORTED_LOCATION
        ${CMAKE_CURRENT_SOURCE_DIR}/openssl/${ANDROID_ABI}/libcrypto.a)


add_library(${CMAKE_PROJECT_NAME} SHARED
        # List C/C++ source files with relative paths to this CMakeLists.txt.
        nativelib.cpp
        )

include_directories(
        native_debug.h
        zlib/include
        libjpeg/include
        libpng/include
        imagemagick/include
        openssl/include
)

target_include_directories(
        ${CMAKE_PROJECT_NAME} PUBLIC
        zlib/include
        libjpeg/include
        libpng/include
        openssl/include
)

# Specifies libraries CMake should link to your target library. You
# can link libraries from various origins, such as libraries defined in this
# build script, prebuilt third-party libraries, or Android system libraries.
target_link_libraries(${CMAKE_PROJECT_NAME}
        # List libraries link to the target library
        zlib
        libjpeg
        libpng
        libMagic++
        libMagickCore
        libMagickWand
        ssl
        crypto
        android
        log
        )
