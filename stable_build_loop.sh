#!/bin/bash

cd /d/admin/code/de1stable/misc

while true; do
bash ./beta_build.sh
echo "sleeping for 30m"
sleep 1800
done
