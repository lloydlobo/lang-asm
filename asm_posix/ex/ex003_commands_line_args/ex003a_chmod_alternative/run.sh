#!/usr/bin/env bash

set -xe

echo "[info] <<<  Stage 3  >>>" && echo

dir

./binary chmodme.txt && sleep 1
echo [info] exit status $? && echo

./binary tmp.txt && sleep 1
echo [info] exit status $? && echo

./binary nop.txt && sleep 1
echo [info] exit status $? && echo
