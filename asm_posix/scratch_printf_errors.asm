%define EXIT_FAILURE 1
%define EXIT_SUCCESS 0

%define FD_STDERR 2
%define FD_STDIN 0
%define FD_STDOUT 1

%define SYS_EXIT 60
%define SYS_WRITE 1

section .text
global  _start

printf:
	; int {rax} printf(int rdi, char *{rsi})
	; Print string of length {rdi} where {rsi} points to starting address of the string's char.
	; Return 0 if success else return 1 if string size is 0

	push rdi
	push rsi

	mov rcx, rdi
	cmp rcx, 1
	jz  .printf_error

	mov rax, SYS_WRITE
	mov rdi, FD_STDOUT
	mov rsi, rsi
	mov rdx, rcx
	syscall
	mov rax, EXIT_SUCCESS
	jmp .printf_done

.printf_error:
	mov rax, EXIT_FAILURE

.printf_done:
	pop rsi
	pop rdi

	ret

_start:
	mov  rsi, PROGN
	mov  rdi, N_PROGN
	call printf

	cmp rax, 0
	jne exit_failure
	jmp exit_success

exit_failure:
	mov rax, SYS_EXIT
	mov rdi, EXIT_FAILURE
	syscall

	ret

exit_success:
	mov rax, SYS_EXIT
	xor rdi, rdi; exit(0)
	syscall

	ret

section .data

PROGN:
	db "scratch *.*.*", 0x0a
	N_PROGN equ $ - PROGN

;_Usage_:

	;----------------------------------------------------------------------
	; "Build and Run"
	;----------------------------------------------------------------------
	;```bash
	; find -name '*.asm' | entr -cprs 'nasm -f elf64 -g scratch.asm
	; ld scratch.o -o scratch -lc
	; ./scratch
	; echo $?'
	;```
	;======================================================================

