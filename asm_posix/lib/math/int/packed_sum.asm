%ifndef PACKED_SUM
%define PACKED_SUM

packed_sum:
	; long {rax} packed_sum(long {rdi}, long* {rsi})
	; Compute the sum of count {rdi} packed signed longs starting at address {rsi}.

	;    Save registers
	push rdi
	push rsi

	xor rax, rax; Initialize running sum accumulator to zero. Sets {rax} to 0, the whole 64-bits.
	cmp rdi, 1; Check for atleast one number to add.
	jb  .done; If we have less than one number, don't bother and [j]ump [b]elow.

.loop:
	add rax, [rsi]; Add the value at the address {rsi} to the running sum accumulator in {rax}.
	add rsi, 8; For 8-bit items, move the {rsi} pointer ahead by 8 bytes.
	dec rdi; Then [dec]rement {rdi} to track count of numbers left.
	jnz .loop

.done:
	;   Restore registers
	pop rsi
	pop rdi

	ret ; [ret]urn

;byte_array    db  1, 2, 3, 4, 5                ; 8-bit items
;word_array    dw  1000, 2000, 3000, 4000       ; 16-bit items
;dword_array   dd  100000, 200000, 300000       ; 32-bit items
;qword_array   dq  1000000000, 2000000000       ; 64-bit items

%endif ; !PACKED_SUM
