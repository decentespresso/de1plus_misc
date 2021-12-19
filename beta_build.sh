#!/bin/bash

cd /d/admin/code/de1beta-release
echo "" > /d/beta.log
echo "Current directory is $PWD" 2>&1 | tee -a /d/beta.log
date 2>&1 | tee -a /d/beta.log 
git checkout de1plus/version.tcl 2>&1 | tee -a /d/beta.log
git fetch --recurse-submodules 2>&1 | tee -a /d/beta.log
git fetch --tags -f 2>&1 | tee -a /d/beta.log
git checkout origin/beta -B beta --force 2>&1 | tee -a /d/beta.log
# This will update this script as it lives in misc
git submodule update --init --recursive 2>&1 | tee -a /d/beta.log
git -C misc clean -xdf 2>&1 | tee -a /d/beta.log

cd de1plus
../misc/create_build_info.sh 1 2>&1 | tee -a /d/beta.log
../misc/makede1.tcl de1beta 1 2>&1 | tee -a /d/beta.log

