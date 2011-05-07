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
#
# Origial is https://github.com/niw/iphone_opencv_test
# 
# Copyright (c) 2009 Yoshimasa Niwa
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

#!/bin/sh

if [ "$1" = "-h" -o "$1" = "--help" -o -z "$1" ]; then
	echo "USAGE"
	echo "    $0 [-h,--help] {device,simulator} source_dir"
	echo "OPTIONS"
	echo "    -h, --help     Show help and default options"
	echo "    device         Build binary for iOS devices"
	echo "    simulator      Build binary for iOS Simulator"
	echo "    source_dir     Path to OpenCV source directory"
	echo "ENVIRONMENT"
	echo "    INSTALL_PREFIX       Path to OpenCV binary directory"
	echo "    SDK_VERSION          iOS SDK version"
	echo "    IPHONEOS_VERSION_MIN iOS deployment target"
	exit
fi

if ! type 'cmake' > /dev/null 2>&1; then
	echo "cmake is not found, please install cmake command which is required to build OpenCV 2.2."
	exit 1;
fi

TARGET_SDK=`echo "$1"|tr '[:upper:]' '[:lower:]'`
if [ "$TARGET_SDK" = "device" ]; then
	TARGET_SDK_NAME="iPhoneOS"
elif [ "$TARGET_SDK" = "simulator" ]; then
	TARGET_SDK_NAME="iPhoneSimulator"
else
	echo "Please select Device or Simulator."
	exit 1
fi

if [ -z "$SDK_VERSION" ]; then
	SDK_VERSION="4.3"
fi

if [ -z "$IPHONEOS_VERSION_MIN" ]; then
	IPHONEOS_VERSION_MIN="4.3"
fi

DEVELOPER_ROOT="/Developer/Platforms/${TARGET_SDK_NAME}.platform/Developer"
SDK_ROOT="${DEVELOPER_ROOT}/SDKs/${TARGET_SDK_NAME}${SDK_VERSION}.sdk"	

if [ ! -d "$SDK_ROOT" ]; then
	echo "iOS SDK Version ${SDK_VERSION} is not found, please select iOS version you have."
	exit 1
fi

if [ -z "$2" ]; then
	echo "Please assign path to OpenCV source directory which includes CMakeLists.txt."
	exit 1
else
	OPENCV_ROOT="$2"
fi

if [ ! -f "${OPENCV_ROOT}/CMakeLists.txt" ]; then
	echo "No CMakeLists.txt in ${OPENCV_ROOT}, please select OpenCV source directory."
	exit 1
fi

if [ -z "$INSTALL_PREFIX" ]; then
	INSTALL_PREFIX="`pwd`/../opencv_${TARGET_SDK}"
fi

#BUILD_PATH="`pwd`/build_${TARGET_SDK}"
#if [ -d "${BUILD_PATH}" ]; then
#	echo "${BUILD_PATH} is found, please remove it prior to run this command."
#	exit 1
#else
#	mkdir -p "${BUILD_PATH}"
#fi
#cd "${BUILD_PATH}"

echo "Starting cmake..."
echo "Target SDK            = $TARGET_SDK_NAME"
echo "iOS SDK Version       = $SDK_VERSION"
echo "iOS Deployment Target = $IPHONEOS_VERSION_MIN"
echo "OpenCV Root           = $OPENCV_ROOT"
echo "OpenCV Install Prefix = $INSTALL_PREFIX"
echo ""

if [ "$TARGET_SDK" = "simulator" ]; then
	FLAGS=""
	ARCH="i386"
	CMAKE_OPTIONS='-D CMAKE_OSX_DEPLOYMENT_TARGET="10.6"'
else
	FLAGS="-miphoneos-version-min=${IPHONEOS_VERSION_MIN} -mno-thumb -O3 -arch armv6 -arch armv7"
	ARCH="armv6;armv7"
	#CMAKE_OPTIONS="-D ENABLE_SSE=OFF -D ENABLE_SSE2=OFF -D CMAKE_SYSTEM_PROCESSOR=arm"
	CMAKE_OPTIONS="-D ENABLE_SSE=OFF -D ENABLE_SSE2=OFF"
fi

env \
	CFLAGS="${FLAGS}" \
	CXXFLAGS="${FLAGS}" \
	LDFLAGS="${FLAGS}" \
cmake \
	-D CMAKE_BUILD_TYPE=Release \
	-D BUILD_NEW_PYTHON_SUPPORT=OFF \
	-D BUILD_SHARED_LIBS=OFF \
	-D BUILD_TESTS=OFF \
	-D OPENCV_BUILD_3RDPARTY_LIBS=OFF \
	-D WITH_1394=OFF \
	-D WITH_CARBON=OFF \
	-D WITH_FFMPEG=OFF \
	-D WITH_JASPER=OFF \
	-D WITH_PVAPI=OFF \
	-D WITH_QUICKTIME=OFF \
	-D WITH_TBB=OFF \
	-D WITH_TIFF=OFF \
	-D CMAKE_OSX_SYSROOT="${SDK_ROOT}" \
	-D CMAKE_OSX_ARCHITECTURES="${ARCH}" \
	-D CMAKE_C_COMPILER="${DEVELOPER_ROOT}/usr/bin/gcc" \
	-D CMAKE_CXX_COMPILER="${DEVELOPER_ROOT}/usr/bin/g++" \
	-D CMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
	${CMAKE_OPTIONS} \
	"${OPENCV_ROOT}" \
	&& echo "" \
	&& echo "Done! next step is runing make (with -j option if you want to build using multi cores)."
