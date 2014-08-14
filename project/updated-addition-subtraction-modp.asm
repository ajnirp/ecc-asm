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