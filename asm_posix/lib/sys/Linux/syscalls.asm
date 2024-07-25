	;------------------------------------------------------------------------------
	; DEFINITIONS
	;------------------------------------------------------------------------------

	;       ID numbers for syscall. put these in {rax}
	;------------------------------------------------------------------------------
	%define SYS_READ 0
	%define SYS_WRITE 1
	%define SYS_EXIT 60
	%define SYS_CHMOD 90
	;==============================================================================

	;       File Descriptors
	;------------------------------------------------------------------------------
	%define SYS_STDIN 0
	%define SYS_STDOUT 1
	%define SYS_STDERR 2
	;==============================================================================

	;        Permissions for SYS_OPEN
	;------------------------------------------------------------------------------
	;%define SYS_READ_ONLY 0x000
	%define  SYS_EXECUTE_PERMISSIONS 744o
	;==============================================================================

	;       Pointer to `argc` at program start
	;------------------------------------------------------------------------------
	%define SYS_ARGC_START_POINTER rsp
	;==============================================================================

	;      Macros
	;------------------------------------------------------------------------------
	%macro SYS_PUSH_SYSCALL_CLOBBERED_REGISTERS 0; 0 indicates that no args are required
	push   rcx
	push   r11
	%endmacro

	%macro SYS_POP_SYSCALL_CLOBBERED_REGISTERS 0; 0 indicates that no args are required
	pop    r11
	pop    rcx
	%endmacro
	;==============================================================================
