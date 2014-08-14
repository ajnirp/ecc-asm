.text
la $a0,number
jal shiftRightLogical
b exit_pgm

# divides an 8-word number by 2
shiftRightLogical:
	addi $sp,$sp,-24
	sw $s0,0($sp)
	sw $s1,4($sp)
	sw $t0,8($sp)
	sw $t1,12($sp)
	sw $t2,16($sp)
	sw $ra,20($sp)
	
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
			sll $t0,$t0,7
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
	sw $s0,0($sp)
	sw $s1,4($sp)
	sw $t0,8($sp)
	sw $t1,12($sp)
	sw $t2,16($sp)
	sw $ra,20($sp)
	addi $sp,$sp,24
	
	jr $ra
	
exit_pgm:

.data
number:	.word 7 6 5 4 3 2 1 0