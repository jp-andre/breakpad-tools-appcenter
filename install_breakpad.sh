#!/bin/bash

set -e
cd `dirname $0`

if [ -d depot_tools ] ; then
    export PATH=$PATH:`pwd`/depot_tools
fi

if ! which fetch 2>&1 >> /dev/null ; then
    echo "SCRIPT: Cloning Google depot_tools..."
    rm -rf depot_tools
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
    export PATH=$PATH:`pwd`/depot_tools

fi

if [ ! -d breakpad ] ; then
    echo "SCRIPT: Cloning Google breakpad..."
    rm -rf breakpad
    mkdir breakpad
    cd breakpad
    fetch breakpad
fi
