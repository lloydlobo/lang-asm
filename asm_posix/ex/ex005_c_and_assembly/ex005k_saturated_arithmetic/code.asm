	; *---------------------------------------------------------------------------------------
	; * code.asm -> add_four_floats.asm
	; *
	; * This is a Linux 64-bit program that shows signed saturated arithmetic.
	; *
	; *     nasm -f elf64 -Ox code.asm                                                         \
	; *         -I ../../../ -I "../../../lib/sys/$(uname)"                                    \
	; *         -Wlabel-orphan -Wno-orphan-labels                                              \
	; *         -O0 -g -F dwarf
	; *     zig cc code.o code.c && ./a.out
	; *
	; * Ported from "[Saturated Arithmetic]: https://cs.lmu.edu/~ray/notes/nasmtutorial/"
	; *----------------------------------------------------------------------------------------

	; * Usage:
	; *     ./a.out
	; *     34ff7fffaa7736548000a677fff

	global main
	extern printf; `printf(char *{rdi} __format, {rsi}, {rdx}, {rcx}, {r8} ...varargs); `

	;------------------------------------
	; TEXT SECTION
	;------------------------------------

	section .text

main:
	push rbp

	movaps xmm0, [arg1]
	movaps xmm1, [arg2]
	paddsw xmm0, xmm1
	movaps [result], xmm0

	lea  rdi, [format]
	mov  esi, dword [result + (4*0)]
	mov  edx, dword [result + (4*1)]
	mov  ecx, dword [result + (4*2)]
	mov  r8d, dword [result + (4*3)]
	xor  rax, rax
	call printf

	pop rbp

.leave:
	ret; return

	;------------------------------------
	; BSS SECTION
	;------------------------------------

	section .bss

	;------------------------------------
	; DATA SECTION
	;------------------------------------

	section .data

	align 16

arg1:
	dw 0x3544, 0x24FF, 0x7654, 0x9A77, 0xF677, 0x9000, 0xFFFF, 0x0000

arg2:
	dw 0x7000, 0x1000, 0xC000, 0x1000, 0xB000, 0xA000, 0x1000, 0x0000

result:
	dd 0, 0, 0, 0

format:
	db "%x%x%x%x", 10, 0

	; * The XMM registers can also do arithmetic on integers. The instructions
	; * have the form:
	; *
	; *     "\mathit{op}\;\mathit{xmmreg\_or\_memory}, \mathit{xmmreg}"
	; *
	; * For integer addition, the instructions are:
	; *
	; * Instruction | Description
	; *             |
	; * paddb       | Do 16 byte-additions
	; * paddw       | Do 8 word-additions
	; * paddd       | Do 4 dword-additions
	; * paddq       | Do 2 qword-additions
	; * paddab      | Do 16 byte-additions with signed saturation (80..7F)
	; * paddsw      | Do 8 word-additions with signed saturation (8000..7F)
	; * paddusb     | Do 16 byte-additions with unsigned saturation (00..FF)
	; * paddusw     | Do 8 word-additions with unsigned saturation (00..FFFF)
	; *
	; * The example also illustrates how you load the XMM registers. You can’t
	; * load immediate values; you have to use movaps to move from memory.

	; * The XMM registers can do arithmetic on floating point values one
	; * operation at a time (scalar) or multiple operations at a time (packed).
	; *
	; * The operations have the form:
	; *
	; *     "\mathit{op}\;\mathit{xmmreg\_or\_memory}, \mathit{xmmreg}"
	; *
	; * For floating point addition, the instructions are:
	; *
	; * Instruction | Description
	; * addpd       | Do two double-precision additions in parallel (add packed double)
	; * addsd       | Do just one double-precision addition, using the low 64-bits of the register (add scalar double)
	; * addps       | Do four single-precision additions in parallel (add packed single)
	; * addss       | Do just one single-precision addition, using the low 32-bits of the register (add sca
