	; *---------------------------------------------------------------------------------------
	; * code.asm -> echo.asm
	; *
	; * This is a Linux console 64-bit program that displays its command line
	; * arguments, one per line. Runs on GNU/Linux only.
	; *
	; * On entry, {rdi} will contain `argc` and {rsi} will contain `argv`.
	; *
	; *     nasm -f elf64 code.asm && zig cc code.o && ./a.out
	; *
	; * Ported from "[Command Line Arguments]: https://cs.lmu.edu/~ray/notes/nasmtutorial/"
	; *----------------------------------------------------------------------------------------

	;----------------------------------------------------------------------
	;        DEFINITIONS
	;----------------------------------------------------------------------
	%define  EXIT_SUCCESS 0
	%define  EXIT_FAILURE 1
	;----------------------------------------------------------------------
	;        INCLUDES
	;----------------------------------------------------------------------
	%include "syscalls.asm"; Requires syscall listing for your OS in lib/sys/
	%include "lib/sys/exit.asm"; void exit(byte {dil})
	;----------------------------------------------------------------------
	;        INSTRUCTIONS
	;----------------------------------------------------------------------
	;        * By the x86 64-bit calling convention, the first six arguments are
	;        * passed in the registers {rdi} {rsi} {rdx} {rcx} {r8} {r9} in that
	;        * order. {rax} contains the system call ordinal.
	;        *
	;        * In x86: EBX(fd) ECX(buffer) EDX(length) EAX(system call ordinal)
	;        * In x64: RDI RSI RDX RCX RAX(system call ordinal)
	global   main
	extern   puts
	;        SECTION `.text`
	section  .text

	; * You know that in C, main is just a plain old function, and it has a
	; * couple parameters of its own:
	; *
	; * `int main(int argc, char** argv)`
	; *
	; * So, you guessed it, `argc` will end up in {rdi}, and `argv` (a pointer)
	; * will end up in {rsi}. Here is a program that uses this fact to simply
	; * echo the command line arguments to a program, one per line:

echo_argv:
	;    * Function: `void {rax} echo_argv(long {rdi}, long *{rsi})`
	;    * Arguments:
	;    * - {rdi}: argument count passed to command line (argc)
	;    * - {rsi}: address of string to output, i.e arguments passed to
	;    command
	;    * line (argv)
	push rdi; save registers that `puts` uses
	push rsi
	sub  rsp, 8; must align stack before call
	mov  rdi, [rsi]; <<< actual work
	call puts; <<< actual work
	add  rsp, 8; restore {rsp} to pre-aligned value
	pop  rsi; restore registers that `puts` used
	pop  rdi
	jmp  .next_argv_elem_inc_rsi
	ret ; else return to label `main`

.next_argv_elem_inc_rsi:
	add rsi, 8; point to the next argument in {rsi}
	;   i.e. long *{rsi} or `char *argv[]`
	dec rdi; count down {rdi} i.e. `int argc`
	jnz echo_argv; if not done counting, keep going
	ret ; return

print_progn:
	mov  rdi, progn
	call puts
	ret

main:
	push rdi; save registers that `puts` uses
	push rsi
	call print_progn
	pop  rsi; restore registers that `puts` used
	pop  rdi
	jmp  echo_argv
	ret ; return to `main` call site in C

	; * Output:
	; * ./a.out
	; * dog
	; * 22
	; * -zzz
	; * Hellope

	;       SECTION `.bss`
	section .bss
	;       * ---

	; ^
	; * NOTE:
	; * before adding section .bss, output of `print_progn:`:
	; *     program: ex005e_command_line_arguments
	; *     Linker: LLD 18.1.6
	; * and after adding section .bss, output of `print_progn:`:
	; *     program: ex005e_command_line_arguments

	;       SECTION `.data`
	section .data

progn:
	db "program: ex005e_command_line_arguments"; note: omit line-feed as `puts`
	;  does it for us
	;  `db "...", 0x0a`; 10 is line-feed `\n`; (10 or 0x0a or 0XA -> `\n`)

