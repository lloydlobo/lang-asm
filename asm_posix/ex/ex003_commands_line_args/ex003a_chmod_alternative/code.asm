	;----------------------------------------------------------------------
	; DEFINITIONS
	;----------------------------------------------------------------------

	%define EXIT_SUCCESS 0
	%define EXIT_FAILURE 1

	;----------------------------------------------------------------------
	; HEADER
	;----------------------------------------------------------------------

	BITS 64

	;----------------------------------------------------------------------
	; INCLUDES
	;----------------------------------------------------------------------

	%include "syscalls.asm"; Requires syscall listing for your OS in lib/sys/

	%include "lib/sys/chmod.asm"; int {rax} chmod(char *{rdi}, long {rsi})

	%include "lib/sys/exit.asm"; void exit(byte {dil})

	;----------------------------------------------------------------------
	; INSTRUCTIONS
	;----------------------------------------------------------------------

	;       SECTION TEXT
	;----------------------------------------------------------------------
	section .text
	global  _start

_start:
	;   Check for argc == 2
	cmp byte [SYS_ARGC_START_POINTER], 2; For example: ./binary <file>
	jne .fail

;.tmp:
	;mov rdi, byte [SYS_ARGC_START_POINTER + (8 * 2)]
	;jmp .exit

	;    Change permissions of file at path in argv[1]
	mov  rdi, [SYS_ARGC_START_POINTER + (8 * 2)]; mov rdi, [SYS_ARGC_START_POINTER+16]
	mov  rsi, SYS_EXECUTE_PERMISSIONS
	call chmod

	; {rax} now contains 0/-1 on success/fail at execution of chmod syscall

	cmp rax, 0
	jne .exit_fprint_stderr

.success:
	xor dil, dil; retval 0 indicates possible success; xor rdi, rdi
	jmp .exit

.exit_fprint_stderr:
	mov r10, rax; Save errno

	; fprintf(stderr, "...")

	mov rax, SYS_WRITE
	mov rdi, SYS_STDERR
	mov rsi, MSG_CHMOD_ERR
	mov rdx, N_MSG_CHMOD_ERR
	syscall

	mov rdi, r10; Return errno as exit status for exit({dil})
	jmp .exit

.fail:
	mov dil, EXIT_FAILURE; mov rdi, 1

.exit:
	call exit
	;======================================================================

	;       SECTION DATA
	;----------------------------------------------------------------------
	section .data

MSG_USAGE:
	db 'Usage: ...', 0x0a; 0x0a is the newline linefeed character
	N_MSG_USAGE equ ($ - MSG_USAGE)

MSG_CHMOD_ERR:
	db '[error] failed to execute chmod syscall', 0x0a; 0x0a is the newline linefeed character
	N_MSG_CHMOD_ERR equ ($ - MSG_CHMOD_ERR)
	;  ...
	;======================================================================

	;----------------------------------------------------------------------
	; USAGE
	;----------------------------------------------------------------------

	; Run:
	;----------------------------------------------------------------------

	;./binary test.txt; echo exit status $?

	;find . -name '*.asm' | entr -prs "date;stat binary;./binary test.txt;echo exit status $?;"

	;while sleep 2; do
	;      date
	;      ./binary test.txt
	;      echo exit status $?
	;done

	;======================================================================

	; ERRORS:
	;----------------------------------------------------------------------
	; chmod +x test.txt; echo exit status $?
	; # chmod: cannot access 'test.txt': No such file or directory
	; # exit status 1
	;======================================================================
