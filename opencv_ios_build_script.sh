#
# OpenCV build script and test codes for iOS.
# opencv_ios_build_script.sh
#
# Copyright (c) Yuichi YOSHIDA, 11/05/07
# All rights reserved.
# 
# BSD License
#
# Redistribution and use in source and binary forms, with or without modification, are 
# permitted provided that the following conditions are met:
# - Redistributions of source code must retain the above copyright notice, this list of
#  conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright notice, this list
#  of conditions and the following disclaimer in the documentation and/or other materia
# ls provided with the distribution.
# - Neither the name of the "Yuichi Yoshida" nor the names of its contributors may be u
# sed to endorse or promote products derived from this software without specific prior 
# written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY E
# XPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES O
# F MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SH
# ALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENT
# AL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROC
# UREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS I
# NTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
# CT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF T
# HE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
 
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