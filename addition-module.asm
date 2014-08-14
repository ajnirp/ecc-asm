

.#a0 contains the address of first word of the 8 words in first number
#a1 contains the address of first word of the 8 words in second number
#a2 contains the address of first word of the 8 words in resultant number

addition : add $sp,$sp,-40
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


li $t0,7
li $t9,0                                     	#holds the carry from lower order digits

loop:
add $t1,$a0,$t0				#setting t1 to address of current words to be added	
lw $t6,($t1)				#reading the word in the register
add $t2,$a1,$t0				#setting t2 to address of current words to be added
lw $t7,($t2)				#reading the word in the register
addu $t3,$t7,$t9			#adding carry and second number 
sltu $t9,$t3,$t7			#storing the carry of above addition
addu $t8,$t6,$t3			#intermediate and first number
sltu $t4,$t8,$t6			#getting carry of above additon
or $t9,$t9,$t4				#getting the final carry

add $t3,$a2,$t0				
sw $t8,($t3)				#storing the final additon
sub $t0,$t0,1				
bgt $t0,-1,loop
	

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
add $sp,$sp,40

	
jr $ra
	
	
	
	
	
	
	
	
