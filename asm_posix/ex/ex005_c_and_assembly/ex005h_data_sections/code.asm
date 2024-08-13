	; *---------------------------------------------------------------------------------------
	; * code.asm -> average.asm
	; *
	; * This is a Linux 64-bit program that treats all its command line
	; * arguments as integers and displays their average as a floating point
	; * number. This program uses a data section to store intermediate results
	; * not that it has to, but only to illustrate how data sections are used.
	; *
	; *     nasm -f elf64 -Ox code.asm                                                         \
	; *         -I ../../../ -I "../../../lib/sys/$(uname)"                                    \
	; *         -Wlabel-orphan -Wno-orphan-labels                                              \
	; *         -O0 -g -F dwarf
	; *     zig cc code.o
	; *
	; * Ported from "[Data Sections]: https://cs.lmu.edu/~ray/notes/nasmtutorial/"
	; *----------------------------------------------------------------------------------------

	; * Usage:
	; *
	; *     ./a.out 19 8 21 -33
	; *     3.75
	; *     ./a.out 19 8 21 -33
	; *     Error: There are no command line arguments to average

	%define EXIT_SUCCESS 0
	%define EXIT_FAILURE 1

	%define F64(x) __?float64?__(x)

	global  main
	extern  atoi
	extern  printf
	extern  puts
	default rel
	;       ^
	;       | Purpose: It sets the default behavior for memory references to be
	;       | relative addressing.
	;       |
	;       | Effect: When `default rel` is used, memory operands without an
	;       | explicit size specifier are assumed to be relative to the
	;       | instruction pointer (RIP in 64-bit mode).
	;       |
	;       | Usage: It's commonly used in 64-bit code to simplify memory
	;       | addressing and enable position-independent code (PIC).
	;       |
	;       | Syntax: You typically place it at the beginning of your
	;       | assembly file:
	;       |
	;       |     default rel
	;       |     section .text
	;       |
	;       | Benefit: It allows for more compact and relocatable code
	;       | especially in 64-bit environments.

	; ************
	; Text Section
	; ************

	section .text

nothing_to_average:
	push rdi
	push rsi

	mov  rdi, fmt_error_no_args_to_average
	xor  rax, rax
	sub  rsp, 8; align stack pointer
	call printf
	add  rsp, 8; restore stack pointer

	pop rsi
	pop rdi
	ret

print_counter:
	push rdi
	push rsi
	push rax
	mov  rdi, fmt_info_counter

	sub  rsp, 8; must align {rsp} stack before call
	call puts
	add  rsp, 8; restore {rsp} to pre-aligned value

	pop rax
	pop rsi
	pop rdi

	push rdi
	push rsi
	push rax

	mov    rdi, fmt_d
	movsxd rsi, dword [arg_num_count]
	mov    al, 1
	sub    rsp, 8; align stack pointer
	call   printf
	add    rsp, 8; restore stack pointer

	pop rax
	pop rsi
	pop rdi

	ret; return

print_example_name:
	push rdi
	push rsi
	push rax

	mov  rdi, fmt_info_example_name
	xor  rax, rax; set {eax} to zero
	sub  rsp, 8; align stack pointer
	call printf
	add  rsp, 8; restore stack pointer

	pop  rax
	pop  rsi
	pop  rdi
	ret; return

print_info_answer_is:
	push rdi
	push rsi
	push rax

	mov  rdi, fmt_info_answer_is
	sub  rsp, 8; must align {rsp} stack before call
	call puts
	add  rsp, 8; restore {rsp} to pre-aligned value

	pop  rax
	pop  rsi
	pop  rdi
	ret; return to call site

main:
	call  print_example_name
	dec   rdi; `argc--`, since we don't count program name
	jz    nothing_to_average
	mov   [arg_num_count], rdi
	call  print_counter; > 4
	align 16

.loop_accumulate:
	push rdi; save register across call to atoi
	push rsi
	mov  rdi, [rsi + rdi * 8]; `argv[{rdi}]`
	call atoi; now {rax} has the "int" value of "arg"
	pop  rsi
	pop  rdi

	add [sum_accumulator], rax; accumulate sum as we go
	dec rdi; `argc--`, count down
	jnz .loop_accumulate; loop if more arguments

.average:
	call print_info_answer_is

	cvtsi2sd xmm0, [sum_accumulator]
	cvtsi2sd xmm1, [arg_num_count]
	divsd    xmm0, xmm1

	mov rdi, fmt_answer; {rdi} is 1st arg to `printf`
	mov rax, 1; since `printf` is *varargs*, there is 1 non-int argument

	sub  rsp, 8; align stack pointer
	call printf
	add  rsp, 8; restore stack pointer

.leave:
	ret; return to `main` in C

	; ************
	; Data Section
	; ************

	section .data
	arg_num_count: dq 0
	sum_accumulator: dq 0
	fmt_d: db "%d", 10, 0
	fmt_answer: db "%g", 10, 0
	fmt_error_bad_argument_count: db "Error: Requires exactly two arguments", 10, 0
	fmt_error_negative_exponent: db "Error: The exponent should not be negative", 10, 0
	fmt_error_no_args_to_average: db "Error: There are no command line arguments to average", 10, 0
	fmt_info_got_argv_arguments: db "Info: Got following arguments:", 10, 0
	fmt_info_example_name: db "Info: Example ex005h_data_sections", 10, 0
	fmt_info_answer_is: db "Info: Answer is:", 0
	fmt_info_counter: db "Info: Current counter is:", 0
