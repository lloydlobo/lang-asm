%define EXIT_SUCCESS 0
%define EXIT_FAILURE 1

%define FD_STDIN 0
%define FD_STDOUT 1
%define FD_STDERR 2

%define SYS_WRITE 1
%define SYS_EXIT 60

section .bss
buffer  resb N_BUFFER64; Buffer to store the string representation

section .text
global  _start

print_integer:
	push rax; Save register
	mov  rcx, buffer
	add  rcx, (N_BUFFER64 - 1); Start from the end of the buffer
	mov  byte [rcx], 0; Null-terminate the string
	;    To convert the number to its decimal (base 10) string
	;    representation and use the remainders to build the string.
	mov  rbx, BASE_10

.loop:
	xor  rdx, rdx
	div  rbx
	;    Convert remainder to ASCII.
	;    NOTE: {dl} is the lower 8 bits of the {rdx} register
	add  dl, '0'
	dec  rcx
	mov  [rcx], dl
	test rax, rax
	jnz  .loop

.loop_print_num:
	;#  32-bit version
	;#  ; Print the number
	;#  mov eax, 4
	;#  mov ebx, 1
	;#  mov edx, buffer
	;#  add edx, 12
	;#  sub edx, ecx
	;#  int 0x80
	mov rax, SYS_WRITE
	mov rdi, FD_STDOUT
	mov rsi, rcx; Address of string to output
	mov rdx, buffer
	add rdx, N_BUFFER64
	sub rdx, rcx; Calculate string length
	syscall

.loop_print_newline:
	;   For the write syscall in Linux x86-64:
	;   - RAX (1) specifies the syscall number for write
	;   - RDI (1) specifies the file descriptor (1 for stdout)
	;   - RSI (newline) points to the buffer to write from
	;   - RDX (1) specifies how many bytes to write
	;   References:
	;   1. "https://www.uclibc.org/docs/psABI-x86_64.pdf"
	;   2. "https://man7.org/linux/man-pages/man2/syscall.2.html"
	;   3. "https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl"
	mov rax, SYS_WRITE
	mov rdi, FD_STDOUT
	mov rsi, NEWLINE_DB
	mov rdx, 1; Specify the number of bytes to write. Writing only one byte (the newline character)
	syscall

.end:
	pop rax; Restore register
	ret

_start:
	;    Example: Print 12345
	mov  rax, 12345
	call print_integer

	mov  rax, MAX_INT
	call print_integer

	jmp .end; TEMP: Quit early

.end:
	mov rax, SYS_EXIT
	xor rdi, rdi; exit status 0
	syscall
	ret

section .data

SIZEOF_DB equ 1  ; `DB 0x12, 'A', 10`      (Define Byte)
SIZEOF_DW equ 2  ; `DW 0x1234, 2000`       (Define Word)
SIZEOF_DD equ 4  ; `DD 0x12345678, -1000`  (Define Double Word)
SIZEOF_DQ equ 8  ; `DQ 0x1122334455667788` (Define Quad Word)
SIZEOF_DT equ 10 ; `DT 3.14159`            (Define Ten Bytes)

BASE_10 equ 10
MAX_INT equ 18446744073709551615; 20 digits
NEWLINE_DB db 10
N_BUFFER64 equ 21; Buffer size for 64-bit numbers, including 1 bytes space for newline
N_BUFFER32 equ 12; Buffer size for 32-bit numbers

ARRAY:
	dq 99, 88, 22, 77, 33, 66, 44, 11, 55
	SIZEOF_ARRAY equ ($ - ARRAY)
	SIZEOF_ARRAY_ITEM equ SIZEOF_DQ
	N_ARRAY equ (SIZEOF_ARRAY) / SIZEOF_ARRAY_ITEM

;Usage:

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

;RegisterSizes:

	;----------------------------------------------------------------------
	;  Register sizes:
	;----------------------------------------------------------------------
	;# RDX      is the 64-bit register
	;# EDX      is the lower 32 bits of RDX
	;# DX       is the lower 16 bits of EDX
	;# DL       is the lower 8 bits of DX
	;======================================================================

	;----------------------------------------------------------------------
	;  Register overlap:
	;----------------------------------------------------------------------
	;# DL       is always the lowest 8 bits of RDX, EDX, and DX
	;# Changes  to DL will affect the lowest 8 bits of RDX, EDX, and DX
	;# Changes  to larger parts of the register (RDX, EDX, DX) will affect DL
	;#
	;# mov rax, 0x1234567890ABCDEF; Set RAX
	;# mov rdx, 0x1111111111111111; Set RDX
	;# mov dl, 0xAA; Modify DL (part of RDX)
	;#
	;# ; After these operations:
	;# ; RAX = 0x1234567890ABCDEF (unchanged)
	;# ; RDX = 0x11111111111111AA
	;# ; EDX = 0x111111AA
	;# ; DX  = 0x11AA
	;# ; DL  = 0xAA
	;======================================================================

;LinuxConventions:
	;----------------------------------------------------------------------
	; See source "https://www.uclibc.org/docs/psABI-x86_64.pdf"
	;----------------------------------------------------------------------

	; Appendix A: Linux Conventions for AMD64
	; =======================================

	; A.1 Execution of 32-bit Programs
	; --------------------------------
	; - AMD64 processors can run both 64-bit and 32-bit programs
	; - 32-bit libraries: /lib, /usr/lib, /usr/bin
	; - 64-bit libraries: /lib64, /usr/lib64
	; - Both 32-bit and 64-bit programs share /usr/bin
	; - No /bin64 directory

	; A.2 AMD64 Linux Kernel Conventions
	; ----------------------------------

	; A.2.1 Calling Conventions
	; -------------------------
	; - Kernel uses same calling conventions as user-level apps, with differences:
	; 1. User apps use: %rdi, %rsi, %rdx, %rcx, %r8, %r9
	; Kernel uses:   %rdi, %rsi, %rdx, %r10, %r8, %r9
	; 2. Syscalls use 'syscall' instruction; destroys %rcx and %r11
	; 3. Syscall number passed in %rax
	; 4. Max 6 arguments for syscalls, none on stack
	; 5. Syscall result in %rax; -4095 to -1 indicates error (-errno)
	; 6. Only INTEGER or MEMORY class values passed to kernel

	; A.2.2 Stack Layout
	; ------------------
	; (Information incomplete in original text)

	; Summary:
	; - Describes Linux-specific conventions for AMD64 architecture
	; - Covers execution of 32-bit programs on 64-bit systems
	; - Details kernel calling conventions, focusing on syscall interface
	; - Highlights differences between user-level and kernel-level calling conventions
	; - Provides important information for low-level system programming on Linux AMD64
	;======================================================================

;Objdump:

	;----------------------------------------------------------------------
	; Disassembly of section .text:
	;----------------------------------------------------------------------
	; push rax
	; movabs rcx, 0x20349c
	; add rcx, 0x14
	; mov byte ptr [rcx], 0x0
	; mov ebx, 0xa
	; xor rdx, rdx
	; div rbx
	; add dl, 0x30
	; dec rcx
	; mov byte ptr [rcx], dl
	; test rax, rax
	; jne 0x201337 <.text+0x17>
	; mov eax, 0x1
	; mov edi, 0x1
	; mov rsi, rcx
	; movabs rdx, 0x20349c
	; add rdx, 0x15
	; sub rdx, rcx
	; syscall
	; mov eax, 0x1
	; mov edi, 0x1
	; movabs rsi, 0x203450
	; mov edx, 0x1
	; syscall
	; pop rax
	; ret
	; mov eax, 0x3039
	; call 0x201320 <.text>
	; mov rax, -0x1
	; call 0x201320 <.text>
	; jmp 0x20139f <.text+0x7f>
	; mov eax, 0x3c
	; xor rdi, rdi
	; syscall
	; ret
	;======================================================================
