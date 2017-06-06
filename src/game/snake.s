# Functions used for game mechanics

populate_empty:
	enter	$0, $0
	pushq	%rbx	# push registers for use
	pushq	%r9
	pushq	%r8
	pushq	%rcx

	# TODO populate the empty array depending on snake array
	movb	$GRID, %r9b
	andq	$0xFF, %r9
	xorq	%r8, %r8	# clear registers
	xorq	%rbx, %rbx
	xorq	%rcx, %rcx

	movzwq	(snakeSize), %rdx	# move snakeSize into rdx for check_element

	# X-loop
	loopx_e:
		xorq	%rdi, %rdi	# clear rdi
		movb	%r8b, %dil	# move x into low order byte pos.
		shl	$8, %rdi	# shift x to high order byte pos.
		movb	%cl, %dil	# mov y into low order byte pos
		mcall	check_element_w, %rdi, $snake
		cmpq	$1, %rax
		je	3f
			#regPrintZero %rdi, $19
			# Add element to empty
			movw	%di, empty(%rbx)
			addq	$2, %rbx	# for next element
		3:
		incq	%r8
		cmpq	%r9, %r8
		jge	loopy_e
		jmp	loopx_e
	# Y-loop
	loopy_e:
		incq	%rcx
		cmpq	%r9, %rcx
		jge	1f
		xor	%r8, %r8	# Clear r8
		jmp	loopx_e
	1:
		xorq	%rax, %rax	# return value of rax = 0
		jmp	2f
	2:
	movw	%bx, (emptySize)
	popq	%rcx	# restore registers
	popq	%r8
	popq	%r9
	popq	%rbx
	leave
	ret

# Check if food has been hit and adds new element to snake if hit returns 1 if game win
check_food:
	enter	$0, $0
	pushq	%rbx

	movzwq	(foodPos), %rbx	# move food-coords in bx
	movzwq	(snake), %rax	# move food-coords in ax

	cmpw	%ax, %bx	# compare coords
	jne	1f
		# If Head = foodPos
		pushq	%r9	# push registers for use
		pushq	%rcx
		movzwq	(snakeSize), %r9	# move snakeSize into r9
		incq	%r9	# increment snakeSize
		movw	%r9w, (snakeSize)	# move value back into memory

		# Move lastElement into last element of snake
		decq	%r9	# get last element address
		shl	$1, %r9	# multiply by 2 because 2-dimensional
		movzwq	(lastElement), %rbx	# move lastElement zero-extended to rbx
		movw	%bx, snake(%r9)	# move lastElement into last element of snake

		scall	populate_empty # needs to happen after food eaten

		movzwq	(emptySize), %r9

		#regPrintZero	%r9, $18
		test	%r9, %r9
		jnz	2f
			# No more free spaces so go to winning screen
			movq	$1, %rax
			popq	%rcx
			popq	%r9
			jmp	3f
		2:
		popq	%rcx	# restore registers
		popq	%r9

		call	food_spawner
		jmp	3f
	1:
	xorq	%rax, %rax	# return value = 0
	jmp	3f
	3:
	popq	%rbx
	leave
	ret

# Check if snake hit itself returns 1 if yes otherwise 0 in rax
check_self:
	enter	$0, $0
	movzwq	(snake), %rdi	# move head into rdi
	movzwq	(snakeSize), %rdx	# move snake size into rdx
	decq	%rdx	# don't compare first element
	movq	$snake, %rsi
	addq	$2, %rsi
	call	check_element_w	# call the comparison

	# debug
	test	%rax, %rax
	jz	4f
	#scall	printString, $0, $10, $bitself, $W_B
	jmp	5f
	4:
	#scall	printString, $0, $10, $notbit, $W_B
	5:
	# end debug

	leave
	ret

/*
	enter	$0, $0
	pushq	%rbx	# save registers so we can use them
	pushq	%r9
	pushq	%r8
	pushq	%rcx

	movzw	(snakeSize), %rcx
	shl	$1, %rcx	# get array size in bytes
	subq	$2, %rcx	# neglect first element

	movq	$0, %rax	# standard return value is 0
	movq	$2, %rbx	# start at second element

	movzw	(snake), %r9
	1:
		movzw	snake(%rbx), %r8
		cmpq	%r9, %r8
		je	2f
		addq	$2, %rbx
		cmpq	%rcx, %rbx
		jg	3f
		jmp	1b
	2:
		movq	$1, %rax
		jmp	3f
	3:
	popq	%rcx	# restore registers
	popq	%r8
	popq	%r9
	popq	%rbx

	# debug
	test	%rax, %rax
	jz	4f
	scall	printString, $0, $10, $bitself, $W_B
	jmp	5f
	4:
	scall	printString, $0, $10, $notbit, $W_B
	5:
	# end debug
	leave
	ret
*/

# Check for boundaries return 1 if hit otherwise 0 in rax
check_bound:
	enter	$0, $0
	pushq	%rbx	# push rbx so we can use it

	movq	$0 ,%rax	# standard return value is 0
	movzb	(snake), %rbx
	cmpq	$GRID_M1, %rbx
	jle	1f
		# hit right/left border
		#scall	printString, $0, $5, $vertstr, $W_B
		movq	$1, %rax
		# TODO
		jmp	4f
	1:
	movzb	(snake+1), %rbx
	cmpq	$GRID_M1, %rbx
	jle	4f
		# hit bottom/top border
		#scall	printString, $0, $5, $horstr, $W_B
		movq	$1, %rax
		# TODO
		jmp	4f
	4:
	popq	%rbx	# restore rbx
	leave
	ret

# Moves the snake one position depending on direction
move_snake:
	enter	$0, $0
	pushq	%rax
	pushq	%rbx
	movzwq	(snakeSize), %rdx	# get snake length
	shl	$1, %rdx	# multiply by 2 to get array length

	# Move last element of snake into lastElement dedicated to check_food
	pushq	%r9	# push r9 for use
	subq	$2, %rdx # get last element address of snake
	movzwq	snake(%rdx), %r9	# move it into r9
	movw	%r9w, (lastElement)	# move it into lastElement-x
	popq	%r9	# restore r9

	addq	$2, %rdx	# increment again to get total size of array

	scall	shift_array, $snake, $2, %rdx, $0
	movzb	(dir), %rax
	#regPrintZero %rax, $5
	cmpb	$0, %al
	jne	1f
		# If up
		movzb	(snake+1), %rbx
		decb	%bl	# decrement because horizontal lines go up as they decrease
		movb	%bl, (snake+1)
		jmp	4f
	1:
	cmpb	$1, %al
	jne	2f
		# If down
		movzb	(snake+1), %rbx
		incb	%bl	# increment because horizontal lines go down as they increase
		movb	%bl, (snake+1)
		jmp	4f
	2:
	cmpb	$2, %al
	jne	3f
		# If left
		movzb	(snake), %rbx
		decb	%bl	# More intuitive than vertical
		movb	%bl, (snake)
		jmp	4f
	3:
		# If right
		movzb	(snake), %rbx
		incb	%bl
		movb	%bl, (snake)
		jmp	4f
	4:
	popq	%rbx
	popq	%rax
	leave
	ret
