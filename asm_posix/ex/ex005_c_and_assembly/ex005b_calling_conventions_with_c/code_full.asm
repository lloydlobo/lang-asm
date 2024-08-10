	; *---------------------------------------------------------------------------------------
	; * file: code.asm
	; *
	; * A 64-bit Linux application that writes the first 90 Fibonacci numbers.
	; *
	; *     nasm -f elf64 code.asm && zig cc code.o && ./a.out
	; *
	; * Ported from "[Understanding Calling Conventions](https://cs.lmu.edu/~ray/notes/nasmtutorial/)"
	; *----------------------------------------------------------------------------------------

	;----------------------------------------------------------------------
	; DEFINITIONS
	;----------------------------------------------------------------------
	; It's so lonely here

	;----------------------------------------------------------------------
	; HEADER
	;----------------------------------------------------------------------
	; It's so lonely here

	;----------------------------------------------------------------------
	; INCLUDES
	;----------------------------------------------------------------------
	; It's so lonely here

	;----------------------------------------------------------------------
	; INSTRUCTIONS
	;----------------------------------------------------------------------

	global main
	extern printf
	extern puts

	;       SECTION TEXT
	;----------------------------------------------------------------------
	section .text

	; `main:` this is called by the C library startup code

main:
	push rbx; save registers. since we use it

	;   {ecx} (range lo: 1, hi: 93).
	;   note: integer overflows for result after {ecx}: 93
	mov ecx, 93; initialize counter; {ecx} will countdown to 0
	xor rax, rax; {rax} will hold the current number
	xor rbx, rbx, ; {rbx} will hold the next number
	inc rbx; {rbx} is originally 1

print:
	; Consider {rax}, {rbx}, and {rcx}, before calling `printf`, since printf`
	; may destroy {rax} and {rcx}. so we will save these before the call and
	; restore them afterwards.

	push rax; caller-save register
	push rcx; caller-save register

	mov rdi, format; set 1st parameter (format)> `db "%20ld", 10, 0`
	mov rsi, rax; set 2nd parameter (current_number)
	xor rax, rax; because `printf` is varargs

	;    Stack is already aligned because we pushed three 8 byte registers
	call printf; printf(format, current_number)

	pop rcx; restore caller-save register
	pop rax; restore caller-save register

	mov rdx, rax; save  the current number
	mov rax, rbx; next number is now current
	add rbx, rdx; get the "new" next number
	dec ecx; count down

	;# See [Matthew Slattery]"https://stackoverflow.com/a/14267642"
	;# JE and JZ are just different names for exactly the same thing: a conditional jump when ZF (the "zero" flag) is equal to 1.
	;# (Similarly, JNE and JNZ are just different names for a conditional jump when ZF is equal to 0.)
	;# You could use them interchangeably, but you should use them depending on what you are doing:
	;#
	;# JZ/JNZ are more appropriate when you are explicitly testing for
	;# something being equal to zero:
	;#
	;# dec    ecx
	;# jz     counter_is_now_zero

	;# JE and JNE are more appropriate after a CMP instruction:
	;#
	;# cmp    edx, 42
	;# je     the_answer_is_42
	;#
	;# (A CMP instruction performs a subtraction, and throws the value of the result away, while keeping the flags; which is why you get ZF=1 when the operands are equal and ZF=0 when they're not.)

	;   `jnz`: if the processor's `Z` (zero) flag is set (equals 0), jump to the given label.
	;   `jz`or`je`: if the processor's `ZF` (zero) flag is set (equals 1), jump to the given label.
	jnz print; if not done counting, do some more(loop again)

leave:
	pop rbx; restore registers. before returning to `main` in C land
	mov rax, 0; instruct `int main(...)` in C to take exit code from {rax}

	ret; return from main block back into C libary wrapper
	;======================================================================

	;       SECTION BSS: WRITABLE DATA
	;----------------------------------------------------------------------
	section .bss
	;       It's so lonely here
	;======================================================================

	;       SECTION DATA
	;----------------------------------------------------------------------
	section .data

progn:
	db "ex004f_calling_conventions_with_c", 0; NOTE: strings must be terminated with `0` in C lang!

format:
	db "%20ld", 10, 0

	;======================================================================

	;----------------------------------------------------------------------
	; NOTES
	;----------------------------------------------------------------------

	; * Context:
	; *
	; * See "https://cs.lmu.edu/~ray/notes/nasmtutorial/"
	; * # Understanding Calling Conventions:
	; *
	; * How did we know the argument to puts was supposed to go in RDI? Answer: there are a number of conventions that are followed regarding calls.
	; * When writing code for 64-bit Linux that integrates with a C library, you must follow the calling conventions explained in the AMD64 ABI Reference. You can also get this information from Wikipedia. The most important points are:
	; * From left to right, pass as many parameters as will fit in registers. The order in which registers are allocated, are:
	; * - For integers and pointers, rdi, rsi, rdx, rcx, r8, r9.
	; * - For floating-point (float, double), xmm0, xmm1, xmm2, xmm3, xmm4, xmm5, xmm6, xmm7.
	; * Additional parameters are pushed on the stack, right to left, and are to be removed by the caller after the call.
	; * After the parameters are pushed, the call instruction is made, so when the called function gets control, the return address is at [rsp], the first memory parameter is at [rsp+8], etc.
	; * The stack pointer rsp must be aligned to a 16-byte boundary before making a call. Fine, but the process of making a call pushes the return address (8 bytes) on the stack, so when a function gets control, rsp is not aligned. You have to make that extra space yourself, by pushing something or subtracting 8 from rsp.
	; * The only registers that the called function is required to preserve (the calle-save registers) are: rbp, rbx, r12, r13, r14, r15. All others are free to be changed by the called function.
	; * The callee is also supposed to save the control bits of the XMCSR and the x87 control word, but x87 instructions are rare in 64-bit code so you probably don’t have to worry about this.
	; * Integers are returned in rax or rdx:rax, and floating point values are returned in xmm0 or xmm1:xmm0.
	; *
	; * previously ...
	; *
	; * See "https://cs.lmu.edu/~ray/notes/nasmtutorial/"
	; * # Using a C Library:
	; *
	; * Writing standalone programs with ... system calls is cool, but rare. * We would like to use the good stuff in the C library.
	; * Remember how in C execution “starts” at the function main? That’s * because the C library actually has the _start label inside itself!
	; * The code at _start does some initialization, then it calls main, then it does some clean up, then it issues the system call for exit. So you just have to implement main. We can do that in assembly!
	; * In macOS land, C functions (or any function that is exported from one module to another, really) must be prefixed with underscores. The call stack must be aligned on a 16-byte boundary (more on this later). And when accessing named variables, a rel prefix is required.
