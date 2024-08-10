	; file: code.asm

	%define _EXIT_FAILURE 1
	%define _SYS_OPEN 2
	%define _SYS_CLOSE 3
	%define _O_RDWR_OR_O_CREAT 2
	%define _MODE_0666 438

	%include "syscalls.asm"; Requires syscall listing for your OS in lib/sys/

	%include "lib/sys/exit.asm"; void exit(byte {dil})

	;       SECTION BSS
	section .bss
	buffer  resb (1024 * 1); Allocate 1KB buffer
	buffer_pos resq 1 ; Position in the buffer (buffer length)

	;        SECTION DATA
	section  .data
	filename db "output.txt", 0
	msg      db "Hello, World!", 0x0a; or 0xA
	msg_len equ ($ - msg)

	;       SECTION TEXT
	section .text
	global  _start

_start:
	;    Open file
	mov  rax, _SYS_OPEN
	;mov rdi, filename
	;mov rsi, _O_RDWR_OR_O_CREAT
	lea  rdi, [filename]; filename
	mov  rsi, 0x42; O_RDWR | O_CREAT (0x42 is O_WRONLY|O_CREAT)
	mov  rdx, _MODE_0666; 438
	syscall
	;    {rax} contains error status from sys_ope syscall
	cmp  rax, 0
	jl   error_open

	mov rdi, rax; Save file descriptor
	mov [file_descriptor], rax

	jmp .close_fd; TMP: skip writing to file

	;    Write to buffer
	;mov rax, msg
	;mov rsi, msg_len
	lea  rsi, [msg]
	call write_to_buffer

	;    Flush the buffer
	call flush_buffer

.close_fd:
	;   Close the file
	mov rdi, [file_descriptor]
	mov rax, _SYS_CLOSE
	syscall

.exit:
	xor  rdi, rdi
	call exit

error_open:
	;    mov  rdi, rax
	;    mov  rax, SYS_WRITE
	;    syscall
	mov  dil, _EXIT_FAILURE
	call exit

write_to_buffer:
	;    Save registers
	push rsi
	push rdx

	mov rax, [buffer_pos]
	add rax, rsi

	cmp  rax, 1024; Check for buffer overflow
	jbe  .write_to_buffer
	call flush_buffer

.write_to_buffer:
	;   Restore registers
	pop rdx
	pop rsi

	mov rax, [buffer_pos]
	lea rdi, [buffer + rax]
	rep movsb
	add qword [buffer_pos], rdx
	ret

flush_buffer:
	mov rax, SYS_WRITE
	mov rdi, [file_descriptor]
	mov rsi, buffer
	mov rdx, [buffer_pos]
	syscall

	mov qword [buffer_pos], 0
	ret

	;       SECTION BSS
	section .bss
	file_descriptor resq 1
