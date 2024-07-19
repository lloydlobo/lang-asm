%define SYS_EXIT 60

section .text
global  _start

sum:
	; size_t {rax} sum(size_t {rdi}, size_t *{rsi}, size_t {rcx})

	push rdi; Count of array
	push rsi; Pointer to first item of array
	push rcx; Size of an item

	cmp rdi, 1; Check if len(array) >= 1
	jb  .sum_done; Do not bother and return early if `cmp` outputs 0

	xor rax, rax; Initialize the accumulator to 0

.sum_loop:
	add rax, [rsi]
	add rsi, rcx; Increment pointer offset by size of item in array
	dec rdi; Decrement count of items left to visit; ( --{rdi}; )
	jnz .sum_loop; If result of `dec {rdi}` is not zero, loop again. else fallthrough to `_done`

.sum_done:
	pop rcx
	pop rsi
	pop rdi

	ret

packedsum:
	; long {rax} sum(long {rdi}, long *{rsi})
	; Compute sum of {rdi} packed signed longs starting at address {rsi}

	push rdi
	push rsi

	cmp rdi, 1; Array count
	jb  .packedsum_done

	xor rax, rax; The sum accumulator

.packedsum_loop:
	;   do { ... } while (( --{rdi} > 0 )); A do-while loop
	add rax, [rsi]; accumulator += (*array[i]); > The value at address [{rsi}]
	add rsi, 8; i += 1; 8-bit

	dec rdi; Count left: --{rdi}
	jnz .packedsum_loop; If result of `dec {rdi}` is not zero, loop again. else fallthrough to `.packedsum_done`

.packedsum_done:
	pop rsi
	pop rdi

	ret

packedmul:
	; long {rax} packedmul(long {rdi}, long *{rsi})
	; Compute the total product of count {rdi} packed signed longs startimg at the address of {rsi}

	;    Save the registers. Ensure to restore when done
	push rdi
	push rsi

	cmp rdi, 1; The array count - Counter
	jb  .packedmul_done

	xor rax, rax; The multiplication accumulator zeroed out
	mov rax, 1; Since we are multiplying, initialize it to 1

.packedmul_loop:
	; do { ... } while (( --{rdi} > 0 )); A do-while loop

	imul rax, [rsi]; The value of the "array" at address [{rsi}]
	add  rsi, 8; Increment the pointer

	dec rdi; Decrement the counter and check if it is "not 0" in the next step
	jnz .packedmul_loop; If not zero, the loop again; Else "fallthrough" to .***_done

.packedmul_done:
	;   Restore the registers save earlier
	pop rsi
	pop rdi

	ret ; Exit "packedmul function" scope

_start:
	mov  rdi, 10
	mov  rsi, FIB_ARRAY
	call packedsum
	mov  rdi, rax; exit code {rdi}

	mov  rdi, 7
	mov  rsi, TWOS_ARRAY
	call packedsum
	mov  rdi, rax; exit code {rdi}

	mov  rdi, 7
	mov  rsi, TWOS_ARRAY
	call packedmul
	mov  rdi, rax; exit code {rdi}

	mov  rdi, N_DW_ARRAY; len(array)
	mov  rsi, DW_ARRAY; *array
	mov  rcx, SIZEOF_DW_ARRAY_ITEM; sizeof(dw) i.e. 2
	call sum; function: size_t {rax} sum(size_t {rdi}, size_t *{rsi}, size_t {rcx})
	mov  rdi, rax; exit code {rdi}

	mov  rax, SYS_EXIT; {rax} = 60
	;xor rdi, rdi; {rdi} = 0; exit code set above so comment this line
	syscall

	ret

section .data

;byte_array    db  1, 2, 3, 4, 5                ; 8-bit items
;word_array    dw  1000, 2000, 3000, 4000       ; 16-bit items
;dword_array   dd  100000, 200000, 300000       ; 32-bit items
;qword_array   dq  1000000000, 2000000000       ; 64-bit items

;byte_count    equ $ - byte_array
;word_count    equ ($ - word_array) / 2
;dword_count   equ ($ - dword_array) / 4
;qword_count   equ ($ - qword_array) / 8

	; NOTE: Any *_"ARRAY" points to the address memory (not instructions
	; like add exit, ...) but points to number 1. (similar to char *argv[])

FIB_ARRAY:
	dq 0, 1, 1, 2, 3, 5, 8, 13, 21, 34; dq `define quad word` allocates 8 bytes per item
	;  assert sum(FIB_ARRAY) == 88; dq long?

TWOS_ARRAY:
	dq 2, 2, 2, 2, 2, 2, 2
	;  assert mul(TWOS_ARRAY) == 128 and sum(ARRAY) == 14; dq long?

DW_ARRAY:
	dw 1, 1, 1, 1, 1, 1, 1, 1; dw `define word` allocates 2 bytes per item
	SIZEOF_DW_ARRAY equ $ - DW_ARRAY; 12; `$` represents current address (location); DW_ARRAY is the starting address of the array
	SIZEOF_DW_ARRAY_ITEM equ 2; 12; `$` represents current address (location); DW_ARRAY is the starting address of the array
	N_DW_ARRAY equ (SIZEOF_DW_ARRAY) / SIZEOF_DW_ARRAY_ITEM; 6

;#DOCS:

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

	;----------------------------------------------------------------------
	; "Common size directives x86 assembly"
	;----------------------------------------------------------------------

	; Preferring Intel syntax and NASM:

	; | Directive | Size     | Example                 |
	; |-----------|----------|-------------------------|
	; | DB        | 1 byte   | `DB 0x12, 'A', 10`      |
	; | DW        | 2 bytes  | `DW 0x1234, 2000`       |
	; | DD        | 4 bytes  | `DD 0x12345678, -1000`  |
	; | DQ        | 8 bytes  | `DQ 0x1122334455667788` |
	; | DT        | 10 bytes | `DT 3.14159`            |

	; `DB` (Define Byte) allocates 1 byte per item
	; `DW` (Define Word) allocates 2 bytes per item
	; `DD` (Define Double Word) allocates 4 bytes per item
	; `DQ` (Define Quad Word) allocates 8 bytes per item
	; `DT` (Define Ten Bytes) allocates 10 bytes per item, typically used for 80-bit floating point

	; > These directives are used to declare initialized data in the `.data` section of the assembly code.
	; > For uninitialized data in the `.bss` section, the `RESB`, `RESW` `RESD`, `RESQ`, and `REST` directives can be used to reserve space without initializing it.
	; > The size of the directive should match the size expected by the instructions referencing the data. For example, `mov eax, [myDword]` expects      a 4-byte value, so `myDword DD 0x12345678` should be used.
	; > Using the correct size directive helps the assembler generate the proper machine code and catch potential mismatches between data sizes and    instruction operands.

	; Citations
	; [1] "https://github.com/ziglang/zig/issues/2081"
	; [2] "https://docs.oracle.com/cd/E26502_01/html/E28388/eoiyg.html"
	; [3] "https://www.csie.ntu.edu.tw/~cyy/courses/assembly/12fall/lectures/handouts/lec13_x86Asm.pdf"
	; [4] "https://www.cs.virginia.edu/~evans/cs216/guides/x86.html"
	; [5] "https://stackoverflow.com/questions/44577130/when-should-i-use-size-directives-in-x86"

	;======================================================================
