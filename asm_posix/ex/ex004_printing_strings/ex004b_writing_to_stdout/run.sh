#!/usr/bin/env bash

set -xe

nasm -f elf64 code.asm \
	-I ../../../ -I "../../../lib/sys/$(uname)" \
	-Ox \
	-Wlabel-orphan -Wno-orphan-labels

ld code.o -o binary -lc -s

time ./binary && sleep 1

echo exit status $?
