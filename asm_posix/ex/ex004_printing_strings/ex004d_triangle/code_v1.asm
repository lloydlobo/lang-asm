	; file: code.asm

	;------------------------------------------------------------------------------
	; DEFINITIONS
	;------------------------------------------------------------------------------

	%define _EXIT_FAILURE 1
	%define _SYS_OPEN 2
	%define _SYS_CLOSE 3
	%define _O_RDWR_OR_O_CREAT 2
	%define _MODE_0666 438

	;------------------------------------------------------------------------------
	; HEADER
	;------------------------------------------------------------------------------

	BITS 64

	;------------------------------------------------------------------------------
	; INCLUDES
	;------------------------------------------------------------------------------

	%include "syscalls.asm"; Requires syscall listing for your OS in lib/sys/

	%include "lib/sys/exit.asm"; void exit(byte {dil})

	;------------------------------------------------------------------------------
	; INSTRUCTIONS
	;------------------------------------------------------------------------------

	;       SECTION TEXT
	;------------------------------------------------------------------------------
	section .text

print_triangle:
	;   triangle.asm. See "[Another Example](https://cs.lmu.edu/~ray/notes/nasmtutorial/))"
	mov rdx, output; {rdx} holds address of next byte to write
	mov r8, 1; initial line length
	mov r9, 0; number of stars written on line so far

.line:
	mov byte [rdx], '*'; write single star
	inc rdx; advance pointer to next cell to write
	inc r9; "count" number so far on line
	cmp r9, r8; did we reach the number of stars for this line?
	jne .line

.line_done:
	mov byte [rdx], 10; write a new line char
	inc rdx; and move pointer to where next char goes
	inc r8; next line will be one char longer
	mov r9, 0; reset count of star written on this line so far
	cmp r8, max_lines
	jng .line

.done:
	;   write buffer to stdout
	mov rax, SYS_WRITE
	mov rdi, SYS_STDOUT
	mov rsi, output; address of string to output
	mov rdx, data_size; number of bytes

	syscall ; invoke operating system to do the write
	ret

	;      begin label _start
	global _start

_start:
	call print_triangle

.exit_success:
	xor  rdi, rdi
	call exit
	;    end label _start

	;==============================================================================

	;       SECTION BSS
	;------------------------------------------------------------------------------
	section .bss
	max_lines equ 8
	data_size equ 44
	output  resb data_size
	;==============================================================================

	;        SECTION DATA
	;------------------------------------------------------------------------------
	section  .data
	filename db "output.txt", 0
	msg      db "Hello, World!", 0x0a; or 0xA
	msg_len equ ($ - msg)
	;==============================================================================

	;         SECTION BSS
	;------------------------------------------------------------------------------
	section   .bss
	buffer    resb 1024; Allocate 1024 bytes or 1KB buffer
	buffer_pos resq 1 ; Position in the buffer (buffer length)
	wordvar   resq 1; Reserve a word
	realarray resq 10; Array of ten reals
	;==============================================================================
