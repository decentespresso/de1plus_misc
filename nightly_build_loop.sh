#!/bin/bash

cd /d/admin/git/de1nightly/misc

while true; do
./nightly_build.sh
echo "sleeping for 30m"
sleep 1800
done
