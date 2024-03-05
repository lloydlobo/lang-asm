%ifndef EXIT
%define EXIT

exit:
	
	mov rax,SYS_EXIT
	syscall

%endif					; EXIT
