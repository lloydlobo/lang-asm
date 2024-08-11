	; *---------------------------------------------------------------------------------------
	; * code.asm -> sum.asm
	; *
	; * This is a Linux 64-bit library function that returns the sum of the
	; * elements in a floating point array. The function has prototype:
	; *
	; *     double sum(double[] array, uint64_t length)
	; *
	; *     nasm -f elf64 code.asm                                                             \
	; *         -I ../../../ -I "../../../lib/sys/$(uname)"                                    \
	; *         -Wlabel-orphan -Wno-orphan-labels                                              \
	; *         -O0 -g -F dwarf     #   -Ox
	; *     zig cc code.o code.c # without C interop -> `ld -o binary code.o -lc -s; `
	; *     ./a.out
	; *
	; * Ported from "[Floating Point Instructions]: https://cs.lmu.edu/~ray/notes/nasmtutorial/"
	; *----------------------------------------------------------------------------------------

	global  sum
	section .text

sum:
	xorpd xmm0, xmm0; initialize the sum to 0
	cmp   rsi, 0; "special case" for length to be 0
	je    .done

.loop_next:
	addsd xmm0, [rdi]; add in the current array element
	add   rdi, 8; move to the next array element (`i++`)
	dec   rsi; count down
	jnz   .loop_next; if not done counting (i.e. {rsi} == 0), continue

.done:
	ret ; return value is already in {xmm0}
