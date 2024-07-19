%define SYS_WRITE 1
%define SYS_EXIT 60

%define FD_STDIN 0
%define FD_STDOUT 1
%define FD_STDERR 2

section .text
global  _start

printf:
	push rdi
	push rsi

	mov rcx, rdi
	cmp rcx, 1
	jz  .printf_done

	mov rax, SYS_WRITE
	mov rdi, FD_STDOUT
	mov rsi, rsi
	mov rdx, rcx
	syscall

.printf_done:
	pop rsi
	pop rdi

	ret

_start:
	mov rsi, PROGN
	mov rdi, N_PROGN

	call printf
	call exit

exit:
	mov rax, SYS_EXIT
	mov rdi, 0; xor rdi, rdi; exit(0)
	syscall

	ret

section .data

PROGN:
	db "scratch *.*.*", 0x0a
	N_PROGN equ $ - PROGN

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

