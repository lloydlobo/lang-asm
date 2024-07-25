	;------------------------------------------------------------------------------
	; DEFINITIONS
	;------------------------------------------------------------------------------

	; It's so lonely here...

	;------------------------------------------------------------------------------
	; HEADER
	;------------------------------------------------------------------------------

	BITS 64

	;------------------------------------------------------------------------------
	; INCLUDES
	;------------------------------------------------------------------------------

	%include "syscalls.asm"; Requires syscall listing for your OS in lib/sys/

	%include "lib/math/int/packed_sum.asm"; long {rax} packed_sum(long {rdi}, long* {rsi})

	%include "lib/sys/exit.asm"; void exit(byte {dil})

	;------------------------------------------------------------------------------
	; INSTRUCTIONS
	;------------------------------------------------------------------------------

	;       SECTION TEXT
	;------------------------------------------------------------------------------
	section .text
	global  _start

_start:
	; debug_stack 10, print_int_h;;;; TODO: from SCHIZONE/.../lab007_todo/code.asm

	;   Check for argc == 1
	cmp byte [SYS_ARGC_START_POINTER], 1
	jne .fail

	;;    Parse input args from command line input
	;mov  rdi, [SYS_ARGC_START_POINTER + (8 * 2)]
	;call parse_int
	;jle  .exit

	;   Ignore any bogus inputs
	cmp rax, 0; NOTE(Lloyd): {rax} from parse_int({rdi}, {rsi}) ???
	jle .fail

	mov  rdi, N_ARRAY; Number of value to sum
	mov  rsi, ARRAY; Address of first value
	call packed_sum; Compute packed sum
	;    {rax} now contains packed sum result.

	mov rdi, rax; Return value as exit status to the console
	jmp .exit

.fail:
	mov dil, 1; 1 retval indicates possible failure or wrong number of arguments, etc...
	jmp .exit

.success:
	xor dil, dil; 0 retval indicates possible success. {dil} is lower 8-bit of {rdx}???

.exit:
	;    exit({rdi})
	call exit; {dil} is used from {rdi} in exit(byte {dil})
	;==============================================================================

	;       SECTION DATA
	;------------------------------------------------------------------------------
	section .data

	SIZEOF_DQ equ 8

ARRAY:
	dq 11, 14, 17, -18, -4, 22; assert(packed_sum(N_ARRAY, ARRAY) == 42)
	N_ARRAY equ ($ - ARRAY) / SIZEOF_DQ
	;==============================================================================
