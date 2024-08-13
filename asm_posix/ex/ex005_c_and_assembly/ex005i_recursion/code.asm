	; *---------------------------------------------------------------------------------------
	; * code.asm -> factorial.asm
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

	global  factorial
	global  fac
	;extern atoi
	;extern printf
	;extern puts
	default rel; Purpose: It sets the default behavior for memory references to be relative addressing.

	; ************
	; Text Section
	; ************

	section .text

factorial:
	cmp  rdi, 1; `n <= 1`
	jnbe L1; if not, go do a recursive call
	mov  rax, 1; otherwise return '1' as exit status result
	ret; return

L1:
	push rdi; save `n` on stack (also aligns {rsp}!); how???
	dec  rdi; `n--` or `n-1`
	call factorial; `factorial(n-1)`, result goes in {rax}
	pop  rdi; restore `n`
	imul rax, rdi; `n * factorial(n-1)`, stored in {rax}
	ret; return

fac:
	;    uint64_t {rax} fac(uint64_t {rdi})
	cmp  rdi, 1; `n <= 1`
	jnbe .loop; if not, go do a recursive call

	mov  rax, 1; else, return result '1' as exit status
	ret; return

.loop:
	push rdi; save register {rdi} `n` on stack (also aligns {rsp}!)
	dec  rdi; count down counter `n-1`
	call fac; if {rdi} is '0' then `fac(n-1)` or `fac({rdi})`, result goes in {rax}
	pop  rdi; restore saved registers i.e. {rdi} `n`

	imul rax, rdi; `n * fact(n-1)`, stored in {rax}
	ret; return

	; ************
	; Data Section
	; ************

	section .data
	;       * arg_num_count: dq 0
	;       * sum_accumulator: dq 0
	;       * fmt_d: db "%d", 10, 0
	;       * fmt_answer: db "%g", 10, 0
	;       * fmt_error_bad_argument_count: db "Error: Requires exactly two arguments", 10, 0
	;       * fmt_error_negative_exponent: db "Error: The exponent should not be negative", 10, 0
	;       * fmt_error_no_args_to_average: db "Error: There are no command line arguments to average", 10, 0
	;       * fmt_info_got_argv_arguments: db "Info: Got following arguments:", 10, 0
	;       * fmt_info_example_name: db "Info: Example ex005h_data_sections", 10, 0
	;       * fmt_info_answer_is: db "Info: Answer is:", 0
	;       * fmt_info_counter: db "Info: Current counter is:", 0
