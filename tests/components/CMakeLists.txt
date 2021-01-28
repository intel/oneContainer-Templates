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

function(test_single_component _COMPONENT)
  cmake_parse_arguments(PARSE_ARGV 1 ARG "" "" "IMAGES")

  set(M4FLAGS_TMP ${M4FLAGS} -E -I ${CMAKE_SOURCE_DIR}/system -I ${CMAKE_SOURCE_DIR}/components)

  foreach(IMAGE IN LISTS ARG_IMAGES)
    message("Generating tests for ${IMAGE} for ${COMPONENT}")
    get_image_bits(${IMAGE} IMAGE_NAME IMAGE_TAG)

    set(FLAVORS runtime devel)
    foreach(FLAVOR IN LISTS FLAVORS)
      set(M4FLAGS ${M4FLAGS_TMP} -D COMPONENT=${_COMPONENT} -D OS_NAME=${IMAGE_NAME} -D OS_VERSION=${IMAGE_TAG})
      if(FLAVOR MATCHES devel)
        set(M4FLAGS ${M4FLAGS} -D CLEANUP_DEV=no)
      endif()

      set(TEST_IMAGE ${IMAGE_NAME}-${IMAGE_TAG}-${_COMPONENT}-${FLAVOR})

      add_test_image(${TEST_IMAGE} ${CMAKE_SOURCE_DIR}/tests/components/single.m4
        DEPENDS ${system_srcs} ${components_srcs}
        TARGET ${DOCKER_BUILD_TARGET})

      if(${DOCKER_BUILD_TARGET} MATCHES last)
        m4(${CMAKE_CURRENT_BINARY_DIR}/.docker/${TEST_IMAGE}/consistency.sh ${CMAKE_SOURCE_DIR}/tests/consistency.sh.m4 EXE)
        add_custom_target(${TEST_IMAGE}-tests ALL DEPENDS
          ${CMAKE_CURRENT_BINARY_DIR}/.docker/${TEST_IMAGE}/consistency.sh)

        add_run_test(${TEST_IMAGE} ${CMAKE_CURRENT_BINARY_DIR}/.docker/${TEST_IMAGE}/consistency.sh)
      endif()
    endforeach()
  endforeach()
endfunction()

# ubuntu18.04:
#  * cmake 3.10
set(IMAGES ubuntu:18.04 ubuntu:20.04 centos:7 centos:8)
set(IMAGES_cmake3 ubuntu:18.04 ubuntu:20.04 centos:8)
set(IMAGES_meson47 ubuntu:20.04 centos:7 centos:8)

test_single_component(dav1d IMAGES ${IMAGES_meson47})
test_single_component(dldt-ie IMAGES ubuntu:20.04)       # cmake-3.13
test_single_component(ffmpeg IMAGES ${IMAGES})
test_single_component(gmmlib IMAGES ${IMAGES})
test_single_component(libva2 IMAGES ${IMAGES})
test_single_component(libva2-utils IMAGES ${IMAGES})
test_single_component(libx264 IMAGES ${IMAGES})
test_single_component(media-driver IMAGES ${IMAGES})
test_single_component(msdk IMAGES ${IMAGES})
test_single_component(nginx IMAGES ${IMAGES})
test_single_component(svt-av1 IMAGES ${IMAGES})
test_single_component(svt-hevc IMAGES ${IMAGES})
test_single_component(gst-core IMAGES ${IMAGES_meson47})
test_single_component(gst-plugins-base IMAGES ${IMAGES_meson47})
test_single_component(gst-plugins-good IMAGES ${IMAGES_meson47})
test_single_component(gst-plugins-bad IMAGES ${IMAGES_meson47})
test_single_component(gst-plugins-ugly IMAGES ${IMAGES_meson47})
test_single_component(gst-libav IMAGES ${IMAGES_meson47})
test_single_component(gst-vaapi IMAGES ${IMAGES_meson47})
test_single_component(opencv IMAGES ${IMAGES_cmake3})
test_single_component(gst-orc IMAGES ${IMAGES_meson47})
test_single_component(gst-svt IMAGES ${IMAGES_meson47})
