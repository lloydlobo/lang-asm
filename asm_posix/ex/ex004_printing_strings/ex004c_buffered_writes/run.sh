#!/usr/bin/env bash

# file: run.sh

set -xe

#------------------------------------------------------------------------------
# Build
#------------------------------------------------------------------------------
# Optimization levels in decreasing order: Ox (default), O1, O0

# 	[nasm] Release build:
# nasm -f elf64 code.asm \
# 	-I ../../../ -I "../../../lib/sys/$(uname)" \
# 	-Wlabel-orphan -Wno-orphan-labels \
# 	-Ox
# 	[nasm] Debug build:
nasm -f elf64 code.asm \
	-I ../../../ -I "../../../lib/sys/$(uname)" \
	-Wlabel-orphan -Wno-orphan-labels \
	-O0 -g -F dwarf

# 	[ld] Release build:
# ld code.o -o binary -lc -s
# 	[ld] Debug build:
ld code.o -o binary -lc

#------------------------------------------------------------------------------
# Run
#------------------------------------------------------------------------------
time ./binary && sleep 1
echo exit status $?

strace -c ./binary && sleep 1
echo exit status $?
