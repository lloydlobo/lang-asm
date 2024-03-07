START:

	; check for argc=2
	cmp byte [SYS_ARGC_START_POINTER],2
	jne .fail

	; ...
	; ...
	; ...

	xor rdi,rdi				; retval 0 indicates possible success
	jmp .leave

.fail:
	mov rdi,1				; retval 1 indicates wrong number of arguments

.leave:
	call exit

END:

