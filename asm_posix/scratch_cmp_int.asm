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
	mov rax, -10
	mov rbx, -10
	cmp rax, rbx
	jl  .less_than
	jg  .greater_than
	je  .equal_to

	; Comparison result handlers

.less_than:
	;   When rax < rbx
	mov rax, -1
	jmp .end

.greater_than:
	;   When rax > rbx
	mov rax, 1
	jmp .end

.equal_to:
	;   When rax == rbx
	mov rax, 0
	jmp .end

.end:
	mov rdi, rax; Set exit code
	mov rax, SYS_EXIT
	;   xor rdi, rdi; Skip overwriting exit code
	syscall
	ret

section .data

SIZEOF_DB equ 1  ; `DB 0x12, 'A', 10`      (Define Byte)
SIZEOF_DW equ 2  ; `DW 0x1234, 2000`       (Define Word)
SIZEOF_DD equ 4  ; `DD 0x12345678, -1000`  (Define Double Word)
SIZEOF_DQ equ 8  ; `DQ 0x1122334455667788` (Define Quad Word)
SIZEOF_DT equ 10 ; `DT 3.14159`            (Define Ten Bytes)

ARRAY:
	dq 99, 88, 22, 77, 33, 66, 44, 11, 55
	SIZEOF_ARRAY equ ($ - ARRAY)
	SIZEOF_ARRAY_ITEM equ SIZEOF_DQ
	N_ARRAY equ (SIZEOF_ARRAY) / SIZEOF_ARRAY_ITEM

;_Usage_:

	;----------------------------------------------------------------------
	; "Build and Run"
	;----------------------------------------------------------------------
	; Without necessary debugging information:
	;```bash
	; find -name '*.asm' | entr -cprs 'nasm -f elf64 -Ox scratch.asm -Wlabel-orphan -Wno-orphan-labels
	; ld scratch.o -o scratch -lc -s
	; ./scratch
	; echo $?'
	;```
	; With necessary debugging information:
	;```bash
	; find -name '*.asm' | entr -cprs 'nasm -f elf64 -O0 -g -F dwarf scratch.asm -Wlabel-orphan -Wno-orphan-labels
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

