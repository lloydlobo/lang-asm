	; file: code.asm

	%define EXIT_SUCCESS 0
	%define EXIT_FAILURE 1

	;%define ITERATIONS 100
	;%define ITERATIONS 1_000
	;%define ITERATIONS 100_000
	%define  ITERATIONS 1_000_000

	%include "syscalls.asm"; Requires syscall listing for your OS in lib/sys/

	align    16
	%include "lib/io/print_chars.asm"; void print_chars(int {rdi}, char *{rsi}, int {rdx})

	%include "lib/sys/exit.asm"; void exit(byte {dil})

	section .text

__dbg__last_call_exit_status:
	mov  rdi, rax
	call _start.exit; NORETURN

	global _start

__dbg__print:
	;   Assuming that {rdx} has count of chars, and {rsi} has array of chars
	;   Load {rdi} with file descriptor to write to. (stdin, stdout, stderr)
	mov rax, SYS_WRITE
	syscall
	ret

_start:
	mov rdi, SYS_STDOUT; fd

	mov  rsi, PROGN
	mov  rdx, N_PROGN
	call __dbg__print

	mov  rsi, TEXT; buf
	;mov rdx, N_TEXT; buf count
	mov  rdx, ADDRESS_AFTER_TEXT

	mov   r15, ITERATIONS
	align 16

.loop:
	call  print_chars
	;call __dbg__print

	dec r15
	jnz .loop

.exit_success:
	;call __dbg__last_call_exit_status
	xor   dil, dil
	jmp   .exit

.exit_failure:
	mov dil, EXIT_FAILURE; {dil} is lower 8-bits of {rdi}

.exit:
	call exit; exit(int {dil}); NORETURN

	section .data

PRINT_BUFFER_SIZE:
	dq 4096

TEXT:
	db '<3 '
	ADDRESS_AFTER_TEXT equ ($-TEXT)

PROGN:
	db 'ex004c_buffered_writes', 0x0a
	N_PROGN equ ($-PROGN)

;ADDRESS_AFTER_TEXT:
	; FIXME: This does not get calculated unfortunately, when used as a placeholder

PRINT_BUFFER:
	; `PRINT_BUFFER_SIZE` bytes will be allocated here at runtime
	; all initialized to zeros

	;# "$ strace -c ./binary"

	;# "%      time     seconds  usecs/call     calls    errors syscall"
	;# "------ ----------- ----------- --------- --------- ----------------"
	;# "       0.00    0.000000           0         1           read"
	;# "       0.00    0.000000           0        16           write"
	;# "       0.00    0.000000           0         1           close"
	;# "       0.00    0.000000           0         7           mmap"
	;# "       0.00    0.000000           0         3           mprotect"
	;# "       0.00    0.000000           0         1           brk"
	;# "       0.00    0.000000           0         2           pread64"
	;# "       0.00    0.000000           0         1         1 access"
	;# "       0.00    0.000000           0         1           execve"
	;# "       0.00    0.000000           0         2         1 arch_prctl"
	;# "       0.00    0.000000           0         1           set_tid_address"
	;# "       0.00    0.000000           0         4         3 openat"
	;# "       0.00    0.000000           0         4         2 newfstatat"
	;# "       0.00    0.000000           0         1           set_robust_list"
	;# "       0.00    0.000000           0         1           prlimit64"
	;# "       0.00    0.000000           0         1           rseq"
	;# "------ ----------- ----------- --------- --------- ----------------"
	;# "100.00 0.000000           0        47         7 total"

	; EOF

