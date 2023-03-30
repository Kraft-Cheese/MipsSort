.data
	smallestElem: .asciiz "Smallest in root: \n"
	childElem: .asciiz "Child of the node is: \n"
	InputSize: .asciiz "What is the number of elements in the array: "
	InputElements: .asciiz "Input your elements \n"
.text


main:
	jal init	#Initialize the array with user input
	jal sort



exit:
li $v0, 10 #end the program
syscall


init:
	lui $s0, 0x1004 #start array at address 0x1004
	#Get User Input for the array
	la $a0, InputSize #a0 = inputsize (ie amount of elements)
	li $v0, 4 #Ready to print a string
	syscall
	li $v0, 5 #Ready to recieve user input of an integer from buffer
	syscall
	move $s1, $v0 #set from v0 to s2; or s1 = v0/sizeofarray
	#now we will recieve input from the user to fill an array; we must make sure not to overflow and base of of s1
	sll $t2, $s1, 2 # t2 = s1*4 4 being size of an int
	move $t0, 0 #t0 = i = 0
	whileloop:
		beq $t0, $t2, end whileloop # while i < sizeofUserInput, accept array elements
		li $v0, 5 #Ready to read in elem
		syscall
		sw $v0, ($s0) # array[i] = element
		addi $s0, $s0, 4 # move to next elem in array
		addi $t0, $t0, 4 #t0 += 4; increment i
		j whileloop
	end whileloop:
	jr $ra

swap:
#boring swap
	add $t1, $s0, $s2 #t1 = array[i]
	add $t2, $s0, $s3 #t2 = array[j]
	lw $a0, 0($t1)	#a0 = t1
	lw $a1, 0($t2) #a1 = t2
	sw $a1, 0($t1) #a1 = t1
	sw $a0, 0($t2) #a0 = t2
	
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
	beq t2, $0, endwhile2
		#swap(0, n)
		move s3, 0
		move s2, t2
		jal swap
		#n--
		sub t2, t2, 4 # t2 -= 4; or minus an elem; n--
		#fixheap(0,n)
		move s4, s3
		move s5, s2
		jal fixHeap
		j while2
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
	move $t3, $s1
#int index = rootIndex
	move $t4, $s1
# while more = true
	while3:
	#childindex = getLeftChildIn
	jal getLeftChildIndex
	#if childindex <= lastindex
	bgt $s3, $s0, endifchildleft
		#rightchild = getRightChildIndex
		jal getRightChildIndex
		#if rightchild <= lastindex and array[rightchild] > array[childindex]
		
			#childindex = rightchild
		#if array[childindex] > rootValue
		ble $s1, $t3, endifchildright
			#array[index] = array[childindex]
			#index = childindex
		#else
		endifchildright:
			#false
		#endif
	#else 
	endifchildleft:
		#false
	
	#endif
	
	j while3
	endwhile3:
	
#array[index] = rootValue
move $s0, $t3
#restore stack
	lw $ra, ($sp)
	lw $s0, 4($sp) 
	lw $s1, 8($sp)
	addi $sp, $sp, 12
jr $ra
