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

function(get_image_bits IMAGE IMAGE_NAME IMAGE_TAG)
  string(REGEX REPLACE ":.*$" "" IMAGE_NAME_ ${IMAGE})
  string(REGEX REPLACE "^.*:" "" IMAGE_TAG_ ${IMAGE})
  set(${IMAGE_NAME} ${IMAGE_NAME_} PARENT_SCOPE)
  set(${IMAGE_TAG} ${IMAGE_TAG_} PARENT_SCOPE)
endfunction()

function(add_docker_build_test IMAGE DOCKERFILE TARGET )
  cmake_parse_arguments(PARSE_ARGV 2 ARG "" "TARGET" "")
  add_test(NAME ${IMAGE}
    COMMAND docker build
      --build-arg http_proxy=$ENV{http_proxy}
      --build-arg https_proxy=$ENV{https_proxy}
      --target "${ARG_TARGET}"
      -t docker-templates/tests/${IMAGE} -f ${DOCKERFILE} .)
  message(" * ${IMAGE}")
endfunction()

function(add_test_image _IMAGE _TEMPLATE)
  set(oneValueArgs OUTDIR TARGET)
  cmake_parse_arguments(PARSE_ARGV 2 ARG "" "${oneValueArgs}" "DEPENDS")

  if(NOT ARG_OUTDIR)
    set(ARG_OUTDIR ${CMAKE_CURRENT_BINARY_DIR}/.docker/${_IMAGE})
  endif()
  set(_DOCKERFILE ${ARG_OUTDIR}/Dockerfile)
  m4(${_DOCKERFILE} ${_TEMPLATE} DEPENDS ${ARG_DEPENDS})
  add_custom_target(${_IMAGE}-Dockerfile ALL DEPENDS ${_DOCKERFILE})
  add_docker_build_test(${_IMAGE} ${_DOCKERFILE} TARGET ${ARG_TARGET})
endfunction()

function(add_run_test IMAGE TEST_SCRIPT)
  get_filename_component(TEST_SCRIPT_DIR ${TEST_SCRIPT} DIRECTORY)
  get_filename_component(TEST_SCRIPT_NAME ${TEST_SCRIPT} NAME)
  get_filename_component(TEST_SCRIPT_NAME_WE ${TEST_SCRIPT} NAME_WE)

  set(TEST_NAME ${IMAGE}-${TEST_SCRIPT_NAME_WE})
  add_test(NAME ${TEST_NAME}
    COMMAND docker run
      --rm -v ${TEST_SCRIPT_DIR}:/opt/tests
      docker-templates/tests/${IMAGE} /opt/tests/${TEST_SCRIPT_NAME})
  message(" * ${TEST_NAME}")
endfunction()

add_subdirectory(components)
add_subdirectory(m4)
add_subdirectory(stacks)
