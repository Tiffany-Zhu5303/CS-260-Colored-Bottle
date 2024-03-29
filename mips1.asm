.data
# DONOTMODIFYTHISLINE
frameBuffer: .space 0x8000 # 512 wide X 256 high pixels
w: .word 100 # width of bottle
h: .word 75 # height of bottle
l: .word 75 # length of bottle 
bgcol: .word 0x00E6CC99 #0xE4D395
# DONOTMODIFYTHISLINE
# Your variables go BELOW here only (and above .text)
.text
main:
		la $t0, frameBuffer		# load frame buffer address
	 	li $t1, 0x20000			# save 512 wide X 256 high pixels
		lw $t2, bgcol 			# load background color
		lw $s0, w			# load width
		lw $s1, h			# load height
		lw $s2, l			# load length
colorPixels: 	sw $t2, 0($t0)			# initialize frame with color
		addi $t0, $t0, 4		# next pixel of frame
		addi $t1, $t1, -1		# pixels left
		bne $t1, $zero, colorPixels 	# if t1 != 0 then continue to loop
		slti $t3, $s0, 62		# if w < cap width + 2 then t3 <- 1; else t3 <-0
		addi $t4, $zero, 1		# t4 <- 1
		beq $t3, $t4, exit		# exit if width < cap width + 2
		slt $t1, $s1, $zero		# if h < 0 then t1 <- 1; else t1 <- 0
		beq $t1, $t4, exit		# exit if h < 0
		slt $t1, $s2, $zero		# if l < 0 then t1 <- 1; else t1 <- 0
		beq $t1, $t4, exit		# exit if l < 0
		andi $t1, $s0, 0x0001		# last bit of w
		beq $t1, $t4, exit		# if w is odd then exit
		addi $t1, $zero, 64		# t1 <- 64
		add $t1, $t1, $s1		# t1 <- 64 + h
		add $t1, $t1, $s2		# t1 <- 64 + h + l
		add $t3, $zero, $s0		# t3 <- w
		addi $t3, $t3, -48		# t3 <- w - 48
		srl $t3, $t3, 1			# t3 <- (w - 48)/2
		add $t1, $t1, $t3		# t1 <- 64 + h + l + ( (w - 48)/2 ) 
		andi $t3, $t1, 0x001		# last bit of bottle height
		beq $t3, $t4, exit		# exit if height is odd
		add $t7, $zero, $t1		# t7 <- t1
		add $t4, $zero, 256		# t4 <- frame height
		slt $t3, $t4, $t1		# if frame height < bottle height then t3 <- 1; else t3 <- 0
		addi $t4, $zero, 1		# t4 <-1
		beq $t3, $t4, exit		# exit if frame height < bottle height
		addi $t1, $zero, 1		# t1 <- 1
		slt $t3, $s1, $t1		# t3 <- 1 if h < 1; else t3 <- 0
		slt $t4, $s2, $t1		# t4 <- 1 if l < 1; else t3 <- 0
		bne $t3, $t4, success		# if they are not the same number then move on
		beq $t1, $t3, exit		# exit if h < 1  and l < 1
		addi $t1, $zero, 512		# t1 <- frame width
		slt $t3, $t1, $s0		# if 512 < w then t3 <- 1; else t3 <-0
		addi $t4, $zero, 1		# t4 <- 1
		beq $t3, $t4, exit		# exit if bottle width > frame width 
success:	li $t2, 0x0000FF		# load blue color
		la $t0, frameBuffer		# load frame buffer address
		add $t1, $zero, $t7		# t1 <- bottle height
		srl $t1, $t1, 1			# t1 <- 0.5*(bottle height)
		addi $t3, $zero, 128		# t3 <-frame height*0.5
		sub $t1, $t3, $t1		# t1 <- 0*5(frame height) - 0.5*(bottle height)
		addi $t0, $t0, 904		# starting center position of cap
skip:		add $t0, $t0, 2048		# skip row
		addi $t1, $t1, -1		# num rows left
		bne $t1, $zero, skip		# if rows not done then loop
		addi $t1, $zero, 1920		# cap pixels to fill
		addi $t3, $zero, 60		# cap width counter
		addi $t4, $zero, 32		# cap height counter
colorCap: 	sw $t2, 0($t0)			# initialize cap with color
		addi $t0, $t0, 4		# next pixel of cap
		addi $t1, $t1, -1		# pixels left to fill
		addi $t3, $t3, -1		# pixels left in the row
		beq $t3, $zero, nextRo		# if t3 == 0 jump to next column
		bne $t1, $zero, colorCap	# if t1 != 0 then continue coloring the cap
		j endCap			# cap finished
nextRo: 	addi $t0, $t0, 1808		# next column
		addi $t3, $zero, 60		# reset cap width counter
		addi $t4, $t4, -1		# num rows left
		bne $t4, $zero, colorCap	# if t4 != 0 then continue coloring the cap
endCap: 	addi $t0, $t0, 24		# bottle neck starting position
		lw $t2, bgcol			# load background color
		srl $t2, $t2, 1			# glass color
		addi $t1, $zero, 1536		# pixels to fill for bottle neck
		addi $t3, $zero, 48		# bottle neck width counter
		addi $t4, $zero, 32		# bottle neck height counter
bottleNeck:	sw $t2, 0($t0)			# initialize bottle neck with color
		addi $t0, $t0, 4		# next pixel of bottle neck
		addi $t1, $t1, -1		# pixels left to fill
		addi $t3, $t3, -1		# pixels left in the row
		beq $t3, $zero, nextRow		# if t1 == 0 jump to next row
		bne $t1, $zero, bottleNeck	# if t1 != 0 then continue coloring the bottle neck
		j endBottleNeck			# bottle neck finished
nextRow: 	addi $t0, $t0, 1856		# next row
		addi $t3, $zero, 48		# reset bottle neck width counter
		addi $t4, $t4, -1		# num rows left
		bne $t4, $zero, bottleNeck	# if t4 != 0 then continue coloring the bottle neck
endBottleNeck:  add $t1, $zero, $s0		# t1 <- w
		addi $t1, $t1, -48		# t1 <- w - 48
		srl $t1, $t1, 1			# t1 <- (w - 48)/2; to figure out height of tapered flask
		addi $t3, $zero, 48		# tapered glass width counter
		add $t4, $zero, $t1		# tapered glass height counter
		addi $t5, $zero, 48		# tapered glass width copy
		addi $t6, $zero, 1852		# tapered glass spacing 
taperedFlask:	sw $t2, 0($t0)			# color tapered flask
		addi $t0, $t0, 4		# next pixel of bottle neck
		addi $t3, $t3, -1		# pixels left in the row
		beq $t3, $zero, nextR		# if t3 == 0 jump to next column
		bne $t3, $s0, taperedFlask	# if t3 != 0 then continue coloring the bottle neck
		j endTaperedFlask		# tapered flask done
nextR: 		add $t0, $t0, $t6		# next column
		addi $t6, $t6, -8		# decrease gap between rows
		addi $t5, $t5, 2		# increase row length
		add $t3, $zero, $t5		# reset bottle neck width counter
		addi $t4, $t4, -1		# num columns left
		bne $t4, $zero, taperedFlask	# if t3 != 0 then continue coloring the bottle neck
endTaperedFlask:add $t1, $zero, $s0		# t1 <- w
		add $t3, $zero, $s1		# t3 <- h
		add $t4, $zero, $t1		# width counter
		add $t5, $zero, $t3		# height counter
		add $t6, $t6, 4			# extend space between rows
colorBottle: 	sw $t2, 0($t0)			# color glass bottle
		addi $t0, $t0, 4		# next pixel
		addi $t4, $t4, -1		# num pixels left
		bne $t4, $zero, colorBottle	# if row is not done then loop
		add $t0, $t0, $t6		# next row
		add $t4, $zero, $t1		# refill pixel count
		add $t5, $t5, -1		# decrease row count
		bne $t5, $zero, colorBottle	# if bottle isn't done then loop
		lw $t2, bgcol			# reset to background color
		srl $t3, $t2, 16		# extract red bits
		andi $t3, $t3, 0xFF		# mask off lower bits
		andi $t4, $t2, 0xFF		# blue bits
		sll $t4, $t4, 16		# shift blue bits
		andi $t5, $t2, 0xFF00		# extract green bits
		or $t2, $t3, $t4		# swap red and blue bits
		or $t2, $t2, $t5		# add green bits
		add $t3, $zero, $s2		# t3 <- l
		add $t4, $zero, $t1		# width counter
		add $t5, $zero, $t3		# length counter
colorLiquid:	sw $t2, 0($t0)			# color liquid
		addi $t0, $t0, 4		# next pixel
		addi $t4, $t4, -1		# num pixels left
		bne $t4, $zero, colorLiquid	# if row is not done then loop
		add $t0, $t0, $t6		# next row
		add $t4, $zero, $t1		# refill pixel count
		add $t5, $t5, -1		# decrease row count	
		bne $t5, $zero, colorLiquid	# if liquid isn't done then loop
exit: 		li $v0, 10			# exit code
syscall 					# exit to OS  
