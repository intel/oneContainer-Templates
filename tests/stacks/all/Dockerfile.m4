# BSD 3-Clause License
#
# Copyright (c) 2020, Intel Corporation
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

include(begin.m4)
include(centos-repo.m4)
include(nasm.m4)
include(yasm.m4)
include(openssl.m4)
include(libva2.m4)
include(libva2-utils.m4)
include(gmmlib.m4)
include(media-driver.m4)
include(msdk.m4)
include(dav1d.m4)
include(libogg.m4)
include(libopus.m4)
include(libvorbis.m4)
include(libfdk-aac.m4)
include(libaom.m4)
include(libvpx.m4)
include(libx264.m4)
include(libx265.m4)
include(svt-av1.m4)
include(svt-hevc.m4)
include(opencv.m4)
include(ffmpeg.m4)
include(gst-plugins-base.m4)
include(gst-plugins-good.m4)
include(gst-plugins-bad.m4)
include(gst-plugins-ugly.m4)
include(gst-libav.m4)
include(gst-vaapi.m4)
include(gst-orc.m4)
include(gst-svt.m4)
ifelse(OS_NAME,ubuntu,`dnl
include(dldt-ie.m4)
')
include(nginx-flv.m4)
include(nginx-upload.m4)
include(nginx.m4)
include(end.m4)dnl
PREAMBLE
FROM OS_NAME:OS_VERSION as base
FROM base as build

ifelse(OS_NAME,centos,
INSTALL_CENTOS_REPO(epel-release)
ifelse(OS_VERSION,8,`
ENABLE_CENTOS_REPO(PowerTools)
INSTALL_CENTOS_RPMFUSION_REPO(OS_VERSION)
INSTALL_CENTOS_OKEY_REPO(OS_VERSION)
INSTALL_CENTOS_RAVEN_RELEASE_REPO(OS_VERSION)
'))dnl

BUILD_ALL()dnl
CLEANUP()dnl

FROM base

ifelse(OS_NAME,centos,
INSTALL_CENTOS_REPO(epel-release)
ifelse(OS_VERSION,8,`
ENABLE_CENTOS_REPO(PowerTools)
INSTALL_CENTOS_RPMFUSION_REPO(OS_VERSION)
INSTALL_CENTOS_OKEY_REPO(OS_VERSION)
INSTALL_CENTOS_RAVEN_RELEASE_REPO(OS_VERSION)
'))dnl

INSTALL_ALL(runtime,build)dnl
