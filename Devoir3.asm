
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
	move $s7, $s2 #save original size
	
	move $a0, $s1 # arg1 sort index
	move $a1, $s2 #arg2 sort sizeof
	jal heapsort
	
	la $a0, PrintElements
	li $v0, 4 #Ready to print a string
	syscall
	
	#print array Fully Functional
	move $t0, $0 #int i = 0
	printarray: #print out contents of array
		beq $t0, $s7, endloop # while (i < sizeof)
		sll $t2, $t0, 2 #index = i*4
		add $t2, $t2, $s0 #array[index]
		lw $a0, ($t2) #a0 = array[index]
		li $v0, 1 #print number
		syscall
		li $v0, 4 #print string
		la $a0, space #\n
		syscall
		addi $t0, $t0, 1 #i++
		j printarray
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
	addi $sp, $sp, -4 #save the stack so we can return to sort
	sw $ra, ($sp) #return to sort
	
	addi $s2, $s2, -1 #s2 = n = sizeof-1
	addi $s3, $s2, -1 #s3 = n - 1
	srl $s3, $s3, 1 #i = s3= t3/2 = (n-1)/2
	#s2 = n; s3 = i
	while:
		move $a0, $s3 # i
		move $a1, $s2 # n
		jal fixHeap #void function ;fixheap(i, n)
		beq $s3, $0, endwhile #while i > 0 ; i = (n-1)/2
		addi $s3, $s3, -1 #i--
		j while
		#end while loop
	endwhile:
	#s2 = n; s3 = 0
	#move $s2, $s7
	while2:
		beq $s2, $0, endwhile2 #while (n > 0)
			move $a0, $0 # a0 = 0
			move $a1, $s2 # a1 = s2 = n
			jal swap # swap(0, n) return void
			addi $s2, $s2, -1 # s2--; n--
			move $a0, $0# $a0 = 0
			move $a1, $s2 # $a1 = s2 = n
			jal fixHeap # fixheap(0,n) returns void 
			j while2 #loop back to while2
	#end while loop	
	endwhile2: #exit to return to main	
	
		lw $ra, ($sp) #load back address of ra
		addi $sp, $sp, 8 #save the stack so we can return to sort
		jr $ra #return to main
fixHeap:
#s0=base, #s1 = lastindex, #s2 = n, #s3 = i, #s4 = index, #s5 = rootvalue
#s3 = leftchildindex, #s6 = rightchildindex #s7 = original size
	addi $sp, $sp, -8 #save the stack so we can return to sort
	sw $ra, ($sp) #return to sort
	sw $s3, 4($sp) #save s3 value 
	
	
	move $s4, $a0 #s4 = i <= rootindex;
	move $s1, $a1 #s1 = n <= lastindex
	sll $t0, $s4, 2 #t0 = rootindex = i * 4;
	add $t0, $t0, $s0 #$t0 = array[rootindex] = array[i*4]
	
	lw $s5, ($t0) #$t2 = rootvalue = array[rootindex]
	 
	
	move $t7, $0 #more = true
	while3: # while more = true
		bnez $t7, endwhile3 #more = false => endloop
		move $a0, $s4 #getleftchild(rootindex); s4 = rootindex
		jal getleftChildIndex
		move $s3, $v0 # s3 = leftchildindex = getleftchildindex(rootindex)
		
		bgt $s3, $s1, elsechildleft #if (leftchildindex <= lastindex) == 2*i+1 <= n
			
			move $a0, $s4 #getRightChildIndex(rootindex)
			jal getRightChildIndex
			move $s6, $v0 #rightchildindex = getRightChildIndex(rootindex) == 2*i+2
			#if2 part 1: rightchildindex <= lastindex
			bgt $s6, $s1, ifroot #if rightchildindex <= lastindex == 2*i+2 <= n
		
			#&&
			#we must now compare the data within
				sll $t3, $s3, 2 # t3 = leftchildindex*4
				sll $t4, $s6, 2 # t4 = rightchildindex*4
				add $t3, $t3, $s0 #t3 = array[leftchildindex] == array[2*(i*4)+2]
				add $t4, $t4, $s0 #t4 = array[rightchildindex] == array[2*(i*4)+1]
				lw $t3, ($t3) #load to address left
				lw $t4, ($t4) #load to address right
				move $t9, $0 #clear $t9 to be safe
	
			#if2 part 2 array[rightchild] > array[leftchild]
			bge $t3, $t4, ifroot #if array[rightchild] > array[leftchild] == array[2*(i*4)+2] > array[2*(i*4)+1]
			move $s3, $s6 #leftchild = rightchild
		
			ifroot:
				sll $t3, $s3, 2 # t3 = leftchildindex*4
				add $t3, $t3, $s0 #t3 = array[leftchildindex] == array[2*(i*4)+2]
				lw $t0, ($t3) #load to address left
				
				ble $t0, $s5, elsechildright #if array[leftchildindex] > rootValue
				sll $t2, $s4, 2 # t2 = index*4
				add $t2, $t2, $s0 #t2 = array[index]
				
				sw $t0, ($t2) #array[index] = array[leftchildindex]
				move $s4, $s3 #index = leftchildindex ; s4 now holds updated value
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
		move $t9, $0 #fix attempt
		sll $t9, $s4, 2 #rootindex*4
		add $t9, $t9, $s0 # array[rootindex]
		sw $s5, ($t9) #array[i/rootindex] = rootValue
	
		lw $s3, 4($sp)
		lw $ra, ($sp) #load back address of ra
		addi $sp, $sp, 8 #save the stack so we can return to sort
	
		jr $ra #return to sort

swap:
	addi $sp, $sp, -16 #save the stack so we can return to sort
	sw $ra, ($sp) #return to sort
	
		#boring swap
		sll $t0, $a0, 2 #i*4
		sll $t1, $a1, 2 #j*4
		add $t1, $t1, $s0 #t1 = array[j]
		add $t0, $t0, $s0 #t0 = array[i]
	
		lw $t3, ($t1)	#t3 = array[i]
		lw $t2, ($t0) #t2 = array[j]
		sw $t3, ($t0) #t3 = t0
		sw $t2, ($t1) #t2 = t1
		
	
	lw $ra, ($sp) #load back address of ra
	addi $sp, $sp, 16 #save the stack so we can return to sort
	
	jr $ra

getleftChildIndex: # return i*2 + 1
	addi $sp, $sp, -16 #save the stack so we can return to sort
	sw $ra, ($sp) #return to sort
	
		sll $v0, $a0, 1 #v0 = a0 * 2 
		addi $v0, $v0, 1 #v0 + 1
	
	lw $ra, ($sp) #load back address of ra
	addi $sp, $sp, 16 #save the stack so we can return to sort
	
	jr $ra

getRightChildIndex: #return i*2 + 2
	addi $sp, $sp, -16 #save the stack so we can return to sort
	sw $ra, ($sp) #return to sort
	
		sll $v0, $a0, 1 #v0 = a0 * 2 
		addi $v0, $v0, 2 #v0 + 2
	
	lw $ra, ($sp) #load back address of ra
	addi $sp, $sp, 16 #save the stack so we can return to sort
	
	jr $ra
