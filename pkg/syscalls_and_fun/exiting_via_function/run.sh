#!/usr/bin/env bash

# $ uname
# Linux
nasm -f bin -I ../../../ -I ../../../lib/sys/`uname` -o binary main.asm
chmod +x binary
./binary
echo $?
