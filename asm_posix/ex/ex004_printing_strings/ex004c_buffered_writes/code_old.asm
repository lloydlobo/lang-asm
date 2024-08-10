	;----------------------------------------------------------------------
	; DEFINITIONS
	;----------------------------------------------------------------------
	; find.-name '*.asm' | entr -rs "date;./run.sh;exit $?;"

	%define ITERATIONS 100
	%define PRINT_BUFFER_SIZE 4096

	;----------------------------------------------------------------------
	; HEADER
	;----------------------------------------------------------------------

	BITS 64

	;----------------------------------------------------------------------
	; INCLUDES
	;----------------------------------------------------------------------

	%include "syscalls.asm"; Requires syscall listing for your OS in lib/sys/

	align    16
	%include "lib/io/print_chars.asm"; void print_chars(int {rdi}, char *{rsi}, int {rdx})

	; @UNIMPLEMENTED
	; %include "lib/io/print_string.asm"; void print_string(...)

	%include "lib/sys/exit.asm"; void exit(byte {dil})

	;----------------------------------------------------------------------
	; INSTRUCTIONS
	;----------------------------------------------------------------------

	section .text
	global  _start

_start:
	;    Example: fprintf(stdout, "Hello, World!\n")
	;----------------------------------------------------------------------
	;mov rax, SYS_WRITE
	;mov rdi, SYS_STDOUT
	;mov rsi, MSG_HELLO
	;mov rdx, (ADDRESS_AFTER_MSG_HELLO - MSG_HELLO); Use nasm to compute length of string in bytes. Brackets are optional
	;syscall
	;======================================================================

	; Example: { int i = ITERATIONS; while (i != 0) { fprintf(stdout, "<3 "); i--; }; }
	;----------------------------------------------------------------------
	; mov rdi, SYS_STDOUT; File Descriptor for standard output
	; mov rsi, MSG_TEXT; Address of test start
	; mov rdx, N_MSG_TEXT; String length in bytes till end
	; mov r15, ITERATIONS; int i = ITERATIONS

	mov rdi, SYS_STDOUT; File Descriptor for standard output
	mov rsi, MSG_TEXT; Address of test start
	mov rdx, (ADDRESS_AFTER_MSG_TEXT - MSG_TEXT); String length in bytes till end

	mov   r15, ITERATIONS; int i = ITERATIONS
	align 16

.loop:
	; while (i != 0) {

	;    #  Normal char array (known length at runtime)
	call print_chars; ./run.sh: line 15: 344073 Segmentation fault      (core dumped) ./binary
	dec  r15; i--
	jnz  .loop; if (i != 0) goto .loop; else break

	;DEBUG
	;mov rdi, rax

	;    }
	;======================================================================
	;jmp .exit

.success:
	xor dil, dil; exit(0)

.exit:
	call exit; exit(int {dil})

	section .data

;MSG_HELLO:
	; db 'Hello, World!', 0x0a; 0x0a is newline character

;ADDRESS_AFTER_MSG_HELLO:
	; ; NOTE: placeholder label
	; ; Example: mov rdx, (ADDRESS_AFTER_MSG_HELLO - MSG_HELLO)

MSG_TEXT:
	db 'Hello '; We are not using a newline character here for aesthetics
	;  BEFORE
	;  N_MSG_TEXT equ ($ - MSG_TEXT); Length in bytes using nasm. nasm calculates address offset from this location ($) to the start of the string's first char address
	;  AFTER

ADDRESS_AFTER_MSG_TEXT:

PRINT_BUFFER:
	; `PRINT_BUFFER_SIZE` bytes will be allocated here at runtime, all
	; initialized to zeros

