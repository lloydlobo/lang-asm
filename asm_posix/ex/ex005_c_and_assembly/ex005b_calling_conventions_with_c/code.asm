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
	call puts; write program name to stdout (standard output)

	mov ecx, 90; counter
	xor rax, rax; current_number
	xor rbx, rbx; next_number
	inc rbx; initialize to 1

print:
._save:
	push rax
	push rcx

._call:
	mov  rdi, format
	mov  rsi, rax
	xor  rax, rax
	call printf

._restore:
	pop rcx
	pop rax

._next:
	; algorithm: next = curr + prev = n-1 + n-2

	mov rdx, rax; temp = curr
	mov rax, rbx; curr = next
	add rbx, rdx; next += temp
	dec ecx; counter--
	jnz print; goto `print:` if {ecx} is not zero
	;^  if not done counting, do some more (loop again)
	;|  `jnz` - if the processor's `Z` (zero) flag is set to 0, jump to the given label.
	;|  `jz`or`je` - if the processor's `ZF` (zero) flag is set to 1, jump to the given label.

leave:
	pop rbx
	mov rax, 0
	ret ; return
