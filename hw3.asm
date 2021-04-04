# Kevin Li
# kevinli8
# 113347865

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text

# int, int load_game(GameState* state, string filename)
load_game:
	addi $sp, $sp, -32	# The input buffer occupies 28($sp)	
	sw $ra, 0($sp)	
	sw $s0, 4($sp)	# Stores state
	sw $s1, 8($sp)	# Stores file descriptor
	sw $s2, 12($sp)	# Stores address of input buffer
	sw $s3, 16($sp)	# Temporary but important storage
	sw $s4, 20($sp)	# Store amount of pockets
	sw $s5, 24($sp)	# Store total amount of stones
	# ===========================================================
	move $s0, $a0		# Store state so it isn't overwritten
	addi $s2, $sp, 28	# Store address of input buffer which is at 28($sp)
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
	add $s5, $s5, $v0	# Add amount of stones
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
	add $s5, $s5, $v0	# Add amount of stones
	sb $v0, 0($s0)		# Store second line's value into byte 0 of state (bot_mancala)
	move $s3, $v1		# Save $v1 for when I know the amount of pockets there are
	
	# Read # of pockets per row (third line)
	move $a0, $s1		
	move $a1, $s2		
	jal readLine
	move $s4, $v0		# Store amount of pockets to avoid 8-bit number limit (255)
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
		sb $0, 2($s0)		# Not necessary - just here for debugging gameE3/03.txt
		sub $s0, $s0, $v0	# Move state back to original position
		
	# moves_executed is 0 at the beginning
	sb $0, 4($s0)
	
	# player_turn is 'B' at the beginning
	li $t0, 'B'		# Player 1
	sb $t0, 5($s0)		# Store 'B' into byte 5 of state (player_turn)

	# Loop to read contents of top row (fourth line)
	move $s3, $s4		# Number of pockets
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
	addi $t4, $t1, -48
	add $s5, $s5, $t4	# Adds one digit to $s5
	li $t4, '0'
	beq $t0, $t4, store_top_pocket
	addi $t4, $t0, -48	# Convert tens digit to numerical value
	li $t5, 10
	mult $t4, $t5		# Multiply by 10
	mflo $t4
	add $s5, $s5, $t4	# Add tens digit to $s5
			
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
	li $a2, 2		# Set amount of characters to read back to 2	
	bot_contents_loop:
	li $v0, 14		# Read syscall
	syscall
	lbu $t0, 0($s2)		# Read first character from input buffer
	lbu $t1, 1($s2)		# Read second character from input buffer	
	# Subtask: convert 2 digits to number to add to stones count
	addi $t4, $t1, -48
	add $s5, $s5, $t4	# Adds one digit to $s5
	li $t4, '0'
	beq $t0, $t4, store_bot_pocket
	addi $t4, $t0, -48	# Convert tens digit to numerical value
	li $t5, 10
	mult $t4, $t5		# Multiply by 10
	mflo $t4
	add $s5, $s5, $t4	# Add tens digit to $s5
			
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

	# Check amount of stones on board
	li $t0, 99
	bgt $s5, $t0, tooManyStones
	li $v0, 1
	j checkPockets
	tooManyStones:
	li $v0, 0
	
	# Check amount of pockets on board
	checkPockets:
	li $t0, 98
	move $t1, $s4		
	sll $t1, $t1, 1		# Multiply by 2
	bgt $t1, $t0, tooManyPockets
	move $v1, $t1		# Return total number of pockets
	j end
	tooManyPockets:
	li $v1, 0
	
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
	# 8-19 is 12 bytes to store a 12-char long string. Largest int is only 10 digits.
	# Use 12 instead of 10 to align with a word boundary.
	addi $sp, $sp, -20	
	sw $s0, 0($sp)		# Store length of value
	sw $s1, 4($sp)		# Store string being read
	# ===========================================================
	addi $s1, $sp, 8	# Store address of string which is from 8($sp) to 19($sp)

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
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 20
	
	jr $ra
	
get_pocket:
	li $v0, -1			# Assume invalid return value

	# Check distance is valid
	lbu $t1, 2($a0)			# Get bot_pockets, valid distance is max bot_pockets - 1
	bge $a2, $t1, return_get_pocket	# Invalid distance should just return with $v0 still set to -1
	blt $a2, $0, return_get_pocket	# Negative distance is wrong too

	# Check player is valid
	li $t0, 'B'
	beq $a1, $t0, get_pocket_bot
	li $t0, 'T'
	beq $a1, $t0, get_pocket_top	
	j return_get_pocket		# Invalid player should just return with $v0 still set to -1
	
	get_pocket_bot:
	# Number of bytes to reach bottomrightmost pocket from byte 0 of BOARD is 2 * 2 * bot_pockets
	addi $a0, $a0, 6	# First, skip past the non-board bytes, to byte 0 of BOARD
	sll $t1, $t1, 2		# Multiply pockets by 4
	add $a0, $a0, $t1
	sll $a2, $a2, 1		# Amount of bytes to go left is 2 * distance
	sub $a0, $a0, $a2	# Now in the correct pocket
	# Left byte - tens digit
	lbu $t0, 0($a0)
	addi $t0, $t0, -48
	li $t1, 10
	mult $t0, $t1
	mflo $v0		# Add tens value to return value
	# Right byte - ones digit
	lbu $t0, 1($a0)
	addi $t0, $t0, -48
	add $v0, $v0, $t0	# Add ones value to return value
	j return_get_pocket
	
	get_pocket_top:
	addi $a0, $a0, 8	# Merely add 8 to reach first pocket of top row
	sll $a2, $a2, 1		# Amount of bytes to go right is 2 * distance
	add $a0, $a0, $a2	# Now in the correct pocket
	# Left byte - tens digit
	lbu $t0, 0($a0)
	addi $t0, $t0, -48
	li $t1, 10
	mult $t0, $t1
	mflo $v0		# Add tens value to return value
	# Right byte - ones digit
	lbu $t0, 1($a0)
	addi $t0, $t0, -48
	add $v0, $v0, $t0	# Add ones value to return value
	
	return_get_pocket:	
	jr $ra
	
set_pocket:
	li $v0, -2			# Assume invalid size
	# Check size constraint
	li $t0, 99
	bgt $a3, $t0, return_set_pocket	# Invalid size should just return with $v0 still set to -2 
	blt $a3, $0, return_set_pocket

	li $v0, -1			# Assume invalid distance/player
	# Check distance is valid
	lbu $t1, 2($a0)			# Get bot_pockets, valid distance is max bot_pockets - 1
	bge $a2, $t1, return_set_pocket	# Invalid distance should just return with $v0 still set to -1

	# Check player is valid
	li $t0, 'B'
	beq $a1, $t0, set_pocket_bot
	li $t0, 'T'
	beq $a1, $t0, set_pocket_top	
	j return_set_pocket		# Invalid player should just return with $v0 still set to -1

	set_pocket_bot:
	# Number of bytes to reach bottomrightmost pocket from byte 0 of BOARD is 2 * 2 * bot_pockets
	addi $a0, $a0, 6	# First, skip past the non-board bytes, to byte 0 of BOARD
	sll $t1, $t1, 2		# Multiply pockets by 4
	add $a0, $a0, $t1
	sll $a2, $a2, 1		# Amount of bytes to go left is 2 * distance
	sub $a0, $a0, $a2	# Now in the correct pocket	
	# Left byte - tens digit
	li $t0, 10
	div $a3, $t0
	mflo $t1		# Tens digit is quotient of dividend / 10
	addi $t2, $t1, 48	# Convert tens digit to equivalent ASCII value
	sb $t2, 0($a0)		# Store into first byte of pocket
	# Right byte - ones digit
	mult $t1, $t0
	mflo $t1		# Multiply tens digit by 10 and subtract size with it for ones digit
	sub $t2, $a3, $t1	# $t2 now contains ones digit
	addi $t2, $t2, 48	# Convert ones digit to equivalent ASCII value
	sb $t2, 1($a0)		# Store into second byte of pocket
	move $v0, $a3		# Return value: size
	j return_set_pocket
	
	set_pocket_top:
	addi $a0, $a0, 8	# Merely add 8 to reach first pocket of top row
	sll $a2, $a2, 1		# Amount of bytes to go right is 2 * distance
	add $a0, $a0, $a2	# Now in the correct pocket
	# Left byte - tens digit
	li $t0, 10
	div $a3, $t0
	mflo $t1		# Tens digit is quotient of dividend / 10
	addi $t2, $t1, 48	# Convert tens digit to equivalent ASCII value
	sb $t2, 0($a0)		# Store into first byte of pocket
	# Right byte - ones digit
	mult $t1, $t0
	mflo $t1		# Multiply tens digit by 10 and subtract size with it for ones digit
	sub $t2, $a3, $t1	# $t2 now contains ones digit
	addi $t2, $t2, 48	# Convert ones digit to equivalent ASCII value
	sb $t2, 1($a0)		# Store into second byte of pocket
	move $v0, $a3		# Return value: size
	
	return_set_pocket:	
	jr $ra
	
collect_stones:
	li $v0, -2		# Assume stones count is invalid initially
	ble $a2, $0, check_player_collect_stones
	move $v0, $a2		# Only gets run if stones count is valid
	check_player_collect_stones:
	li $t0, 'B'
	beq $t0, $a1, collect_stones_bot
	li $t0, 'T'
	beq $t0, $a1, collect_stones_top
	li $v0, -1		# Invalid player
	j return_collect_stones	# Return values are set in advance
	
	collect_stones_bot:
	li $t0, -2
	beq $v0, $t0, return_collect_stones	# If return value is still -2, just return
	
	lbu $t0, 0($a0)		# Get bottom mancala value
	add $t0, $t0, $a2	# Add stones
	sb $t0, 0($a0)		# Replace bottom mancala value
	lbu $t1, 2($a0)		# Get amount of pockets
	sll $t1, $t1, 2		# Multiply by 4
	addi $t1, $t1, 8	# Skip to first byte of first pocket in game_board
	
	add $a0, $a0, $t1	# Increment address of state to second to last byte (contains mancala)
	# Left byte - tens digit
	li $t1, 10
	div $t0, $t1
	mflo $t2		# Tens digit is quotient of dividend / 10
	addi $t3, $t2, 48	# Convert tens digit to equivalent ASCII value
	sb $t3, 0($a0)		# Store into first byte of bot mancala on board
	# Right byte - ones digit
	mult $t2, $t1
	mflo $t2		# Multiply tens digit by 10 and subtract stones with it for ones digit
	sub $t3, $t0, $t2	# $t3 now contains ones digit
	addi $t3, $t3, 48	# Convert ones digit to equivalent ASCII value
	sb $t3, 1($a0)		# Store into second byte of bot mancala on board
	j return_collect_stones
	
	collect_stones_top:
	li $t0, -2
	beq $v0, $t0, return_collect_stones	# If return value is still -2, just return
	
	lbu $t0, 1($a0)		# Get top mancala value
	add $t0, $t0, $a2	# Add stones	
	sb $t0, 1($a0)		# Replace top mancala value
	
	# Left byte - tens digit
	li $t1, 10
	div $t0, $t1
	mflo $t2		# Tens digit is quotient of dividend / 10
	addi $t3, $t2, 48	# Convert tens digit to equivalent ASCII value
	sb $t3, 6($a0)		# Store into first byte of game_board
	# Right byte - ones digit
	mult $t2, $t1
	mflo $t2		# Multiply tens digit by 10 and subtract stones with it for ones digit
	sub $t3, $t0, $t2	# $t3 now contains ones digit
	addi $t3, $t3, 48	# Convert ones digit to equivalent ASCII value
	sb $t3, 7($a0)		# Store into second byte game_board
	
	return_collect_stones:
	jr $ra
	
verify_move:
	# This function actually calls a helper function!
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	move $s0, $a2		# Store distance argument

	li $v0, 2		# Assume return value is 2 at first
	li $t0, 99
	bne $t0, $a2, skipChangeTurn
	# Swap turns
	lbu $t0, 5($a0)		# Get current turn
	li $t1, 'B'
	beq $t0, $t1, switchToT
	switchToB:
	sb $t1, 5($a0)
	switchToT:
	li $t1, 'T'
	sb $t1, 5($a0)
	j return_verify_move
	
	skipChangeTurn:
	# Run get_pocket, $a0 is already the state argument
	move $a2, $a1		# "Distance" in get_pocket = "origin_pocket" in verify_move
	lbu $a1, 5($a0)		# Get current turn into $a1
	jal get_pocket
	li $t0, -1		# If $v0 from get_pocket is -1, distance (origin_pocket) is invalid
	beq $v0, $t0, return_verify_move
	beq $v0, $0, return_verify_move
	
	# Checking -2 return error case
	move $t0, $v0		# Move amount of stones to $t0 (it is valid)
	li $v0, -2		# Assume return value is -2 at first
	beq $s0, $0, return_verify_move		# Distance (in $s0) of 0, just return -2
	bne $s0, $t0, return_verify_move	# Distance not equal to amount of stones, return -2
	li $v0, 1				# Move is legal
	
	return_verify_move:
	bne $s0, $0, skipZeroDistance
	li $v0, -2
	
	skipZeroDistance:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
execute_move:
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	move $s0, $a0		# Save state argument
	move $s1, $a1		# Save origin_pocket (distance) argument
	li $s2, 0		# Amount of stones added to mancala
	lbu $s4, 5($s0)		# Useful to track whether we're on top or bottom row

	# Call get_pocket to get amount of stones in the relevant pocket
	move $a1, $s4		# Put player in $a1, $a0 is already filled with state
	move $a2, $s1		# "distance" in get_pocket is "origin_pocket" in this method.
	jal get_pocket
	move $s3, $v0		# Store amount of stones (for iterating with) in $s3
	# Set that pocket to 0
	move $a0, $s0
	move $a1, $s4
	move $a2, $s1
	move $a3, $0
	jal set_pocket
		
	# ===================================================================================
	decrement_stones_loop:		
	addi $s1, $s1, -1	# Decrement distance will always go in a "counterclockwise" direction
	addi $s3, $s3, -1	# Decrement stones
	li $t0, -1
	beq $s1, $t0, addToMancala	# If distance equals -1, a mancala has been reached.
	# Call get_pocket
	move $a0, $s0			# State argument
	move $a1, $s4			# Player argument
	move $a2, $s1			# Distance argument
	jal get_pocket
	move $s5, $v0			# Store initial value of get_pocket, useful for return value
	# Call set_pocket with pocket_stones + 1 as size
	move $a0, $s0			# State argument
	move $a1, $s4			# Player argument
	move $a2, $s1			# Distance argument
	addi $a3, $v0, 1		# pocket_stones + 1
	jal set_pocket
		# Check for last stone into pocket
		bne $s3, $0, decrement_stones_loop
		bne $s5, $0, return_zero	# Check if last pocket was empty
		lbu $t0, 5($s0)
		bne $t0, $s4, return_zero	# Check that the last deposit was in player's row
		sb $s1, 28($sp)			# Store the destination pocket for steal later on
		li $v1, 1
		j return_execute_loop
		return_zero:
		li $v1, 0
		j return_execute_loop
		
	addToMancala:
	# Check whether $s4 matches up with the (current) turn, and add to mancala accordingly.
	addi $s3, $s3, 1			# Add to stones in case mancala is not the turn's
	lbu $s1, 2($s0)				# Reset distance to pockets - 1
	lbu $t0, 5($s0)				# Current turn
	bne $s4, $t0, switchRow			# If $t0 != $s4, skip adding to mancala
	# Call collect_stones and increment mancala by 1
	addi $s3, $s3, -1			# It is the turn's mancala so decrement stones again
	move $a0, $s0
	lbu $a1, 5($s0)
	li $a2, 1
	jal collect_stones
	addi $s2, $s2, 1			# Increment stones added to mancala by 1
	bne $s3, $0, switchRow			# If last stone ends up in your mancala, don't swap turns
	li $v1, 2
	j skipSwitchTurn
	switchRow:
		li $t0, 'B'
		beq $s4, $t0, switchToT2
		switchToB2:
		li $s4, 'B'
		j advance_execute_loop
		switchToT2:
		li $s4, 'T'
	
	advance_execute_loop:
	bne $s3, $0, decrement_stones_loop
	# ===================================================================================
	return_execute_loop:
		# Switch turns
		lbu $t0, 5($s0)
		li $t1, 'B'
		beq $t0, $t1, switchToT3
		switchToB3:
		sb $t1, 5($s0)
		j skipSwitchTurn
		switchToT3:
		li $t1, 'T'
		sb $t1, 5($s0)
	
	skipSwitchTurn:
	# Increment turns	
	lbu $t0, 4($s0)
	addi $t0, $t0, 1
	sb $t0, 4($s0)
	
	# Uncomment for step by step
	# addi $a0, $s0, 6
	# li $v0, 4
	# syscall
	# li $a0, '\n'
	# li $v0, 11
	# syscall
	
	move $v0, $s2				# Return stones added to mancala
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	jr $ra
	
steal:
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	move $s0, $a0		# Store state
	move $s1, $a1		# Store destination_pocket
	li $s2, 0		# Store total amount of stones to add to mancala

	# Check which was the former turn
	lbu $t0, 5($s0)
	li $t1, 'B'		# If current turn is 'B', former turn was 'T'.
	beq $t0, $t1, formerTurnWasT
	formerTurnWasB:
	# Call get_pocket with 'B' as player argument
	move $a0, $s0
	li $a1, 'B'
	move $a2, $s1
	jal get_pocket
	add $s2, $s2, $v0
	# Now set that pocket to 0
	move $a0, $s0
	li $a1, 'B'
	move $a2, $s1
	li $a3, 0
	jal set_pocket
	# Call get_pocket with 'T' as player argument, use (num_pockets - 1) - destination_pocket to align pockets
	move $a0, $s0
	li $a1, 'T'
	lbu $t0, 2($s0)
	addi $t0, $t0, -1
	sub $a2, $t0, $s1
	jal get_pocket
	add $s2, $s2, $v0
	# Now set that pocket to 0
	move $a0, $s0
	li $a1, 'T'
	lbu $t0, 2($s0)
	addi $t0, $t0, -1
	sub $a2, $t0, $s1
	li $a3, 0
	jal set_pocket
	# Call collect_stones with $s2 as stones argument
	move $a0, $s0
	li $a1, 'B'
	move $a2, $s2
	jal collect_stones
	j return_steal

	formerTurnWasT:
	# Call get_pocket with 'T' as player argument
	move $a0, $s0
	li $a1, 'T'
	move $a2, $s1
	jal get_pocket
	add $s2, $s2, $v0
	# Now set that pocket to 0
	move $a0, $s0
	li $a1, 'T'
	move $a2, $s1
	li $a3, 0
	jal set_pocket
	# Call get_pocket with 'B' as player argument, use 5 - destination_pocket to align pockets
	move $a0, $s0
	li $a1, 'B'
	li $t0, 5
	sub $a2, $t0, $s1
	jal get_pocket
	add $s2, $s2, $v0
	# Now set that pocket to 0
	move $a0, $s0
	li $a1, 'B'
	li $t0, 5
	sub $a2, $t0, $s1
	li $a3, 0
	jal set_pocket
	# Call collect_stones with $s2 as stones argument
	move $a0, $s0
	li $a1, 'T'
	move $a2, $s2
	jal collect_stones

	return_steal:
	move $v0, $s2		# Return stones added to mancala
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	
check_row:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)		# Store state argument
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	move $s0, $a0
	li $s2, 0		# Store amount of remaining stones in top row
	li $s3, 0		# Store amount of remaining stones in bottom row

	# Gather all the stones in the top row
	lbu $s1, 2($s0)		# Get amount of pockets
	accumulate_top_row_loop:
	addi $s1, $s1, -1	# Decrement index
	# Call get_pocket on respective pocket
	move $a0, $s0
	li $a1, 'T'
	move $a2, $s1
	jal get_pocket
	add $s2, $s2, $v0	# Add to amount of remaining stones
	bgt $s1, $0, accumulate_top_row_loop
	
	# Gather all the stones in the bottom row
	lbu $s1, 2($s0)		# Get amount of pockets
	accumulate_bot_row_loop:
	addi $s1, $s1, -1	# Decrement index
	# Call get_pocket on respective pocket
	move $a0, $s0
	li $a1, 'B'
	move $a2, $s1
	jal get_pocket
	add $s3, $s3, $v0	# Add to amount of remaining stones
	bgt $s1, $0, accumulate_bot_row_loop
	
	# Check which row is empty (if any)
	beq $s2, $0, putRemainingStonesInBottomMancala	# Top row is empty
	beq $s3, $0, putRemainingStonesInTopMancala	# Bottom row is empty
	# Neither rows are empty
	li $s1, 0		# Store $v0 return value in $s1 for now so it isn't overwritten
	j return_check_row
	putRemainingStonesInBottomMancala:
	# Clear out the bottom row
		lbu $s1, 2($s0)		# Get amount of pockets
		clear_out_bot_row_loop:
		addi $s1, $s1, -1	# Decrement index
		# Call set_pocket on respective pocket
		move $a0, $s0
		li $a1, 'B'
		move $a2, $s1
		li $a3, 0
		jal set_pocket
		bgt $s1, $0, clear_out_bot_row_loop
	# Call collect_stones
	move $a0, $s0
	li $a1, 'B'
	move $a2, $s3		# Bottom row stones
	jal collect_stones
	li $s1, 1		# $v0 return value
	li $t0, 'D'		# Set player turn to done
	sb $t0, 5($s0)
	j return_check_row
	
	putRemainingStonesInTopMancala:
	# Clear out the top row
		lbu $s1, 2($s0)		# Get amount of pockets
		clear_out_top_row_loop:
		addi $s1, $s1, -1	# Decrement index
		# Call set_pocket on respective pocket
		move $a0, $s0
		li $a1, 'T'
		move $a2, $s1
		li $a3, 0
		jal set_pocket
		bgt $s1, $0, clear_out_top_row_loop
	# Call collect_stones
	move $a0, $s0
	li $a1, 'T'
	move $a2, $s2		# Top row stones
	jal collect_stones
	li $s1, 1		# $v0 return value
	li $t0, 'D'		# Set player turn to done
	sb $t0, 5($s0)
	
	return_check_row:
	# Check which player has more stones
	lbu $t0, 0($s0)		# Bottom mancala
	lbu $t1, 1($s0)		# Top mancala
	bgt $t0, $t1, player1HasMore
	blt $t0, $t1, player2HasMore
	player1HasMore:
		li $v1, 1
		j actually_return_lol
	player2HasMore:
		li $v1, 2
		j actually_return_lol
	li $v1, 0		# Tie
	
	actually_return_lol:
	move $v0, $s1		# $v0 return value
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra
	
load_moves:
	addi $sp, $sp, -28	# The input buffer occupies 12($sp)	
	sw $ra, 0($sp)	
	sw $s0, 4($sp)	# Stores moves array
	sw $s1, 8($sp)	# Stores file descriptor
	sw $s2, 12($sp)	# Stores address of input buffer
	sw $s3, 16($sp)	# Store amount of rows
	sw $s4, 20($sp)	# Store number of columns
	# ===========================================================	
	move $s0, $a0		# Store moves array so it isn't overwritten	
	addi $s2, $sp, 24	# Store address of input buffer which is at 24($sp)
	
	# Open board file
	li $v0, 13	
	move $a0, $a1	# Move file name to $a0
	li $a1, 0	# Move reading flag to $a1
	syscall
	move $s1, $v0	# Save file descriptor
	bgtz $s1, readMoves
	# Error accessing file, close and return -1
	li $v0, 16	
	move $a0, $s1	# Move file descriptor to $a0
	syscall
	li $v0, -1
	j return_load_moves

	readMoves:	
	# Read # of columns		
	move $a0, $s1		# Move file descriptor to $a0
	move $a1, $s2		# Move input buffer to $a1
	jal readLine
	move $s4, $v0		# Store amount of columns
	
	# Read # of rows
	move $a0, $s1		
	move $a1, $s2		
	jal readLine
	move $s3, $v0	# Store amount of rows
	
	# Loop through moves file
	move $a0, $s1		# Move file descriptor to $a0
	move $a1, $s2		# Move input buffer to $a1
	li $a2, 2		# Read 2 characters at once into buffer
	li $t4, 0		# Store size of moves array for returning later
	li $t5, 99		# 99 move
	rowLoop:
	move $t0, $s4		# Reset columns remaining
		colLoop:
		move $a0, $s1		# Move file descriptor to $a0
		li $v0, 14		# Read syscall
		syscall
		lbu $t1, 0($s2)		# Read first character from input buffer
		lbu $t2, 1($s2)		# Read second character from input buffer
		addi $t1, $t1, -48	# Convert to numerical representation
		addi $t2, $t2, -48
		blt $t1, $0, invalidMove
		blt $t2, $0, invalidMove
		li $t3, 9
		bgt $t1, $t3, invalidMove
		bgt $t2, $t3, invalidMove
		
		# Convert 2 characters to 2-digit number
		li $t3, 10
		mult $t1, $t3
		mflo $t1		# Contains multiple of 10
		add $t1, $t1, $t2	# Add ones digit
		sb $t1, 0($s0)		# Add move to moves array
		
		j advanceColLoop
		
		invalidMove:
			li $t1, -1
			sb $t1, 0($s0)
		
		advanceColLoop:
		addi $s0, $s0, 1	# Move forward 1 in moves array
		addi $t4, $t4, 1	# Append to size of moves array
		addi $t0, $t0, -1	# Decrement cols remaining
		bne $t0, $0, colLoop

	sb $t5, 0($s0)		# Store 99 move
	addi $s0, $s0, 1	# Move forward 1 in moves array
	addi $t4, $t4, 1	# Append to size of moves array
	addi $s3, $s3, -1	# Decrement rows remaining
	bne $s3, $0, rowLoop

	# Close board file
	li $v0, 16	
	move $a0, $s1	# Move file descriptor to $a0
	syscall
	addi $v0, $t4, -1	# Don't count the last 99 move
	
	return_load_moves:
	lw $ra, 0($sp)	
	lw $s0, 4($sp)	
	lw $s1, 8($sp)	
	lw $s2, 12($sp)				
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 28
	jr $ra
	
# string moves_filename, string board_filename, GameState* state, byte[] moves, int num_moves_to_execute
play_game:
	lw $t0, 0($sp)		# First obtain the num_moves_to_execute from stack pointer
	addi $sp, $sp, -28
	# Ensure nothing important occupies 0($sp)
	sw $ra, 4($sp)		
	sw $s0, 8($sp)		# Store state
	sw $s1, 12($sp)		# Store moves array
	sw $s2, 16($sp)		# Store num_moves_to_execute
	sw $s3, 20($sp)		# Store various misc. stuff
	sw $s4, 24($sp)		# Store individual move
	move $s0, $a2
	move $s1, $a3
	move $s2, $t0	
	move $s3, $a0		# Store moves_filename

	# Call load_game
	loadgame:
	move $a0, $s0		# $a1 already contains board_filename
	jal load_game	
	blez $v0, returnError	# load_game's invalid return values are all <= 0
	blez $v1, returnError
	j loadmoves
	
	returnError:
	li $v0, -1
	li $v1, -1
	j return_play_game
	
	loadmoves:		
	# Call load_moves
	move $a0, $s1
	move $a1, $s3	
	jal load_moves					
	bgtz $v0, actually_play_game
	li $v0, -1
	li $v1, -1
	j return_play_game
	
	actually_play_game:
	move $s3, $v0		# Store size of moves array
	# ===========================================================
	game_loop:
	ble $s2, $0, endGame	# First condition to exit: num_moves_to_execute is 0		
	ble $s3, $0, endGame	# Second condition to exit: end of moves array has been reached
	
	# Obtain move from moves array
	lbu $s4, 0($s1)

	# Get amount of stones (distance) in pocket of move
	move $a0, $s0		# State
	lbu $a1, 5($s0)		# Get current turn
	move $a2, $s4		# Distance
	jal get_pocket
	
	# Now call verify_move
	move $a0, $s0
	move $a1, $s4
	move $a2, $v0		# Amount of stones = distance
	
	li $t0, 99
	bne $s4, $t0, dontSetDistanceTo99
	li $a2, 99
	dontSetDistanceTo99:
	jal verify_move
		
	# Check if it was a skip move (verify_move returns 2), and skip executing if so
	li $t0, 2
	bne $v0, $t0, not99
	# Add to moves_executed
	lbu $t0, 4($s0)
	addi $t0, $t0, 1
	sb $t0, 4($s0)
	j advanceGameLoop
	
	not99:
	# Check if verify_move returned error	
	blez $v0, skipDecrementingNumMovesToExecute
	
	# Now move has to be valid (return value of 1). Call execute_move
	move $a0, $s0
	move $a1, $s4		# Move argument
	jal execute_move
	
	# Check if execute_move returns 1 in $v1, if so steal
	li $t0, 1
	bne $v1, $t0, advanceGameLoop	
		# Call steal
		move $a0, $s0
		lbu $a1, 0($sp)		# execute_move should've put destination_pocket in here
		jal steal
	
	advanceGameLoop:
	addi $s2, $s2, -1	# Only decrement num_moves_to_execute if valid move
	# Check if either row is empty and end game if so
	move $a0, $s0
	jal check_row
	beq $v0, $0, skipDecrementingNumMovesToExecute	
	j endGame
	
	skipDecrementingNumMovesToExecute:
	addi $s1, $s1, 1	# Increment array position
	addi $s3, $s3, -1	# Decrement size of array remaining
	j game_loop
	# ===========================================================
	
	endGame:
	# Check if either row is empty and end game if so
	move $a0, $s0
	jal check_row
	beq $v0, $0, fillOutV1
	move $v0, $v1		# $v0 is not 0 so there has to be either a win or a tie
	fillOutV1:
	lbu $v1, 4($s0)		# Moves executed is stored in byte 4 of state
	
	return_play_game:
	lw $ra, 4($sp)
	lw $s0, 8($sp)
	lw $s1, 12($sp)
	lw $s2, 16($sp)
	lw $s3, 20($sp)
	lw $s4, 24($sp)
	addi $sp, $sp, 28
	jr $ra

print_board:
	addi $sp, $sp, -4
	sw $s0, 0($sp)		# Store state
	move $s0, $a0
	
	# Obtain amount of pockets
	lbu $t0, 2($s0)

	# Move state to game_board
	addi $s0, $s0, 6

	# Print top mancala (bytes 0 and 1)
	li $v0, 11
	lbu $a0, 0($s0)
	syscall
	lbu $a0, 1($s0)
	syscall
	li $a0, '\n'
	syscall
	
	sll $t0, $t0, 2		# Multiply by 4	
	add $s0, $s0, $t0	
	addi $s0, $s0, 2	# Add 2 to reach bottom mancula
	# Print bottom mancula
	li $v0, 11
	lbu $a0, 0($s0)
	syscall
	lbu $a0, 1($s0)
	syscall
	li $a0, '\n'
	syscall
	
	# Set state to first byte of first pocket on top row
	sub $s0, $s0, $t0
	# Loop through next 4 * pocket_amt characters in game_board and print
	li $v0, 11
	srl $t1, $t0, 1			# Split top and bottom part of board
	print_board_top_loop:
		lbu $a0, 0($s0)
		syscall
		addi $s0, $s0, 1	# Increment state pointer
		addi $t1, $t1, -1	# Decrement 4 * pocket_amt
		bne $t1, $0, print_board_top_loop
		
	li $a0, '\n'
	syscall
	srl $t1, $t0, 1
	print_board_bot_loop:
		lbu $a0, 0($s0)
		syscall
		addi $s0, $s0, 1	# Increment state pointer
		addi $t1, $t1, -1	# Decrement 4 * pocket_amt
		bne $t1, $0, print_board_bot_loop

	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
write_board:
	jr $ra
	
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
