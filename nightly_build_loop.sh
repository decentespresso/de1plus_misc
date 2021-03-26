#!/bin/bash

cd /d/admin/code/de1app/misc

while true; do
./nightly_build.sh
sleep 3600
done
