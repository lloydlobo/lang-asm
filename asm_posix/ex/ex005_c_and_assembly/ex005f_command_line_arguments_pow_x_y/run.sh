#!/usr/bin/env bash

# file: run.sh
#
# watch:
# : find . -name '*.asm' | entr -rs "date;nasm -f elf64 code.asm && zig cc code.o && ./a.out && echo;echo exit status $?;"
# : find -name '*.asm' | entr -crs 'date;./run.sh'

set -xe

nasm -f elf64 code.asm \
	-I ../../../ -I "../../../lib/sys/$(uname)" \
	-Wlabel-orphan -Wno-orphan-labels \
	-O0 -g -F dwarf
#   -Ox
: exit status $?

# when C interop:
# : ld -o binary code.o -lc -s
# else:
zig cc code.o
: exit status $?

hexdump -C a.out >code.asm.hex.dump &
: exit status $?

objdump -M intel -d a.out >code.asm.a.out.obj.dump &
: exit status $?

strace -c ./a.out 2 5 &
: exit status $?

./a.out 2 5 && : $?
# HACK: trying to ^^^ log exit status if ./a.out fails
: exit status $?

# FIN
