#!/bin/bash
#
# Test script file that maps itself into a docker container and runs
#
# Example invocation:
#
# $ AOSP_VOL=$PWD/build ./sync-kitkat.sh
#
set -ex

if [ "$1" = "docker" ]; then
    TEST_BRANCH=${TEST_BRANCH:-android-4.4.4_r2.0.1}
    TEST_URL=${TEST_URL:-https://android.googlesource.com/platform/manifest}

    repo init --depth 1 -u "$TEST_URL" -b "$TEST_BRANCH"

    # Use default sync '-j' value embedded in manifest file to be polite
    repo sync
    retval=$?

    echo "repo sync returned: $retval"
    exit $retval
else
    aosp_url="https://raw.githubusercontent.com/kylemanna/docker-aosp/master/utils/aosp"
    args="run.sh docker"
    export AOSP_EXTRA_ARGS="-v $(cd $(dirname $0) && pwd -P)/$(basename $0):/usr/local/bin/run.sh:ro"
    export AOSP_VOL=/vol1
    export AOSP_IMAGE="kylemanna/aosp:4.4-kitkat"

    [ -n "$TEST_URL" ] && AOSP_EXTRA_ARGS+=" -e TEST_URL=$TEST_URL"
    [ -n "$TEST_BRANCH" ] && AOSP_EXTRA_ARGS+=" -e TEST_BRANCH=$TEST_BRANCHcY"

    #
    # Try to invoke the aosp wrapper with the following priority:
    #
    # 1. If AOSP_BIN is set, use that
    # 2. If aosp is found in the shell $PATH
    # 3. Grab it from the web
    #
    if [ -n "$AOSP_BIN" ]; then
        $AOSP_BIN $args
    elif [ -x "../utils/aosp" ]; then
        ../utils/aosp $args
    elif [ -n "$(type -P aosp)" ]; then
        aosp $args
    else
        if [ -n "$(type -P curl)" ]; then
            bash <(curl -s $aosp_url) $args
        elif [ -n "$(type -P wget)" ]; then
            bash <(wget -q $aosp_url -O -) $args
        else
            echo "Unable to run the aosp binary"
        fi
    fi
fi
