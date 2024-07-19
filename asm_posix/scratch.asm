%define EXIT_SUCCESS 0
%define EXIT_FAILURE 1

%define FD_STDIN 0
%define FD_STDOUT 1
%define FD_STDERR 2

%define SYS_WRITE 1
%define SYS_EXIT 60

section .text
global  _start

_start:
	mov rdx, 2
	cmp rdx, 2
	jnz .error
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
	db "scratch.asm", 0x0a
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

