# General functions

# int64	getScore()
# Gets the score based on the length of the snake
getScore:
	enter	$0, $0

	# TODO return the score as snakeSize - INIT_SIZE
	# Perform snakeSize-INIT_SIZE
	movzwq	(snakeSize), %rax
	subq	$INIT_SIZE, %rax
	movw	%ax, (last)	# save score in memory

	leave
	ret

# int16 getTimer()	returns in (r)ax as 16-bit word
getTimer:
	enter	$0,$0
	
	xorq	%rax, %rax	# Clear rax
	outb	%al, $PIT_MC	# Send low byte(00000000b)to PIT mode/command register to latch counter

	inb	$PIT_CH_0, %al	# Get low byte from channel 0
	shl	$8, %ax		# Shift low byte into high byte
	inb	$PIT_CH_0, %al	# Get high byte from channel 0 into low byte
	xchgb	%al, %ah	# Swap low and high byte for right order
	# By now all data is read from channel 0 so the counter will be released again	

	leave
	ret

# bool check_element(int16 element int *arp, int64 length)
# Checks from *arp length times if there is an element in the array
# Length is in elements (so in words)
check_element_w:
	enter	$0, $0
	pushq	%rbx	# save registers so we can use them
	pushq	%r8

	decq	%rdx		# get address of last element
	shl	$1, %rdx	# get array size in bytes

	movq	$0, %rax	# standard return value is 0
	xorq	%rbx, %rbx	# start at first element

	1:
		movzw	(%rsi, %rbx, 1), %r8	# move the element to be compared to r8
		cmpq	%rdi, %r8	# Compare the two words
		je	2f		# Match found! go to local 2
		addq	$2, %rbx	# go to next element
		cmpq	%rdx, %rbx	# check if at last element
		jg	3f		# if last element is checked go to epilogue
		jmp	1b		# otherwise repeat the loop
	2:
		movq	$1, %rax	# move 1 into return value
		jmp	3f		# jump to local 3
	3:
	popq	%r8	# restore registers
	popq	%rbx
	leave
	ret

# void shift_array (int *ar, int64 shift, int64 length, int8 dir)
# Shift memory from *ar shift amount
# if dir = 1 shift down in memory
# if dir = 0 shift up in memory
# This shift will chop off begin/end of array
shift_array:
	enter	$0, $0
	pushq	%r9	# Save r9 on stack so we can use it
	pushq	%r8	# Save r8 on stack so we can use it
	pushq	%rax	# Save rax on stack so we can use it
	movq	%rdx, %rax
	test	%rcx, %rcx
	jz	3f
	1:
		# Down in memory
		xorq	%rdx, %rdx	# rdx = 0
		addq	%rsi, %rdx
		2:
		movb	(%rdi, %rdx, 1), %r9b	# Move byte in memory to r9b
		andq	$0xFF, %r9	# Mask low order byte of r9
		movq	%rdx, %r8	# Move rdx to r8
		subq	%rsi, %r8	# Subtract shift for new address
		movb	%r9b, (%rdi, %r8, 1)	# Move data into memory
		incq	%rdx
		cmpq	%rax, %rdx
		jge	5f
		jmp	2b
	3:
		# Up in memory
		subq	%rsi, %rdx	# subtract shift from that so we are at the byte that
					# will be at the last place when shifted
		4:
		decq	%rdx		# First decrement rdx by one so we are at that last byte
		movb	(%rdi, %rdx, 1), %r9b	# Move byte from memory into r9
		andq	$0xFF, %r9	# Mask low order byte of r9
		movq	%rdx, %r8	# Move rdx to r8
		addq	%rsi, %r8	# Add shift for new address
		movb	%r9b, (%rdi, %r8, 1)	# Move r9 into new address
		test	%rdx, %rdx
		jnz	4b	# Repeat until rdx = 0
		jmp	5f	# Jump to end
	5:
	popq	%rax	# Restore rax
	popq	%r8	# Restore r8
	popq	%r9	# Restore r9
	leave		# Epilogue
	ret		# Return to caller

# bool array_comp (int *ar1, int *ar2, int amount, int scale) rdi rsi rdx rcx
# Start from *ar1+amount*scale-scale and *ar2+amount*scale-scale 
# and loops all the way to *ar1 and *ar2
# by "scale" steps
# Returns 1 (true) if equal otherwise 0 (false) in rax
array_comp:
	pushq	%rbp	# make stack frame
	movq	%rsp, %rbp

	pushq	%r9	# save these register on the stack so we can use them
	pushq	%r8
	pushq	%rbx

	movq	%rcx, %r8	# store scale in r8 so scale is preserved in r8 when using rcx
	decq	%rdx	# decrement amount by one to acces the last element in the array

	comp_loop:
		cmpq	$-1, %rdx
		je	comp_equal

		leascl	%rdi, %rdx, %r8, %r9
		movscl	(%r9), b, %r8

		leascl	%rsi, %rdx, %r8, %r9
		movscl	(%r9), c, %r8

		decq	%rdx
		cmpq	%rbx, %rcx
		jne	comp_nequal
		jmp	comp_loop

	comp_nequal:
		movq	$0, %rax
		jmp	comp_end
	comp_equal:
		movq	$1, %rax
		jmp	comp_end

	comp_end:
	popq	%rbx	# restore saved registers
	popq	%r8
	popq	%r9
	
	movq	%rbp, %rsp	# destroy stack frame
	popq	%rbp
	ret
