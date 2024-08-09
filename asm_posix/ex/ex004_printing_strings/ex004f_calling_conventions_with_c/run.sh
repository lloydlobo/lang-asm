#!/usr/bin/env bash
# file: run.sh

set -xe

nasm -f elf64 code.asm
: exit status $?

zig cc code.o
: exit status $?

./a.out
: exit status $?

hexdump -C a.out >code.asm.dump
: exit status $?

objdump -d a.out >"objdump_intel_a.out_$(date +%s)"
: exit status $?

# strace -c ./a.out
# : exit status $?
#
# watch:
# find . -name '*.asm' | entr -rs "date;nasm -f elf64 code.asm && zig cc code.o && ./a.out && echo;echo exit status $?;"
