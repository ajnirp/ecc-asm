.text

b test_exponentiate
#b display_p_plus_one_by_four
#b test_srl
#b test_sqrt

# Tonelli-Shanks algo to find sqrt where S = 1
# arguments are: a0 points to n
# returns: v0 points to the negative sqrt of n
#          v1 points to the positive sqrt of n
sqrt:

add $sp, $sp, -24
sw $t0, ($sp)
sw $t1, 4($sp)
sw $a0, 8($sp)
sw $a1, 12($sp)
sw $a2, 16($sp)
sw $ra, 20($sp)

move $t0, $a0
move $t1, $a1

# first we find the positive square root as n ^ (p_plus_one_by_four)
la $a0, prime
la $a1, const_one # exponent = (p+1)/4
#la $a2, temp1
jal exponentiate # this gives the positive square root

# now we store the positive square root in v1
# copy the contents of the address pointed to by v0 to the contents of the address pointed to by v1

lw $t0, ($a2)
sw $t0, ($v0)
lw $t0, 4($a2)
sw $t0, 4($v0)
lw $t0, 8($a2)
sw $t0, 8($v0)
lw $t0, 12($a2)
sw $t0, 12($v0)
lw $t0, 16($a2)
sw $t0, 16($v0)
lw $t0, 20($a2)
sw $t0, 20($v0)
lw $t0, 24($a2)
sw $t0, 24($v0)
lw $t0, 28($a2)
sw $t0, 28($v0)

# then negate v0 to find the negative square root
# to negate, we subtract v0 from const_zero
la $a0, const_zero
move $a1, $v0
la $a2, temp2 # used to hold the result of the subtraction
jal subtraction
# copy the contents of the address pointed to by a2 to the contents of the address pointed to by v0

lw $t0, ($a2)
sw $t0, ($v0)
lw $t0, 4($a2)
sw $t0, 4($v0)
lw $t0, 8($a2)
sw $t0, 8($v0)
lw $t0, 12($a2)
sw $t0, 12($v0)
lw $t0, 16($a2)
sw $t0, 16($v0)
lw $t0, 20($a2)
sw $t0, 20($v0)
lw $t0, 24($a2)
sw $t0, 24($v0)
lw $t0, 28($a2)
sw $t0, 28($v0)

# now v0 = negative square root

lw $t0, ($sp)
lw $t1, 4($sp)
lw $a0, 8($sp)
lw $a1, 12($sp)
lw $a2, 16($sp)
lw $ra, 20($sp)
add $sp, $sp, 24

jr $ra



##########################################################

#exponentiate function begins here
exponentiate:
# arguments:
#    a0 points to the mantissa and a1 points to the exponent
#    a2 points to the space for the result
# return value: v0 points to the filled up result
# side effects - fills up the 8 word array pointed to by a2
add $sp, $sp, -20
sw $t0, ($sp)
sw $t1, 4($sp)
sw $a0, 8($sp)
sw $a1, 12($sp)
sw $ra, 16($sp)

# exponent is either 0, 1 or >= 2
move $t0,$a0
move $a0,$a1
la $a1,const_one
jal isGreater # compare exponent and 1
move $a1, $a0 # restore value of a1
move $a0, $t0 # restore value of a0
bgez $v0,exponent_is_not_zero
exponent_is_zero:
# simply return 1
la $a2, const_one
la $v0, const_one
b exit_exp
exponent_is_not_zero:
# exponent is either 1 or >= 2
beq $v0, 1, exponent_is_gt_one
# return mantissa
lw $t0, ($a0)
sw $t0, ($a2)
lw $t0, 4($a0)
sw $t0, 4($a2)
lw $t0, 8($a0)
sw $t0, 8($a2)
lw $t0, 12($a0)
sw $t0, 12($a2)
lw $t0, 16($a0)
sw $t0, 16($a2)
lw $t0, 20($a0)
sw $t0, 20($a2)
lw $t0, 24($a0)
sw $t0, 24($a2)
lw $t0, 28($a0)
sw $t0, 28($a2)
move $v0, $a2
b exit_exp

exponent_is_gt_one:

# first check if exponent is odd or even
lw $t0, 28($a1)
and $t0, $t0, 1
beq $t0, 1, exponent_odd

exponent_even:

# first, save a0 and a1 in t0 and t1 respectively
move $t0, $a0
move $t1, $a1

# divide exponent by 2
move $a0, $a1
jal shiftRightLogical

# now a1 has been shifted right by one bit
# recursive call
move $a0, $t0 # now a0 = mantissa again
la $a2, exp_result
jal exponentiate

# now square the recursive call result
move $a0, $v0
move $a1, $v0
la $a2, c
jal multiply

# now find (result of multiplication) % p
move $a0, $v0
jal mod # the result of mod is stored at sum+32
# now we have our answer
b exit_exp

exponent_odd:

# first, save a0 and a1 in t0 and t1 respectively
move $t0, $a0

move $t1, $a1

# shift a1 right
# b/2
move $a0, $a1
jal shiftRightLogical

# now do a recursive call
# (a ^ b/2)mod p
move $a0, $t0 # now a0 = mantissa again, and a1 has been shifted right
la $a2, exp_result
jal exponentiate

# now square the result of the recursive call
# ((a ^ b/2) mod p)^2
move $a0, $v0
move $a1, $v0
la $a2, c
jal multiply

# now reduce the result mod p
# ((a ^ b/2) mod p)^2 mod p
move $a0, $v0
jal mod

# now multiply the current result with mantissa
# a * (((a ^ b/2) mod p)^2 mod p)
move $a0, $t0 # now a0 = mantissa again
move $a1, $v0 # now a1 = current result
jal multiply

# now reduce the current result by mod p
# (a * ((a ^ b/2) mod p)^2 mod p) mod p
move $a0, $v0
jal mod

# exponentiate function over, load all saved values back
exit_exp:
lw $t0, ($sp)
lw $t1, 4($sp)
lw $a0, 8($sp)
lw $a1, 12($sp)
lw $ra, 16($sp)
add $sp, $sp, 20

jr $ra

# function mult begins here
multiply:
# arguments are:- a0 contains address of a, a1 of b and a2 of c

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


mod:
	add $sp,$sp,-12
	sw $s0,0($sp)
	sw $t0,4($sp)
	sw $ra,8($sp)
	
	# the number which has to be reduced is pointed to by a0
	move $s0,$a0
	
	# compute s1
	jal finds1
	
	move $a0,$s0
	
	# compute s2
	jal finds2
	
	move $a0,$s0
	
	# compute s3
	jal finds3
	
	move $a0,$s0
	
	# compute s4
	jal finds4
	
	move $a0,$s0
	
	# compute s5
	jal finds5
	
	move $a0,$s0
	
	# compute s6
	jal finds6
	
	move $a0,$s0
	
	# compute s7
	jal finds7
	
	move $a0,$s0
	
	# compute s8
	jal finds8
	
	move $a0,$s0
	
	# compute s9
	jal finds9
	
	# s1 + s2
	la $a0,space_for_s1
	la $a1,space_for_s2
	la $a2,sum
	add $a2,$a2,32
	jal addition

	# check for the carry bit
	lw $t0,sum + 28
	add $t0,$t0,$v0
	sw $t0,sum + 28

	# s1 + 2s2
	la $a2,sum
	add $a2,$a2,32
	move $a0,$a2
	la $a1,space_for_s2
	la $a2,temp
	jal addition
	
	# copy from temp to sum
	la $a0,sum+32
	la $a1,temp
	jal copy

	# check for the carry bit
	lw $t0,sum + 28
	add $t0,$t0,$v0
	sw $t0,sum + 28
	
	# s1 + 2s2 + s3
	la $a2,sum
	add $a2,$a2,32
	move $a0,$a2
	la $a1,space_for_s3
	la $a2,temp
	jal addition

	# copy from temp to sum
	la $a0,sum+32
	la $a1,temp
	jal copy

	# check for the carry bit
	lw $t0,sum + 28
	add $t0,$t0,$v0
	sw $t0,sum + 28
	
	# s1 + 2s2 + 2s3
	la $a2,sum
	add $a2,$a2,32
	move $a0,$a2
	la $a1,space_for_s3
	la $a2,temp
	jal addition

	# copy from temp to sum
	la $a0,sum+32
	la $a1,temp
	jal copy
	
	# check for the carry bit
	lw $t0,sum + 28
	add $t0,$t0,$v0
	sw $t0,sum + 28
	
	# s1 + 2s2 + 2s3 + s4
	la $a2,sum
	add $a2,$a2,32
	move $a0,$a2
	la $a1,space_for_s4
	la $a2,temp
	jal addition
	
	# copy from temp to sum
	la $a0,sum+32
	la $a1,temp
	jal copy
	
	# check for the carry bit
	lw $t0,sum + 28
	add $t0,$t0,$v0
	sw $t0,sum + 28
	
	# s1 + 2s2 + 2s3 + s4 + s5
	la $a2,sum
	add $a2,$a2,32
	move $a0,$a2
	la $a1,space_for_s5
	la $a2,temp
	jal addition
	
	# copy from temp to sum
	la $a0,sum+32
	la $a1,temp
	jal copy
	
	# check for the carry bit
	lw $t0,sum + 28
	add $t0,$t0,$v0
	sw $t0,sum + 28
	
	# s1 + 2s2 + 2s3 + s4 + s5 - s6
	la $a2,sum
	add $a2,$a2,32
	move $a0,$a2
	la $a1,space_for_s6
	la $a2,temp
	jal subtraction
	
	# copy from temp to sum
	la $a0,sum+32
	la $a1,temp
	jal copy
	
	# check for the borrow bit
	lw $t0,sum+28
	sub $t0,$t0,$v0
	sw $t0,sum+28
	
	# s1 + 2s2 + 2s3 + s4 + s5 - s6 - s7
	la $a2,sum
	add $a2,$a2,32
	move $a0,$a2
	la $a1,space_for_s7
	la $a2,temp
	jal subtraction
	
	# copy from temp to sum
	la $a0,sum+32
	la $a1,temp
	jal copy
	
	# check for the borrow bit
	lw $t0,sum+28
	sub $t0,$t0,$v0
	sw $t0,sum+28
	
	# s1 + 2s2 + 2s3 + s4 + s5 - s6 - s7 - s8
	la $a2,sum
	add $a2,$a2,32
	move $a0,$a2
	la $a1,space_for_s8
	la $a2,temp
	jal subtraction
	
	
	# copy from temp to sum
	la $a0,sum+32
	la $a1,temp
	jal copy
	
	# check for the borrow bit
	lw $t0,sum+28
	sub $t0,$t0,$v0
	sw $t0,sum+28
	
	# s1 + 2s2 + 2s3 + s4 + s5 - s6 - s7 - s8 - s9
	la $a2,sum
	add $a2,$a2,32
	move $a0,$a2
	la $a1,space_for_s9
	la $a2,temp
	jal subtraction
	
	
	# copy from temp to sum
	la $a0,sum+32
	la $a1,temp
	jal copy
	
	# check for the borrow bit
	lw $t0,sum+28
	sub $t0,$t0,$v0
	sw $t0,sum+28
	
	# keep adding or subtracting p from the sum so that sum is inside the field!
	# divide into 3 cases t0 = 0, < 0 and > 0
	zero:bnez $t0,not_zero
	# check if p greater than sum
	la $a0,prime
	la $a1,sum+32
	jal isGreater
	bgez $v0,exit_mod
	# subtract prime from sum
	la $a0,sum+32
	la $a1,prime
	la $a2,temp
	jal subtraction
	la $a0,sum+32
	la $a1,temp
	jal copy
	b exit_mod
	not_zero:bltz $t0,less_than_zero
	# keep subtracting till t0 is 0
	loop_red:beqz $t0,zero
	la $a0,sum+32
	la $a1,prime
	la $a2,temp
	jal subtraction
	sub $t0,$t0,$v0
	sw $t0,sum+28
	la $a0,sum+32
	la $a1,temp
	jal copy
	b loop_red
	less_than_zero:
	# keep adding till t0 is 0
	loop_red1:beqz $t0,zero
	la $a0,sum+32
	la $a1,prime
	la $a2,temp
	jal addition
	add $t0,$t0,$v0
	sw $t0,sum+28
	la $a0,sum+32
	la $a1,temp
	jal copy
	b loop_red1
	
	exit_mod:
	lw $s0,0($sp)
	lw $t0,4($sp)
	lw $ra,8($sp)
	add $sp,$sp,12
	
	la $v0,sum+32
		
	jr $ra

finds1:
	addi $sp,$sp,-16
	sw $ra,($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $t0,12($sp)
	
	# the number is in a0
	move $s0,$a0
	
	# s1 will point to s1
	la $s1,space_for_s1
	
	# load c7 from s0 and store in first position of s1
	# 60-4(7) = 32
	lw $t0,32($s0)
	sw $t0,($s1)
	
	# load c6 from s0 and store in next position of s1
	lw $t0,36($s0)
	sw $t0,4($s1)
	
	# load c5 from s0 and store in next position of s1
	lw $t0,40($s0)
	sw $t0,8($s1)
	
	# load c4 from s0 and store in next position of s1
	lw $t0,44($s0)
	sw $t0,12($s1)
	
	# load c3 from s0 and store in next position of s1
	lw $t0,48($s0)
	sw $t0,16($s1)
	
	# load c2 from s0 and store in next position of s1
	lw $t0,52($s0)
	sw $t0,20($s1)
	
	# load c1 from s0 and store in next position of s1
	lw $t0,56($s0)
	sw $t0,24($s1)
	
	# load c0 from s0 and store in next position of s1
	lw $t0,60($s0)
	sw $t0,28($s1)
	
	lw $ra,($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $t0,12($sp)
	addi $sp,$sp,16
	
	jr $ra

finds2:
	addi $sp,$sp,-16
	sw $ra,($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $t0,12($sp)
	
	# the number is in a0
	move $s0,$a0
	
	# s1 will point to s2
	la $s1,space_for_s2
	
	# load c15 from s0 and store in first position of s1
	lw $t0,($s0)
	sw $t0,($s1)
	
	# load c14 from s0 and store in next position of s1
	lw $t0,4($s0)
	sw $t0,4($s1)
	
	# load c13 from s0 and store in next position of s1
	lw $t0,8($s0)
	sw $t0,8($s1)
	
	# load c12 from s0 and store in next position of s1
	lw $t0,12($s0)
	sw $t0,12($s1)
	
	# load c11 from s0 and store in next position of s1
	lw $t0,16($s0)
	sw $t0,16($s1)
	
	# store 0 in next position of s1
	sw $0,20($s1)
	
	# store 0 in next position of s1
	sw $0,24($s1)
	
	# store 0 in next position of s1
	sw $0,28($s1)
	
	lw $ra,($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $t0,12($sp)
	addi $sp,$sp,16
	
	jr $ra

finds3:
	addi $sp,$sp,-16
	sw $ra,($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $t0,12($sp)
	
	# the number is in a0
	move $s0,$a0
	
	# s1 will point to s3
	la $s1,space_for_s3
	
	# store 0 in first position of s1
	sw $0,($s1)
	
	# load c15 from s0 and store in next position of s1
	lw $t0,0($s0)
	sw $t0,4($s1)
	
	# load c14 from s0 and store in next position of s1
	lw $t0,4($s0)
	sw $t0,8($s1)
	
	# load c13 from s0 and store in next position of s1
	lw $t0,8($s0)
	sw $t0,12($s1)
	
	# load c12 from s0 and store in next position of s1
	lw $t0,12($s0)
	sw $t0,16($s1)
	
	# store 0 in next position of s1
	sw $0,20($s1)
	
	# store 0 in next position of s1
	sw $0,24($s1)
	
	# store 0 in next position of s1
	sw $0,28($s1)
	
	lw $ra,($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $t0,12($sp)
	addi $sp,$sp,16
	
	jr $ra
	
finds4:
	addi $sp,$sp,-16
	sw $ra,($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $t0,12($sp)
	
	# the number is in a0
	move $s0,$a0
	
	# s1 will point to s4
	la $s1,space_for_s4
	
	# load c15 from s0 and store in first position of s1
	lw $t0,0($s0)
	sw $t0,($s1)
	
	# load c14 from s0 and store in next position of s1
	lw $t0,4($s0)
	sw $t0,4($s1)
	
	# store 0 in next position of s1
	sw $0,8($s1)
	
	# store 0 in next position of s1
	sw $0,12($s1)
	
	# store 0 in next position of s1
	sw $0,16($s1)
	
	# load c10 from s0 and store in next position of s1
	lw $t0,20($s0)
	sw $t0,20($s1)
	
	# load c9 from s0 and store in next position of s1
	lw $t0,24($s0)
	sw $t0,24($s1)
	
	# load c8 from s0 and store in next position of s1
	lw $t0,28($s0)
	sw $t0,28($s1)
	
	lw $ra,($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $t0,12($sp)
	addi $sp,$sp,16
	
	jr $ra
	
finds5:
	addi $sp,$sp,-16
	sw $ra,($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $t0,12($sp)
	
	# the number is in a0
	move $s0,$a0
	
	# s1 will point to s5
	la $s1,space_for_s5
	
	# load c8 from s0 and store in first position of s1
	lw $t0,28($s0)
	sw $t0,($s1)
	
	# load c13 from s0 and store in next position of s1
	lw $t0,8($s0)
	sw $t0,4($s1)
	
	# load c15 from s0 and store in next position of s1
	lw $t0,0($s0)
	sw $t0,8($s1)
	
	# load c14 from s0 and store in next position of s1
	lw $t0,4($s0)
	sw $t0,12($s1)
	
	# load c13 from s0 and store in next position of s1
	lw $t0,8($s0)
	sw $t0,16($s1)
	
	# load c11 from s0 and store in next position of s1
	lw $t0,16($s0)
	sw $t0,20($s1)
	
	# load c10 from s0 and store in next position of s1
	lw $t0,20($s0)
	sw $t0,24($s1)
	
	# load c9 from s0 and store in next position of s1
	lw $t0,24($s0)
	sw $t0,28($s1)
	
	lw $ra,($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $t0,12($sp)
	addi $sp,$sp,16
	
	jr $ra
	
finds6:
	addi $sp,$sp,-16
	sw $ra,($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $t0,12($sp)
	
	# the number is in a0
	move $s0,$a0
	
	# s1 will point to s6
	la $s1,space_for_s6
	
	# load c10 from s0 and store in first position of s1
	lw $t0,20($s0)
	sw $t0,($s1)
	
	# load c8 from s0 and store in next position of s1
	lw $t0,28($s0)
	sw $t0,4($s1)
	
	# store 0 in next position of s1
	sw $0,8($s1)
	
	# store 0 in next position of s1
	sw $0,12($s1)
	
	# store 0 in next position of s1
	sw $0,16($s1)
	
	# load c13 from s0 and store in next position of s1
	lw $t0,8($s0)
	sw $t0,20($s1)
	
	# load c12 from s0 and store in next position of s1
	lw $t0,12($s0)
	sw $t0,24($s1)
	
	# load c11 from s0 and store in next position of s1
	lw $t0,16($s0)
	sw $t0,28($s1)
	
	lw $ra,($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $t0,12($sp)
	addi $sp,$sp,16
	
	jr $ra
	
finds7:
	addi $sp,$sp,-16
	sw $ra,($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $t0,12($sp)
	
	# the number is in a0
	move $s0,$a0
	
	# s1 will point to s7
	la $s1,space_for_s7
	
	# load c11 from s0 and store in first position of s1
	lw $t0,16($s0)
	sw $t0,($s1)
	
	# load c9 from s0 and store in next position of s1
	lw $t0,24($s0)
	sw $t0,4($s1)
	
	# store 0 in next position of s1
	sw $0,8($s1)
	
	# store 0 in next position of s1
	sw $0,12($s1)
	
	# load c15 from s0 and store in next position of s1
	lw $t0,0($s0)
	sw $t0,16($s1)
	
	# load c14 from s0 and store in next position of s1
	lw $t0,4($s0)
	sw $t0,20($s1)
	
	# load c13 from s0 and store in next position of s1
	lw $t0,8($s0)
	sw $t0,24($s1)
	
	# load c12 from s0 and store in next position of s1
	lw $t0,12($s0)
	sw $t0,28($s1)
	
	lw $ra,($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $t0,12($sp)
	addi $sp,$sp,16
	
	jr $ra
	
finds8:
	addi $sp,$sp,-16
	sw $ra,($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $t0,12($sp)
	
	# the number is in a0
	move $s0,$a0
	
	# s1 will point to s8
	la $s1,space_for_s8
	
	# load c12 from s0 and store in first position of s1
	lw $t0,12($s0)
	sw $t0,($s1)
	
	# store 0 in next position of s1
	sw $0,4($s1)
	
	# load c10 from s0 and store in next position of s1
	lw $t0,20($s0)
	sw $t0,8($s1)
	
	# load c9 from s0 and store in next position of s1
	lw $t0,24($s0)
	sw $t0,12($s1)
	
	# load c8 from s0 and store in next position of s1
	lw $t0,28($s0)
	sw $t0,16($s1)
	
	# load c15 from s0 and store in next position of s1
	lw $t0,0($s0)
	sw $t0,20($s1)
	
	# load c14 from s0 and store in next position of s1
	lw $t0,4($s0)
	sw $t0,24($s1)
	
	# load c13 from s0 and store in next position of s1
	lw $t0,8($s0)
	sw $t0,28($s1)
	
	lw $ra,($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $t0,12($sp)
	addi $sp,$sp,16
	
	jr $ra
	
finds9:
	addi $sp,$sp,-16
	sw $ra,($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	sw $t0,12($sp)
	
	# the number is in a0
	move $s0,$a0
	
	# s1 will point to s9
	la $s1,space_for_s9
	
	# load c13 from s0 and store in first position of s1
	lw $t0,8($s0)
	sw $t0,($s1)
	
	# store 0 in next position of s1
	sw $0,4($s1)
	
	# load c11 from s0 and store in next position of s1
	lw $t0,16($s0)
	sw $t0,8($s1)
	
	# load c10 from s0 and store in next position of s1
	lw $t0,20($s0)
	sw $t0,12($s1)
	
	# load c9 from s0 and store in next position of s1
	lw $t0,24($s0)
	sw $t0,16($s1)
	
	# store 0 in next position of s1
	sw $0,20($s1)
	
	# load c15 from s0 and store in next position of s1
	lw $t0,0($s0)
	sw $t0,24($s1)
	
	# load c14 from s0 and store in next position of s1
	lw $t0,4($s0)
	sw $t0,28($s1)
	
	lw $ra,($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	lw $t0,12($sp)
	addi $sp,$sp,16
	
	jr $ra
	
###########################################################################################
#a0 contains the address of first word of the 8 words in first number
#a1 contains the address of first word of the 8 words in second number
#a2 contains the address of first word of the 8 words in resultant number
addition:
########################################################################################### 

add $sp,$sp,-44
sw $t0,0($sp)#
sw $t1,4($sp)#
sw $t2,8($sp)#
sw $t3,12($sp)
sw $t4,16($sp)
sw $t5,20($sp)
sw $t6,24($sp)
sw $t7,28($sp)
sw $t8,32($sp)
sw $t9,36($sp)
sw $ra,40($sp)

li $t0,28
li $t9,0                        #holds the carry from lower order digits

loop:	
	add $t1,$a0,$t0		#setting t1 to address of current words to be added	
	lw $t6,($t1)		#reading the word in the register
	add $t2,$a1,$t0		#setting t2 to address of current words to be added
	lw $t7,($t2)		#reading the word in the register
	addu $t3,$t7,$t9	#adding carry and second number 
	sltu $t9,$t3,$t7	#storing the carry of above addition
	addu $t8,$t6,$t3	#intermediate and first number
	sltu $t4,$t8,$t6	#getting carry of above additon
	or $t9,$t9,$t4		#getting the final carry
	
	add $t3,$a2,$t0				
	sw $t8,($t3)		#storing the final additon
	sub $t0,$t0,4				
	bgt $t0,-1,loop
	
	# set v0 to the carry result
	move $v0,$t9
	beq $v0,1 subt
	la $a1,prime
	move $t0,$a0
	move $a0,$a2
	jal isGreater
	move $a0,$t0
	
	beq $v0,1,subt
	b done
	
	
subt:	la $a1,prime
	move $t0,$a0
	move $a0,$a2
	jal subtraction ############ Rishi put a call to subtractionWOMod here. Changing on a trial basis ############
	move $a0,$t0
	
done:	
lw $t0,0($sp)
lw $t1,4($sp)
lw $t2,8($sp)
lw $t3,12($sp)
lw $t4,16($sp)
lw $t5,20($sp)
lw $t6,24($sp)
lw $t7,28($sp)
lw $t8,32($sp)
lw $t9,36($sp)
lw $ra,40($sp)
add $sp,$sp,44

jr $ra

#############################################################################
#a0 contains the address of first word of the 8 words in first number
#a1 contains the address of first word of the 8 words in second number
#a2 contains the address of first word of the 8 words in resultant number
subtraction:
#############################################################################
add $sp,$sp,-44
sw $t0,0($sp)
sw $t1,4($sp)
sw $t2,8($sp)
sw $t3,12($sp)
sw $t4,16($sp)
sw $t5,20($sp)
sw $t6,24($sp)
sw $t7,28($sp)
sw $t8,32($sp)
sw $t9,36($sp)
sw $ra,40($sp)


li $t0,28
li $t9,0              #holds the borrow from lower order digits

loop_sub:
	add $t1,$a0,$t0       #setting t1 to address of current words to be added 
	lw $t6,($t1)          #reading the word in the register
	add $t2,$a1,$t0       #setting t2 to address of current words to be added
	lw $t7,($t2)          #reading the word in the register
	subu $t3,$t6,$t9      #subtracting borrow from first number
	sltu $t9,$t6,$t9      #storing the borrow of above addition
	subu $t8,$t3,$t7      #subtract second number from intermediate
	sltu $t4,$t3,$t7      #getting carry of above additon
	or $t9,$t9,$t4        #getting the final carry
	add $t3,$a2,$t0       
	sw $t8,($t3)          #storing the final additon
	sub $t0,$t0,4       
	bgt $t0,-1,loop_sub
  
  	# store the final borrow in v0
  	move $v0,$t9
  	beq $v0,1,addprime
  	b doneall
  	
 addprime:	la $a1,prime
		move $t0,$a0
		move $a0,$a2
		jal addition ############ Rishi put a call to additionWOMod here. Changing on a trial basis ############
		move $a0,$t0
  	
doneall:
lw $t0,0($sp)
lw $t1,4($sp)
lw $t2,8($sp)
lw $t3,12($sp)
lw $t4,16($sp)
lw $t5,20($sp)
lw $t6,24($sp)
lw $t7,28($sp)
lw $t8,32($sp)
lw $t9,36($sp)
lw $ra,40($sp)
add $sp,$sp,44

  
jr $ra


isGreater:
# two numbers to be compared have addresses at $a0 and $a1
# puts 1 in $v0 if $a0 > $a1, -1 if $a0 < $a1, 0 if they're equal
add $sp,$sp,-24
sw $t0,0($sp)
sw $t1,4($sp)
sw $t2,8($sp)
sw $t3,12($sp)
sw $t4,16($sp)
sw $ra, 20($sp)

li $t0,0 # 4 * word offset within element

loop_compare:
add $t1,$a0,$t0		#setting t1 to address of current words to be compared	
lw $t3,($t1)		#reading the word in the register
add $t2,$a1,$t0		#setting t2 to address of current words to be compared
lw $t4,($t2)		#reading the word in the register
bgtu $t4, $t3, a1isGreater
bgtu $t3, $t4, a0isGreater

equalWords:		#the words just compared were equal
add $t0,$t0,4		# next most significant word pe jao			
bgt $t0,28,equalNumbers
b loop_compare

a0isGreater:		#$a0 is greater, yay!
li $v0, 1
j endOfComparison

a1isGreater:		#$a1 is greater. I know for sure
li $v0, -1
j endOfComparison

equalNumbers:
li $v0, 0

endOfComparison:	# end function here, load everything that was saved
lw $t0,0($sp)
lw $t1,4($sp)
lw $t2,8($sp)
lw $t3,12($sp)
lw $t4,16($sp)
lw $ra,20($sp)
add $sp,$sp,24

jr $ra

# copy function begins here
copy:
	add $sp,$sp,-16
	sw $t0,0($sp)
	sw $t1,4($sp)
	sw $a0,8($sp)
	sw $a1,12($sp)
	
	li $t1,0
	loop_copy:	beq $t1,8,exit_copy
			# load from a1
			lw $t0,($a1)
			# store to a0
			sw $t0,($a0)
			# advance a0 and a1
			addi $a0,$a0,4
			addi $a1,$a1,4
			addi $t1,$t1,1
			b loop_copy
	exit_copy:
	
	lw $t0,0($sp)
	lw $t1,4($sp)
	lw $a0,8($sp)
	lw $a1,12($sp)
	add $sp,$sp,16
	
	
	jr $ra

# divides an 8-word number by 2
shiftRightLogical:
	addi $sp,$sp,-28
	sw $s0,0($sp)
	sw $s1,4($sp)
	sw $t0,8($sp)
	sw $t1,12($sp)
	sw $t2,16($sp)
	sw $a0,20($sp)
	sw $ra,24($sp)
	 
	
	# the start of the number is at a0
	move $s0,$a0
	# left-over from shift of last word
	li $t0,0
	# iterator
	li $t1,0
	loop_shift:	beq $t1,8,exit_shift
			# load the word in s1
			lw $s1,($s0)
			# store the last bit in t2
			and $t2,$s1,1
			# shift the word right by 1
			srl $s1,$s1,1
			# shift t0 left by 7
			sll $t0,$t0,31
			# include left-over bit in s1
			or $s1,$s1,$t0
			# store back in s0
			sw $s1,($s0)
			# update $t0
			move $t0,$t2
			# update s0
			addi $s0,$s0,4
			# update iterator
			addi $t1,$t1,1
			b loop_shift
	exit_shift:
	lw $s0,0($sp)
	lw $s1,4($sp)
	lw $t0,8($sp)
	lw $t1,12($sp)
	lw $t2,16($sp)
	lw $a0, 20($sp)
	lw $ra,24($sp)
	addi $sp,$sp,28
	
	jr $ra
	
exit_pgm:

print_8_word_number:
	add $sp, $sp, -20
	sw $t0, ($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $a0, 12($sp)
	sw $ra, 16($sp)
	
	
	move $t0, $a0 # save the original argument into t0
	
	li $t1, 0 # loop variable
	print_loop_begin:
		bgt $t1, 28, print_loop_end
		add $t2, $t0, $t1
		lw $a0, ($t2)
		li $v0, 1 # print integer
		syscall
		li $v0, 4
		la $a0, space_char
		syscall
		add $t1, $t1, 4
		b print_loop_begin
	print_loop_end:
	
	lw $t0, ($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $a0, 12($sp)
	lw $ra, 16($sp)
	add $sp, $sp, 20

	jr $ra

print_newline:
	add $sp, $sp, -20
	sw $a0, ($sp)
	sw $v0, 4($sp)
	sw $v1, 8($sp)
	
	la $a0, newline_char
	li $v0, 4 # print string
	syscall

	lw $a0, ($sp)
	lw $v0, 4($sp)
	lw $v1, 8($sp)
	add $sp, $sp, 20
	
	jr $ra
		
test_exponentiate:
	# raise aa to the power bb
	la $a0, aa
	la $a1, bb
	la $a2, exp_result
	jal exponentiate

	move $a0, $v0
	jal print_8_word_number

	li $v0, 10
	syscall

display_p_plus_one_by_four:
	la $a0, p_plus_one
	jal shiftRightLogical
	jal shiftRightLogical
	jal print_8_word_number
	
	li $v0, 10
	syscall
	
test_srl:
	la $a0, p_plus_one
	jal shiftRightLogical
	jal shiftRightLogical
	jal print_8_word_number
	
	li $v0, 10
	syscall

test_sqrt:
	la $a0, element
	la $v0, neg_element_sqrt
	la $v1, pos_element_sqrt
	jal sqrt
	move $a0, $v0
	jal print_8_word_number
	jal print_newline
	move $a0, $v1
	jal print_8_word_number
	
	li $v0, 10
	syscall

.data
#a: .word 0 0 0 0 0 0 0 0xffffffff
#b: .word 0 0 0 0 0 0 0 0xffffffff
aa: .word 0 0 0 0 0 0 0 3
bb: .word 0 0 0 0 0 0 0 2
c: .space 64 # the array where the result of multiplication is stored
# 2^256-2^224+2^192+2^96-1
#prime:	.word 15 1 0 0 0 15 15 15

prime: .word 0xffffffff 1 0 0 0 0xffffffff 0xffffffff 0xffffffff
space_for_s1:	.space 32
space_for_s2:	.space 32
space_for_s3:	.space 32
space_for_s4:	.space 32
space_for_s5:	.space 32
space_for_s6:	.space 32
space_for_s7:	.space 32
space_for_s8:	.space 32
space_for_s9:	.space 32
sum:		.space 64
temp:		.space 32
temp1:		.space 32
temp2:		.space 32
exp_result:     .space 32 # array storing the result of exponentiation
const_one:      .word 0 0 0 0 0 0 0 1
const_zero:     .word 0 0 0 0 0 0 0 0
space_char:     .asciiz " "
newline_char:   .asciiz "\n"
p_plus_one:         .word 0xffffffff 1 0 0 1 0 0 0
p_plus_one_by_four: .word 0x3fffffff 0xc0000000 0x40000000 0 0 0x40000000 0 0

element:          .word 0 0 0 0 0 0 0 0
pos_element_sqrt: .space 32
neg_element_sqrt: .space 32
