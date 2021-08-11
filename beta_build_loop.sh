#!/bin/bash

cd /d/admin/code/de1beta-release/misc

while true; do
bash ./beta_build.sh
echo "sleeping for 30m"
sleep 1800
done
