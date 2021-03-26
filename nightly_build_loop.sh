#!/bin/bash

cd /d/admin/code/de1app/misc

while true; do
./nightly_build.sh
echo "sleeping for 1h"
sleep 3600
done
