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

	%define F64(x) __?float64?__(x)

	global sum
	global mul
	global divide

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

	;* ; initialize accumulator to 1.0
	;* movsd xmm0, [one_f64]
	;* ; or
	;* xorpd xmm0, xmm0; set {xmm0} to 0
	;* mov rax, 0x3FF0000000000000; set the bits for 1.0 in double precision
	;* movq xmm0, rax
	;* ; or

mul:
	mov      rax, 1
	cvtsi2sd xmm0, rax; set {xmm0} to 1.0; using integer instructions and conversion
	cmp      rsi, 0; *special case* for length to be 0
	je       .done

.loop_next:
	mulsd xmm0, [rdi]; multiply in the current array element
	add   rdi, 8; move to next array element (`i++`)
	dec   rsi; count down
	jnz   .loop_next; if not done counting ({rsi} == 0) then continue

.done:
	ret; return value is already in {xmm0}

divide:
	mov      rax, 1
	cvtsi2sd xmm0, rax; set {xmm0} to 1
	cmp      rsi, 0; *special case* for length to be 0
	je       .done

.loop_next:
	;       check division by zero:
	;       sets the zero flag (ZF) if the value are equal, and the Parity Flag (PF)
	;       if the result is unordered (e.g. on of the values in `NaN`)
	movsd   xmm1, [rdi]; with this SSE instruction, [{rdi}]: This instruction copies the value from the memory location [rdi] into the XMM0 register. The original value in memory at [rdi] is not changed.
	xorpd   xmm2, xmm2; set {xmm2} to 0.0
	ucomisd xmm1, xmm2
	je      .done

	divsd xmm0, [rdi]
	add   rdi, 8; move to next array element (`i++`)
	dec   rsi; count down
	jnz   .loop_next; if not done counting(i.e. {rsi} is 0) then continue

.done:
	ret; return value is already in {xmm0}

	section .bss
	;       ---

	section .data
	;       data: constants
	zero_f64    dq F64(0.0)
	one_f64    dq F64(1.0)
	two_f64    dq F64(2.0)
	three_f64  dq F64(3.0)
	five_f64   dq F64(5.0)
	seven_f64  dq F64(7.0)
	pi_f64     dq 3.14
	half_f64   dq 0.5
	;       data: variables
	result_f64 dq 0.0

	;* XMM registers and instructions like XORPD and ADDSD are
	;* part of the SSE (Streaming SIMD Extensions) instruction set, which provides
	;* more modern and efficient ways to handle floating-point operations compared
	;* to the older x87 FPU.
	;*
	;* XMM registers:
	;* - XMM0 through XMM15 (in 64-bit mode) are 128-bit registers
	;* - They can hold 4 single-precision or 2 double-precision floating-point values
	;* - Used for SIMD (Single Instruction, Multiple Data) operations
	;*
	;* Some common SSE instructions for floating-point operations:
	;*
	;* 1. XORPD (XOR Packed Double-Precision)
	;* - Performs a bitwise XOR on two 128-bit operands
	;* - Often used to efficiently set a register to zero: `xorpd xmm0, xmm0`
	;*
	;* 2. ADDSD (Add Scalar Double-Precision)
	;* - Adds the lower 64 bits (double-precision value) of two XMM registers
	;* - Example: `addsd xmm0, xmm1`
	;*
	;* 3. SUBSD (Subtract Scalar Double-Precision)
	;* - Subtracts the lower 64 bits of one XMM register from another
	;* - Example: `subsd xmm0, xmm1`
	;*
	;* 4. MULSD (Multiply Scalar Double-Precision)
	;* - Multiplies the lower 64 bits of two XMM registers
	;* - Example: `mulsd xmm0, xmm1`
	;*
	;* 5. DIVSD (Divide Scalar Double-Precision)
	;* - Divides the lower 64 bits of one XMM register by another
	;* - Example: `divsd xmm0, xmm1`
	;*
	;* 6. MOVSD (Move Scalar Double-Precision)
	;* - Moves a 64-bit (double-precision) value between XMM registers or memory
	;* - Example: `movsd xmm0, [variable]`
	;*
	;* These SSE instructions are generally preferred over x87 FPU instructions in
	;* modern code due to their better performance and easier integration with
	;* other parts of the program.
