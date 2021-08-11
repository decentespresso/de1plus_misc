#!/bin/bash

cd /d/admin/code/de1app/misc

while true; do
bash ./nightly_build.sh
echo "sleeping for 30m"
sleep 1800
done
