;syscall ID numbers; Put these in {rax}

%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60

;File Descriptors

%define SYS_STDIN 0
%define SYS_STDOUT 1
%define SYS_STDERR 2

;Pointer to `argc` at program start
%define  SYS_ARGC_START_POINTER rsp
