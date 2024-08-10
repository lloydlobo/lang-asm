#!/usr/bin/env bash
#
# file: run.sh
#
# strace -c ./a.out
# : exit status $?
#
# watch:
# find . -name '*.asm' | entr -rs "date;nasm -f elf64 code.asm && zig cc code.o && ./a.out && echo;echo exit status $?;"

set -xe

nasm -f elf64 code.asm
: exit status $?

# zig cc code.o
zig cc code.c code.o
: exit status $?

./a.out
: exit status $?

hexdump -C a.out >code.asm.hex.dump
: exit status $?

objdump -M intel -d a.out >code.asm.a.out.obj.dump
: exit status $?
