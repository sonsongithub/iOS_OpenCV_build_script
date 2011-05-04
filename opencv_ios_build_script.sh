#!/bin/sh

patch -p1 < ./OpenCV-2.2.0.patch

mkdir ios
mkdir ios/device_armv7
mkdir ios/device_armv6
mkdir ios/simulator

cd ./ios
cd ./device_armv7
../../opencv_cmake.sh armv7 ../../
make -j 4

cd ../device_armv6
../../opencv_cmake.sh armv6 ../../
make -j 4

cd ../simulator
../../opencv_cmake.sh simulator ../../
make -j 4
