	; *---------------------------------------------------------------------------------------
	; * file: code.asm
	; *
	; * This is a Linux console program that writes a little triangle of
	; * asterisks to standard output. Runs on GNU/Linux only.
	; *
	; *     nasm -f elf64 code.asm; ld -o binary code.o; ./binary; echo $?
	; *
	; * Ported from "[Another Example]: https://cs.lmu.edu/~ray/notes/nasmtutorial/"
	; *----------------------------------------------------------------------------------------

	;----------------------------------------------------------------------
	; DEFINITIONS
	;----------------------------------------------------------------------

	; It's so lonely here

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

	;       SECTION TEXT
	;----------------------------------------------------------------------
	section .text

print_progn:
	mov rax, SYS_WRITE
	mov rdi, SYS_STDOUT
	mov rsi, progn
	mov rdx, progn_len; number of bytes
	syscall
	ret

	; By the x86 64-bit calling convention, the first six arguments are
	; passed in the registers {rdi} {rsi} {rdx} {rcx} {r8} {r9} in that
	; order. {rax} contains the system call ordinal.

	; In x86: EBX(fd) ECX(buffer) EDX(length) EAX(system call ordinal)
	; In x64: RDI RSI RDX RCX RAX(system call ordinal)

print_triangle:
	; Function: void print_triangle(long {rdi}, long *{rsi}, long {rdx}, long {rcx})
	; Arguments:
	; - {rdi}: file descriptor (fd)
	; - {rsi}: address of string to output (buf)
	; - {rdx}: number of bytes in {rsi} buffer (len)
	; - {rcx}: constant count of max lines of stars to print

	push rdi; save registers
	push rsi
	push rdx
	push rcx

	mov r12, rsi; set address of next byte to write to
	mov r8, 1; set initial line-length
	mov r9, 0; set counter i.e. number of stars written on line so far

	align 16

.line:
	mov byte [r12], '*'; write a single star
	inc r12; and move pointer to where next char goes
	inc r9; update counter i.e. "count" number so far on line
	cmp r9, r8; did we reached the number for stars for this line
	jne .line; not yet, then keep writing on this line

.line_done:
	;   (10 or 0x0a or 0XA -> `\n`)
	mov byte [r12], 10; write a new line char
	inc r12; and move pointer to where next char goes
	inc r8; increment line-length i.e. next line will be one char longer
	mov r9, 0; reset counter i.e. count of star written on this line so far
	cmp r8, rcx; wait, did we already finish the last line?
	jng .line; if not, then begin writing this line (loop)

.done:
	;   write buffer to stdout
	;   invoke operating system to do the write
	mov rax, SYS_WRITE
	syscall

.leave:
	pop rcx; restore registers
	pop rdx
	pop rsi
	pop rdi
	ret

	;      main entry point: _start label
	global _start

_start:
	align 16
	call  print_progn

	align 16
	mov   rdi, SYS_STDOUT; {rdi} holds fd (file descriptor)
	mov   rsi, output; {rsi} holds address of next byte to write
	mov   rdx, data_size; {rdx} number of bytes in output buffer
	mov   rcx, max_lines; {rcx} holds count of max lines of stars to print
	call  print_triangle

	;    exit
	xor  dil, dil; exit status 0
	call exit; exit(int {dil})
	;======================================================================

	;       SECTION BSS: WRITABLE DATA
	;----------------------------------------------------------------------
	section .bss
	data_size equ 44
	output  resb data_size

	; `equ` is actually not a real instruction...
	; ... It simply defines an abbreviation for the assembler itself to use.
	max_lines equ 8
	;======================================================================

	;       SECTION DATA
	;----------------------------------------------------------------------
	section .data
	progn   db "ex004d_triangle", 0x0a; or 0xA
	progn_len equ ($ - progn)
	;======================================================================

	;----------------------------------------------------------------------
	; OUTPUT
	;----------------------------------------------------------------------

	; ```bash
	; $ find . -name '*.asm' | entr -rs "./run.sh;exit $?;"
	; ex004d_triangle
	; *
	; **
	; ***
	; ****
	; *****
	; ******
	; *******
	; ********
	; exit status 0
	; ```
