	.data
number:	.word 7 6 5 4 3 2 1 0
# 2^256-2^224+2^192+2^96-1
prime:	.word 15 1 0 0 0 15 15 15
# u v x and y are intermediate variables by the inversion function
inversion_u:	.space 32
inversion_v:	.space 32
inversion_x1:	.space 32
inversion_x2:	.space 32
answer:		.space 32

	
	.text
	
la $a0, number # $a0 contains the base address of the number to be inverted
la $a1, answer



#######################################################################################




#start of function to invert a binary number
# $a0 has argument, $a1 has answer
binaryInversion:	
# VARIABLES- 
# $s0 stores address of the number
# $s1 stores address of u
# $s2 stores address of v
# $s3 stores address of x1
# $s4 stores address of x2
# $s5 stores address of p
# $s6 stores address of the answer
# $t0 is a temporary variable. Use only for on-the-spot initialization/use
addi $sp, $sp, -36
sw $t0, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)
sw $s6, 28($sp)
sw $ra, 32($sp)


# List of variables to store- $s0 through $s6, $t0
move $s0, $a0		# $s0 stores address of the number
la $s1, inversion_u	# $s1 stores address of u
la $s2, inversion_v	# $s2 stores address of v
la $s3, inversion_x1	# $s3 stores address of x1
la $s4, inversion_x2	# $s4 stores address of x2
la $s5, prime		# $s5 stores address of p
move $s6, $a1		# $s5 stores address of answer
# copy a (the number) into u
move $a0, $s0
move $a1, $s1
jal copyNumber

# copy p into v
move $a0, $s5
move $a1, $s2
jal copyNumber

# initialize x1 to one
sw $zero, 0($s3)
sw $zero, 4($s3)
sw $zero, 8($s3)
sw $zero, 12($s3)
sw $zero, 16($s3)
sw $zero, 20($s3)
sw $zero, 24($s3)
li $t0, 1
sw $t0, 28($s3)

# initialize x2 to zero
sw $zero, 0($s3)
sw $zero, 4($s3)
sw $zero, 8($s3)
sw $zero, 12($s3)
sw $zero, 16($s3)
sw $zero, 20($s3)
sw $zero, 24($s3)
sw $zero, 28($s3)


# first level loop
firstLevelLoop:
	
	innerLoopU:
		# checking if u is odd
		move $a0, $s1 
		jal isEven
		beq $v0, 0, innerLoopV	# if u is odd, proceed to inner loop for v
		# else, first, u /= 2
		move $a0, $s1
		jal shiftRightLogical
		
		# now, if x1 is even then x1/=2
		move $a0, $s3
		jal isEven 
		beq $v0, 0, x1IsNotEven	# if isEven returns 0, x1 is not even, so branch
		move $a0, $s3		
		jal shiftRightLogical	# else divide x1 by 2
		b innerLoopU		# check again if u has become odd or still even
		
		x1IsNotEven:	# x1 wasn't even, so now do x1 <- (x1+p)/2
		move $a0, $s3	# x1 into $a0
		move $a1, $s5	# p into $a1
		move $a2, $s3	# x1 into $a2 (result)
		jal addition	# x1 <= x1 + p
		
		move $a0, $s3 	
		jal shiftRightLogical	# x1 /= 2
		b innerLoopU	# check again if u has become odd or still even

	innerLoopV:
	# checking if v is odd	
		move $a0, $s2 
		jal isEven
		beq $v0, 0, endOfInnerLoops	# if v is odd, proceed to end of loop
		# else, first, v /= 2
		move $a0, $s2
		jal shiftRightLogical
		
		# if x2 is even then x2/=2
		move $a0, $s4
		jal isEven 
		beq $v0, 0, x2IsNotEven	# if isEven returns 0, x2 is not even, so branch
		move $a0, $s4		
		jal shiftRightLogical	# else divide x2 by 2
		b innerLoopV		# check again if v has become odd or still even
		
		x2IsNotEven:	# x2 wasn't even, so now do x2 <- (x2+p)/2
		move $a0, $s4	# x2 into $a0
		move $a1, $s5	# p into $a1
		move $a2, $s4	# x2 into $a2 (result)
		jal addition	# x2 <= x2 + p
		
		move $a0, $s4 	
		jal shiftRightLogical	# x2 /= 2
		b innerLoopV	# check again if u has become odd or still even

	endOfInnerLoops:
	# here end the update loops for (u, x1) and (v, x2)
	move $a0, $s1
	move $a1, $s2
	jal isGreater
	blt $v0, 0, uIsLessThanV	# u is less than v, so branch and take second step

	# Must do u <- u - v, x1 <- x1 - x2
	move $a0, $s1
	move $a1, $s2
	move $a2, $s1
	jal subtraction		# accomplishes u <- u - v
	move $a0, $s3
	move $a1, $s4
	move $a2, $s3
	jal subtraction		# accomplishes x1 <- x1 - x2

	j isU1OrV1		# now check for loop termination condition (u==1 or v==1)
	
	uIsLessThanV:	# u was less than v, so....
	# Must do v <- v - u, x2 <- x2 - x1
	
	move $a0, $s1
	move $a1, $s2
	move $a2, $s1
	jal subtraction		# accomplishes u <- u - v
	move $a0, $s3
	move $a1, $s4
	move $a2, $s3
	jal subtraction		# accomplishes x1 <- x1 - x2

	isU1OrV1:
	
	# if u equals 1, jump to endOfOuterLoop
	move $a0, $s1
	jal equalsOne
	beq $v0, 1, endOfFirstLevelLoop
	# if u != 1 but v equals 1, jump to endOfOuterLoop
	move $a0, $s2
	jal equalsOne
	beq $v0, 1, endOfFirstLevelLoop
	# neither of u or v equals 1
	b firstLevelLoop

endOfFirstLevelLoop:
move $a0, $s1
jal equalsOne
beq $v0, 1, uEqualsOne	# if at the end of the process, u = 1, then branch

move $a0, $s4	# if I didn't branch, v = 1 and my answer is x2 mod p. Returning x2 for now
move $a1, $s6
jal copyNumber
b endOfInversion

uEqualsOne:	# u equals 1, so the answer is x1 mod p. I'm just returning x1 for now.
move $a0, $s3
move $a1, $s6
jal copyNumber

endOfInversion:

lw $t0, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
lw $s5, 24($sp)
lw $s6, 28($sp)
lw $ra, 32($sp)
addi $sp, $sp, 36

jr $ra

#########################################################################################
# function to check if an 8 word number with address in $a0 is equal to 1
# puts 1 in $v0 if the number pointed to by $a0 equals 1, puts 0 in $v0 otherwise
#########################################################################################
equalsOne:

li $t0, 0 # $t0 will store the byte offset of the word being accessed from the element

equalsOneLoop:

lw $t1, ($t0) # $t1 stores the word being compared to 0
bne $t1, 0, numberDoesNotEqualOne # one of the 7 most significant words was not equal to one. So the number doesn't equal one
addi $t0, $t0, 4 # advance the word pointer
bgt $t0, 24, equalsOneLoop # loop for 7 words

# at this point the 7 most significant words are checked

lw $t1, ($t0) # load the least significant word in $t1
beq $t1, 1, numberEqualsOne # if $t1 = 1, the whole number equals one

numberDoesNotEqualOne: # I come here if my number wasn't equal to 1s
li $v0, 0
jr $ra

numberEqualsOne: # I My number is 1. Party time!
li $v0, 1
jr $ra

#########################################################################################
# function to copy the number contained at $a0 into space at $a1
#########################################################################################
copyNumber:

addi $sp, $sp, -4
sw $t0, 0($sp)

# $t0 is my temp register, an intermedaite between loading and storing values.

lw $t0, ($a0)
sw $t0, ($a1)
lw $t0, 4($a0)
sw $t0, 4($a1)
lw $t0, 8($a0)
sw $t0, 8($a1)
lw $t0, 12($a0)
sw $t0, 12($a1)
lw $t0, 16($a0)
sw $t0, 16($a1)
lw $t0, 20($a0)
sw $t0, 20($a1)
lw $t0, 24($a0)
sw $t0, 24($a1)
lw $t0, 28($a0)
sw $t0, 28($a1)

lw $t0, 0($sp)
addi $sp, $sp, 4
jr $ra

#########################################################################################
# function to determine whether the number at $a0 is even
# puts 1 in $v0 if it's even, 0 otherwise
#########################################################################################
isEven:
addi $sp, $sp, -4
sw $t0, 0($sp)

# load the last word of the number in $t0
lw $t0, 28($a0)
# AND with 1
andi $t0, $t0, 1

# if result is greater than 0, number is not even
bgt $t0, 0, numberIsNotEven
li $v0, 1
b endOfIsEven

numberIsNotEven:
li $v0, 0

endOfIsEven:
lw $t0, 0($sp)
addi $sp, $sp, 4
jr $ra