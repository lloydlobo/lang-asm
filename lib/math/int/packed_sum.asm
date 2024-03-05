%ifndef PACKED_SUM
%define PACKED_SUM

; NOTE: put line 64 here?

packed_sum:
; long {rax} packed_sum(long {rdi}, long* {rsi});
; computes the sum of {rdi} packed signed longs starting at {rsi}

	push rdi				; save registers
	push rsi

	xor rax,rax				; init running sum to zero. sets {rax} to 0, whole 64 bits
	cmp rdi,1				; check for at least 1 number to add
	jb .done				; if less than 1 number, don't bother. jb [j]ump [b]elow

.loop:						; packed_sum.loop
	add rax,[rsi]			; add the value at the address in {rsi} to running sum
	add rsi,8				; move the {rsi} pointer ahead by 8 bytes
	dec rdi					; [dec]rement {rdi} to track the number of numbers left
	jnz .loop				; if {rdi} is [n]ot yet [z]ero, repeat the loop

.done:
	pop rsi					; restore registers
	pop rdi
	ret						; [ret]urn

%endif ; PACKED_SUM
