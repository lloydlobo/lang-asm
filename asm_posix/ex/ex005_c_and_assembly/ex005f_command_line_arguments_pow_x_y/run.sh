#!/usr/bin/env bash
# file: run.sh
set -xe
build() {
	nasm -f elf64 code.asm \
		-I ../../../ -I "../../../lib/sys/$(uname)" \
		-Wlabel-orphan -Wno-orphan-labels \
		-O0 -g -F dwarf #   -Ox
	zig cc code.o    # when C interop: `ld -o binary code.o -lc -s;`
}
dump() {
	hexdump -C a.out >code.asm.hex.dump &
	objdump -M intel -d a.out >code.asm.a.out.obj.dump &
}
run() {
	local x=2
	local y=19
	strace -c ./a.out "${x}" "${y}" &
	./a.out "${x}" "${y}" && : $? # HACK: trying to log exit status if ./a.out fails
	: exit status $?
} # watch: `find -name '*.asm' | entr -crs 'date;./run.sh;echo $?;'`
main() {
	build
	dump
	run
}
main
