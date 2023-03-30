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
	move $t0, $0 #t0 = i = 0
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
# return i*2 + 1
	sll $v0, $a0, 1 #v0 = a0 * 2 
	addi $v0, $v0, 1 #v0 + 1
jr $ra

getRightChildIndex:
#return i*2 + 2
	sll $v0, $a0, 1 #v0 = a0 * 2 
	addi $v0, $v0, 2 #v0 + 2
jr $ra

sort:
	
#set values
	#int n = sizeof - 1
	move $t6, $s1 #n = sizeof
	sub $t6, $t6, 1 # n = n-1
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
		move s4, s3 #s4 = s3
		move s5, s2 #s5 = s2
		jal fixHeap
		j while2
	#end while loop	
endwhile2:	

jr $ra

fixHeap:
	addi $sp, $sp, -4 #save the stack so we can return to sort
	sw $ra, ($sp) #return to sort
	move $s4, $a0 #first param, i <= rootindex
	sll $t2, $s4, 2 #t2 = i * 4; 4 as 4bits are needed per integer
	add $t2, $t2, $s0 #t2 = array[i]
	lw $s5, ($t2) #rootvalue = array[i/rootindex]
	 
# while more = true
move $t7, $0 #move = true
while3:
	bnez $t7, endwhile3 #more = false => endloop
	move $a0, $s4 #set 1st parameter of getleftchild(int ) to a0
	jal getLeftChildIndex
	move $s6, $v0 #returned index  of getleftchild
	bgt $s6, $a1, endifchildleft #if leftchildindex <= lastindex (a1 = 2nd parameter)
		#rightchild = getRightChildIndex
		jal getRightChildIndex
		move $s7, $v0 #returned index of rightchild
		bgt $s7, $a1, elsechildright #if rightchild <= lastindex and 
		sll $t3, $s7, 2 #t3 = rightchild*4
		add $t3, $t3, $s0 #t3 = array[rightchild]
		sll $t4, $s6, 2 #t3 = leftchild*4
		add $t4, $t4, $s0 #t4 = array[leftchild]
		lw $t4, ($t4) #sets to address
		lw $t3, ($t3) #sets to address
		#if array[rightchild] > array[leftchild]
		bge $t4, $t3, elsechildright
		move $t4, $t3 #leftchild = rightchild
		#if array[leftchild] > rootValue
		ble $t4, $t2, elsechildright
		move $t3, $0 #clear t3
		sll $t3, $s6, 2 #t3 = leftchild * 4; integer
		add $t3, $t3, $s0 #t3 = array[leftchild] 
		lw $t3, ($t3) #load to address
		sw $t3, ($t2) #array[i] = array[leftchild]
		move $s4, $s6 #i = leftchild
		j while3
		#else
		elsechildright:
			addi $t7, $t7, 1 #move = false
			j while3
		#endif
	#else 
	elsechildleft:
		addi $t7, $t7, 1 #move = false
		j while3
	
	#endif
	
	j while3
endwhile3:
	sw $s5, ($t0) #array[i/rootindex] = rootValue

lw $ra, ($sp) #load back address of ra
addi $sp, $sp, 4 #save the stack so we can return to sort
	
jr $ra #return to sort
