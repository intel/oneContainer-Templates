dnl BSD 3-Clause License
dnl
dnl Copyright (c) 2020, Intel Corporation
dnl All rights reserved.
dnl
dnl Redistribution and use in source and binary forms, with or without
dnl modification, are permitted provided that the following conditions are met:
dnl
dnl * Redistributions of source code must retain the above copyright notice, this
dnl   list of conditions and the following disclaimer.
dnl
dnl * Redistributions in binary form must reproduce the above copyright notice,
dnl   this list of conditions and the following disclaimer in the documentation
dnl   and/or other materials provided with the distribution.
dnl
dnl * Neither the name of the copyright holder nor the names of its
dnl   contributors may be used to endorse or promote products derived from
dnl   this software without specific prior written permission.
dnl
dnl THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
dnl AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
dnl IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
dnl DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
dnl FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
dnl DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
dnl SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
dnl CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
dnl OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
dnl OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
dnl
include(begin.m4)
include(opencv.m4)

DECLARE(`DLDT_VER',2021.2)
DECLARE(`DLDT_WARNING_AS_ERRORS',false)
DECLARE(`DLDT_WITH_OPENCL',false)

define(`DLDT_WITH_OPENCL_INSTALL',dnl
ifelse(DLDT_WITH_OPENCL,true,`ifelse(
OS_NAME,ubuntu,ocl-icd-libopencl1)'))dnl

ifelse(OS_NAME,ubuntu,dnl
define(`DLDT_BUILD_DEPS',`ca-certificates cmake gcc g++ git libboost-all-dev libgtk2.0-dev libgtk-3-dev libtool libusb-1.0-0-dev make python python-yaml xz-utils')
define(`DLDT_INSTALL_DEPS',`libgtk-3-0 libnuma1 DLDT_WITH_OPENCL_INSTALL')
)

define(`BUILD_DLDT',
ARG DLDT_REPO=https://github.com/openvinotoolkit/openvino.git

RUN git clone ${DLDT_REPO} BUILD_HOME/openvino && \
  cd BUILD_HOME/openvino && \
  git checkout DLDT_VER && \
  git submodule update --init --recursive

# TODO:
# Perform make install of openvino instead of manually copying build artifacts.
#
# For now, only ngraph target is installed using make install (it auto-generates .cmake
# files during install stage, so they can be later used by other projects).

RUN cd BUILD_HOME/openvino && \
sed -i 's/"deployment_tools\/ngraph\/"//g' $(grep -ril '"deployment_tools\/ngraph\/"') && \
ifelse(DLDT_WARNING_AS_ERRORS,false,`dnl
  sed -i s/-Werror//g $(grep -ril Werror inference-engine/thirdparty/) && \
')dnl
  mkdir build && cd build && \
  cmake \
    -DCMAKE_INSTALL_PREFIX=BUILD_PREFIX/dldt \
    -DENABLE_CPPLINT=OFF \
    -DENABLE_GNA=OFF \
    -DENABLE_VPU=OFF \
    -DENABLE_OPENCV=OFF \
    -DENABLE_MKL_DNN=ON \
    -DENABLE_CLDNN=ifelse(DLDT_WITH_OPENCL,false,OFF,ON) \
    -DENABLE_SAMPLES=OFF \
    -DENABLE_TESTS=OFF \
    -DBUILD_TESTS=OFF \
    -DTREAT_WARNING_AS_ERROR=ifelse(DLDT_WARNING_AS_ERRORS,false,OFF,ON) \
    -DNGRAPH_WARNINGS_AS_ERRORS=ifelse(DLDT_WARNING_AS_ERRORS,false,OFF,ON) \
    -DNGRAPH_COMPONENT_PREFIX=inference-engine/ \
    -DNGRAPH_UNIT_TEST_ENABLE=OFF \
    -DNGRAPH_TEST_UTIL_ENABLE=OFF \
    .. && \
  make -j $(nproc) && \
  make -C ngraph install && \
  make -C ngraph install DESTDIR=BUILD_DESTDIR && \
  rm -rf ../bin/intel64/Release/lib/libgtest* && \
  rm -rf ../bin/intel64/Release/lib/libgmock* && \
  rm -rf ../bin/intel64/Release/lib/libmock* && \
  rm -rf ../bin/intel64/Release/lib/libtest*

ARG CUSTOM_IE_DIR=BUILD_PREFIX/dldt/inference-engine
ARG CUSTOM_IE_LIBDIR=${CUSTOM_IE_DIR}/lib/intel64
ENV CUSTOM_DLDT=${CUSTOM_IE_DIR}

ENV InferenceEngine_DIR=BUILD_PREFIX/dldt/inference-engine/share
ENV TBB_DIR=BUILD_PREFIX/dldt/inference-engine/external/tbb/cmake
ENV ngraph_DIR=BUILD_PREFIX/dldt/inference-engine/cmake

RUN cd BUILD_HOME && \
  mkdir -p ${CUSTOM_IE_DIR}/include && \
  mkdir -p BUILD_DESTDIR/${CUSTOM_IE_DIR}/include && \
  cp -r openvino/inference-engine/include/* ${CUSTOM_IE_DIR}/include && \
  cp -r openvino/inference-engine/include/* BUILD_DESTDIR/${CUSTOM_IE_DIR}/include && \
  \
  mkdir -p ${CUSTOM_IE_LIBDIR} && \
  mkdir -p BUILD_DESTDIR/${CUSTOM_IE_LIBDIR} && \
  cp -r openvino/bin/intel64/Release/lib/* ${CUSTOM_IE_LIBDIR} && \
  cp -r openvino/bin/intel64/Release/lib/* BUILD_DESTDIR/${CUSTOM_IE_LIBDIR} && \
  \
  mkdir -p ${CUSTOM_IE_DIR}/src && \
  mkdir -p BUILD_DESTDIR/${CUSTOM_IE_DIR}/src && \
  cp -r openvino/inference-engine/src/* ${CUSTOM_IE_DIR}/src/ && \
  cp -r openvino/inference-engine/src/* BUILD_DESTDIR/${CUSTOM_IE_DIR}/src/ && \
  \
  mkdir -p ${CUSTOM_IE_DIR}/share && \
  mkdir -p BUILD_DESTDIR/${CUSTOM_IE_DIR}/share && \
  mkdir -p ${CUSTOM_IE_DIR}/external/ \
  mkdir -p BUILD_DESTDIR/${CUSTOM_IE_DIR}/external && \
  cp -r openvino/build/share/* ${CUSTOM_IE_DIR}/share/ && \
  cp -r openvino/build/share/* BUILD_DESTDIR/${CUSTOM_IE_DIR}/share/ && \
  cp -r openvino/inference-engine/temp/tbb ${CUSTOM_IE_DIR}/external/ && \
  cp -r openvino/inference-engine/temp/tbb BUILD_DESTDIR/${CUSTOM_IE_DIR}/external/ && \
  \
  mkdir -p "${CUSTOM_IE_LIBDIR}/pkgconfig"

RUN { \
  echo "prefix=${CUSTOM_IE_DIR}"; \
  echo "libdir=${CUSTOM_IE_LIBDIR}"; \
  echo "includedir=${CUSTOM_IE_DIR}/include"; \
  echo ""; \
  echo "Name: DLDT"; \
  echo "Description: Intel Deep Learning Deployment Toolkit"; \
  echo "Version: 5.0"; \
  echo ""; \
  echo "Libs: -L\${libdir} -linference_engine -linference_engine_c_wrapper"; \
  echo "Cflags: -I\${includedir}"; \
  } > ${CUSTOM_IE_LIBDIR}/pkgconfig/dldt.pc

RUN rm -rf BUILD_HOME/openvino
)

define(`INSTALL_DLDT',
ARG CUSTOM_IE_DIR=BUILD_PREFIX/dldt/inference-engine
ARG CUSTOM_IE_LIBDIR=${CUSTOM_IE_DIR}/lib/intel64
RUN { \
   echo "${CUSTOM_IE_LIBDIR}"; \
   echo "${CUSTOM_IE_DIR}/external/tbb/lib"; \
} > /etc/ld.so.conf.d/dldt.conf
RUN ldconfig
)

define(`ENV_VARS_DLDT',`
ENV InferenceEngine_DIR=BUILD_PREFIX/dldt/inference-engine/share
ENV TBB_DIR=BUILD_PREFIX/dldt/inference-engine/external/tbb/cmake
ENV ngraph_DIR=BUILD_PREFIX/dldt/inference-engine/cmake
')

REG(DLDT)

include(end.m4)dnl
