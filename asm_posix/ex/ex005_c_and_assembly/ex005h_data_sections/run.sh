#!/usr/bin/env bash
# file: run.sh
set -xe
build() {
	nasm -f elf64 -Ox code.asm \
		-I ../../../ -I "../../../lib/sys/$(uname)" \
		-Wlabel-orphan -Wno-orphan-labels \
		-O0 -g -F dwarf
	# without C interop -> `ld -o binary code.o -lc -s;`
	zig cc code.o
}
dump() {
	hexdump -C a.out >code.asm.hex.dump &
	objdump -M intel -d a.out >code.asm.a.out.obj.dump &
}
run() {
	local a=19
	local b=8
	local c=21
	local d=-33
	strace -c ./a.out "${a}" "${b}" "${c}" "${d}" &
	./a.out "${a}" "${b}" "${c}" "${d}" && : $? # HACK: trying to log exit status if ./a.out fails
	: exit status $?
} # watch: `find -name '*.asm' | entr -crs 'date;./run.sh;echo $?;'`
main() {
	build
	dump
	run
}
main
