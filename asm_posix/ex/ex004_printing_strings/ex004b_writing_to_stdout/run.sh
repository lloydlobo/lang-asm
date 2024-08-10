#!/usr/bin/env bash

set -xe

nasm -f elf64 \
	-g -F dwarf \
	-Ox \
	-Wlabel-orphan -Wno-orphan-labels \
	-I ../../../ -I "../../../lib/sys/$(uname)" \
	code.asm

# ld code.o -o binary -lc -s
ld code.o -o binary -lc

time ./binary && sleep 1

echo exit status $?
