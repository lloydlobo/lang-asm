	; *---------------------------------------------------------------------------------------
	; * code.asm -> power.asm
	; *
	; * This is a Linux console 64-bit command line application program that
	; * computes `x^y`.
	; *
	; * Syntax: `power x y`
	; * - `x` and `y` are (32-bit) integers
	; *
	; *     nasm -f elf64 code.asm && zig cc code.o && ./a.out
	; *     ./a.out 2 19
	; *     524288
	; *
	; * Ported from "[A Longer Example]: https://cs.lmu.edu/~ray/notes/nasmtutorial/"
	; *----------------------------------------------------------------------------------------

	; $ gdb --args ./a.out <integer1> <integer2>

	%define EXIT_SUCCESS 0
	%define EXIT_FAILURE 1

	global main
	extern printf
	extern puts
	extern atoi

	section .text

puts_progn:
	push rdi
	push rsi
	mov  rdi, progn
	call puts
	pop  rsi
	pop  rdi
	ret

error1:
	mov  edi, fmt_bad_argument_count
	call puts
	mov  rax, EXIT_FAILURE
	jmp  leave

error2:
	mov  edi, fmt_negative_exponent
	call puts
	mov  rax, EXIT_FAILURE
	jmp  leave

main:
	push r12; save callee-save registers
	push r13
	push r14

	call puts_progn

	cmp rdi, 3
	jne error1

pow:
	mov  r12, rsi; point {r12} to `char *argv[]`
	mov  rdi, [r12 + (8 * 2)]; `argv[2]`
	call atoi; > (exponent) `y` in {eax}

	cmp eax, 0; disallow "-ve" exponents
	jl  error2
	mov r13d, eax; (counter) `y` in {r13d}

	mov  rdi, [r12 + (8 * 1)]; argv[1]
	call atoi; > (base) `x` in {eax}
	mov  r14d, eax

	mov eax, 1; set with "answer = 1"

.loop_check:
	test r13d, r13d; check if exponent `y` (counter) is zero
	jz   .got_pow

	imul eax, r14d; {eax} *= `x` in {r14d}
	dec  r13d; counter--
	jmp  .loop_check

.got_pow:
	mov    rdi, fmt_answer
	movsxd rsi, eax
	xor    rax, rax; set {eax} to zero
	call   printf
	mov    rax, EXIT_SUCCESS

leave:
	pop r14; restore saved registers
	pop r13
	pop r12
	ret ; return to `main` in C

	; .bss

	section .bss

	; ---

	; .data

	section .data

progn:
	db "ex005f_command_line_arguments_pow_x_y", 0, 0

fmt_d:
	db "%d", 10

fmt_answer:
	db "%d", 10, 0

fmt_bad_argument_count:
	db "Requires exactly two arguments", 10, 0

fmt_negative_exponent:
	db "The exponent should not be negative", 10, 0
