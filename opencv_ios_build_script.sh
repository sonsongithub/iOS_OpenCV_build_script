#!/bin/sh

# target paths

PATH_TARGET=./lib/
PATH_LIB_OUTPUT=${PATH_TARGET}/
PATH_ARMV7=${PATH_TARGET}device_armv7/
PATH_ARMV6=${PATH_TARGET}device_armv6/
PATH_SIMULARTOR=${PATH_TARGET}simulator/

# patched opencv's cmake script

cd ./OpenCV-2.2.0
patch -p1 < ../OpenCV-2.2.0.patch
cd ../

# make target directories

mkdir ${PATH_TARGET}
mkdir ${PATH_LIB_OUTPUT}
mkdir ${PATH_ARMV7}
mkdir ${PATH_ARMV6}
mkdir ${PATH_SIMULARTOR}

# build three architectures

cd ./${PATH_ARMV7}
../../opencv_cmake.sh armv7 ../../OpenCV-2.2.0
make -j 4
cd ../../

cd ./${PATH_ARMV6}
../../opencv_cmake.sh armv6 ../../OpenCV-2.2.0
make -j 4
cd ../../

cd ./${PATH_SIMULARTOR}
../../opencv_cmake.sh simulator ../../OpenCV-2.2.0
make -j 4
cd ../../

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