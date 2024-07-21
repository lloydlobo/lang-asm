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

	;----------------------------------------------------------------------
	; #"Pseudocode"
	;----------------------------------------------------------------------
	; # static long ARRAY[] = {3, 9, 11, 4}                                               // dq
	; #
	; # int main(int argc, char *argv[]) {
	; #     long SIZEOF_ARRAY_ITEM = 8                                                    // dq
	; #     long SIZEOF_ARRAY = sizeof(ARRAY)
	; #     long N_ARRAY = SIZEOF_ARRAY / sizeof(ARRAY[0])
	; #
	; #     long rax                                                                      // return arg1
	; #     long rdx                                                                      // return arg2
	; #                                                                                   // max_int(...)
	; #     long rdi = N_ARRAY                                                            // param1
	; #     long *rsi = ARRAY                                                             // param2
	; #     rdx = SIZEOF_ARRAY_ITEM                                                       // param3
	; #
	; #     long rcx = rdi                                                                // Counter
	; #     rax = ARRAY[0]                                                                // "max"
	; #     long r8 = 0                                                                   // max_index
	; #     long r9 = 0                                                                   // cur_index
	; #
	; # find_max:
	; #     if (rcx == 1) goto done
	; #                                                                                   // (*rsi)+=rdx;
	; #     r9 += 1
	; #     if (ARRAY[r9] <= rax) goto not_larger
	; #     rax = ARRAY[r9]
	; #     r8=r9
	; #
	; # not_larger:
	; #     rcx -= 1
	; #     goto find_max
	; #
	; # done:
	; #     rdx = r8
	; #     return rax
	; #
	; #     return 0
	; # }
	; #
	; #  -Os -Wall -Wextra -ffreestanding -mno-red-zone -mgeneral-regs-only -march=native
	; #
	; # main:
	; #         mov     eax, 11
	; #         ret
	; #
	; #  -O0 -Wall -Wextra -ffreestanding -mno-red-zone -mgeneral-regs-only -march=native
	; #
	; # ARRAY:
	; #         .quad   3
	; #         .quad   9
	; #         .quad   11
	; #         .quad   4
	; # main:
	; #         push    rbp
	; #         mov     rbp, rsp
	; #         sub     rsp, 96
	; #         mov     DWORD PTR [rbp-84], edi
	; #         mov     QWORD PTR [rbp-96], rsi
	; #         mov     QWORD PTR [rbp-40], 8
	; #         mov     QWORD PTR [rbp-48], 32
	; #         mov     rax, QWORD PTR [rbp-48]
	; #         shr     rax, 3
	; #         mov     QWORD PTR [rbp-56], rax
	; #         mov     rax, QWORD PTR [rbp-56]
	; #         mov     QWORD PTR [rbp-64], rax
	; #         mov     QWORD PTR [rbp-72], OFFSET FLAT:ARRAY
	; #         mov     rax, QWORD PTR [rbp-40]
	; #         mov     QWORD PTR [rbp-80], rax
	; #         mov     rax, QWORD PTR [rbp-64]
	; #         mov     QWORD PTR [rbp-16], rax
	; #         mov     rax, QWORD PTR ARRAY[rip]
	; #         mov     QWORD PTR [rbp-8], rax
	; #         mov     QWORD PTR [rbp-24], 0
	; #         mov     QWORD PTR [rbp-32], 0
	; # .L2:
	; #         cmp     QWORD PTR [rbp-16], 1
	; #         je      .L9
	; #         inc     QWORD PTR [rbp-32]
	; #         mov     rax, QWORD PTR [rbp-32]
	; #         mov     rax, QWORD PTR ARRAY[0+rax*8]
	; #         cmp     QWORD PTR [rbp-8], rax
	; #         jge     .L10
	; #         mov     rax, QWORD PTR [rbp-32]
	; #         mov     rax, QWORD PTR ARRAY[0+rax*8]
	; #         mov     QWORD PTR [rbp-8], rax
	; #         mov     rax, QWORD PTR [rbp-32]
	; #         mov     QWORD PTR [rbp-24], rax
	; #         jmp     .L6
	; # .L10:
	; #         nop
	; # .L6:
	; #         dec     QWORD PTR [rbp-16]
	; #         jmp     .L2
	; # .L9:
	; #         nop
	; #         mov     rax, QWORD PTR [rbp-24]
	; #         mov     QWORD PTR [rbp-80], rax
	; #         mov     rax, QWORD PTR [rbp-8]
	; #         leave
	; #         ret
	;======================================================================

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
