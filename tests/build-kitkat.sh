#!/bin/bash
#
# Test script file that maps itself into a docker container and runs
#
set -ex

AOSP_BIN=${AOSP_BIN:-aosp}

if [ "$1" = "docker" ]; then
    branch=android-4.4.4_r2.0.1
    cpus=$(grep ^processor /proc/cpuinfo | wc -l)

    repo init -u https://android.googlesource.com/platform/manifest -b $branch
    repo sync -j $(($cpus * 2))

    prebuilts/misc/linux-x86/ccache/ccache -M 10G

    source build/envsetup.sh 
    lunch aosp_arm-eng
    make -j $cpus
else 
    export AOSP_EXTRA_ARGS="-v $(readlink -f $0):/usr/local/bin/run.sh:ro"
    $AOSP_BIN run.sh docker
fi
