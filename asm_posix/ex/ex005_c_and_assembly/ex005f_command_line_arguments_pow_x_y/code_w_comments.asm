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

	global main
	extern printf
	extern puts
	extern atoi

	section .text

	; * In the System V AMD64 ABI, the first six integer or pointer arguments
	; * to a function are passed in registers. {rdi} is the first of these, so
	; * it's used for argc.

main:
	push r12; save callee-save registers
	push r13
	push r14
	;    By pushing 3 registers our stack is already aligned for calls

	; * The off-by-one aspect: A common source of confusion in C programming.
	; * argc is always at least 1 (for the program name) so "two arguments" to
	; * the user means `argc == 3`.

	cmp rdi, 3; must have exactly two arguments (x and y)
	;   i.e. argc == 3 where argv[] == ['./a.out', x, y]
	jne error1; [j]ump if [n]ot [e]qual: check ZF (zero flag) set by previous `cmp` instruction

	mov r12, rsi; `long *{rsi}[]` i.e. `char *argv[]` or `char **argv`

	; Use {r13d} to count down from the exponent to zero, {esi} to hold the
	; value of the base, and {eax} to hold the running product.

	mov  rdi, [r12 + 8*2]; `argv[2]`
	call atoi; `y` in {eax}
	cmp  eax, 0; disallow negative exponents
	jl   error2
	mov  r13d, eax; `y` in {r13d}

	mov  rdi, [r12 + 8]
	call atoi
	mov  r14d, eax; `x` in {r14d}

	mov eax, 1; start with `answer = 1`, since 1 allows pure multiplication with it

check:
	test r13d, r13d; we're counting `y` downto 0
	jz   gotit; done
	imul eax, r14d; multiply in another `x`
	dec  r13d
	jmp  check

gotit:
	mov    rdi, fmt_answer; print report on success
	movsxd rsi, eax
	xor    rax, rax
	call   printf; `printf(long *{rdi} __format, long {rsi, ...} args)`
	jmp    done

error1:
	mov  edi, fmt_bad_argument_count; print error message
	call puts; `puts(long *{rdi})`
	jmp  done

error2:
	mov  edi, fmt_negative_exponent; print error message
	call puts; `puts(long *{rdi})`

done:
	pop r14; restore saved registers
	pop r13
	pop r12
	ret ; return

	;***************
	; .bss section
	;***************

	section .bss
	;       so lonely here...

	;***************
	; .data section
	;***************

	section .data

fmt_answer:
	db "%d", 10, 0

fmt_bad_argument_count:
	db "Requires exactly two arguments", 10, 0

fmt_negative_exponent:
	db "The exponent may not be negative", 10, 0
