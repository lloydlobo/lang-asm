#!/usr/bin/env bash
# file: run.sh
set -xe
build() {
	nasm -f elf64 code.asm \
		-I ../../../ -I "../../../lib/sys/$(uname)" \
		-Wlabel-orphan -Wno-orphan-labels \
		-Ox
	# -O0 -g -F dwarf
	zig cc code.o # without C interop -> `ld -o binary code.o -lc -s;`
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
