#!/bin/bash

cd /d/admin/code/de1stable
echo "" > /d/stable.log
echo "Current directory is $PWD" 2>&1 | tee -a /d/stable.log 
date 2>&1 | tee -a /d/stable.log 
git checkout de1plus/version.tcl 2>&1 | tee -a /d/stable.log
git fetch --recurse-submodules 2>&1 | tee -a /d/stable.log
git fetch --tags -f 2>&1 | tee -a /d/stable.log 
git checkout origin/stable -B stable --force 2>&1 | tee -a /d/stable.log
# This will update this script as it lives in misc
git submodule update --init --recursive 2>&1 | tee -a /d/stable.log
git -C misc clean -xdf 2>&1 | tee -a /d/stable.log

cd de1plus
../misc/create_build_info.sh 1 2>&1 | tee -a /d/stable.log 
../misc/makede1.tcl de1plus 1 2>&1 | tee -a /d/stable.log 