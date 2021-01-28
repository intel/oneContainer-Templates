#!/bin/bash

set -e

include(begin.m4)
include(end.m4)

PREFIX=BUILD_PREFIX
LIBDIR=BUILD_LIBDIR
BINDIR=BUILD_BINDIR

declare -a missing_libs=()

check_dependencies(){
    local path="$1"
    for i in $(find $path -executable -type f)
    do
        # skip libtool la extension due these files are not a dynamic executable
        if [[ $i = *.la ]]; then continue ; fi
        ldd $i > /dev/null 2>&1
        if [[ $? -ne 0 ]]; then continue ; fi
        ldd_output=$(ldd $i | grep "not found" | cut -d '=' -f1)
        if [[ $ldd_output ]]; then echo "$i"; fi
        filter_repeated_libs=$(echo "$ldd_output" | xargs -n1 | sort -u | xargs)
        missing_libs+=("${filter_repeated_libs} " )
    done
    if [ "$(echo -ne ${missing_libs[@]} | wc -m)" -eq 0 ]; then
        exit 0
    else
        echo  "${missing_libs[@]}" | xargs -n1 | sort -u
        echo -e "\n"
        exit 1
    fi
}

check_dependencies $LIBDIR
check_dependencies $BINDIR

ifelse(CLEANUP_DEV,no,
export PKG_CONFIG_PATH=$LIBDIR/pkgconfig
for pc in $LIBDIR*/pkgconfig/*.pc; do
    pc1=$(basename ${pc/.pc/})
    pkg-config --exists $pc1
    g++ -x c++ $(pkg-config --cflags --libs $pc1) - <<EOF
int main(){return 0;}
EOF
done
)
