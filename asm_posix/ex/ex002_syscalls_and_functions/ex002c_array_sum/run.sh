#!/usr/bin/env bash

# file: run.sh

echo "[info] $(date +%s)"
echo "[info] $(nasm -v)"
echo "[info] $(ld -v)"
echo

set -e # set -xe

echo "[info] <<<<    Stage 1    >>>>" && echo
nasm -f elf64 code.asm \
	-I ../../../ -I "../../../lib/sys/$(uname)" \
	-Ox -Wlabel-orphan -Wno-orphan-labels
echo "[info] Assembled source file: exit status: $?" && echo "[info] $(file code.o | cowsay -f small)" && echo

echo "[info] <<<<    Stage 2    >>>>" && echo
ld code.o -o binary -lc -s
echo "[info] Linked object files together: exit status: $?" && echo "[info] $(file binary | cowsay -f small)" && echo

echo "[info] <<<<    Stage 3    >>>>" && echo
./binary && echo # HACK: To print exit status with next echo command, if clashes with `set -xe` set at top of file
echo "[info] Executed binary: exit status: $?"

# Watch: build and run
# find . -name '*.asm' | entr -cprs './run.sh'
