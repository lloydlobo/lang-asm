	; *---------------------------------------------------------------------------------------
	; * code.asm -> add_four_floats.asm
	; *
	; * This is a Linux 64-bit program that treats all its command line
	; * arguments as integers and displays their average as a floating point
	; * number. This program uses a data section to store intermediate results
	; * not that it has to, but only to illustrate how data sections are used.
	; *
	; *     void add_four_floats(float {rdi} x[4], float {rsi} y[4])
	; *     x[i] += y[i] for i in range(0..4)
	; *
	; *     nasm -f elf64 -Ox code.asm                                                         \
	; *         -I ../../../ -I "../../../lib/sys/$(uname)"                                    \
	; *         -Wlabel-orphan -Wno-orphan-labels                                              \
	; *         -O0 -g -F dwarf
	; *     zig cc code.o code.c
	; *
	; * Ported from "[SIMD Parallelism]: https://cs.lmu.edu/~ray/notes/nasmtutorial/"
	; *----------------------------------------------------------------------------------------

	; * Also see this "[nice little x86 floating-point slide deck from Ray Seyfarth](http://rayseyfarth.com/asm/pdf/ch11-floating-point.pdf)".

	global  add_four_floats
	section .text

add_four_floats:
	movdqa xmm0, [rdi]; all four values of `x`
	movdqa xmm1, [rsi]; all four values of `y`
	addps  xmm0, xmm1; do all four sums in one shot. result is in {xmm0}
	movdqa [rdi], xmm0
	ret;   return

	; * 0000000001001650 <add_four_floats>:
	; *  1001650: 66 0f 6f 07                   movdqa  xmm0, xmmword ptr [rdi]
	; *  1001654: 66 0f 6f 0e                   movdqa  xmm1, xmmword ptr [rsi]
	; *  1001658: 0f 58 c1                      addps   xmm0, xmm1
	; *  100165b: 66 0f 7f 07                   movdqa  xmmword ptr [rdi], xmm0
	; *  100165f: c3                            ret

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
