	;# Conditional Instructions "[#](https://cs.lmu.edu/~ray/notes/nasmtutorial/)"
	;#
	;# After an arithmetic or logic instruction, or the compare instruction
	;# cmp, the processor sets or clears bits in its rflags.
	;# The most interesting flags are:
	;#
	;# - s (sign)
	;# - z (zero)
	;# - c (carry)
	;# - o (overflow)
	;#
	;# So after doing, say, an addition instruction, we can perform a jump
	;# move, or set, based on the new flag settings. For example:
	;#
	;# | Instruction  | Description                                            |
	;# | ------------ | ------------------------------------------------------ |
	;# | jz L         | Jump to label if the result of the operation was zero  |
	;# | cmovno x, y  | x <- y if the last operation did not overflow          |
	;# | setc x       | x <- 1 if the last operation had a carry, but otherwise|
	;# |              | (x must be a byte-size register or memory location)    |
	;#
	;# The conditional instructions have three base forms: j for conditional
	;# jump, cmov for conditional move, and set for conditional set.
	;#
	;# The suffix of the instruction has one of the 30 forms:
	;# `s ns z nz c nc o no p np pe po e ne l nl le nle g ng ge nge a na ae nae
	;# b nb be nbe`.
