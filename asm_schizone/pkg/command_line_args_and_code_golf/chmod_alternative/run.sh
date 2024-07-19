#!/usr/bin/env bash

nasm -f bin -I ../../../ -I ../../../lib/sys/`uname` -o binary main.asm
chmod +x binary
./binary
echo $?

# Usage
#	$ touch executable
#	$ ./binary executable
