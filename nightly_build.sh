#!/bin/bash

cd ../de1app
git fetch --recurse-submodules
git checkout origin/main -B main --force
# This will update this script as it lives in misc
git submodule update --init --recursive

cd de1plus
../misc/create_build_info.sh  1 >/d/nightly.log 2>&1
../misc/makede1.tcl 1 >>/d/nightly.log 2>&1
cat /d/nightly.log
