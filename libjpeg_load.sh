#!/bin/zsh

LIBJPEG_VERSION=2.1.5.1

rm -rf ./.tmp
mkdir .tmp

cp archives/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz ./.tmp/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz

tar -xf .tmp/libjpeg-turbo-${LIBJPEG_VERSION}.tar.gz -C ./.tmp

# Set these variables to suit your needs
NDK_PATH=/Users/vshpyrka/Library/Android/sdk/ndk/25.2.9519653
# {"gcc" or "clang"-- "gcc" must be used with NDK r14b and earlier,
#  and "clang" must be used with NDK r17c and later}
TOOLCHAIN="clang"
ANDROID_VERSION="23"

TARGET_DIR=src/main/cpp/libjpeg
rm -fr ${TARGET_DIR}

cd .tmp/libjpeg-turbo-${LIBJPEG_VERSION}

# armeabi-v7a
/Users/vshpyrka/Library/Android/sdk/cmake/3.22.1/bin/cmake -G"Unix Makefiles" \
  -DCMAKE_INSTALL_PREFIX=./build/armeabi-v7a \
  -DANDROID_NDK=${NDK_PATH} \
  -DCMAKE_ANDROID_NDK=${NDK_PATH} \
  -DANDROID_ABI=armeabi-v7a \
  -DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a \
  -DANDROID_ARM_MODE=arm \
  -DANDROID_PLATFORM=android-${ANDROID_VERSION} \
  -DCMAKE_SYSTEM_NAME=Android \
  -DCMAKE_SYSTEM_VERSION=23 \
  -DANDROID_TOOLCHAIN=${TOOLCHAIN} \
  -DCMAKE_ASM_FLAGS="--target=arm-linux-androideabi${ANDROID_VERSION}" \
  -DCMAKE_TOOLCHAIN_FILE=${NDK_PATH}/build/cmake/android.toolchain.cmake

make install

rm -fr CMakeFiles
rm -fr CMakeCache.txt

# arm64-v8a
/Users/vshpyrka/Library/Android/sdk/cmake/3.22.1/bin/cmake -G"Unix Makefiles" \
  -DCMAKE_INSTALL_PREFIX=./build/arm64-v8a \
  -DANDROID_NDK=${NDK_PATH} \
  -DCMAKE_ANDROID_NDK=${NDK_PATH} \
  -DANDROID_ABI=arm64-v8a \
  -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
  -DANDROID_ARM_MODE=arm \
  -DANDROID_PLATFORM=android-${ANDROID_VERSION} \
  -DCMAKE_SYSTEM_NAME=Android \
  -DCMAKE_SYSTEM_VERSION=23 \
  -DANDROID_TOOLCHAIN=${TOOLCHAIN} \
  -DCMAKE_ASM_FLAGS="--target=aarch64-linux-android${ANDROID_VERSION}" \
  -DCMAKE_TOOLCHAIN_FILE=${NDK_PATH}/build/cmake/android.toolchain.cmake

make install

rm -fr CMakeFiles
rm -fr CMakeCache.txt

# x86
/Users/vshpyrka/Library/Android/sdk/cmake/3.22.1/bin/cmake -G"Unix Makefiles" \
  -DCMAKE_INSTALL_PREFIX=./build/x86 \
  -DANDROID_NDK=${NDK_PATH} \
  -DCMAKE_ANDROID_NDK=${NDK_PATH} \
  -DANDROID_ABI=x86 \
  -DCMAKE_ANDROID_ARCH_ABI=x86 \
  -DANDROID_PLATFORM=android-${ANDROID_VERSION} \
  -DCMAKE_SYSTEM_NAME=Android \
  -DCMAKE_SYSTEM_VERSION=23 \
  -DANDROID_TOOLCHAIN=${TOOLCHAIN} \
  -DCMAKE_TOOLCHAIN_FILE=${NDK_PATH}/build/cmake/android.toolchain.cmake
#  -DCOMPILE_FLAGS=-mfloat-abi=hard

make install

rm -fr CMakeFiles
rm -fr CMakeCache.txt

# x86_64
/Users/vshpyrka/Library/Android/sdk/cmake/3.22.1/bin/cmake -G"Unix Makefiles" \
  -DCMAKE_INSTALL_PREFIX=./build/x86_64 \
  -DANDROID_NDK=${NDK_PATH} \
  -DCMAKE_ANDROID_NDK=${NDK_PATH} \
  -DANDROID_ABI=x86_64 \
  -DCMAKE_ANDROID_ARCH_ABI=x86_64 \
  -DANDROID_PLATFORM=android-${ANDROID_VERSION} \
  -DCMAKE_SYSTEM_NAME=Android \
  -DCMAKE_SYSTEM_VERSION=23 \
  -DANDROID_TOOLCHAIN=${TOOLCHAIN} \
  -DCMAKE_TOOLCHAIN_FILE=${NDK_PATH}/build/cmake/android.toolchain.cmake

make install

rm -fr CMakeFiles
rm -fr CMakeCache.txt

cd ../../

mkdir -p ${TARGET_DIR}/armeabi-v7a/
mkdir -p ${TARGET_DIR}/arm64-v8a/
mkdir -p ${TARGET_DIR}/x86/
mkdir -p ${TARGET_DIR}/x86_64/

cp .tmp/libjpeg-turbo-${LIBJPEG_VERSION}/build/armeabi-v7a/lib/*.a ${TARGET_DIR}/armeabi-v7a/
cp .tmp/libjpeg-turbo-${LIBJPEG_VERSION}/build/armeabi-v7a/lib/*.so ${TARGET_DIR}/armeabi-v7a/
cp .tmp/libjpeg-turbo-${LIBJPEG_VERSION}/build/arm64-v8a/lib/*.a ${TARGET_DIR}/arm64-v8a/
cp .tmp/libjpeg-turbo-${LIBJPEG_VERSION}/build/arm64-v8a/lib/*.so ${TARGET_DIR}/arm64-v8a/
cp .tmp/libjpeg-turbo-${LIBJPEG_VERSION}/build/x86/lib/*.a ${TARGET_DIR}/x86/
cp .tmp/libjpeg-turbo-${LIBJPEG_VERSION}/build/x86/lib/*.so ${TARGET_DIR}/x86/
cp .tmp/libjpeg-turbo-${LIBJPEG_VERSION}/build/x86_64/lib/*.a ${TARGET_DIR}/x86_64/
cp .tmp/libjpeg-turbo-${LIBJPEG_VERSION}/build/x86_64/lib/*.so ${TARGET_DIR}/x86_64/

mkdir -p ${TARGET_DIR}/include
cp .tmp/libjpeg-turbo-${LIBJPEG_VERSION}/build/x86_64/include/*.h ${TARGET_DIR}/include

rm -rf ./.tmp

echo Update complete
