		.data
msg1:		.asciiz	"Please enter an integer for number of rows(up to 20): "
msg2:		.asciiz	"Please enter an integer for number of columns(up to 20): "
op1:		.asciiz	"    "	
op2:		.asciiz	" ___"
op3:		.asciiz	" "
op4:		.asciiz	"|"
op5:		.asciiz	"___"
op6:		.asciiz	"   "
rows:		.word	0
columns:	.word	0
area:		.word	0
wall:		.space	160000
sets:		.space	1600
		
		.text

main:		
		

getMazeSize:	la	$a0, msg1		
		li	$v0, 4
		syscall				#print	"Please enter an integer for number of rows(up to 20): "
		
		
		li	$v0, 5			
		syscall				#get rows
		sw	$v0, rows		
		
		
		la	$a0, msg2		
		li	$v0, 4
		syscall				#print "Please enter an integer for number of columns(up to 20): "
		
		
		li	$v0, 5			
		syscall				#get columns
		sw	$v0, columns
		
		
		lw	$t0, rows		#calculate area
		lw	$t1, columns
		mult	$t0, $t1
		mflo	$t0
		sw	$t0, area
		

		
build:		addi	$sp, $sp, -8		# adjust stack to make room for 2 items
		sw	$s1, 4($sp)		# save register $s1 for use afterwards 
		sw	$s2, 0($sp)		# save register $s2 for use afterwards
		
		
		li	$s1, 0			#i = 0

buildLoopi1:
		li	$s2, 0			#j = 0

buildLoopj1:		
		la	$a0, wall		
		move	$a1, $s1
		move	$a2, $s2
		jal	array			#get &wall[i][j]
		
		
		li	$t0, 1
		sb	$t0, ($a3)
		
		
		addi	$s2, $s2, 1		#j++
		
		
		lw	$t0, area
		blt	$s2, $t0, buildLoopj1	#if j < area
		
		
		addi	$s1, $s1, 1		#i++
		
		
		lw	$t0, area
		blt	$s1, $t0, buildLoopi1	#if i < area
		
		
		lw	$t0, columns
		addi	$t0, $t0, -1
		move	$s1, $t0		#i = columns - 1


buildLoopi2:	
		move	$t0, $s1		#i
		addi	$t1, $t0, 1		#i + 1
		la	$a0, wall		
		move	$a1, $t0
		move	$a2, $t1
		jal	array
		
		
		sb	$zero, ($a3)		#wall[i][i+1] = false;
		
		
		move	$t0, $s1		#i
		addi	$t1, $t0, 1		#i + 1
		la	$a0, wall		
		move	$a1, $t1
		move	$a2, $t0
		jal	array
		
		
		sb	$zero, ($a3)		#wall[i+1][i] = false;
		
		
		lw	$t0, columns
		add	$s1, $s1, $t0		#i = i + columns
		
		
		lw	$t0, area
		addi	$t0, $t0, -1		#area - 1
		blt	$s1, $t0, buildLoopi2	#if i < area - 1
		
		
		
		lw	$s2, 0($sp)       	# restore register $s2 for caller
		lw	$s1, 4($sp)       	# restore register $s1 for caller
		addi	$sp, $sp, 8  		# adjust stack to delete 2 items	
		

knockDown:	addi	$sp, $sp, -24		# adjust stack to make room for 6 items
		sw	$s5, 20($sp)		# save register $s5 for use afterwards
		sw	$s4, 16($sp)		# save register $s4 for use afterwards
		sw	$s3, 12($sp)		# save register $s3 for use afterwards
		sw	$s2, 8($sp)		# save register $s2 for use afterwards
		sw	$s1, 4($sp)		# save register $s1 for use afterwards 
		sw	$s0, 0($sp)		# save register $s0 for use afterwards
		
		
		li	$s0, 1			#times = 1
		li	$s1, 0			#a
		li	$s2, 0			#b
		li	$s3, 0			#c
		jal	DisjSets
		
		
while:		lw	$a1, area		
		li	$v0, 42
		syscall				#random number from 0 to area-1
		
		
		move	$s1, $a0		#set s1(a)
		
		
		li	$a1, 4			#random number from 0 to 3
		li	$v0, 42
		syscall
		
		
		addi	$s3, $a0, 1		#set s3(c)
		
		
		beq	$s3, 1, case1
		beq	$s3, 2, case2
		beq	$s3, 3, case3
		beq	$s3, 4, case4


case1:		lw	$t0, columns
		add	$s2, $s1, $t0
		j	switchbreak


case2:		lw	$t0, columns
		sub	$s2, $s1, $t0
		j	switchbreak


case3:		addi	$s2, $s1, 1
		j	switchbreak



case4:		addi	$s2, $s1, -1
		j	switchbreak		#set s2(b)
		


switchbreak:	ble	$s2, -1, ifend5		#if b <= -1
		lw	$t0, area
		bge	$s2, $t0, ifend5	#if b >= area
		
		
		la	$a0, wall		
		move	$a1, $s1
		move	$a2, $s2
		jal	array
		
		
		lb	$t0, ($a3)
		bne	$t0, 1, ifend5		#if wall[a][b] != 1
		
		
		move	$a0, $s1
		jal	find
		move	$s5, $a0		#s5 = find (s1)
		
		
		move	$a0, $s2
		jal	find
		move	$s6, $a0		#s6 = find (s2)
		
		
		beq	$s5, $s6, ifend5	#if find(s1) == find(s2)
		
		
		move	$a0, $s5
		move	$a1, $s6
		jal	union			#union(find(a),find(b));


		la	$a0, wall
		move	$a1, $s1
		move	$a2, $s2
		jal	array			
		
		
		sb	$zero, ($a3)		#wall[a][b] = false;
		
		
		la	$a0, wall
		move	$a1, $s2
		move	$a2, $s1
		jal	array			
		
		
		sb	$zero, ($a3)		#wall[b][a] = false;
		
		
		addi	$s0, $s0, 1
ifend5:		lw	$t0, area
		blt	$s0, $t0, while		#while (times < area)
		
		
		lw	$s0, 0($sp)        	# restore register $s0 for caller
		lw	$s1, 4($sp)       	# restore register $s1 for caller
		lw	$s2, 8($sp)        	# restore register $s2 for caller
		lw	$s3, 12($sp)        	# restore register $s3 for caller
		lw	$s4, 16($sp)        	# restore register $s4 for caller
		lw	$s5, 20($sp)        	# restore register $s5 for caller
		addi	$sp, $sp, 24   		# adjust stack to delete 6 items	

		
print:		addi	$sp, $sp, -8		# adjust stack to make room for 2 items
		sw	$s1, 4($sp)		# save register $s1 for use afterwards 
		sw	$s2, 0($sp)		# save register $s2 for use afterwards
		
		
		la	$a0, op1		
		li	$v0, 4
		syscall				#print "    "
		
		
		li	$s1, 1			#i=1
printLoopi1:	la	$a0, op2	
		li	$v0, 4
		syscall				#print " ___"
		addi	$s1, $s1, 1		#i++
		
		
		lw	$t0, columns
		blt	$s1, $t0,printLoopi1	#if i < columns
		
		
		li	$v0, 11			
		li	$a0, 10
		syscall				#println
		
		
		li	$s1, 0			#i = 0
printLoopi2:	beqz	$s1, l1			#if i == 0
		
		
		la	$a0, op4		
		li	$v0, 4
		syscall				#print "|"
		
		
		j	l2


l1:		la	$a0, op3		
		li	$v0, 4
		syscall				#print " "


l2:		li	$s2, 0			#j = 0
printLoopj1:	lw	$t0, rows
		addi	$t0, $t0, -1		#rows - 1
		bne	$s1, $t0, l3		#if i != rows - 1
		
		
		lw	$t0, columns
		addi	$t0, $t0, -1		#columns - 1
		bne	$s2, $t0, l3		#if j != columns - 1
		
		
		la	$a0, op6	
		li	$v0, 4
		syscall				#print "   "
		j	ifend1


l3:		lw	$t0, rows
		addi	$t0, $t0, -1		#rows - 1
		bne	$s1, $t0, l4		#if i != rows - 1
		
		
		la	$a0, op5	
		li	$v0, 4
		syscall				#print "___"
		
		
		j	ifend1	 


l4:		lw	$t0, columns		
		mult	$s1, $t0
		mflo	$t0
		add	$t0, $t0, $s2		#i * columns + j
		
		
		addi	$t1, $s1, 1
		lw	$t2, columns
		mult	$t1, $t2
		mflo	$t1
		add	$t1, $t1, $s2		#(i + 1) * columns + j
		
		
		la	$a0, wall
		move	$a1, $t0
		move	$a2, $t1
		jal	array
		
		
		lb	$t0, ($a3)		


		bne	$t0, 1, l5		#if wall[i * columns + j][(i + 1) * columns + j] != true
		la	$a0, op5	
		li	$v0, 4
		syscall				#print "___"
		
		
		j	ifend1


l5:		la	$a0, op6	
		li	$v0, 4
		syscall				#print "   "


ifend1:		lw	$t0, rows
		addi	$t0, $t0, -1		#rows - 1
		bne	$s1, $t0, l6		#if i != rows - 1
		
		
		lw	$t0, columns
		addi	$t0, $t0, -1		#columns - 1
		bne	$s2, $t0, l6		#if j != columns - 1
		
		
		la	$a0, op3	
		li	$v0, 4
		syscall				#print " "
		j	ifend2


l6:		lw	$t0, columns
		addi	$t0, $t0, -1		#columns - 1	
		bne	$s2, $t0, l7		#if j != columns - 1
		
		
		la	$a0, op4	
		li	$v0, 4
		syscall				#print "|"
		
		
		j	ifend2			


l7:		lw	$t0, columns		
		mult	$s1, $t0
		mflo	$t0
		add	$t0, $t0, $s2		#i * columns + j
		
		
		addi	$t1, $t0, 1		#i * columns + j + 1
		
		
		la	$a0, wall
		move	$a1, $t0
		move	$a2, $t1
		jal	array
		
		
		lb	$t0, ($a3)
		
		
		bne	$t0, 1, l8		#if wall[i * columns + j][i * columns + j + 1] != true
		la	$a0, op4	
		li	$v0, 4
		syscall				#print "|"
		
		
		j	ifend2


l8:		la	$a0, op3	
		li	$v0, 4
		syscall				#print " "
		

ifend2:		addi	$s2, $s2, 1		#j++
		lw	$t0, columns
		blt	$s2, $t0, printLoopj1	#if j < columns
		
		li	$v0, 11			
		li	$a0, 10
		syscall				#println
		
		addi	$s1, $s1, 1		#i++
		lw	$t0, rows
		blt	$s1, $t0, printLoopi2	#if i < rows
		
		

		lw	$s2, 0($sp)       	# restore register $s2 for caller
		lw	$s1, 4($sp)       	# restore register $s1 for caller
		addi	$sp, $sp, 8  		# adjust stack to delete 2 items

		
Exit:		li 	$v0, 10			#exit
		syscall
		
		
array:		# a = a0, i = a1, j = a2, &a[i][j] = a3
		addi	$sp, $sp, -4		# adjust stack to make room for 1 items
		sw	$s0, 0($sp)		# save register $s0 for use afterwards
		
		
		lw	$s0, area
		mult	$a1, $s0
		mflo	$s0
		add	$s0, $s0, $a2		# i * area + j
		add	$a3, $s0, $a0		#&a[i][j]
		
		
		lw	$s0, 0($sp)
		addi	$sp, $sp, 4		# restore register $s0 for caller
		jr	$ra			# adjust stack to delete 1 items
		
		
DisjSets:	addi	$sp, $sp, -4		# adjust stack to make room for 1 items
		sw	$s0, 0($sp)		# save register $s0 for use afterwards
		
		
		li	$s0, 0			#i = 0
DisjLoopi1:		
		li	$t1, 4
		mult	$s0, $t1		#i * 4	
		mflo	$t1
		la	$t0, sets
		add	$t0, $t0, $t1
		li	$t1, -1
		sw	$t1, ($t0)
		addi	$s0, $s0, 1
		lw	$t0, area
		blt	$s0, $t0, DisjLoopi1	#if i < area
		
		
		lw	$s0, 0($sp)		# restore register $s0 for caller
		addi	$sp, $sp, 4		# adjust stack to delete 1 items
		jr	$ra
		
		
union:		#a0 = root1, a1 = root2
		addi	$sp, $sp, -16		# adjust stack to make room for 4 items
		sw	$s3, 12($sp)		# save register $s3 for use afterwards
		sw	$s2, 8($sp)		# save register $s2 for use afterwards
		sw	$s1, 4($sp)		# save register $s1 for use afterwards 
		sw	$s0, 0($sp)		# save register $s0 for use afterwards
		
		
		la	$t0, sets		
		li	$t1, 4
		mult	$a0, $t1
		mflo	$t1			
		add	$s0, $t0, $t1		#root1 ad.
		
		
		la	$t1, sets		
		li	$t2, 4
		mult	$a1, $t2
		mflo	$t2
		add	$s1, $t1,$t2		#root2 ad.
		
		
		lw	$s3, ($s0)		#s[root1]
		lw	$s4, ($s1)		#s[root2]
		
		
		ble	$s3, $s4, d1
		sw	$a1, ($s0)		#s[ root1 ] = root2; 
		j	ifend3


d1:		bne	$s3, $s4, d2
		addi	$t5, $s3, -1
		sw	$t5, ($s0)		#s[root1]--


d2:		sw	$a0, ($s1)		#s[ root2 ] = root1;


ifend3:
		lw	$s0, 0($sp)        	# restore register $s0 for caller
		lw	$s1, 4($sp)       	# restore register $s1 for caller
		lw	$s2, 8($sp)        	# restore register $s2 for caller
		lw	$s3, 16($sp)        	# restore register $s3 for caller
		addi	$sp, $sp, 16    	# adjust stack to delete 4 items
		jr	$ra
		
		
find:		#a0 = x
		la	$t0, sets		
		li	$t1, 4
		mult	$a0, $t1
		mflo	$t1
		add	$t0, $t0, $t1		#&s[x].
		lw	$t2, ($t0)		#s[x]
		
		
		bge	$t2, $zero, d3		#if
		j	ifend4			#return


d3:		move	$a0, $t2
		j	find			#recursion
		
		
ifend4:		jr	$ra


		 
		
		.
		
		

		
