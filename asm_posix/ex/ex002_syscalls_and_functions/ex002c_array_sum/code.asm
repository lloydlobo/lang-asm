	BITS 64

	%include "syscalls.asm"; Requires syscall listing for your OS in lib/sys/
	%include "lib/math/int/packed_sum.asm"; long {rax} packed_sum(long {rdi}, long* {rsi}); packed_sum
	%include "lib/sys/exit.asm"; void exit(byte {dil}); exit

	section .text
	global  _start

_start:
	mov  rdi, N_ARRAY; Number of value to sum
	mov  rsi, ARRAY; Address of first value
	call packed_sum; Compute packed sum
	;    Now {rax} contains packed sum result.
	mov  rdi, rax; Return the value to the console
	call exit; {dil} is used from {rdi} in exit(byte {dil})
	ret

section .data

SIZEOF_DQ equ 8

ARRAY:
	dq 11, 14, 17, -18, -4, 22; assert(packed_sum(N_ARRAY, ARRAY) == 42)
	N_ARRAY equ ($ - ARRAY) / SIZEOF_DQ
