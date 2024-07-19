%define SYS_STDIN 0
%define SYS_STDOUT 1
%define SYS_STDERR 2

%define SYS_WRITE 1
%define SYS_EXIT 60

%define EXIT_SUCCESS 0
%define EXIT_FAILURE 1

section .text
global  _start

packed_sum:
	; long {rax} packed_sum(long {rdi}, long* {rsi})
	; Compute the sum of count {rdi} packed signed longs starting at address {rsi}

	push rdi; Save register rdi
	push rsi; Save register rsi

	xor rax, rax; Initialize running sum to zero. Sets {rax} to 0, whole 64-bits
	cmp rdi, 1; Check for atleast one number to add. assert(n_array > 0).
	jb  .packed_sum_done; If have less than 1 number, don't bother. [j]ump [b]elow

.packed_sum_loop:
	; packed_sum.loop

	add rax, [rsi]; Add the value at the address in {rsi} to the running sum accumulator in rax. array[i]
	add rsi, 8; Move the {rsi} pointer ahead by 8 bytes. i++

	dec rdi; Then [dec]rement {rdi} to track count of numbers left. n_array-=1
	jnz .packed_sum_loop

.packed_sum_done:
	; packed_sum.done

	pop rsi; Restore register rsi
	pop rdi; Restore register rdi
	ret

_start:
	mov rdi, 10; Load count of array to sum
	mov rsi, ARRAY; Load address of first value of the array

	call packed_sum; Returns {rax} containing the packed_sum result
	mov  rdi, rax; Load register destination instruction {rdi} with {rax} result from packed_sum() as exit code

	mov  rax, SYS_EXIT
	;xor rdi, rdi; No need for this instruction as {rdi} is loaded with exit code above
	syscall

	ret

section .data

ARRAY:
	; ARRAY points to the address memory (not instructions like add, exit, ...) but points to number 1. (similar to char *argv[])

	dq 0, 0, 1, 2, 3, 5, 8, 13, 21, 34

	;;---------------------------------------------------------------------
	;; lib/math/int/packed_sum.asm
	;;---------------------------------------------------------------------
	;  "https://github.com/lloydlobo/SCHIZONE/blob/main/lib/math/int/packed_sum.asm"
	;;=====================================================================

	;;---------------------------------------------------------------------
	;; Build & Run
	;;---------------------------------------------------------------------
	;  nasm -f elf64 -g scratch.asm
	;  ld scratch.o -o scratch -lc
	;  ./scratch
	;  echo $?
	;;=====================================================================

	;;---------------------------------------------------------------------
	;; minimal executable
	;;---------------------------------------------------------------------
	;  %define SYS_EXIT 60
	;  %define EXIT_SUCCESS 0
	;  %define EXIT_FAILURE 1
	;#
	;  section .text
	;  global  _start
	;#
	;  _start:
	;  mov rax, SYS_EXIT
	;  mov rdi, EXIT_FAILURE; xor rdi, rdi
	;  syscall
	;  ret
	;;=====================================================================
