#!/bin/zsh

echo removing existing imagemagick source
rm -rf ./.tmp
mkdir .tmp

IMAGEMAGICK_VERSION=7.1.1-11

echo downloading imagemagick release ${IMAGEMAGICK_VERSION}
curl https://imagemagick.org/archive/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz -o ./.tmp/ImageMagick.tar.gz
tar -xf .tmp/ImageMagick.tar.gz -C ./.tmp

TARGET_DIR=src/main/cpp/imagemagick
rm -fr ${TARGET_DIR}

cd .tmp/ImageMagick-${IMAGEMAGICK_VERSION}

export ANDROID_NDK=/Users/vshpyrka/Library/Android/sdk/ndk/25.2.9519653
export PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH
export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/darwin-x86_64
export API=23

CURRENT_DIR=$(pwd)
echo "$CURRENT_DIR"

echo "Prepare output directories"
rm -fr build
mkdir build

for OUTPUT_DIR in "armeabi-v7a" "arm64-v8a" "x86" "x86_64"
do

  if [[ $OUTPUT_DIR == "armeabi-v7a" ]]; then
      TARGET="armv7a-linux-androideabi"
  elif [[ $OUTPUT_DIR == "arm64-v8a" ]]; then
      TARGET="aarch64-linux-android"
  elif [[ $OUTPUT_DIR == "x86" ]]; then
      TARGET="i686-linux-android"
  elif [[ $OUTPUT_DIR == "x86_64" ]]; then
      TARGET="x86_64-linux-android"
  else
      echo "Invalid output dir $OUTPUT_DIR"
      exit 1
  fi

  export AR=$TOOLCHAIN/bin/llvm-ar
  export CC=$TOOLCHAIN/bin/$TARGET$API-clang
  export AS=$CC
  export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
  export LD=$TOOLCHAIN/bin/ld
  export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
  export STRIP=$TOOLCHAIN/bin/llvm-strip
  export CFLAGS="-fPIC"
  export CXXFLAGS="-fPIC"

  #arguments are specified in configure.ac
  make clean
  ./configure --prefix="${CURRENT_DIR}"/build \
    --libdir="${CURRENT_DIR}"/build/lib/$OUTPUT_DIR \
    --host $TARGET \
    CPPFLAGS='-I../../src/main/cpp/libjpeg/include' \
    LDFLAGS="-L../../src/main/cpp/libjpeg/${OUTPUT_DIR}/" \
    --with-jpeg=yes \
    --without-xml \
    --without-threads \
    --without-bzlib \
    --without-zlib \
    --without-x \
    --without-jxl \
    --without-tiff \
    --without-freetype \
    --without-openjp2 \
    --without-openexr \
    --without-djvu \
    --without-webp \
    --without-fontconfig \
    --without-lzma \
    --without-raqm \
    --without-lcms \
    --without-raw \
    --without-pango \
    --with-fpx=no

  make install

  mkdir -p ../../${TARGET_DIR}/${OUTPUT_DIR}/

  cp build/lib/${OUTPUT_DIR}/*.a ../../${TARGET_DIR}/${OUTPUT_DIR}
  cp build/lib/${OUTPUT_DIR}/*.so ../../${TARGET_DIR}/${OUTPUT_DIR}

done

cd ../../

mkdir ${TARGET_DIR}/include

cp -R .tmp/ImageMagick-${IMAGEMAGICK_VERSION}/build/include/ImageMagick-7/Magick++ ${TARGET_DIR}/include
cp -R .tmp/ImageMagick-${IMAGEMAGICK_VERSION}/build/include/ImageMagick-7/MagickCore ${TARGET_DIR}/include
cp -R .tmp/ImageMagick-${IMAGEMAGICK_VERSION}/build/include/ImageMagick-7/MagickWand ${TARGET_DIR}/include
cp -R .tmp/ImageMagick-${IMAGEMAGICK_VERSION}/build/include/ImageMagick-7/Magick++.h ${TARGET_DIR}/include

rm -rf ./.tmp

echo Update complete
