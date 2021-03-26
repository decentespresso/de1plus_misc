#!/bin/bash

cd /d/admin/code/de1app
git fetch --all
git checkout origin/beta -B beta
git pull --recurse-submodules
git submodule update --init --recursive

cd de1plus
../misc/makede1.tcl de1beta 1

