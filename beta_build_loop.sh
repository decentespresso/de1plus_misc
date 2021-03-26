#!/bin/bash

cd /d/admin/git/de1beta/misc

while true; do
./beta_build.sh
echo "sleeping for 30m"
sleep 1800
done
