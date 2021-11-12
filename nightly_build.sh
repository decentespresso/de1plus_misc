#!/bin/bash

cd /d/admin/code/de1app
echo "" > /d/nightly.log
echo "Current directory is $PWD" 2>&1 | tee -a /d/beta.log
date 2>&1 | tee -a /d/nightly.log 
git checkout de1plus/version.tcl 2>&1 | tee -a /d/nightly.log
git fetch --recurse-submodules 2>&1 | tee -a /d/nightly.log
git fetch --tags -f 2>&1 | tee -a /d/nightly.log 
git checkout origin/main -B main --force 2>&1 | tee -a /d/nightly.log
# This will update this script as it lives in misc
git submodule update --init --recursive  2>&1 | tee -a /d/nightly.log
git -C misc clean -xdf 2>&1 | tee -a /d/nightly.log 

cd de1plus
x../misc/create_build_info.sh 1 2>&1 | tee -a /d/nightly.log 
../misc/makede1.tcl de1nightly 1 2>&1 | tee -a /d/nightly.log 
