#!/bin/bash

cd /d/admin/code/de1app
git pull
git pull --recurse-submodules
git submodule update --init --recursive

cd de1plus
../misc/makede1.tcl 1

