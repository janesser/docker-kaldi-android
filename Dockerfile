FROM ubuntu

RUN mkdir -p /opt/android-sdk-linux && mkdir -p ~/.android && touch ~/.android/repositories.cfg

ENV WORKING_DIR /opt

ENV ANDROID_NDK_HOME ${WORKING_DIR}/android-ndk-linux

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    clang \
    file \
    gfortran \
    git \
    python \
    unzip \
    wget

RUN apt-get install -y --no-install-recommends automake autoconf sox libtool subversion python

RUN apt-get clean autoclean && \
    apt-get autoremove -y

##### Install Android toolchain
RUN cd ${WORKING_DIR} && \
    wget -q --output-document=android-ndk.zip https://dl.google.com/android/repository/android-ndk-r21d-linux-x86_64.zip && \
    unzip android-ndk.zip && \
    rm -f android-ndk.zip && \
    mv android-ndk-r21d ${ANDROID_NDK_HOME}

ENV TOOLCHAIN ${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64
ENV TARGET "aarch64-linux-android"
ENV API=21
ENV AR=$TOOLCHAIN/bin/$TARGET-ar
ENV AS=$TOOLCHAIN/bin/$TARGET-as
ENV CC=$TOOLCHAIN/bin/$TARGET$API-clang
ENV CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
ENV LD=$TOOLCHAIN/bin/$TARGET-ld
ENV RANLIB=$TOOLCHAIN/bin/$TARGET-ranlib
ENV STRIP=$TOOLCHAIN/bin/$TARGET-strip

##### Download, compile and install OpenBlas
RUN cd ${WORKING_DIR} && \
    git clone https://github.com/xianyi/OpenBLAS

RUN cd ${WORKING_DIR} && cd OpenBLAS && \
    sed -i 's/GETARCH_FLAGS += -march=native/#GETARCH_FLAGS += -march=native/g' Makefile.system && \
    make ONLY_CBLAS=1 ARM_SOFTFP_ABI=1 HOSTCC=gcc TARGET=ARMV8 AR=$AR CC=$CC RANLIB=$RANLIB && \
    make install NO_SHARED=1 PREFIX=`pwd`/install

##### Download, compile and install CLAPACK
RUN cd ${WORKING_DIR} && \
    git clone https://github.com/brightenai/android_libs && \
    cd android_libs/lapack && \
    sed -i 's/LOCAL_MODULE:= testlapack/#LOCAL_MODULE:= testlapack/g' jni/Android.mk && \
    sed -i 's/LOCAL_SRC_FILES:= testclapack.cpp/#LOCAL_SRC_FILES:= testclapack.cpp/g' jni/Android.mk && \
    sed -i 's/LOCAL_STATIC_LIBRARIES := lapack/#LOCAL_STATIC_LIBRARIES := lapack/g' jni/Android.mk && \
    sed -i 's/include $(BUILD_SHARED_LIBRARY)/#include $(BUILD_SHARED_LIBRARY)/g' jni/Android.mk && \
    ${ANDROID_NDK_HOME}/ndk-build

RUN cd ${WORKING_DIR} && \
    cd android_libs/lapack && \
    cp obj/local/arm64-v8a/*.a ${WORKING_DIR}/OpenBLAS/install/lib

ENV OPENFST_VERSION 1.8.0

##### Compile kaldi
# Using "/opt" because of a bug in Docker:
# https://github.com/docker/docker/issues/25925

COPY ./compile-kaldi.sh /opt

RUN chmod +x /opt/compile-kaldi.sh

ENTRYPOINT ["./opt/compile-kaldi.sh"]
