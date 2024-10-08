	; *---------------------------------------------------------------------------------------
	; * code.asm -> maxofthree.asm
	; *
	; * A 64-bit Linux application that returns the maximum value of its three
	; * 64-bit integer arguments. The function has signature:
	; *     int64_t maxofthree(int64_t x, int64_t y, int64_t z)
	; *
	; * Note that the parametrs have already been passed in {rdi}, {rsi}, and  {rdx}.
	; * We just have to return the value in rax.
	; *
	; *     nasm -f elf64 code.asm && zig cc code.c code.o && ./a.out
	; *
	; * Ported from "[Mixing C and Assembly Language](https://cs.lmu.edu/~ray/notes/nasmtutorial/)"
	; *----------------------------------------------------------------------------------------

	global  maxofthree
	section .text

maxofthree:
	mov   rax, rdi; result {rax} initially holds x
	cmp   rax, rsi; is x less than y?
	cmovl rax, rsi; if so, set result to y
	cmp   rax, rdx; is max(x, y) less than z?
	cmovl rax, rdx; if so, set result to z
	ret   ; the max will be in {rax}
