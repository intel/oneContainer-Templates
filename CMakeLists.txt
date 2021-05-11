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

cmake_minimum_required (VERSION 2.8)

project(m4docker LANGUAGES NONE)

set(PROJECT_VERSION_MAJOR 2)
set(PROJECT_VERSION_MINOR 0)

include(GNUInstallDirs)
include(CTest)

find_program(M4 m4 REQUIRED)

# User overridable dockerfile target to build
set(DOCKER_BUILD_TARGET "" CACHE STRING "")

# Compiles ``source`` into ``target`` via ``m4``.
# Supported input file extension:
#
# * .m4 - pure m4 input file
#
# * .in - cmake input file to generate .m4 from (via ``configure_file``)
function(m4 target source)
  cmake_parse_arguments(PARSE_ARGV 2 ARG "EXE" "" "DEPENDS")
  get_filename_component(ext ${source} EXT)
  if(NOT IS_ABSOLUTE ${target})
    set(target ${CMAKE_CURRENT_BINARY_DIR}/${target})
  endif()
  get_filename_component(outdir ${target} DIRECTORY)
  if(ext MATCHES ".in$")
    configure_file(${source} ${target}.m4)
    set(source ${target}.m4)
  elseif(NOT ext MATCHES ".m4$")
    message(FATAL_ERROR "wrong input (.m4|.in): ${source}")
  endif()
  add_custom_command(OUTPUT ${target} DEPENDS ${source} ${ARG_DEPENDS}
    COMMAND mkdir -p ${outdir}
    COMMAND ${M4} ${M4FLAGS} ${source} > ${target}
    COMMAND $<$<BOOL:${ARG_EXE}>:chmod> $<$<BOOL:${ARG_EXE}>:a+x> $<$<BOOL:${ARG_EXE}>:${target}>
    VERBATIM)
endfunction()

file(GLOB system_srcs ${CMAKE_SOURCE_DIR}/system/*.m4)
file(GLOB components_srcs ${CMAKE_SOURCE_DIR}/components/*.m4)

install(
  DIRECTORY
    ${CMAKE_SOURCE_DIR}/system
    ${CMAKE_SOURCE_DIR}/components
  DESTINATION
    ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}-${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR})

set(M4FLAGS ${M4FLAGS} -E -I ${CMAKE_SOURCE_DIR}/system -I ${CMAKE_SOURCE_DIR}/components)

if(BUILD_TESTING)
  add_subdirectory(tests)
endif()
