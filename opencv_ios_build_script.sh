#!/bin/sh

# target paths

PATH_IOS=./ios/
PATH_LIB_OUTPUT=${PATH_IOS}/lib/
PATH_ARMV7=${PATH_IOS}device_armv7/
PATH_ARMV6=${PATH_IOS}device_armv6/
PATH_SIMULARTOR=${PATH_IOS}simulator/

# patched opencv's cmake script

patch -p1 < ./OpenCV-2.2.0.patch

# make target directories

mkdir ${PATH_IOS}
mkdir ${PATH_LIB_OUTPUT}
mkdir ${PATH_ARMV7}
mkdir ${PATH_ARMV6}
mkdir ${PATH_SIMULARTOR}

# build three architectures

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

# integrate static libraries into one file.

libfiles[0]=libopencv_contrib.a
libfiles[1]=libopencv_core.a
libfiles[2]=libopencv_features2d.a
libfiles[3]=libopencv_flann.a
libfiles[4]=libopencv_gpu.a
libfiles[5]=libopencv_imgproc.a
libfiles[6]=libopencv_legacy.a
libfiles[7]=libopencv_ml.a
libfiles[8]=libopencv_objdetect.a
libfiles[9]=libopencv_video.a

for file in ${libfiles[@]};do
	lipo -create ${PATH_ARMV7}lib/${file} ${PATH_ARMV6}lib/${file} ${PATH_SIMULARTOR}lib/${file} -output ${PATH_LIB_OUTPUT}${file}
	lipo -info ${PATH_LIB_OUTPUT}${file}
done 