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

set(STACK_NAME intelpkg)

set(IMAGES ubuntu:20.04)
set(M4FLAGS_TMP ${M4FLAGS})

set(COMPONENT_TESTS ${CMAKE_SOURCE_DIR}/tests)

foreach(IMAGE IN LISTS IMAGES)
  message("Generating tests for ${IMAGE} for ${STACK_NAME} stack")
  get_image_bits(${IMAGE} IMAGE_NAME IMAGE_TAG)

  set(M4FLAGS ${M4FLAGS_TMP} -D OS_NAME=${IMAGE_NAME} -D OS_VERSION=${IMAGE_TAG})
  set(TEST_IMAGE ${IMAGE_NAME}-${IMAGE_TAG}-${STACK_NAME})

  add_test_image(${TEST_IMAGE} ${CMAKE_CURRENT_SOURCE_DIR}/Dockerfile.m4
    DEPENDS ${system_srcs} ${components_srcs}
    TARGET ${DOCKER_BUILD_TARGET})
endforeach()
