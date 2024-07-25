#!/usr/bin/env bash

# file: run.sh

set -xe

# Disassemble:
#
# 	objdump -M intel -d binary > objdump_intel_binary_$(date +%s)

# args=("$@")
# filename="${args[0]}"
# echo argument count: $#
# echo args[0]: \""${args[0]}"\"
# echo args[1]: \""${args[1]}"\"
# echo file name: "${filename}"
# echo

echo "[info] $(date +%s) [$(date)]"
echo "[info] $(nasm -v)"
echo "[info] $(ld -v)"
echo

echo "[info] <<<  Stage 1  >>>" && echo
nasm -f elf64 code.asm \
	-I ../../../ -I "../../../lib/sys/$(uname)" \
	-Ox \
	-Wlabel-orphan -Wno-orphan-labels
echo "[info] Assembled source file: exit status: $?" && echo "[info] $(file code.o | cowsay -f small)" && echo

echo "[info] <<<  Stage 2  >>>" && echo
ld code.o -o binary -lc -s
echo "[info] Linked object files together: exit status: $?" && echo "[info] $(file binary | cowsay -f small)"

# echo "[info] <<<  Stage 3  >>>" && echo
# ./binary "${filename}" && echo # HACK: To print exit status with next echo command, if clashes with `set -xe` set at top of file
# echo "[info] Executed binary: exit status: $?"
