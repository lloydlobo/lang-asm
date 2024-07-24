	;----------------------------------------------------------------------
	; Some macros
	;----------------------------------------------------------------------

	; Macro to define arrays that take 3 parameters (array name, item type, item size)

	%macro define_array_of_ones_of_count_8 3

%1:
	%2 1, 1, 1, 1, 1, 1, 1, 1; type [...items]
	SIZEOF_%1 equ $ - %1
	SIZEOF_%1_ITEM equ %3
	N_%1 equ (SIZEOF_%1) / SIZEOF_%1_ITEM
	%endmacro

	; Macro to define n size arrays that take 4+ parameters (array name, item type, item size, pointer to array)

	%macro define_narray 4+

%1:
	%2 %4; type [...items]
	SIZEOF_%1 equ $ - %1
	SIZEOF_%1_ITEM equ %3
	N_%1 equ (SIZEOF_%1) / SIZEOF_%1_ITEM
	%endmacro

	; Macro for sum function call that take 1 parameter (array name)

	%macro sum_array 1
	mov    rdi, N_%1
	mov    rsi, %1
	mov    rcx, SIZEOF_%1_ITEM
	call   sum
	%endmacro

	;======================================================================

	;----------------------------------------------------------------------
	; Some defines
	;----------------------------------------------------------------------

	%define SYS_EXIT 60

	;======================================================================

	section .text
	global  _start

sum:
	; size_t {rax} sum(size_t {rdi}, size_t *{rsi}, size_t {rcx})
	; Compute the sum of count {rdi} packed size_t items starting at address {rsi}
	; where   rdi: array count, rsi: array pointer, rcx: array item size

	push rdi; Count of array
	push rsi; Pointer to first item of array
	push rcx; Size of an item

	xor rax, rax; Initialize the accumulator to 0
	cmp rdi, 1; Check if array is empty. if len(array) >= 1
	jb  .sum_done; Don't bother and return early if `cmp` outputs 0

.sum_loop:
	; do { ... } while (( --{rdi} > 0 ))

	add rax, [rsi]; Add items value at address of {rsi} to accumulator
	add rsi, rcx; Increment pointer offset by size of item in array (move to next item in array)
	dec rdi; Decrement count of items left to visit; ( --{rdi}; )
	jnz .sum_loop; If result of `dec {rdi}` is not zero, loop again. else fallthrough to `_done`

.sum_done:
	pop rcx
	pop rsi
	pop rdi

	ret

_start:
	mov  rdi, N_DB_ARRAY; len(array)
	mov  rsi, DB_ARRAY; *array
	mov  rcx, SIZEOF_DB_ARRAY_ITEM; sizeof(dw) i.e. 1
	call sum; function: size_t {rax} sum(size_t {rdi}, size_t *{rsi}, size_t {rcx})
	mov  rdi, rax; exit code {rdi}

	mov  rdi, N_DW_ARRAY; len(array)
	mov  rsi, DW_ARRAY; *array
	mov  rcx, SIZEOF_DW_ARRAY_ITEM; sizeof(dw) i.e. 2
	call sum; function: size_t {rax} sum(size_t {rdi}, size_t *{rsi}, size_t {rcx})
	mov  rdi, rax; exit code {rdi}

	mov  rdi, N_DD_ARRAY; len(array)
	mov  rsi, DD_ARRAY; *array
	mov  rcx, SIZEOF_DD_ARRAY_ITEM; sizeof(dd) i.e. 4
	call sum; function: size_t {rax} sum(size_t {rdi}, size_t *{rsi}, size_t {rcx})
	mov  rdi, rax; exit code {rdi}

	mov  rdi, N_DQ_ARRAY; len(array)
	mov  rsi, DQ_ARRAY; *array
	mov  rcx, SIZEOF_DQ_ARRAY_ITEM; sizeof(dq) i.e. 8
	call sum; function: size_t {rax} sum(size_t {rdi}, size_t *{rsi}, size_t {rcx})
	mov  rdi, rax; exit code {rdi}

	sum_array DB_ARR
	mov rdi, rax; 8

	sum_array DB_NARRAY
	mov rdi, rax; 36

	sum_array DW_NARRAY
	mov rdi, rax; 16

	sum_array DD_NARRAY
	mov rdi, rax; 160

	sum_array DQ_NARRAY
	mov rdi, rax; 64

	mov  rax, SYS_EXIT; {rax} = 60
	;xor rdi, rdi; {rdi} = 0; exit code set above so comment this line
	syscall

	ret

section .data

;_macro_constants:
	define_array_of_ones_of_count_8 DB_ARR, db, 1
	define_array_of_ones_of_count_8 DW_ARR, dw, 1
	define_array_of_ones_of_count_8 DD_ARR, dd, 1
	define_array_of_ones_of_count_8 DQ_ARR, dq, 1

	define_narray DB_NARRAY, db, 1, 1,2,3,4,5,6,7,8
	define_narray DW_NARRAY, dw, 2, 100,200,300,400,500,600,700,800
	define_narray DD_NARRAY, dd, 4, 1000,2000,3000,4000,5000,6000,7000,8000
	define_narray DQ_NARRAY, dq, 8, 10000,20000,30000,40000,50000,60000,70000,80000

DB_ARRAY:
	db 1, 1, 1, 1, 1, 1, 1, 1; db `define word` allocates 1 bytes per item
	SIZEOF_DB_ARRAY equ $ - DB_ARRAY; `$` represents current address (location); DB_ARRAY is the starting address of the array
	SIZEOF_DB_ARRAY_ITEM equ 1
	N_DB_ARRAY equ (SIZEOF_DB_ARRAY) / SIZEOF_DB_ARRAY_ITEM; 8

DW_ARRAY:
	dw 1, 1, 1, 1, 1, 1, 1, 1; dw `define word` allocates 2 bytes per item
	SIZEOF_DW_ARRAY equ $ - DW_ARRAY; `$` represents current address (location); DW_ARRAY is the starting address of the array
	SIZEOF_DW_ARRAY_ITEM equ 2
	N_DW_ARRAY equ (SIZEOF_DW_ARRAY) / SIZEOF_DW_ARRAY_ITEM; 8

DD_ARRAY:
	dd 1, 1, 1, 1, 1, 1, 1, 1; dw `define word` allocates 2 bytes per item
	SIZEOF_DD_ARRAY equ $ - DD_ARRAY; 12; `$` represents current address (location); DD_ARRAY is the starting address of the array
	SIZEOF_DD_ARRAY_ITEM equ 4
	N_DD_ARRAY equ (SIZEOF_DD_ARRAY) / SIZEOF_DD_ARRAY_ITEM; 8

DQ_ARRAY:
	dq 1, 1, 1, 1, 1, 1, 1, 1; dw `define word` allocates 8 bytes per item
	SIZEOF_DQ_ARRAY equ $ - DQ_ARRAY; `$` represents current address (location); DQ_ARRAY is the starting address of the array
	SIZEOF_DQ_ARRAY_ITEM equ 8
	N_DQ_ARRAY equ (SIZEOF_DQ_ARRAY) / SIZEOF_DQ_ARRAY_ITEM; 8

;ARCHIVE:
	;byte_array    db  1, 2, 3, 4, 5                ; 8-bit items
	;word_array    dw  1000, 2000, 3000, 4000       ; 16-bit items
	;dword_array   dd  100000, 200000, 300000       ; 32-bit items
	;qword_array   dq  1000000000, 2000000000       ; 64-bit items

	;byte_count    equ $ - byte_array
	;word_count    equ ($ - word_array) / 2
	;dword_count   equ ($ - dword_array) / 4
	;qword_count   equ ($ - qword_array) / 8

;NOTES:

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
