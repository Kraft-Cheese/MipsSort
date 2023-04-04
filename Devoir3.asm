
.data
	smallestElem: .asciiz "Smallest in root: \n"
	childElem: .asciiz "Child of the node is: \n"
	InputSize: .asciiz "What is the number of elements in the array: "
	InputElements: .asciiz "Input your elements \n"
	PrintElements: .asciiz "Here are the elements in the array: \n "
	newline: .asciiz "\n"
	space: .asciiz " "
.text


main:
	lui $s0, 0x1004 #start array at address 0x1004
	jal init #Initialize the array with user input
	move $s1, $v0 #save index
	move $s2, $v1 #save sizeof
	#move $a0, $s1 # arg1 sort index
	#move $a1, $s2 #arg2 sort sizeof
	#jal sort
	
	la $a0, PrintElements
	li $v0, 4 #Ready to print a string
	syscall
	#print array
	move $t0, $0
	printloop:
		beq $t0, $s2, endloop
		sll $t2, $t0, 2
		add $t2, $t2, $s0
		lw $a0, ($t2)
		li $v0, 1
		syscall
		li $v0, 4
		la $a0, newline
		syscall
		addi $t0, $t0, 1
		j printloop
	
	endloop:
	

exit:
li $v0, 10 #end the program
syscall


init:
	#Get User Input for the array
	la $a0, InputSize #a0 = inputsize (ie amount of elements)
	li $v0, 4 #Ready to print a string
	syscall
	li $v0, 5 #Ready to recieve user input of an integer from buffer
	syscall
	move $t1, $v0 #set from v0 to t1; or t1 = v0/sizeofarray
	#now we will recieve input from the user to fill an array; we must make sure not to overflow and base of of s1
	move $t2, $t1 # i = sizeof
	move $t0, $0 #t0 = i = 0
	whileloop:
		beq $t0, $t2, endwhileloop # while i < sizeofUserInput, accept array elements
		sll $t3, $t0, 2 # t3 = i*4 4 being size of an int
		add $t3, $t3, $s0 # set address array
		li $v0, 5 #Ready to read in elem
		syscall
		move $s5, $v0 # array = input
		sw $s5, ($t3) # array[i] = element
		addi $t0, $t0, 1 #t0 += 1; increment i
		j whileloop
	endwhileloop:
	move $v0, $t0 #return index
	move $v1, $t1 #return sizeof
	
	jr $ra



sort:
	addi $sp, $sp, -4 #save the stack so we can return to sort
	sw $s0, ($sp) #save base address
	#set values
	#int n = sizeof - 1
	move $t0, $a0 #t0 -= array
	move $t1, $a1 #t1 = n = sizeof
	subi $t1, $t1, 1 #t1 = n = n-1
	subi $t3, $t1, 1 #t3 = n - 1
	srl $t3, $t3, 1 #i = t3 = t3/2 = (n-1)/2
while:
	beq $t3, $0, endwhile
	#while i >= 0
		#i = (n-1)/2
	#fixheap(i, n)
	move $a0, $t3 # i
	move $a1, $t1 # n
	jal fixHeap
	subi $t3, $t3, 1 #i--
	#end while loop
endwhile:

while2:
	beq $t2, $0, endwhile2 #while (n > 0)
		move $a0, $0
		move $a1, $t2 # n
		
		jal swap # swap(0, n)
		
		move $t2, $v0
		sub $t2, $t2, 1 # $t2 -= 1; or minus an elem; n--

		move $a0, $s3 # $a0 = s3
		move $a1, $s2 # $a1 = s2
		
		jal fixHeap # fixheap(0,n)
		
		move $s3, $v0 # $s3 = $v0
		move $s4, $v1 # $s4 = $v1
		
		j while2 #loop back to while2
	#end while loop	
endwhile2: #exit to return to main	

	lw $s0, ($sp) #save base address
	addi $sp, $sp, 4 #save the stack so we can return to sort

	jr $ra

fixHeap:
	addi $sp, $sp, -12 #save the stack so we can return to sort
	sw $ra, ($sp) #return to sort
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	
	move $t0, $a0 #t0 = i <= rootindex
	move $t1, $a1 #t1 = n <= lastindex
	
	sll $t2, $t0, 2 #t2 = i * 4; 4 as 4bits are needed per integer
	add $t2, $t2, $s0 #t2 = array[rootindex]
	lw $s5, ($t2) #rootvalue = array[rootindex]
	move $s1, $t0 #index = rootindex
	 
# while more = true
move $t7, $0 #more = true
while3:
	bnez $t7, endwhile3 #more = false => endloop
	move $a0, $t0 #set 1st parameter of getleftchild(index) to a0
	jal getleftChildIndex
	move $t6, $v0 #leftchildindex = getleftchildindex
	bgt $t6, $t1, elsechildleft #if leftchildindex <= lastindex (t1 = 2nd parameter)
		move $a0, $t0 #getLeftChildindex(index)
		jal getRightChildIndex
		move $t8, $v0 #rightchild = getRightChildIndex
		bgt $t8, $t1, elsechildright #if rightchild <= lastindex
		sll $t3, $t8, 2 #t3 = rightchild*4
		add $t3, $t3, $s0 #t3 = array[rightchild]
		sll $t4, $t6, 2 #t4 = leftchild*4
		add $t4, $t4, $s0 #t4 = array[leftchild]
		lw $t4, ($t4) #sets to address
		lw $t3, ($t3) #sets to address
	
		bge $t4, $t3, elsechildright #if array[rightchild] > array[leftchild]
		move $t4, $t3 #leftchild = rightchild
		
		ble $t4, $t2, elsechildright #if array[leftchild] > rootValue
		move $t3, $0 #clear t3
		sll $t3, $t6, 2 #t3 = leftchild * 4; integer
		add $t3, $t3, $s0 #t3 = array[leftchild] 
		lw $t3, ($t3) #load to address
		sw $t3, ($t2) #array[index] = array[leftchild]
		move $t0, $t6 #index = leftchild
		j while3
		#else
		elsechildright:
			addi $t7, $t7, 1 #more = false
			j while3
		#endif
	#else 
	elsechildleft:
		addi $t7, $t7, 1 #more = false
		j while3
	
	#endif
	
	j while3
endwhile3:
	sw $t3, ($t0) #array[i/rootindex] = rootValue
	move $v0, $t3 #return array[i]
	
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, ($sp) #load back address of ra
	addi $sp, $sp, 12 #save the stack so we can return to sort
	
	jr $ra #return to sort

swap:
	addi $sp, $sp, -4 #save the stack so we can return to sort
	sw $ra, ($sp) #return to sort
#boring swap
	add $t1, $s0, $s2 #t1 = array[i]
	add $t2, $s0, $s3 #t2 = array[j]
	
	lw $a0, 0($t1)	#a0 = t1
	lw $a1, 0($t2) #a1 = t2
	sw $a1, 0($t1) #a1 = t1
	sw $a0, 0($t2) #a0 = t2
	move $v0, $a0 #return i
	move $v1, $a1 #return j
	
	lw $ra, ($sp) #load back address of ra
	addi $sp, $sp, 4 #save the stack so we can return to sort
jr $ra

getleftChildIndex: # return i*2 + 1
	addi $sp, $sp, -4 #save the stack so we can return to sort
	sw $ra, ($sp) #return to sort
	
	sll $v0, $a0, 1 #v0 = a0 * 2 
	addi $v0, $v0, 1 #v0 + 1
	
	lw $ra, ($sp) #load back address of ra
	addi $sp, $sp, 4 #save the stack so we can return to sort
jr $ra

getRightChildIndex: #return i*2 + 2
	addi $sp, $sp, -4 #save the stack so we can return to sort
	sw $ra, ($sp) #return to sort
	
	sll $v0, $a0, 1 #v0 = a0 * 2 
	addi $v0, $v0, 2 #v0 + 2
	
	lw $ra, ($sp) #load back address of ra
	addi $sp, $sp, 4 #save the stack so we can return to sort
jr $ra
