	; *---------------------------------------------------------------------------------------
	; * file: code.asm
	; *
	; * A 64-bit Linux application that writes the first 90 Fibonacci numbers.
	; *
	; *     nasm -f elf64 code.asm && zig cc code.o && ./a.out
	; *
	; * Ported from "[Understanding Calling Conventions](https://cs.lmu.edu/~ray/notes/nasmtutorial/)"
	; *----------------------------------------------------------------------------------------

	global main
	extern printf
	extern puts

	section .bss
	;...none

	section .data

progn:
	db "ex004f_calling_conventions_with_c", 0

format:
	db "%20ld", 10, 0

	section .text

main:
	push rbx

	mov  rdi, progn
	call puts

	mov ecx, 42
	xor rax, rax
	xor rbx, rbx
	inc rbx

print:
.save:
	push rax
	push rcx

.load:
	mov rdi, format
	mov rsi, rax
	xor rax, rax

	call printf

.restore:
	pop rcx
	pop rax

.next:
	mov rdx, rax
	mov rax, rbx
	add rbx, rdx
	dec ecx
	jnz print

leave:
	pop rbx
	mov rax, 0
	ret
