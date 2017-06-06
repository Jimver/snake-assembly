# Subroutines for randomness/propability

# Sets the seed word in game data
setSeed:
	enter	$0, $0

	call	getTimer
	movw	%ax, (seed)

	leave
	ret

# int64 randomRange (int64 input, int32 seedMax, int64 max)
# Get a random number from 0 - and including max
randomRange:
	enter	$0, $0

	# TODO get a random number
	movq	%rdi, %rax	# move parameter into rax for multiplication
	mulq	%rdx		# multiply by max value
	# TODO div rax by max
	movq	%rax, %rdx	# Move
	shr	$32, %rdx	# Shift high order long to low order long in rdx
	divl	%esi		# Perform division
	# Quotient is now in rax

	leave
	ret
food_spawner:
	enter	$0, $0

	# TODO spawn food at a random position (maybe use array with all free spaces??)
	# Free spaces in: empty
	movzwq	(emptySize), %rdx	# move emptySize into argument
	movzwq	(seed), %rdi
	mcall	randomRange, %rdi, $65535, %rdx
	movzwq	empty(%rax), %rdi
	movw	%di, (foodPos)

	#scall	printString, $0, $17, $spawn, $W_B

	leave
	ret
