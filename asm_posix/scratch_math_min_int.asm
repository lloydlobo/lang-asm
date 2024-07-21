%define EXIT_SUCCESS 0
%define EXIT_FAILURE 1

%define FD_STDIN 0
%define FD_STDOUT 1
%define FD_STDERR 2

%define SYS_WRITE 1
%define SYS_EXIT 60

section .text
global  _start

min_int:
	; long {rax}, ulong {rdx} min_int(ulong {rdi}, long *{rsi}, long {rdx})

	push  rdi; Save registers
	push  rsi
	;push rdx; Do not save as we will load it with return index of min value item in array

	mov rcx, rdi; Initialize counter, Move item count ulong to {rcx}
	mov rax, [rsi]; Set initial "min" with value at first address in {rsi}
	xor r8, r8; Initialize index of "min" to 0
	xor r9, r9; Initialize current index

.loop:
	cmp rcx, 1; Check if we've processed all numbers
	je  .done; If no numbers left then break
	add rsi, rdx; Increment array pointer
	inc r9; Increment current index
	cmp [rsi], rax; Compare current number in {rsi} with "min" in {rax}
	jg  .not_smaller; If not smaller, skip update
	mov rax, [rsi]; Since value is lesser than "min" in {rax}, update {rax} with the value
	mov r8, r9; Update index of "min" value, found in long *{rsi}

.not_smaller:
	dec rcx; Decrement counter
	jmp .loop; Continue loop

.done:
	;   {rax} now contains "min" result
	mov rdx, r8; Load {rdx} with index of "min" in {r8}

	;pop rdx; NOTE: Did not save earlier
	pop  rsi; Restore registers
	pop  rdi

	ret ; return

_start:
	;    long {rax}, ulong {rdx} min_int(ulong {rdi}, long* {rsi}, long {rdx})
	mov  rdi, N_ARRAY
	mov  rsi, ARRAY
	mov  rdx, SIZEOF_ARRAY_ITEM
	call min_int
	;    {rax} now contains the "min" value
	;    {rdx} contains the index of the "min" value
	mov  rdi, rax; Load "min" result in {rdi} as exit code (for demonstration purposes)
	mov  rax, SYS_EXIT
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
