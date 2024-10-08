;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DEFINITIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; what address will the binary start at when the OS loads it into memory
%define LOAD_ADDRESS 0x00020000 ; pretty much any number >0 works
; local variable just for nasm, not included in code. Uses load address as origin
%define CODE_SIZE END-(LOAD_ADDRESS+0x78) ; everything beyond the HEADER is code

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;HEADER;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BITS 64						; assume 64 bits after this, as nasm uses 16 bits
org LOAD_ADDRESS			; plug in address
ELF_HEADER:
	db 0x7F,"ELF"			; magic number to indicate ELF file
	db 0x02					; 0x1 for 32-bit, 0x2 for 64-bit
	db 0x01					; 0x1 for litle endian, 0x2 for big endian
	db 0x01					; 0x1 for currend version of EFL
	db 0x09					; 0x9 for FreeBSD, 0x3 forr Linux (doesn't seem to matter)
	db 0x00					; ABI version (ignored?)
	times 7 db 0x00			; 7 padding bytes
	dw 0x0002				; executable file
	dw 0x003E				; AMD x86-64
	dd 0x00000001			; version 1
	dq START				; entry point for our program
	dq 0x0000000000000040	; 0x40 offset from EFL_HEADER to PROGRAM_HEADER
	dq 0x0000000000000000 	; section header offset (we don't have this)
	dd 0x00000000			; unused flags
	dw 0x0040				; 64-byte size of ELF-HEADER
	dw 0x0038 				; 56-byte size of each program header entry
	dw 0x0001 				; number of program header entries (we have one)
	dw 0x0000 				; size of each section header entries (none)
	dw 0x0000 				; number of section header entries (none)
	dw 0x0000 				; index in section header table for section names (waste)
PROGRAM_HEADER:
	dd 0x00000001			; 0x1 for loadable program segment
	dd 0x00000007			; read/write/execute flags
	dq 0x0000000000000078	; offset of code start in file image (0x40+0x38)
	dq LOAD_ADDRESS+0x78	; virtual address of segment in memory
	dq 0x0000000000000000	; physical address of segment in memory  (ignored?)
	dq CODE_SIZE			; size (bytes) of segment in file image
	dq CODE_SIZE			; size(bytes) of segment in memory
	; ^ dq CODE_SIZE+HEAP_SIZE+BUFFER_SIZE
	; |              ^					^
	; | add to this one if we add dynamic memory to use or any other headesr etc..
	; ---
	dq 0x0000000000000000	; alignment (doesn't matter, only 1 segment)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INCLUDES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%include "syscalls.asm"		; requires syscall listing for your OS in lib/sys/

%include "lib/sys/chmod.asm"
;	int {rax} chmod(char* {rdi}, long {rsi});

%include "lib/sys/exit.asm"
;	void exit(byte {dil});

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INSTRUCTIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


START:

	; check for argc=2
	cmp byte [SYS_ARGC_START_POINTER],2
	jne .fail

	; change permissions of file at path in argv[1]
	mov rdi,[SYS_ARGC_START_POINTER+16]
	mov rsi,SYS_EXECUTE_PERMISSIONS
	call chmod

	xor rdi,rdi				; retval 0 indicates possible success
	jmp .leave
.fail:
	mov rdi,1				; retval 1 indicates wrong number of arguments
.leave:
	call exit

END:

