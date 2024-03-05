; long {rax} add_up_three_numbers(long {rdi}, long {rsi}, long {rdx});
add_up_three_numbers:
	push rdi		; preserve all
	push rsi		; registers
	push rdx		; rdx isn't mutated so this instruction is useless
	
	add rsi,rdx		; {rsi}={rsi}+{rsx}
	add rdi,rsi		; {rdi}={rdi}+{rsi}
	mov rax,rdi		; {rax}={rdi}

	pop rdx			; restore all
	pop rsi			; registers
	pop rdi

	ret				; computation done and returned in return value

; Shorter version
add_up_three_numbers_concise:
	mov rax,rdi		; {rax}={rdi}
	add rax,rsi		; {rax}+={rsi}
	add rax,rdx		; {rax}+={rdx}
	ret
