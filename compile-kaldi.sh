#!/bin/bash

cd ${WORKING_DIR}/kaldi/tools
make openfst
make cub

cd ../src
CXX=clang++ ./configure --static --android-incdir=${ANDROID_TOOLCHAIN_PATH}/sysroot/usr/include/ --host=arm-linux-androideabi --openblas-root=${WORKING_DIR}/OpenBLAS/install
sed -i 's/-g # -O0 -DKALDI_PARANOID/-O3 -DNDEBUG/g' kaldi.mk
make clean -j
make depend -j
make -j 4
