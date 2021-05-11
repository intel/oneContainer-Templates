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

DECLARE(`IGC_VER',igc-1.0.5964)
DECLARE(`LLVM_SPIRV_VER',v10.0.0)
DECLARE(`LLVM_PROJECT_VER',llvmorg-10.0.0)
DECLARE(`OPENCL_CLANG_VER',v10.0.0)
DECLARE(`SPIRV_LLVM_TRANSLATOR_VER',v10.0.0)
DECLARE(`VC_INTRINSICS_VER',master)
DECLARE(`LLVM_PATCHES_VER',master)

ifelse(OS_NAME,ubuntu,`dnl
define(`IGC_BUILD_DEPS',`ca-certificates cmake ccache flex bison flex bison libz-dev patch git make g++ python')
')

define(`BUILD_IGC',
ARG IGC_REPO=https://github.com/intel/intel-graphics-compiler.git
ARG LLVM_SPIRV_REPO=https://github.com/KhronosGroup/SPIRV-LLVM-Translator.git
ARG LLVM_PROJECT_REPO=https://github.com/llvm/llvm-project.git
ARG OPENCL_CLANG_REPO=https://github.com/intel/opencl-clang.git
ARG SPIRV_LLVM_TRANSLATOR_REPO=https://github.com/KhronosGroup/SPIRV-LLVM-Translator.git
ARG VC_INTRINSICS_REPO=https://github.com/intel/vc-intrinsics.git
ARG LLVM_PATCHES_REPO=https://github.com/intel/llvm-patches.git

RUN mkdir -p BUILD_HOME/intel-compute-runtime/workspace/build_igc

RUN cd BUILD_HOME/intel-compute-runtime/workspace; \
    git clone -b IGC_VER ${IGC_REPO} igc; \
    git clone -b LLVM_SPIRV_VER ${LLVM_SPIRV_REPO} llvm-spirv; \
    git clone -b LLVM_PROJECT_VER ${LLVM_PROJECT_REPO} llvm-project; \
    git clone -b OPENCL_CLANG_VER ${OPENCL_CLANG_REPO} llvm-project/llvm/projects/opencl-clang; \
    git clone -b SPIRV_LLVM_TRANSLATOR_VER ${SPIRV_LLVM_TRANSLATOR_REPO} llvm-project/llvm/projects/llvm-spirv; \
    git clone -b VC_INTRINSICS_VER ${VC_INTRINSICS_REPO} vc-intrinsics; \
    git clone -b LLVM_PATCHES_VER ${LLVM_PATCHES_REPO} llvm_patches;

RUN cd BUILD_HOME/intel-compute-runtime/workspace/build_igc && \
    cmake ../igc/IGC && \
    make -j $(nproc) && \
    make install && \
    make install DESTDIR=BUILD_DESTDIR
)

REG(IGC)

include(end.m4)dnl
