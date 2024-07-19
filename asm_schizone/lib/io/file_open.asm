%ifndef FILE_OPEN
%define FILE_OPEN

file_open:

	; save clobered registers
	SYS_PUSH_SYSCALL_CLOBBERED_REGISTERS

	mov rax,SYS_OPEN		; set {ret} to open syscall
	syscall					; execute open syscall
							
	; restore clobbered registers
	SYS_POP_SYSCALL_CLOBBERED_REGISTERS

	ret						; return

%endif						; FILE_OPEN
