	;------------------------------------------------------------------------------
	; DEFINITIONS
	;------------------------------------------------------------------------------

	;       ID numbers for syscall. put these in {rax}
	;------------------------------------------------------------------------------
	%define SYS_EXIT 1
	%define SYS_READ 3
	%define SYS_WRITE 4
	%define SYS_CHMOD 15
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
	%define  SYS_EXECUTE_PERMISSIONS 755o
	;==============================================================================

	;       Pointer to `argc` at program start
	;------------------------------------------------------------------------------
	%define SYS_ARGC_START_POINTER rdi
	;==============================================================================

	;      Macros
	;------------------------------------------------------------------------------
	%macro SYS_PUSH_SYSCALL_CLOBBERED_REGISTERS 0; 0 indicates that no args are required
	push   rcx
	push   r8
	push   r9
	push   r10
	push   r11
	%endmacro

	%macro SYS_POP_SYSCALL_CLOBBERED_REGISTERS 0; 0 indicates that no args are required
	pop    r11
	pop    r10
	pop    r9
	pop    r8
	pop    rcx
	%endmacro
	;==============================================================================
