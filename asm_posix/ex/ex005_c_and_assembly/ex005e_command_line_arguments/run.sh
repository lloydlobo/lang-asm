#!/usr/bin/env bash
#
# file: run.sh

set -xe

nasm -f elf64 code.asm \
	-I ../../../ -I "../../../lib/sys/$(uname)" \
	-Ox \
	-Wlabel-orphan -Wno-orphan-labels
: exit status $?

# : ld -o binary code.o -lc -s
# : # or
zig cc code.o
: exit status $?

hexdump -C a.out >code.asm.hex.dump &
: exit status $? &

objdump -M intel -d a.out >code.asm.a.out.obj.dump &
: exit status $? &

strace -c ./a.out &
: exit status $? &

./a.out dog 22 -zzz "Hellope"
: exit status $?

# FIN

# watch:
# : find . -name '*.asm' | entr -rs "date;nasm -f elf64 code.asm && zig cc code.o && ./a.out && echo;echo exit status $?;"

# ; * Simple version:
#
# ; * main_:
# ; *     push rdi; save registers that `puts` uses
# ; *     push rsi
# ; *     sub  rsp, 8; must align stack before call
# ; *; ^^^^^ ^^^^^^ how is it different from using `align` or adding 8 `nop`?
# ; *
# ; *     mov  rdi, [rsi]; the argument string to display
# ; *     call puts; print it; "call C's" `puts` to write to stdout
# ; *
# ; *     add rsp, 8; restore {rsp} to pre-aligned value
# ; *     pop rsi; restore registers `puts` used
# ; *     pop rdi
# ; *
# ; *     add rsi, 8; point to the next argument
# ; *     dec rdi; count down
# ; *     jnz main_; if not done counting, keep going
# ; *
# ; *     ret; return
