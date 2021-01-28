#!/bin/bash
#
# BSD 3-Clause License
#
# Copyright (c) 2018,Intel Corporation
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

files=$(git diff-tree --no-commit-id --name-only -r $1)
echo "== Modified files:"
echo $files
shift
known=$@
echo "== Known components:"
echo $known

affected=
for f in $files; do
  if echo $f | grep -q ^components/; then
    c=${f#*/}
    c=${c%.m4}
    affected+="$c "
  fi
done

echo "== Affected components:"
echo $affected

unknown=
for c in $affected; do
  found=no
  for k in $known; do
    if [[ $k = $c ]]; then
      echo "::set-output name=$c::1"
      found=yes
      break
    fi
  done
  if [[ $found = no ]]; then
    unknown+="$c "
  fi
done
echo "== Uknown affected components:"
echo $unknown

if [[ -n "$unknown" ]]; then
  exit 1
fi
