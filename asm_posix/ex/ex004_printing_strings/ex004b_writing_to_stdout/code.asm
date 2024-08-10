	;----------------------------------------------------------------------
	; DEFINITIONS
	;----------------------------------------------------------------------

	%define ITERATIONS 1000

	;----------------------------------------------------------------------
	; HEADER
	;----------------------------------------------------------------------

	BITS 64

	;----------------------------------------------------------------------
	; INCLUDES
	;----------------------------------------------------------------------

	%include "syscalls.asm"; Requires syscall listing for your OS in lib/sys/

	%include "lib/sys/exit.asm"; void exit(byte {dil})

	;----------------------------------------------------------------------
	; INSTRUCTIONS
	;----------------------------------------------------------------------

	section .text
	global  _start

_start:
	;   Example: fprintf(stdout, "Hello, World!\n")
	;----------------------------------------------------------------------
	mov rax, SYS_WRITE
	mov rdi, SYS_STDOUT
	mov rsi, MSG_HELLO
	mov rdx, (ADDRESS_AFTER_MSG_HELLO - MSG_HELLO); Use nasm to compute length of string in bytes. Brackets are optional
	syscall
	;======================================================================

	;   Example: { int i = ITERATIONS; while (i != 0) { fprintf(stdout, "<3 "); i--; }; }
	;----------------------------------------------------------------------
	mov rdi, SYS_STDOUT; File Descriptor for standard output
	mov rsi, MSG_TEXT; Address of test start
	mov rdx, N_MSG_TEXT; String length in bytes till end
	mov r15, ITERATIONS; int i = ITERATIONS

.loop:
	;   while (i != 0) {
	mov rax, SYS_WRITE; sys_write syscall
	syscall
	dec r15; i--
	jnz .loop; if (i != 0) goto .loop; else break
	;   }
	;======================================================================

	;    exit(0)
	xor  dil, dil
	call exit

	section .data

MSG_HELLO:
	db 'Hello, World!', 0x0a; 0x0a is newline character

ADDRESS_AFTER_MSG_HELLO:
	; NOTE: placeholder label
	; Example: mov rdx, (ADDRESS_AFTER_MSG_HELLO - MSG_HELLO)

MSG_TEXT:
	db '<3 '; NOTE: We are not using a newline character here for aesthetics

	N_MSG_TEXT equ ($ - MSG_TEXT); Length in bytes using nasm.
	; nasm calculates address offset from this location ($) to the start
	; of the string's first char address
