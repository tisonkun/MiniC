	.comm	g0,100,4
	.comm	g1,4,4
	.comm	g2,100,4
	.text
	.align	2
	.global	main
	.type	main, @function
main:
	add	sp,sp,-768
	sw	ra,764(sp)
	sw	s1,0(sp)
	sw	s4,4(sp)
	sw	s5,8(sp)
	sw	s3,12(sp)
	sw	s2,16(sp)
	sw	s0,20(sp)
	lui	a5,%hi(g2)
	add	s0,a5,%lo(g2)
	add	s1,sp,24
	lui	a5,%hi(g0)
	add	s2,a5,%lo(g0)
	li	a4,0
	li	a4,0
	add	a5,s2,a4
	sw	a4,0(a5)
	li	s3,1
.l11:
	slt	t0,s3,25
	beq	t0,zero,.l12
	li	s4,0
.l13:
	slt	t0,s4,100
	beq	t0,zero,.l14
	sll	t0,s4,2
	li	a4,0
	add	a5,s1,t0
	sw	a4,0(a5)
	add	t0,s4,1
	mv	s4,t0
	j	.l13
.l14:
	li	s4,0
.l15:
	slt	t0,s4,s3
	beq	t0,zero,.l16
	li	s5,0
.l17:
	add	t0,s4,1
	slt	t1,s5,t0
	beq	t1,zero,.l18
	sll	t1,s4,2
	add	a5,s2,t1
	lw	t0,0(a5)
	sll	t1,s5,2
	add	a5,s2,t1
	lw	t2,0(a5)
	mv	a0,t0
	mv	a1,t2
	call	_xor
	mv	t1,a0
	sll	t0,t1,2
	li	a4,1
	add	a5,s1,t0
	sw	a4,0(a5)
	add	t1,s5,1
	mv	s5,t1
	j	.l17
.l18:
	add	t1,s4,1
	mv	s4,t1
	j	.l15
.l16:
	li	s4,0
	li	t1,0
.l19:
	slt	t0,s4,100
	seqz	t2,t1
	and	t3,t0,t2
	snez	t3,t3
	beq	t3,zero,.l20
	sll	t0,s4,2
	add	a5,s1,t0
	lw	t3,0(a5)
	seqz	t0,t3
	beq	t0,zero,.l21
	sll	t0,s3,2
	add	a5,s2,t0
	sw	s4,0(a5)
	li	t1,1
.l21:
	add	t0,s4,1
	mv	s4,t0
	j	.l19
.l20:
	add	t1,s3,1
	mv	s3,t1
	j	.l11
.l12:
	call	getint
	mv	t1,a0
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	mv	t0,t1
	li	s2,1
.l22:
	li	a4,0
	xor	t1,t0,a4
	snez	t1,t1
	beq	t1,zero,.l23
	li	s3,0
.l24:
	slt	t1,s3,t0
	beq	t1,zero,.l25
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	call	getint
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	mv	t1,a0
	sll	t3,s3,2
	add	a5,s0,t3
	sw	t1,0(a5)
	add	t1,s3,1
	mv	s3,t1
	j	.l24
.l25:
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	mv	a0,s2
	call	putGame
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	add	t1,s2,1
	mv	s2,t1
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	call	test
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	mv	t1,a0
	beq	t1,zero,.l26
	li	s3,0
	li	s1,0
.l27:
	slt	t1,s3,t0
	seqz	t3,s1
	and	t2,t1,t3
	snez	t2,t2
	beq	t2,zero,.l35
	sll	t1,s3,2
	add	a5,s0,t1
	lw	t3,0(a5)
	beq	t3,zero,.l29
	add	t1,s3,1
	mv	s4,t1
.l30:
	slt	t1,s4,t0
	seqz	t3,s1
	and	t2,t1,t3
	snez	t2,t2
	beq	t2,zero,.l29
	mv	s5,s4
.l32:
	slt	t1,s5,t0
	seqz	t3,s1
	and	t2,t1,t3
	snez	t2,t2
	beq	t2,zero,.l33
	sll	t1,s3,2
	add	a5,s0,t1
	lw	t3,0(a5)
	li	a4,1
	sub	t1,t3,a4
	sll	t3,s3,2
	add	a5,s0,t3
	sw	t1,0(a5)
	sll	t1,s4,2
	add	a5,s0,t1
	lw	t3,0(a5)
	add	t1,t3,1
	sll	t3,s4,2
	add	a5,s0,t3
	sw	t1,0(a5)
	sll	t1,s5,2
	add	a5,s0,t1
	lw	t3,0(a5)
	add	t1,t3,1
	sll	t3,s5,2
	add	a5,s0,t3
	sw	t1,0(a5)
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	call	test
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	mv	t1,a0
	seqz	t3,t1
	beq	t3,zero,.l34
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	mv	a0,s3
	call	putint
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	li	a0,32
	call	putchar
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	mv	a0,s4
	call	putint
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	li	a0,32
	call	putchar
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	mv	a0,s5
	call	putint
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	li	a0,10
	call	putchar
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	li	s1,1
.l34:
	sll	t1,s3,2
	add	a5,s0,t1
	lw	t3,0(a5)
	add	t1,t3,1
	sll	t3,s3,2
	add	a5,s0,t3
	sw	t1,0(a5)
	sll	t1,s4,2
	add	a5,s0,t1
	lw	t3,0(a5)
	li	a4,1
	sub	t1,t3,a4
	sll	t3,s4,2
	add	a5,s0,t3
	sw	t1,0(a5)
	sll	t1,s5,2
	add	a5,s0,t1
	lw	t3,0(a5)
	li	a4,1
	sub	t1,t3,a4
	sll	t3,s5,2
	add	a5,s0,t3
	sw	t1,0(a5)
	add	t1,s5,1
	mv	s5,t1
	j	.l32
.l33:
	add	t1,s4,1
	mv	s4,t1
	j	.l30
.l29:
	add	t1,s3,1
	mv	s3,t1
	j	.l27
.l26:
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	li	a0,-1
	call	putint
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	li	a0,32
	call	putchar
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	li	a0,-1
	call	putint
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	li	a0,32
	call	putchar
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	li	a0,-1
	call	putint
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	li	a0,10
	call	putchar
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
.l35:
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	call	getint
	lui	a5,%hi(g1)
	lw	t0,%lo(g1)(a5)
	mv	t1,a0
	mv	t0,t1
	j	.l22
.l23:
	lui	a5,%hi(g1)
	sw	t0,%lo(g1)(a5)
	li	a0,0
	lw	s1,0(sp)
	lw	s4,4(sp)
	lw	s5,8(sp)
	lw	s3,12(sp)
	lw	s2,16(sp)
	lw	s0,20(sp)
	lw	ra,764(sp)
	add	sp,sp,768
	jr	ra
	.size	main, .-main
	.text
	.align	2
	.global	putGame
	.type	putGame, @function
putGame:
	add	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,0(sp)
	mv	s0,a0
	li	a0,71
	call	putchar
	li	a0,97
	call	putchar
	li	a0,109
	call	putchar
	li	a0,101
	call	putchar
	li	a0,32
	call	putchar
	mv	a0,s0
	call	putint
	li	a0,58
	call	putchar
	li	a0,32
	call	putchar
	li	a0,0
	lw	s0,0(sp)
	lw	ra,12(sp)
	add	sp,sp,16
	jr	ra
	.size	putGame, .-putGame
	.text
	.align	2
	.global	_xor
	.type	_xor, @function
_xor:
	add	sp,sp,-400
	sw	ra,396(sp)
	sw	s1,0(sp)
	sw	s2,4(sp)
	sw	s0,8(sp)
	mv	t0,a0
	mv	s2,a1
	add	s1,sp,20
	add	s0,sp,180
	mv	a0,t0
	mv	a1,s1
	call	_2
	mv	a0,s2
	mv	a1,s0
	call	_2
	li	t0,39
	mv	t1,t0
	li	t0,0
.l4:
	li	a4,-1
	xor	t2,t1,a4
	snez	t2,t2
	beq	t2,zero,.l5
	sll	t2,t1,2
	add	a5,s1,t2
	lw	t3,0(a5)
	sll	t2,t1,2
	add	a5,s0,t2
	lw	t4,0(a5)
	add	t2,t3,t4
	li	a4,1
	xor	t4,t2,a4
	seqz	t4,t4
	beq	t4,zero,.l6
	li	a4,2
	mul	t4,t0,a4
	add	t2,t4,1
	mv	t0,t2
	j	.l7
.l6:
	li	a4,2
	mul	t4,t0,a4
	mv	t0,t4
.l7:
	li	a4,1
	sub	t4,t1,a4
	mv	t1,t4
	j	.l4
.l5:
	mv	a0,t0
	lw	s1,0(sp)
	lw	s2,4(sp)
	lw	s0,8(sp)
	lw	ra,396(sp)
	add	sp,sp,400
	jr	ra
	.size	_xor, .-_xor
	.text
	.align	2
	.global	test
	.type	test, @function
test:
	add	sp,sp,-80
	sw	ra,76(sp)
	sw	s1,0(sp)
	sw	s2,4(sp)
	sw	s0,8(sp)
	lui	a5,%hi(g0)
	add	s1,a5,%lo(g0)
	lui	a5,%hi(g1)
	lw	t1,%lo(g1)(a5)
	lui	a5,%hi(g2)
	add	s0,a5,%lo(g2)
	li	t0,0
	li	s2,0
.l8:
	slt	t2,s2,t1
	beq	t2,zero,.l9
	sll	t2,s2,2
	add	a5,s0,t2
	lw	t3,0(a5)
	li	a4,2
	rem	t2,t3,a4
	li	a4,1
	xor	t3,t2,a4
	seqz	t3,t3
	beq	t3,zero,.l10
	sub	t3,t1,s2
	li	a4,1
	sub	t3,t3,a4
	sub	t3,t1,s2
	li	a4,1
	sub	t3,t3,a4
	sll	t2,t3,2
	add	a5,s1,t2
	lw	t3,0(a5)
	sw	t0,12(sp)
	lui	a5,%hi(g1)
	sw	t1,%lo(g1)(a5)
	mv	a0,t0
	mv	a1,t3
	call	_xor
	lw	t0,12(sp)
	lui	a5,%hi(g1)
	lw	t1,%lo(g1)(a5)
	mv	t3,a0
	mv	t0,t3
.l10:
	add	t3,s2,1
	mv	s2,t3
	j	.l8
.l9:
	lui	a5,%hi(g1)
	sw	t1,%lo(g1)(a5)
	mv	a0,t0
	lw	s1,0(sp)
	lw	s2,4(sp)
	lw	s0,8(sp)
	lw	ra,76(sp)
	add	sp,sp,80
	jr	ra
	.size	test, .-test
	.text
	.align	2
	.global	_2
	.type	_2, @function
_2:
	add	sp,sp,-64
	sw	ra,60(sp)
	mv	t2,a0
	mv	t1,a1
	li	t0,0
.l0:
	li	a4,0
	xor	t3,t2,a4
	snez	t3,t3
	beq	t3,zero,.l1
	li	a4,2
	rem	t3,t2,a4
	sll	t4,t0,2
	add	a5,t1,t4
	sw	t3,0(a5)
	add	t4,t0,1
	mv	t0,t4
	li	a4,2
	div	t4,t2,a4
	mv	t2,t4
	j	.l0
.l1:
	mv	t4,t0
.l2:
	slt	t2,t4,40
	beq	t2,zero,.l3
	sll	t2,t4,2
	li	a4,0
	add	a5,t1,t2
	sw	a4,0(a5)
	add	t2,t4,1
	mv	t4,t2
	j	.l2
.l3:
	mv	a0,t0
	lw	ra,60(sp)
	add	sp,sp,64
	jr	ra
	.size	_2, .-_2
