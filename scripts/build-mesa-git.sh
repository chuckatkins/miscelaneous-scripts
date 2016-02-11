#!/bin/bash
if [ ! -e llvm-3.7.1.src.tar.xz ]
then
  wget http://llvm.org/releases/3.7.1/llvm-3.7.1.src.tar.xz
fi
tar -xvf llvm-3.7.1.src.tar.xz
mkdir llvm-3.7.1.bld
pushd llvm-3.7.1.bld
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$(readlink -f ..)/llvm-3.7.1.inst \
  -DLLVM_ENABLE_RTTI=ON \
  -DLLVM_TARGETS_TO_BUILD=X86 \
  -DLLVM_INSTALL_UTILS=ON \
  ../llvm-3.7.1.src
make -j8 install
popd
export PATH=${PWD}/llvm-3.7.1.inst/bin:${PATH}

if [ ! -e Mako-1.0.3.tar.gz ]
then
  wget https://pypi.python.org/packages/source/M/Mako/Mako-1.0.3.tar.gz
fi
tar -xvf Mako-1.0.3.tar.gz
export PYTHONPATH=${PWD}/Mako-1.0.3:${PYTHONPATH}


git clone git://anongit.freedesktop.org/git/mesa/mesa mesa-master
pushd mesa-master

# Patch Mesa to avoid duplicate conflicting libGL
sed 's|^SUBDIRS += drivers/x11|if !HAVE_GALLIUM\n\0\nendif|' -i src/mesa/Makefile.am

# Determine a mesa version based on the most recent git commit
VER=$(cat VERSION)-$(git log --pretty=format:"%ci" | head -1 | sed 's|\([^-]*\)-\([^-]*\)-\([^ ]*\) .*|\1\2\3|')git

# Set common config arguments for all mesa abuilds
MESA_CONFIG_ARGS="--disable-va --disable-gbm --disable-xvmc --disable-vdpau --disable-dri --with-dri-drivers= --disable-egl --with-egl-platforms= --disable-gles1 --disable-gles2 --disable-shared-glapi --disable-llvm-shared-libs --enable-texture-float --enable-glx --enable-xlib-glx --enable-gallium-llvm=yes --enable-gallium-osmesa"

make distclean
./autogen.sh ${MESA_CONFIG_ARGS} \
  --with-gallium-drivers=swrast \
  --prefix=$(readlink -f ..)/mesa-install/${VER}
make -j8 install
popd

git clone https://github.com/OpenSWR/openswr-mesa.git openswr-master
pushd openswr-master

# Patch Mesa to avoid duplicate conflicting libGL
sed 's|^SUBDIRS += drivers/x11|if !HAVE_GALLIUM\n\0\nendif|' -i src/mesa/Makefile.am

# Patch the configure script to add an extra necessary llvm component for swr
sed 's|^            HAVE_GALLIUM_SWR=yes|\0\n            LLVM_COMPONENTS="${LLVM_COMPONENTS} irreader"|' -i configure.ac

# Determine a mesa version based on the most recent git commit
VER=$(cat VERSION)-$(git log --pretty=format:"%ci" | head -1 | sed 's|\([^-]*\)-\([^-]*\)-\([^ ]*\) .*|\1\2\3|')git

make distclean
./autogen.sh ${MESA_CONFIG_ARGS} \
  --with-gallium-drivers=swr,swrast \
  --enable-swr-native \
  --with-swr-arch=AVX \
  --prefix=$(readlink -f ..)/mesa-install/openswr-${VER}-avx
make -j8 install

make distclean
./configure ${MESA_CONFIG_ARGS} \
  --with-gallium-drivers=swr,swrast \
  --enable-swr-native \
  --with-swr-arch=CORE-AVX2 \
  --prefix=$(readlink -f ..)/mesa-install/openswr-${VER}-avx2
make -j8 install
popd

