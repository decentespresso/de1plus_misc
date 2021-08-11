#!/bin/bash

cd /d/admin/code/de1stable
git checkout de1plus/version.tcl
git fetch --recurse-submodules
git checkout origin/stable -B stable --force
# This will update this script as it lives in misc
git submodule update --init --recursive
git -C misc clean -xdf

cd de1plus
echo "Current directory is $PWD" >/d/stable.log 2>&1
date >>/d/stable.log 2>&1
../misc/create_build_info.sh  1 >>/d/stable.log 2>&1
../misc/makede1.tcl de1beta 1 >>/d/stable.log 2>&1
cat /d/beta.log
