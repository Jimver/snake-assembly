.macro	regPrint	reg, col, line
	pushq	\reg
	pushq	%rdx
	movq	8(%rsp), %rdx
	scall	putNum, \col, \line, %rdx, $W_B
	popq	%rdx
	popq	\reg
.endm

.macro	regPrintZero	reg, line
	pushq	\reg
	pushq	%rdx
	movq	8(%rsp), %rdx
	scall	putNum, $0, \line, %rdx, $W_B
	popq	%rdx
	popq	\reg
.endm

# void arrPrint(int *arp, int64 len, int64 line)
arrPrint:
	enter	$0, $0
	pushq	%rax
	pushq	%r9
	pushq	%rbx
	pushq	%r8
	movq	$0, %r9		# clear r9
	movq	%rdi, %rax
	movq	%rdi, %rbx
	addq	%rsi, %rbx
	1:
	movb	(%rax), %r8b
	andq	$0xFF, %r8	# Mask low order byte of r8
	scall	putNum, %r9, %rdx, %r8, $W_B	# print byte at rax
	incq	%rax	# increment rax
	addq	$4, %r9	# r9 += 4
	cmpq	%rbx, %rax
	jl	1b
	popq	%r8
	popq	%rbx
	popq	%r9
	popq	%rax
	leave
	ret
