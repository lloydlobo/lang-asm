#!/usr/bin/env bash
# file: run.sh

set -xe

nasm -f elf64 code.asm
zig cc code.o
./a.out
echo exit status $?

#strace -c ./binary && sleep 1
#echo exit status $?

# watch:
# find . -name '*.asm' | entr -rs "date;nasm -f elf64 code.asm && zig cc code.o && ./a.out && echo;echo exit status $?;"
