isGreater:
# two numbers to be compared have addresses at $a0 and $a1
# puts 1 in $v0 if $a0 > $a1, -1 if $a0 < $a1, 0 if they're equal
add $sp,$sp,-20
sw $t0,0($sp)
sw $t1,4($sp)
sw $t2,8($sp)
sw $t3,12($sp)
sw $t4,16($sp)

li $t0,0 # 4 * word offset within element

loop:
add $t1,$a0,$t0		#setting t1 to address of current words to be compared	
lw $t3,($t1)		#reading the word in the register
add $t2,$a1,$t0		#setting t2 to address of current words to be compared
lw $t4,($t2)		#reading the word in the register
bgtu $t4, $t3, a1isGreater
bgtu $t3, $t4, a0isGreater

equalWords:		#the words just compared were equal
add $t0,$t0,4		# next most significant word pe jao			
bgt $t0,28,equalNumbers
b loop

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
add $sp,$sp,20

jr $ra
