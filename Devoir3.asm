.data
	smallestElem: .asciiz "Smallest in root: \n"
	childElem: .asciiz "Child of the node is: \n"
	InputSize: .asciiz "What is the number of elements in the array: "
	InputElements: .asciiz "Input your elements \n"
.text


main:
	jal init

whileloop: #while i < sizeofUserInput, accept array elements
	beq $t0, $t2, end whileloop # while i < sizeof
	add $t0, $t0, $s0 #t0 = array[i]; set temp to array at location i
	li $v0, 5 #Ready to read in elem
	syscall
	move $t3, $v0 #t3 = v0
	sw $t3, ($t0) #now array at location i (t0) is set to int in t3
	addi $t0, $t0, 4 #t0 += 4; increment i
	j whileloop
end whileloop:
	jr $ra #return to main


exit:
li $v0, 10
syscall


init:
	lui $s0, 0x1004 #start at adress 0x1004
	#Get User Input for the array
	la $a0, InputSize #a0 = inputsize (ie amount of elements)
	li $v0, 4 #Ready to print a string
	syscall
	li $v0, 5 #Ready to recieve user input of an integer from buffer
	syscall
	move $s1, $v0 #set from v0 to s2; or s1 = v0
	#now we will recieve input from the user to fill an array; we must make sure not to overflow and base of of s1
	sll $t2, $s1, 2 # t2 = s1*4 4 being size of an int
	move $t0, 0 #t0 = i = 0
jr $ra

swap:
#save stack
	addi $sp, $sp, -12
	sw $ra, ($sp) #return address
	sw $s0, 4($sp) #i
	sw $s1, 8($sp) #j

#boring move swap
	#move $t0, $s0  # temp = a[i]
	#move $s0, $s1 # a[i] = a[j]
	#move $s1, $t0  #a[j] = temp

#chad xor swap
	xor $s0, $s0, $s1 # s0 = s0 xor s1
	xor $s1, $s0, $s1 # s1 = s0 xor s1
	xor $s0, $s0, $s1 # s0 = s0 xor s1

#restore stack
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $ra , ($sp)
	addi $sp, $sp, 12
jr $ra

getleftChildIndex:
#save stack
	addi $sp, $sp, -8
	sw $ra, ($sp)
	sw $s0, 4($sp)
# return i*2 + 1
	sll $s0, $a0, 1
	addi $s0, $s0, 1
#restore stack
	lw $ra, ($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
jr $ra

getRightChildIndex:
#save stack
	addi $sp, $sp, -8
	sw $ra, ($sp)
	sw $s0, 4($sp)
#return i*2 + 2
	sll $s0, $a0, 1
	addi $s0, $s0, 2
#restore stack
	lw $ra, ($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
jr $ra

sort:
#save stack
	addi $sp, $sp, -16
	sw $ra, ($sp)
	sw $s0, 4($sp) #i
	sw $s1, 8($sp) #N
	sw $s2, 12($sp) #array

#set values
	#int n = sizeof - 1
while:
	#while i >= 0
		#i = (n-1)/2
	#fixheap(i, n)
	fixHeap
		#i--
	#end while loop
endwhile:

while2:
	#while (n > 0)
		#swap(0, n)
		jal swap
		#n--
		#fixheap(0,n)
		jal fixHeap
	#end while loop
endwhile2:
#restore stack
	lw $ra, ($sp)
	lw $s0, 4($sp) #i
	lw $s1, 8($sp) #N
	lw $s2, 12($sp) #array
	addi $sp, $sp, 16
jr $ra

fixHeap:
#save stack
	addi $sp, $sp, -12
	sw $ra, ($sp)
	sw $s0, 4($sp) #lastIndex
	sw $s1, 8($sp) #rootIndex

#remove root; rootValue = array[rootindex]
#int index = rootIndex
# while more = true
	#childindex = getLeftChildIndex
	jal getLeftChildIndex
	#if childindex <= lastindex
		#rightchild = getRightChildIndex
		jal getRightChildIndex
		#if rightchild <= lastindex and array[rightchild] > array[childindex]
			#childindex = rightchild
		#if array[childindex > rootValue
			#array[index] = array[childindex]
			#index = childindex
		#else
			#false
		#endif
	#else
		#false
	#endif
#array[index] = rootValue
#restore stack
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12
jr $ra
