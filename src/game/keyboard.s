# Functions for input from keyboard

# void ps2_poll()
# Returns 1 if there is a scancode in the "buffer"
ps2_poll:
	enter	$0, $0
	movzb	(read_bytes), %rax
	test	%rax, %rax
	jz	1f
	movq	$1, %rax
	1:
	leave
	ret

# void setDir ()
setDir:
	enter	$0, $0
	pushq	%rbx
	movzbq	(dir), %rbx
	mcall	array_comp, $UP_ARROW, $read_bytes, $1, $1
	test	%rax, %rax
	jz	1f
		cmpq	$1, %rbx	# protect against illegal direction change
		je	4f
		movb	$0, (dir)
		jmp	4f
	1:
	mcall	array_comp, $DOWN_ARROW, $read_bytes, $1, $1
	test	%rax, %rax
	jz	2f
		cmpq	$0, %rbx	# protect against illegal direction change
		je	4f
		movb	$1, (dir)
		jmp	4f
	2:
	mcall	array_comp, $LEFT_ARROW, $read_bytes, $1, $1
	test	%rax, %rax
	jz	3f
		cmpq	$3, %rbx	# protect against illegal direction change
		je	4f
		movb	$2, (dir)
		jmp	4f
	3:
	mcall	array_comp, $RIGHT_ARROW, $read_bytes, $1, $1
	test	%rax, %rax
	jz	4f
		cmpq	$2, %rbx	# protect against illegal direction change
		je	4f
		movb	$3, (dir)
		jmp	4f
	4:
	popq	%rbx
	leave
	ret
