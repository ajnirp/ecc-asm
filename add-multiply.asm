.data

ask1: .asciiz "Enter element 1\n"
ask2: .asciiz "Enter element 2\n"
askp: .asciiz "Enter polynomial: 0x"

poly: .space 4 # 3 hex chars

.text

li $v0, 4
la $a0, ask1
syscall

li $v0, 5
syscall

li $v0, 4
la $a0, ask2
syscall

li $v0, 5
syscall

# exit
li $v0, 10
syscall
