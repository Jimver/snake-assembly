# Subroutines for VGA text mode graphics

# void printFood()
# Prints the food on the screen
printFood:
	enter	$0, $0

	movzbq	(foodPos), %rdx
	movzbq	(foodPos+1), %rsi
	scall	printCorrect, %rdx, %rsi, $FOOD_C, $R_B

	leave
	ret

# void printBorders()
# Prints the borders
printBorders:
	enter	$0, $0
	pushq	%rbx	# save rbx so we can use it

	# Horizontal borders
	movq	$X_OFF, %rbx
	1:
	scall	putChar, %rbx, $Y_OFF_M1, $GRID_T, $Y_B
	scall	putChar, %rbx, $GRID_Y, $GRID_B, $Y_B
	incq	%rbx
	cmpq	$GRID_COR_X_M1, %rbx
	jl	1b
	# Vertical borders
	movq	$Y_OFF, %rbx
	2:
	scall	putChar, $X_OFF_M1, %rbx, $GRID_L, $Y_B
	scall	putChar, $GRID_COR_X_M1, %rbx, $GRID_R, $Y_B
	incq	%rbx
	cmpq	$GRID_Y, %rbx
	jl	2b

	# Corners
	scall	putChar, $X_OFF_M1, $Y_OFF_M1, $GRID_TL, $Y_B
	scall	putChar, $GRID_COR_X_M1, $Y_OFF_M1, $GRID_TR, $Y_B
	scall	putChar, $X_OFF_M1, $GRID_Y, $GRID_BL, $Y_B
	scall	putChar, $GRID_COR_X_M1, $GRID_Y, $GRID_BR, $Y_B

	popq	%rbx	# restore rbx
	leave
	ret

# printString(int8 x, int8 y, int *string, int8 color)
# Prints a null terminated string beginning at x,y
printString:
	enter	$0, $0		# Prologue
	pushq	%r9		# Save r9 on stack so we can use it
	pushq	%rdi		# Save rdi on stack so we can use rdi with scas
	pushq	%rcx		# Save rcx on stack for scas

	xorq	%rcx, %rcx	# rcx = 0
	notq	%rcx		# rcx = -1
	movq	%rdx, %rdi	# Move address of string into rdi
	xorq	%rax, %rax	# rax = 0 (null)
	cld			# Set direction flag for low->high direction in memory
	repne	scasb		# Scan until zero is found in memory
	notq	%rcx		# Invert rcx
	decq	%rcx		# Decrement by one so we get length of string without null term.
	movq	%rcx, %r9	# Move stringlength into r9

	popq	%rcx		# Restore rcx
	popq	%rdi		# Restore rdi

	1:
		decq	%r9	# Decrement x
		pushq	%rdi	# Save old x
		leaq	(%rdi, %r9, 1), %rdi	# x = x + r9
		pushq	%rdx	# save string address on stack
		movb	(%rdx, %r9, 1), %dl
		scall	putChar
		popq	%rdx	# restore string address
		popq	%rdi	# restore initial x
		test	%r9, %r9
		jnz	1b

	popq	%r9		# Restore r9
	leave			# Epilogue
	ret			# Return to caller

# void printCorrect(int8 x, int8 y, int8 char, int8 color)
# Prints a char at 2*x+1, y followed by a space
printCorrect:
	enter	$0, $0
	shl	$1, %rdi	# x *= 2
	addq	$X_OFF, %rdi	# x += 1
	addq	$Y_OFF, %rsi	# y += 1
	scall	putChar		# Print the character

	# Space is not only necessary when using diff back color for snake than general back color
	incq	%rdi		# Increment 2*x+1
	movq	$0x20, %rdx	# Move "space" into rcx
	scall	putChar		# Print the space next to previous character

	leave
	ret			# Return to caller

# void printSnake()
# Prints the snake on the screen
printSnake:
	enter	$0, $0
	pushq	%r9		# Save r9 on stack so we can use r9
	pushq	%r8		# Save r8 on stack so we can use r8
	movzwq	(snakeSize), %r9	# Move snakeSize to r9
	movq	$snake, %r8	# Copy address of snake into r8
	movq	$SN_BODY, %rdx	# pass 'o' for putChar
	1:
		decw	%r9w	# Decrement size counter
		cmpw	$0, %r9w	# Compare r9 to 0
		je	2f	# If r9 = 0 jump to local 2
		jl	4f	# If r9 < 0 jump to local 4 (after head printed)
		3:
		movzb	(%r8, %r9, 2), %rdi	# move x position to rdi
		#incq	%rdi	# account for left vertical border
		movzb	1(%r8, %r9, 2), %rsi	# move y position to rsi
		#incq	%rsi	# account for horizontal top border
		scall	printCorrect, %rdi, %rsi, %rdx, $G_B # Print it
		jmp	1b	# Jump to local 1
	2:
	movq	$SN_HEAD, %rdx	# Move head symbol into rdx
	jmp	3b		# Jump back to local 3
	4:
	popq	%r8	# restore r8
	popq	%r9	# restore r9

	leave
	ret		# Return to caller

# void cls(int8 char, int8 color)
# Fills the screen with a char and color
fill:
	enter	$0, $0
	movq	%rdi, %rdx	# save parameters in appropriate registers for putChar
	movq	%rsi, %rcx	
	movq	$0, %rdi	# Start at 0,0
	movq	$0, %rsi

	# X-loop
	loopx:
		scall	putChar, %rdi, %rsi, %rdx, %rcx
		incq	%rdi
		cmpq	$80, %rdi
		jge	loopy
		jmp	loopx
	# Y-loop
	loopy:
		incq	%rsi
		cmpq	$25, %rsi
		jge	1f
		xor	%rdi, %rdi	# Clear rdi
		jmp	loopx
	1:
	leave
	ret
# void cls()
# Clears the screen
cls:
	enter	$0, $0
	movq	$0x48, %rdi
	movq	$0, %rsi
	call	fill
	leave
	ret

# void putDigit(int8 x, int8 y, int8 digit, int8 color)
#
# Writes a digit to x,y
putDigit:
	enter	$0, $0
	cmpq	$9, %rdx
	jg	1f
	addb	$'0, %dl
	call	putChar
	1:
	leave
	ret

# void putNum(int8 x, int8 y, int64 num, int8 color)
#
# Writes a number to the screen starting from coordinates (x, y), it will chop off at end of screen
putNum:
	enter	$0, $0
	movq	%rdx, %rax	# Move num to rax
	shl	$32, %rax	# Remove 32-63 bits from rax
	shr	$32, %rax	#

	shr	$32, %rdx	# Shift high bits (31-63) of rdx to the lower bits (0-31)
	
	pushq	%r9
	movq	$10, %r9
	divq	%r9		# Divide rax by 10, quotient in rax and remainder in rdx
	popq	%r9
	pushw	%dx		# Push digit (16-bit) to stack

	movq	%rax, %rdx	# Use quotient for next division

	test	%rax, %rax	# Use test instr. for zero flag on rax
	jz	1f		# If quotient is zero jump to local 1 (printing)
	call	putNum		# Recursion

	1:
		popw	%dx	# Pop latest digit into dl,
				# because this is also the argument for putChar
		# High order digits are on the top of the stack so print those first (as digit)
		# Perform a safe call to make it save registers
		scall	putDigit
		cmpb	$80, %dil	# Compare x to 80
		jge	2f	# If x >= 80 go to local 2 (epilogue)
		incb	%dil	# Increment dil for next char (lower order digit)
	2:
	leave
	ret
