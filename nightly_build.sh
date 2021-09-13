#!/bin/bash

cd /d/admin/code/de1app
date
git checkout de1plus/version.tcl
git fetch --recurse-submodules
git checkout origin/main -B main --force
# This will update this script as it lives in misc
git submodule update --init --recursive
git -C misc clean -xdf

cd de1plus
echo "Current directory is $PWD" >/d/nightly.log 2>&1
date >>/d/nightly.log 2>&1
../misc/create_build_info.sh  1 >>/d/nightly.log 2>&1
../misc/makede1.tcl de1nightly 1 >>/d/nightly.log 2>&1
cat /d/nightly.log
