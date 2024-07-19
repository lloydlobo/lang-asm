%define SYS_EXIT 60

section .text
global  _start

_start:
	mov rax, SYS_EXIT
	mov rdi, 42; xor rdi, rdi; exit(0)
	syscall

;Usage:

	;----------------------------------------------------------------------
	; "Build and Run"
	;----------------------------------------------------------------------
	;```bash
	; find -name '*.asm' | entr -cprs 'nasm -f elf64 -g scratch.asm
	; ld scratch.o -o scratch -lc
	; ./scratch
	; echo $?'
	;```
	;======================================================================

