# Kevin Li
# kevinli8
# 113347865

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text

# int, int load_game(GameState* state, string filename)
load_game:
	addi $sp, $sp, -20	# The input buffer occupies 16($sp)
	sw $ra, 0($sp)
	sw $s0, 4($sp)	# Stores state
	sw $s1, 8($sp)	# Stores file descriptor
	sw $s2, 12($sp)	# Stores address of input buffer
	# ===========================================================
	move $s0, $a0		# Store state so it isn't overwritten
	addi $s2, $sp, 16	# Store address of input buffer which is at 16($sp)
	
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
	# Read # of top mancala stones
	move $a0, $s1		# Move file descriptor to $a0
	move $a1, $s2		# Move input buffer to $a1
	jal getMultiDigitValue
	sb $v0, 0($s0)		# Store first line's value into byte 0 of state

	# Close board file
	li $v0, 16	
	move $a0, $s1	# Move file descriptor to $a0
	syscall

	end: 	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 20
	jr $ra
	
# ($a0: int fd, $a1: int buffer) -> Returns multi (or single)-digit value from file
getMultiDigitValue:
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
			j findValue
		continue_length_loop:	
			addi $s0, $s0, 1	# Increment length
			sb $t2, 0($s1)		# Store character in string
			addi $s1, $s1, 1	# Increment string pointer
			j findLengthLoop
	
	findValue:
	sb $0, 0($s1)		# Null terminate string, just feel like doing it
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
