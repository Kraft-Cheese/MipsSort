
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
#saved registers $s0=base address, $s1=lastindex, $s2=sizeof $s3 = n, $s4 = i, $s5=array, $s6, $s7

	lui $s0, 0x1004 #start array at address 0x1004
	jal init #Initialize the array with user input
	
	move $s1, $v0 #save index
	move $s2, $v1 #save sizeof
	
	move $a0, $s1 # arg1 sort index
	move $a1, $s2 #arg2 sort sizeof
	jal heapsort
	
	la $a0, PrintElements
	li $v0, 4 #Ready to print a string
	syscall
	
	#print array Fully Functional
	move $t0, $0
	printloop: #print out contents of array
		beq $t0, $s2, endloop # while (i < sizeof)
		sll $t2, $t0, 2 #index = i*4
		add $t2, $t2, $s0 #array[index]
		lw $a0, ($t2) #a0 = array[index]
		li $v0, 1 #print number
		syscall
		li $v0, 4 #print string
		la $a0, newline #\n
		syscall
		addi $t0, $t0, 1 #i++
		j printloop
	endloop:
	

exit:

li $v0, 10 #end the program
syscall


init:	#Fully Functional
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

heapsort:

	#int n = sizeof - 1
	addi $s2, $s2, -1 #s2 = n = sizeof-1
	addi $t3, $s2, -1 #t3 = n - 1
	srl $s3, $t3, 1 #i = s4= t3/2 = (n-1)/2
	#s2 = n
	#s3 = i
	while:
		beq $s3, $0, endwhile #while i >= 0 ; i = (n-1)/2
		move $a0, $s3 # i
		move $a1, $s2 # n
		jal fixHeap #void function ;fixheap(i, n)
		addi $s3, $s3, -1 #i--
		#end while loop
	endwhile:
	#s2 = n
	while2:
		beq $s2, $0, endwhile2 #while (n > 0)
			move $a0, $0
			move $a1, $s2 # n
			jal swap # swap(0, n); void function
			addi $s2, $s2, -1 # $t2 -= 1; or minus an elem; n--
			move $a0, $0# $a0 = 0
			move $a1, $s2 # $a1 = s3 = n
			jal fixHeap # fixheap(0,n); void function
			j while2 #loop back to while2
	#end while loop	
	endwhile2: #exit to return to main	

		jr $ra

fixHeap:
#s0=base, #s1 = lastindex, #s2 = n, #s3 = i, #s4 = index, #s5 = rootvalue
#s3 = leftchildindex, #s6 = rightchildindex
	addi $sp, $sp, -8 #save the stack so we can return to sort
	sw $ra, ($sp) #return to sort
	sw $s3, 4($sp)
	
	
	move $s4, $a0 #s4 = i <= rootindex;
	move $s1, $a1 #s1 = n <= lastindex (already *4)
	sll $t0, $s4, 2 #t0 = rootindex = i * 4; 4 as 4bits are needed per integer
	add $t0, $t0, $s0 #$t0 = array[rootindex] = array[i*4]
	lw $s5, ($t0) #$t2 = rootvalue = array[rootindex]
	 
	# while more = true
	move $t7, $0 #more = true
	while3:
		bnez $t7, endwhile3 #more = false => endloop
		move $a0, $s4 #set 1st parameter of getleftchild(index) to a0
		jal getleftChildIndex
		move $s3, $v0 #$t6 = leftchildindex = getleftchildindex(index) == 2*(i*4)+1
		bgt $s3, $s1, elsechildleft #if leftchildindex <= lastindex == 2*(i*4)+1 <= n*4
			move $a0, $s4 #getRightChildIndex(index)
			jal getRightChildIndex
			move $s6, $v0 #rightchildindex = getRightChildIndex(index) == 2*(i*4)+2
			#if part 1: rightchildindex <= lastindex
			bgt $s6, $s1, elsechildright #if rightchildindex <= lastindex == 2*(i*4)+2 <= n*4
		
			#&&
		
			add $t3, $s3, $s0 #t3 = array[leftchildindex] == array[2*(i*4)+2]
			add $t4, $s6, $s0 #t4 = array[rightchildindex] == array[2*(i*4)+1]
			lw $t3, ($t3) #sets to address left
			lw $t4, ($t4) #sets to address right
			move $t9, $0 #clear $t9
	
			#if part 2 array[rightchild] > array[leftchild]
			bge $t4, $t3, ifroot #if array[rightchild] > array[leftchild] == array[2*(i*4)+2] > array[2*(i*4)+1]
			move $s3, $s6 #leftchild = rightchild
		
			ifroot:
			ble $t3, $s5, elsechildright #if array[leftchildindex] > rootValue
		
				add $t9, $t3, $s0 #t9 = array[leftchildindex] 
				lw $t9, ($t9) #load to address
				sw $t9, ($s4) #array[index] = array[leftchildindex]
				move $s4, $s3 #index = leftchildindex
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
		
		sw $s5, ($s4) #array[i/rootindex] = rootValue ####ERROR#### Address Unaligned on Boundary
	
		lw $s3, 4($sp)
		lw $ra, ($sp) #load back address of ra
		addi $sp, $sp, 8 #save the stack so we can return to sort
	
		jr $ra #return to sort

swap:
	addi $sp, $sp, -16 #save the stack so we can return to sort
	sw $ra, ($sp) #return to sort
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t3, 12($sp)
	
		#boring swap
		sll $t0, $a0, 2 #i*4
		sll $t1, $a1, 2 #j*4
		add $t1, $t1, $s0 #t1 = array[i]
		add $t3, $t3, $s0 #t2 = array[j]
	
		lw $a0, ($t1)	#a0 = array[i]
		lw $a1, ($t3) #a1 = array[j]
		sw $a1, ($t1) #a1 = t1
		sw $a0, ($t3) #a0 = t2
	
	lw $t3 12($sp)
	lw $t1 8($sp)
	lw $t0 4($sp)
	lw $ra, ($sp) #load back address of ra
	addi $sp, $sp, 16 #save the stack so we can return to sort
	
	jr $ra

getleftChildIndex: # return i*2 + 1
	addi $sp, $sp, -16 #save the stack so we can return to sort
	sw $ra, ($sp) #return to sort
	sw $t3, 4($sp)
	sw $t1, 8($sp)
	sw $t0, 12($sp)
	
		sll $v0, $a0, 1 #v0 = a0 * 2 
		addi $v0, $v0, 1 #v0 + 1
	
	lw $t0, 12($sp)
	lw $t1, 8($sp)
	lw $t3, 4($sp)
	lw $ra, ($sp) #load back address of ra
	addi $sp, $sp, 16 #save the stack so we can return to sort
	
	jr $ra

getRightChildIndex: #return i*2 + 2
	addi $sp, $sp, -16 #save the stack so we can return to sort
	sw $ra, ($sp) #return to sort
	sw $t3, 4($sp)
	sw $t1, 8($sp)
	sw $t0, 12($sp)
	
		sll $v0, $a0, 1 #v0 = a0 * 2 
		addi $v0, $v0, 2 #v0 + 2
	
	lw $t0, 12($sp)
	lw $t1, 8($sp)
	lw $t3, 4($sp)
	lw $ra, ($sp) #load back address of ra
	addi $sp, $sp, 16 #save the stack so we can return to sort
	
	jr $ra
