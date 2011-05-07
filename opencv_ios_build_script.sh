#!/bin/sh

# target paths

PATH_WORKING_SPACE=./build/
PATH_LIB_TARGET=${PATH_WORKING_SPACE}lib/
PATH_HEADER_TARGET=${PATH_WORKING_SPACE}include/

PATH_LIB_OUTPUT=${PATH_LIB_TARGET}/

PATH_ARMV=${PATH_WORKING_SPACE}armv/
PATH_SIMULARTOR=${PATH_WORKING_SPACE}simulator/

OPENCV=OpenCV-2.2.0

# patched opencv's cmake script

cd ./${OPENCV}
patch -p1 < ../OpenCV-2.2.0.patch
cd ../

# make target directories

mkdir ${PATH_WORKING_SPACE}
mkdir ${PATH_LIB_TARGET}
mkdir ${PATH_HEADER_TARGET}
mkdir ${PATH_LIB_OUTPUT}
mkdir ${PATH_ARMV}
mkdir ${PATH_SIMULARTOR}

# build three architectures

cd ./${PATH_ARMV}
../../opencv_cmake.sh device ../../${OPENCV}
make -j 4
cd ../../

cd ./${PATH_SIMULARTOR}
../../opencv_cmake.sh simulator ../../${OPENCV}
make -j 4
cd ../../

# integrate static libraries into one file.

modules[0]=contrib
modules[1]=core
modules[2]=features2d
modules[3]=flann
modules[4]=gpu
modules[5]=imgproc
modules[6]=legacy
modules[7]=ml
modules[8]=objdetect
modules[9]=video
modules[10]=calib3d

for module in ${modules[@]};do
	file="libopencv_${module}.a"
	lipo -create ${PATH_ARMV}lib/${file} ${PATH_SIMULARTOR}lib/${file} -output ${PATH_LIB_TARGET}${file}
	lipo -info ${PATH_LIB_TARGET}${file}
done

# setup header files

cp -r ./${OPENCV}/include/* ${PATH_HEADER_TARGET}

for module in ${modules[@]};do
	cp -r ./${OPENCV}/modules/${module}/include/opencv2/${module} ${PATH_HEADER_TARGET}/opencv2/
done