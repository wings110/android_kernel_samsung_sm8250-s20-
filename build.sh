#!/bin/bash

# 设置架构为 ARM64
export ARCH=arm64

# 设置 python 为 python2.7
sudo ln -sf /usr/bin/python2.7 /usr/bin/python

# 创建输出目录
mkdir -p out

# 定义交叉编译器路径
BUILD_CROSS_COMPILE=$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-

# 定义 LLVM (clang) 二进制文件路径
KERNEL_LLVM_BIN=$(pwd)/toolchain/llvm-arm-toolchain-ship/10.0/bin/clang

# 定义 CLANG 三元组
CLANG_TRIPLE=aarch64-linux-gnu-

# 设置内核 make 的附加环境变量
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

# 创建日志文件
LOGFILE=$(pwd)/kernel.log

# 使用 ccache 包装编译器
export CC="ccache $KERNEL_LLVM_BIN"
export CXX="ccache $(dirname $KERNEL_LLVM_BIN)/clang++"

# 设置优化级别
export CFLAGS="-O2"
export CXXFLAGS="-O2"

# 使用 defconfig 配置并添加 LTO=thin
make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE LTO=thin vendor/y2q_chn_openx_defconfig 2>&1 | tee -a $LOGFILE

# 手动配置（可选）
make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE LTO=thin menuconfig

# 实际构建内核并添加 LTO=thin
make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE LTO=thin 2>&1 | tee -a $LOGFILE

# 将生成的内核镜像复制到指定目录
cp out/arch/arm64/boot/Image $(pwd)/arch/arm64/boot/Image

