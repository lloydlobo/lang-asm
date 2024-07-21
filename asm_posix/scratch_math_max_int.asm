%define EXIT_SUCCESS 0
%define EXIT_FAILURE 1

%define FD_STDIN 0
%define FD_STDOUT 1
%define FD_STDERR 2

%define SYS_WRITE 1
%define SYS_EXIT 60

section .text

	; See also "https://github.com/xmdi/SCHIZONE/blob/main/lib/math/int/max_int.asm"

max_int:
	; long {rax}, ulong {rdx} max_int(ulong {rdi}, long *{rsi}, long {rdx})

	; Calculates max of {rdi} signed longs starting at address {rsi}.
	; Additional offset between items in {rdx}.
	; Returns the result in {rax} and first index of max in {rdx}.

	push rdi
	push rsi
	push rdx
	mov  rcx, rdi; Initialize counter: Move item count ulong to {rcx}
	mov  rax, [rsi]; Set initial "max" by loading first number at address/location of {rsi} to {rax}
	xor  r8, r8; Initialize index of "max" to 0
	xor  r9, r9; Initialize current index

.find_max:
	cmp rcx, 0x1; Check if we've processed all numbers. -> if rcx == 1 -> 1-1==0 -> if 0 set ZF to 1 (Zero Flag) -> je checks for ZF == 1 -> if 1 == 1 -> jump to ".done"
	je  .done; If so, exit loop ".find_max"
	add rsi, rdx; Move to next number, by {rdx} offset
	inc r9; Increment current index
	cmp [rsi], rax; Compare current number with "max" in {rax}
	jle .not_larger; If not larger, skip update
	mov rax, [rsi]; Update current "max" in {rax} if larger
	mov r8, r9; Update index of "max"

.not_larger:
	dec rcx; Decrement counter
	jmp .find_max; Continue loop

.done:
	;   {rax} now contains "max" result
	mov rdx, r8; Move index of "max" to {rdx}
	pop rdx
	pop rsi
	pop rdi
	ret ; return

global _start

_start:
	mov  rdi, N_ARRAY
	mov  rsi, ARRAY
	mov  rdx, SIZEOF_ARRAY_ITEM
	;    long {rax}, ulong {rdx} max_int(ulong {rdi}, long* {rsi}, long {rdx})
	call max_int
	;    {rax} now contains the maximum value
	;    {rdx} contains the index of the maximum value
	mov  rdi, rax; Use max value as exit code

.exit:
	mov rax, SYS_EXIT
	syscall
	ret

section .data

SIZEOF_DB equ 1  ; `DB 0x12, 'A', 10`      (Define Byte)
SIZEOF_DW equ 2  ; `DW 0x1234, 2000`       (Define Word)
SIZEOF_DD equ 4  ; `DD 0x12345678, -1000`  (Define Double Word)
SIZEOF_DQ equ 8  ; `DQ 0x1122334455667788` (Define Quad Word)
SIZEOF_DT equ 10 ; `DT 3.14159`            (Define Ten Bytes)

ARRAY:
	dq 3, 9, 4, 11; Suitable for 64-bit
	SIZEOF_ARRAY_ITEM equ SIZEOF_DQ
	SIZEOF_ARRAY equ ($ - ARRAY)
	N_ARRAY      equ (SIZEOF_ARRAY) / SIZEOF_ARRAY_ITEM

;_Usage_:

	;----------------------------------------------------------------------
	; "Build and Run"
	;----------------------------------------------------------------------
	; Without necessary debugging information:
	;```bash
	; find -name '*.asm' | entr -cprs 'nasm -f elf64 -Ox scratch.asm
	; ld scratch.o -o scratch -lc
	; ./scratch
	; echo $?'
	;```
	; With necessary debugging information:
	;```bash
	; find -name '*.asm' | entr -cprs 'nasm -f elf64 -O0 -g -F dwarf scratch.asm
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
