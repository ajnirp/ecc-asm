.text

la $a0,a
la $a1,b
la $a2,c
jal multiply
b exit_pgm

# function mult begins here
multiply:
# arguments are:- a0 contains address of a, a1 of b and a2 of c
# multiplies a and b and puts the result in c

add $sp,$sp,-52
sw $t6,($sp)
sw $s1,4($sp)
sw $s2,8($sp)
sw $s3,12($sp)
sw $s4,16($sp)
sw $s5,20($sp)
sw $s6,24($sp)
sw $t0,28($sp)
sw $t1,32($sp)
sw $t2,36($sp)
sw $t3,40($sp)
sw $t4,44($sp)
sw $t5,48($sp)
# initialize variables
# pointer to a
move $s1,$a0
# pointer to b
move $s2,$a1
# pointer to c
move $s3,$a2

# initialize c to all zeroes and make pointer s3 point to the end of c
# iterator i
li $s4,0

loop_init:	beq $s4,16,exit_init		
		sw $0,($s3)
		add $s3,$s3,4
		add $s4,$s4,1
		b loop_init
exit_init:

# make pointers s1 and s2 point to the end of a and b resp.
li $s4,0

add $s1,$s1,32
add $s2,$s2,32

# copy s2 to t6
move $t6,$s2

# reset s4 to 0
li $s4,0

# the outer loop
loop1:	beq $s4,8,exit1
	# s6 stores U, initialise to 0
	li $s6,0
	# iterator j, initialise to 0
	li $s5,0
	# s2 stores B[j], so reset
	move $s2,$t6
	add $s2,$s2,-4
	
	# s3 stores C[i] and s1 stores A[i] currently
	addi $s1,$s1,-4
	addi $s3,$s3,-4
	# initialize t4 to s3
	move $t4,$s3
	# the inner loop
	loop2:	beq $s5,8,exit2
		# load A[i] into t0
		lw $t0,($s1)
		# load B[j] into t1
		lw $t1,($s2)
		# multipliy t0 and t1
		multu $t0,$t1
		# move from hi to t2
		mfhi $t2
		# move from lo to t3, t3 will store V
		mflo $t3
		# add s6 and t3 and store in t3
		addu $t3,$t3,$s6
		# check for overflow
		if_ovfl: bleu $s6,$t3,e_ovfl
		# add 1 to t2
		addi $t2,$t2,1
		e_ovfl:
		# load C[i+j] in t5
		lw $t5,($t4)
		# add t3 and t5 and store in t3
		addu $t3,$t3,$t5
		# check for overflow
		if_ovfl2: bleu $t5,$t3,e_ovfl2
		# add 1 to t2
		addi $t2,$t2,1
		e_ovfl2:
		# store t3 in C[i+j]
		sw $t3,($t4)
		# update U
		move $s6,$t2
		# increase j
		addi $s5,$s5,1
		# increase pointer to C[i+j]
		add $t4,$t4,-4
		# increase pointer to B[j]
		add $s2,$s2,-4
		b loop2
	exit2:
	# t4 points to C[i+t]
	sw $s6,($t4)
	# increase i
	addi $s4,$s4,1
	b loop1
exit1:

lw $t6,($sp)
lw $s1,4($sp)
lw $s2,8($sp)
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $s6,24($sp)
lw $t0,28($sp)
lw $t1,32($sp)
lw $t2,36($sp)
lw $t3,40($sp)
lw $t4,44($sp)
lw $t5,48($sp)
add $sp,$sp,52

# pointer to c in v0
move $v0,$a2

jr $ra

exit_pgm:

.data
a: .word 0 0 0 0 0 0 0 0xffffffff
b: .word 0 0 0 0 0 0 0 0xffffffff
c: .space 64
