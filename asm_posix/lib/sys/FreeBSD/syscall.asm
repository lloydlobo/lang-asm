;syscall ID numbers; Put these in {rax}

%define SYS_EXIT 1
%define SYS_READ 3
%define SYS_WRITE 4

;File Descriptors

%define SYS_STDIN 0
%define SYS_STDOUT 1
%define SYS_STDERR 2

;Pointer to `argc` at program start
%define  SYS_ARGC_START_POINTER rdi
