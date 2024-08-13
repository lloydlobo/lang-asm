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
	; *     zig cc code.o
	; *
	; * Ported from "[SIMD Parallelism]: https://cs.lmu.edu/~ray/notes/nasmtutorial/"
	; *----------------------------------------------------------------------------------------

	; * Also see this "[nice little x86 floating-point slide deck from Ray Seyfarth](http://rayseyfarth.com/asm/pdf/ch11-floating-point.pdf)".

	global  add_four_floats
	section .text

add_four_floats:
	movdqa xmm0, [rdi]; all four values of `x`
	movdqa xmm1, [rsi]; all four values of `y`
	addps  xmm0, xmm1; do all four sums in one shot
	movdqa [rdi], xmm0
	ret
