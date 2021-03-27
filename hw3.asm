# Kevin Li
# kevinli8
# 113347865

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text

# int, int load_game(GameState* state, string filename)
load_game:
	addi $sp, $sp, -32	# The input buffer occupies 16($sp)	
	sw $ra, 0($sp)	
	sw $s0, 4($sp)	# Stores state
	sw $s1, 8($sp)	# Stores file descriptor
	sw $s2, 12($sp)	# Stores address of input buffer
	sw $s3, 16($sp)	# Temporary but important storage
	sw $s4, 20($sp)	# Convenient to store $s0 for later
	sw $s5, 24($sp)	# Store total amount of stones
	# ===========================================================
	move $s0, $a0		# Store state so it isn't overwritten
	addi $s2, $sp, 28	# Store address of input buffer which is at 20($sp)
	move $s4, $s0		# Store state again for later
	li $s5, 0		# Total amount of stones is 0 at beginning
	
	# Open board file
	li $v0, 13	
	move $a0, $a1	# Move file name to $a0
	li $a1, 0	# Move reading flag to $a1
	syscall
	move $s1, $v0	# Save file descriptor
	bgtz $s1, read
	# File does not exist, close board file then return -1, -1
	li $v0, 16	
	move $a0, $s1	# Move file descriptor to $a0
	syscall
	li $v0, -1
	li $v1, -1
	j end

	read:
	# Read # of top mancala stones (first line) + put it into board
	move $a0, $s1		# Move file descriptor to $a0
	move $a1, $s2		# Move input buffer to $a1
	jal readLine
	sb $v0, 1($s0)		# Store first line's value into byte 1 of state (top_mancala)
	
	move $t0, $v1		# Copy 2-digit ASCII into $t0
	srl $t0, $t0, 8		# Move tens digit into ones digit
	sb $t0, 6($s0)		# Store tens digit of top_mancula into byte 6 of state
	andi $v1, $v1, 0x00FF	# Only care about the last 8 bits of $v1 (ones digit)
	sb $v1, 7($s0)		# Store ones digit of top_mancula into byte 7 of state
	
	# Read # of bottom mancala stones (second line) [can't put it into board yet]
	move $a0, $s1		
	move $a1, $s2		
	jal readLine
	sb $v0, 0($s0)		# Store second line's value into byte 0 of state (bot_mancala)
	move $s3, $v1		# Save $v1 for when I know the amount of pockets there are
	# Read # of pockets per row (third line)
	move $a0, $s1		
	move $a1, $s2		
	jal readLine
	sb $v0, 2($s0)		# Store third line's value into byte 2 of state (bot_pockets)
	sb $v0, 3($s0)		# Store third line's value into byte 3 of state (top_pockets)
		# Subtask: fill last 2 bytes of game_board
		sll $v0, $v0, 2		# Multiply pockets by 4 so I can reach the last 2 bytes of game_board
		addi $v0, $v0, 8	# Add the first 8 bytes
		add $s0, $s0, $v0	# Advance state to the second to last digit
		move $t0, $s3		# Copy 2-digit ASCII into $t0
		srl $t0, $t0, 8		# Move tens digit into ones digit
		sb $t0, 0($s0)		# Store tens digit of bot_mancula into 2nd to last byte of state
		andi $s3, $s3, 0x00FF	# Only care about the last 8 bits of $s3 (ones digit)
		sb $s3, 1($s0)		# Store ones digit of bot_mancula into last byte of state
		sb $0, 2($s0)		# Not necessary - just here for debugging gameE3.txt
		sub $s0, $s0, $v0	# Move state back to original position
		
	# moves_executed is 0 at the beginning
	sb $0, 4($s0)
	
	# player_turn is 'B' at the beginning
	li $t0, 'B'		# Player 1
	sb $t0, 5($s0)		# Store 'B' into byte 5 of state (player_turn)

	# Loop to read contents of top row (fourth line)
	lbu $s3, 2($s0)		# Number of pockets
	move $t3, $s3		# Need to use $s3 again next loop
	addi $s0, $s0, 8	# Move board state to byte 8
	
	move $a0, $s1		# Move file descriptor to $a0
	move $a1, $s2		# Move input buffer to $a1
	li $a2, 2		# Read 2 characters at once into buffer
	top_contents_loop:
	li $v0, 14		# Read syscall
	syscall
	lbu $t0, 0($s2)		# Read first character from input buffer
	lbu $t1, 1($s2)		# Read second character from input buffer
	# Subtask: convert 2 digits to number to add to stones count
	# addi $t4, $t1, -48
	# add $s5, $s5, $t4	# Adds one digit to $s5
	# li $t4, '0'
	# beq $t0, $t4, store_top_pocket
	# addi $t4, $t0, -48	# Convert tens digit to numerical value
	# li $t5, 10
	# mult $t4, $t5		# Multiply by 10
	# mflo $t4
	# add $s5, $s5, $t4	# Add tens digit to $s5
			
	store_top_pocket:
	sb $t0, 0($s0)		# Store tens digit into pocket
	sb $t1, 1($s0)		# Store ones digit into pocket
	addi $s0, $s0, 2	# Move on to next pocket
	addi $t3, $t3, -1	
	bgtz $t3, top_contents_loop
	
	# Loop to read contents of bottom row (fifth line) [first skip past \r\n or \n]
	li $a2, 1		# Set amount of characters to read to 1
	li $v0, 14
	syscall
	li $t0, '\r'
	lbu $t1, 0($s2)
	bne $t0, $t1, bot_contents_loop
	li $v0, 14		# \r skipped, now skip the \n
	syscall			
	bot_contents_loop:
	li $v0, 14		# Read syscall
	li $a2, 2		# Set amount of characters to read back to 2
	syscall
	lbu $t0, 0($s2)		# Read first character from input buffer
	lbu $t1, 1($s2)		# Read second character from input buffer	
	# Subtask: convert 2 digits to number to add to stones count
	# addi $t4, $t1, -48
	# add $s5, $s5, $t4	# Adds one digit to $s5
	# li $t4, '0'
	# beq $t0, $t4, store_top_pocket
	# addi $t4, $t0, -48	# Convert tens digit to numerical value
	# li $t5, 10
	# mult $t4, $t5		# Multiply by 10
	# mflo $t4
	# add $s5, $s5, $t4	# Add tens digit to $s5
			
	store_bot_pocket:
	sb $t0, 0($s0)		# Store tens digit into pocket
	sb $t1, 1($s0)		# Store ones digit into pocket
	addi $s0, $s0, 2	# Move on to next pocket
	addi $s3, $s3, -1	
	bgtz $s3, bot_contents_loop

	# Close board file
	li $v0, 16	
	move $a0, $s1	# Move file descriptor to $a0
	syscall

	end: 	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 32
	jr $ra
	
# ($a0: int fd, $a1: int buffer) -> Returns multi (or single)-digit value from file, and 2-digit ASCII value
readLine:
	# 20-31 is 12 bytes to store a 12-char long string. Largest int is only 10 digits.
	# Use 12 instead of 10 to align with a word boundary.
	addi $sp, $sp, -24	
	sw $ra, 0($sp)
	sw $s0, 4($sp)		# Store length of value
	sw $s1, 8($sp)		# Store string being read
	# ===========================================================
	addi $s1, $sp, 12	# Store address of string which is from 12($sp) to 23($sp)

	# First, find length of value 
	li $s0, 0		# Length of value
	li $a2, 1		# Read 1 character (fd and input buffer are already in the correct slots of $a0 and $a1)
	li $t0, '\r'
	li $t1, '\n'
	findLengthLoop: 
		li $v0, 14
		syscall				# Read 1 character to input buffer
		lbu $t2, 0($a1)			# Load character from input buffer
		beq $t2, $t0, foundSlashR
		beq $t2, $t1, foundSlashN
		j continue_length_loop
		foundSlashR:			# Skip \n character (in case of \r\n to end line)
			li $v0, 14
			syscall
		foundSlashN:			# Skip character (\n)
			j find2DigitASCII
		continue_length_loop:	
			addi $s0, $s0, 1	# Increment length
			sb $t2, 0($s1)		# Store character in string
			addi $s1, $s1, 1	# Increment string pointer
			j findLengthLoop
	
	find2DigitASCII:
	sb $0, 0($s1)		# Null terminate string, just feel like doing it
	move $t1, $s1		# Copy string into $t1
	# Subtask: put "00" - "99" into $v1
	li $v1, '0'		# Assume tens digit is 0 if input is only 1 digit
	sll $v1, $v1, 8		# Ones digit is 8 bits large, shift '0' to tens digit
	addi $t1, $t1, -1
	lbu $t0, 0($t1)		# Ones digit
	or $v1, $v1, $t0	# Add ones digit while maintaining tens digit
	li $t0, 1
	ble $s0, $t0, findValue
	
	# Case where the return value isn't "0X"
	addi $t1, $t1, -1
	lbu $v1, 0($t1)		# Tens digit
	sll $v1, $v1, 8		# Tens digit is 8 bits large, shift it into position
	lbu $t0, 1($t1)		# Ones digit
	or $v1, $v1, $t0	# Add ones digit while maintaining tens digit
	
	findValue:
	li $t0, 0		# Loop from end to start of string
	li $t1, 10		# Constant 10
	li $t2, 1		# Multiply this however many times by 10 for each digit
	li $t3, 0		# To store actual value of all the digits
	findValueLoop:
		addi $s1, $s1, -1 		# Decrement string pointer
		lbu $t4, 0($s1)			# Load next character in the string (but backwards)
		addi $t4, $t4, -48		# Find actual value of digit
		mult $t4, $t2			# Multiply it by the appropriate power of 10
		mflo $t4
		add $t3, $t3, $t4		# Add to total sum
		
		addi $t0, $t0, 1 		# Move on to digit left of this one
		mult $t2, $t1			# Multiply $t2 by 10
		mflo $t2
		bne $t0, $s0, findValueLoop	# Once $t0 reaches the length, stop
	
	move $v0, $t3	# Actual value
	# ===========================================================
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 24
	jr $ra
	
get_pocket:
	jr $ra
	
set_pocket:
	jr $ra
	
collect_stones:
	jr $ra
	
verify_move:
	jr  $ra
	
execute_move:
	jr $ra
	
steal:
	jr $ra
	
check_row:
	jr $ra
	
load_moves:
	jr $ra
	
play_game:
	jr  $ra
	
print_board:
	jr $ra
	
write_board:
	jr $ra
	
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
