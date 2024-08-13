#!/usr/bin/env bash

# file: run.sh

set -xe

BIN=a.out
OBJS=code.o
SRCS_ASM=code.asm
# SRCS_C=code.c

build() {
	nasm -f elf64 -Ox "${SRCS_ASM}" \
		-I ../../../ -I "../../../lib/sys/$(uname)" \
		-Wlabel-orphan -Wno-orphan-labels \
		-O0 -g -F dwarf
	zig cc "${OBJS}" # "${SRCS_C}"
}

dump() {
	hexdump -C "${BIN}" >"${SRCS_ASM}".hex.dump &
	objdump -M intel -Dsx a.out >"${SRCS_ASM}".a.out.obj.dump &
}

run() { # watch: `find -name '*.asm' | entr -crs 'date;./run.sh;echo $?;'`
	strace -c ./"${BIN}" >/dev/null &
	./"${BIN}" && : $?
	: exit status $?
}

main() {
	time build
	#time dump &
	time run &
}

main
