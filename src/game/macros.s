# Some macros

# Perform a "safe" call
# Macro for label and passing arguments in registers
.macro	scall label, aa=%rdi, ab=%rsi, ac=%rdx, ad=%rcx, ae=%r8, af=%r9
	pushaq
	movq	\aa, %rdi
	movq	\ab, %rsi
	movq	\ac, %rdx
	movq	\ad, %rcx
	movq	\ae, %r8
	movq	\af, %r9
	call	\label
	popaq
.endm

.macro	pushar
	pushq	%rdi
	pushq	%rsi
	pushq	%rdx
	pushq	%rcx
	pushq	%rbx
	pushq	%r9
	pushq	%r8
.endm

.macro	popar
	popq	%r8
	popq	%r9
	popq	%rbx
	popq	%rcx
	popq	%rdx
	popq	%rsi
	popq	%rdi
.endm

# Perform a call
# Macro for label and passing arguments in registers
.macro	mcall label, aa=%rdi, ab=%rsi, ac=%rdx, ad=%rcx, ae=%r8, af=%r9
	pushar
	movq	\aa, %rdi
	movq	\ab, %rsi
	movq	\ac, %rdx
	movq	\ad, %rcx
	movq	\ae, %r8
	movq	\af, %r9
	call	\label
	popar
.endm

# Macro for passing the scale to memory addressing
.macro leascl base, index, scale, dest
	cmpq	$1, \scale
	jne	2f
		leaq	(\base, \index, 1),\dest #leascl %rdi,%rsi,$1,%rax="leaq (%rdi, %rsi, 1),%rax"
		jmp	9f
	2:
	cmpq	$2, \scale
	jne	4f
		leaq	(\base, \index, 2),\dest #leascl %rdi,%rsi,$2,%rax="leaq (%rdi, %rsi, 2),%rax"
		jmp	9f
	4:
	cmpq	$4, \scale
	jne	8f
		leaq	(\base, \index, 4),\dest #leascl %rdi,%rsi,$4,%rax="leaq (%rdi, %rsi, 4),%rax"
		jmp	9f
	8:
	cmpq	$8, \scale
	jne	9f
		leaq	(\base, \index, 8),\dest #leascl %rdi,%rsi,$8,%rax="leaq (%rdi, %rsi, 8),%rax"
		jmp	9f
	9:
.endm

# Macro for moving depening on scale
.macro movscl sc, dest, scale
	cmpq	$1, \scale
	jne	2f
		movzb	\sc, %r\dest\()x # so sc=(%rax), dest=b, scale=1 would be "movb (%rax), %bl"
		jmp	9f
	2:
	cmpq	$2, \scale
	jne	4f
		movzw	\sc, %r\dest\()x # so sc=(%rax), dest=b, scale=2 would be "movw (%rax), %bx"
		jmp	9f
	4:
	cmpq	$4, \scale
	jne	8f
		movl	\sc, %e\dest\()x # so sc=(%rax), dest=b, scale=4 would be "movl (%rax), %ebx"
		jmp	9f
	8:
	cmpq	$8, \scale
	jne	9f
		movq	\sc, %r\dest\()x # so sc=(%rax), dest=b, scale=8 would be "movq (%rax), %rbx"
		jmp	9f
	9:
.endm
