%define EXIT_SUCCESS 0
%define EXIT_FAILURE 1

%define FD_STDIN 0
%define FD_STDOUT 1
%define FD_STDERR 2

%define SYS_WRITE 1
%define SYS_EXIT 60

section .text
global  _start

fprintf:
	;int {rax} fprintf(int {rcx}, int {rdi}, char *{rsi})
	;    Write to {rcx} file descriptor a string of length {rdi} where
	;    {rsi} points to starting address of the string's char.
	;    Return bytes written to the file descriptor's stream

	push rcx
	push rdi
	push rsi
	lea  r8, [rdi]; Copy/Save length of string
	mov  rbx, rdi; Load length of string
	mov  rax, SYS_WRITE
	mov  rdi, rcx; Caller moved file descriptor into {rcx}
	mov  rsi, rsi; Starting address of string
	mov  rdx, rbx; Length of string
	syscall

	mov rax, r8
	pop rsi
	pop rdi
	pop rcx
	ret

printf:
	;int {rax} printf(int {rdi}, char *{rsi})
	;    Print string of length {rdi} where {rsi} points to starting
	;    address of the string's char. Return 0 if success else return 1 if
	;    string size is 0

	push rdi
	push rsi
	mov  rcx, rdi
	cmp  rcx, 1
	jz   .error
	mov  rax, SYS_WRITE
	mov  rdi, FD_STDOUT
	mov  rsi, rsi
	mov  rdx, rcx
	syscall
	mov  rax, EXIT_SUCCESS
	jmp  .done

.error:
	mov rax, EXIT_FAILURE

.done:
	pop rsi
	pop rdi
	ret

_start:
	mov  rsi, PROGN
	mov  rdi, N_PROGN
	call printf
	cmp  rax, EXIT_SUCCESS
	jne  .error

	mov  rsi, HELLO
	mov  rdi, N_HELLO
	mov  rcx, FD_STDOUT
	call fprintf

	;Check  if bytes written by fprintf into {rax} matches length of
	;string to write to stdout
	;cmp    rax, N_HELLO
	;jne    .error
	cmp     rax, (N_HELLO)-1
	jle     .error

	jmp .done

.error:
	mov rax, SYS_EXIT
	mov rdi, EXIT_FAILURE; exit(1)
	syscall
	ret

.done:
	mov rax, SYS_EXIT
	xor rdi, rdi; exit(0)
	syscall
	ret

section .data

PROGN:
	db "scratch *.*.*", 0x0a
	N_PROGN equ $ - PROGN

HELLO:
	db "Hello, World!", 0x0a
	N_HELLO equ $ - HELLO

;_Usage_:

	;----------------------------------------------------------------------
	; "Build and Run"
	;----------------------------------------------------------------------
	; Without necessary debugging information:
	;```bash
	; find -name '*.asm' | entr -cprs 'nasm -f elf64 scratch.asm
	; ld scratch.o -o scratch -lc
	; ./scratch
	; echo $?'
	;```
	; With necessary debugging information:
	;```bash
	; find -name '*.asm' | entr -cprs 'nasm -f elf64 -g -F dwarf scratch.asm
	; ld scratch.o -o scratch -lc
	; ./scratch
	; echo $?'
	;```
	;======================================================================

	;----------------------------------------------------------------------
	; "Disassembly"
	;----------------------------------------------------------------------
	;```bash
	; objdump -M intel -d scratch > scratch_objdump_intel.txt
	;```
	;======================================================================

	;----------------------------------------------------------------------
	; "Debugging"
	;----------------------------------------------------------------------
	; (gdb) set disassembly-flavor intel
	; OR
	; echo "set disassembly-flavor intel" >> ~/.gdbinit
	;======================================================================

