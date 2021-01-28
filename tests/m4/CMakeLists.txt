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

message("Generating tests for m4 templates generation")

set(M4FLAGS ${M4FLAGS} -D OS_NAME=ubuntu -D OS_VERSION=20.04)

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/args.m4
"include(begin.m4)include(end.m4)dnl
define(`ECHO_SEP',`-')dnl
define(`RESULT',`ECHO(ARGS(`a b  c   d'))')dnl
define(`EXPECT',``a-b-c-d'')dnl
ifelse(RESULT,EXPECT,RESULT,`ERROR(`expect != result: \"EXPECT\" vs. \"RESULT\"')')
")

m4(args ${CMAKE_CURRENT_BINARY_DIR}/args.m4 DEPENDS ${system_srcs})

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/pkgs.m4
"include(begin.m4)include(end.m4)dnl
define(`PKG',`ifelse($1,abc,abc=1.2.3,$1)')dnl
define(`RESULT',`PKGS(abc,def)')dnl
define(`EXPECT',``abc=1.2.3 def'')dnl
ifelse(RESULT,EXPECT,RESULT,`ERROR(`expect != result: \"EXPECT\" vs. \"RESULT\"')')
")

m4(pkgs ${CMAKE_CURRENT_BINARY_DIR}/pkgs.m4 DEPENDS ${system_srcs})

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/to-regexp.m4
"include(begin.m4)include(end.m4)dnl
define(`RESULT',`TO_REGEXP(`g++')')dnl
define(`EXPECT',`g\\+\\+')dnl
ifelse(RESULT,EXPECT,RESULT,`ERROR(`expect != result: \"EXPECT\" vs. \"RESULT\"')')
")

m4(to-regexp ${CMAKE_CURRENT_BINARY_DIR}/to-regexp.m4 DEPENDS ${system_srcs})

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/remove-head.m4
"include(begin.m4)include(end.m4)dnl
define(`RESULT',`REMOVE(`a b c d',`a')')dnl
define(`EXPECT',`b c d')dnl
ifelse(RESULT,EXPECT,RESULT,`ERROR(`expect != result: \"EXPECT\" vs. \"RESULT\"')')
")

m4(remove-head ${CMAKE_CURRENT_BINARY_DIR}/remove-head.m4 DEPENDS ${system_srcs})

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/remove-middle.m4
"include(begin.m4)include(end.m4)dnl
define(`RESULT',`REMOVE(`a b c d',`b')')dnl
define(`EXPECT',`a c d')dnl
ifelse(RESULT,EXPECT,RESULT,`ERROR(`expect != result: \"EXPECT\" vs. \"RESULT\"')')
")

m4(remove-middle ${CMAKE_CURRENT_BINARY_DIR}/remove-middle.m4 DEPENDS ${system_srcs})

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/remove-tail.m4
"include(begin.m4)include(end.m4)dnl
define(`RESULT',`REMOVE(`a b c d',`d')')dnl
define(`EXPECT',`a b c')dnl
ifelse(RESULT,EXPECT,RESULT,`ERROR(`expect != result: \"EXPECT\" vs. \"RESULT\"')')
")

m4(remove-tail ${CMAKE_CURRENT_BINARY_DIR}/remove-tail.m4 DEPENDS ${system_srcs})

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/remove-two.m4
"include(begin.m4)include(end.m4)dnl
define(`RESULT',`REMOVE(`a b c d',`a',`c')')dnl
define(`EXPECT',`b d')dnl
ifelse(RESULT,EXPECT,RESULT,`ERROR(`expect != result: \"EXPECT\" vs. \"RESULT\"')')
")

m4(remove-two ${CMAKE_CURRENT_BINARY_DIR}/remove-two.m4 DEPENDS ${system_srcs})

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/remove-duplicates.m4
"include(begin.m4)include(end.m4)dnl
define(`RESULT',`REMOVE_DUPLICATES(`a b a d')')dnl
define(`EXPECT',`a b d')dnl
ifelse(RESULT,EXPECT,RESULT,`ERROR(`expect != result: \"EXPECT\" vs. \"RESULT\"')')
")

m4(remove-duplicates ${CMAKE_CURRENT_BINARY_DIR}/remove-duplicates.m4 DEPENDS ${srcs})

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/remove-specials.m4
"include(begin.m4)include(end.m4)dnl
define(`RESULT',`REMOVE(`a++ b',`a++')')dnl
define(`EXPECT',`b')dnl
ifelse(RESULT,EXPECT,RESULT,`ERROR(`expect != result: \"EXPECT\" vs. \"RESULT\"')')
")

m4(remove-specials ${CMAKE_CURRENT_BINARY_DIR}/remove-specials.m4 DEPENDS ${srcs})

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/remove-matching.m4
"include(begin.m4)include(end.m4)dnl
define(`BUILD_DEPS',`a b c d')dnl
define(`BUILD_PROVIDES',`a c')dnl
define(`RESULT',`REMOVE_MATCHING(`BUILD_DEPS',`BUILD_PROVIDES')')dnl
define(`EXPECT',`b d')dnl
ifelse(RESULT,EXPECT,RESULT,`ERROR(`expect != result: \"EXPECT\" vs. \"RESULT\"')')
")

m4(remove-matching ${CMAKE_CURRENT_BINARY_DIR}/remove-matching.m4 DEPENDS ${system_srcs})

add_custom_target(m4-tests ALL DEPENDS
  args pkgs to-regexp
  remove-head remove-middle remove-tail remove-two remove-specials
  remove-duplicates remove-matching)
