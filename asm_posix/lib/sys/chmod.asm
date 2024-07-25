%ifndef CHMOD
%define CHMOD

chmod:
	;int {rax} chmod(char *{rdi}, long {rsi})
	;    Sets permissions of file with the path indicated by
	;    null-terminated char array at address in {rdi}; to the value in
	;    the low 9 bits of {rsi}.
	;    Returns 0/-1 in {rax} on success/fail.

	; Save clobbered registers
	SYS_PUSH_SYSCALL_CLOBBERED_REGISTERS

	mov     rax, SYS_CHMOD; Set {rax} to chmod syscall
	syscall ; Execute chmod syscall

	; Restore clobbered registers
	SYS_POP_SYSCALL_CLOBBERED_REGISTERS

	ret ; [ret]urn

%endif ; !CHMOD

