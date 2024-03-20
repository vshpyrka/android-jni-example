#!/bin/zsh

rm -rf ./.tmp
mkdir .tmp

OPENSSL_VERSION=3.1.1

cp archives/openssl-${OPENSSL_VERSION}.tar.gz ./.tmp/openssl-${OPENSSL_VERSION}.tar.gz
tar -xf .tmp/openssl-${OPENSSL_VERSION}.tar.gz -C ./.tmp

TARGET_DIR=src/main/cpp/openssl
rm -fr ${TARGET_DIR}

cd .tmp/openssl-${OPENSSL_VERSION}

export ANDROID_NDK_ROOT=/Users/vshpyrka/Library/Android/sdk/ndk/25.2.9519653
PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH

for architecture in android-arm android-arm64 android-x86 android-x86_64
do

  if [[ $architecture == android-arm ]]; then
        TARGET="armeabi-v7a"
    elif [[ $architecture == android-arm64 ]]; then
        TARGET="arm64-v8a"
    elif [[ $architecture == android-x86 ]]; then
        TARGET="x86"
    elif [[ $architecture == android-x86_64 ]]; then
        TARGET="x86_64"
    else
        echo "Invalid output dir $architecture"
        exit 1
  fi

  mkdir -p ../../${TARGET_DIR}/${TARGET}/

  make clean
  echo $architecture
  ./Configure $architecture -D__ANDROID_API__=23
  make

  cp libcrypto.a ../../${TARGET_DIR}/${TARGET}
  cp libssl.a ../../${TARGET_DIR}/${TARGET}
  cp libcrypto.so ../../${TARGET_DIR}/${TARGET}
  cp libssl.so ../../${TARGET_DIR}/${TARGET}

done

cd ../../

cp -R .tmp/openssl-${OPENSSL_VERSION}/include ${TARGET_DIR}

rm -rf ./.tmp

echo Update complete
