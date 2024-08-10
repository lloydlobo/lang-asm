	; *---------------------------------------------------------------------------------------
	; * file: code.asm
	; *
	; * Writes "Hola, mundo" to the console using a C library. Runs on Linux.
	; *
	; *     nasm -f elf64 code.asm && zig cc code.o && ./a.out
	; *
	; * Watch build and run:
	; *
	; *     find . -name '*.asm' | entr -rs "date;nasm -f elf64 code.asm && zig cc code.o && ./a.out && echo;echo exit status $?;"
	; *
	; * Ported from #[Using a C Library]: "https://cs.lmu.edu/~ray/notes/nasmtutorial/"
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
	extern puts

	;       SECTION TEXT
	;----------------------------------------------------------------------
	section .text

	; `main:` this is called by the C library startup code

main:
	mov  rdi, progn; first integer (or pointer) argument in {rdi}
	call puts; puts(message)

	mov  rdi, message
	call puts

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

message:
	db "Hola, mundo", 0; NOTE: strings must be terminated with `0` in C lang!

progn:
	db "ex004e_using_c_library", 0; NOTE: strings must be terminated with `0` in C lang!
	;======================================================================

	;----------------------------------------------------------------------
	; NOTES
	;----------------------------------------------------------------------

	; * Context:
	; *
	; * See "https://cs.lmu.edu/~ray/notes/nasmtutorial/"
	; * # Using a C Library:
	; *
	; * Writing standalone programs with ... system calls is cool, but rare.
	; * We would like to use the good stuff in the C library.
	; *
	; * Remember how in C execution “starts” at the function main? That’s
	; * because the C library actually has the _start label inside itself!
	; *
	; * The code at _start does some initialization, then it calls main, then
	; * it does some clean up, then it issues the system call for exit. So
	; * you just have to implement main. We can do that in assembly!
	; * ...
	; * In macOS land, C functions (or any function that is exported from
	; * one module to another, really) must be prefixed with underscores. The
	; * call stack must be aligned on a 16-byte boundary (more on this
	; * later). And when accessing named variables, a rel prefix is required.

