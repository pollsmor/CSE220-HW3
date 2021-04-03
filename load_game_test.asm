.data
board_filename: .asciiz "game01.txt"
v0_value: .asciiz " (v0 return value)"
v1_value: .asciiz " (v1 return value)"
.align 2
state:        
    .byte 0         # bot_mancala       	(byte #0)
    .byte 1         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 2         # moves_executed		(byte #4)
    .byte 'B'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0108070601000404040404040400"
    
.text
.globl main
main:
la $a0, state
la $a1, board_filename
jal load_game
# You must write your own code here to check the correctness of the function implementation.
la $t0, state

# Print $v0
move $a0, $v0
li $v0, 1
syscall
la $a0, v0_value
li $v0, 4
syscall
li $a0, '\n'
li $v0, 11
syscall

# Print $v1
move $a0, $v1
li $v0, 1
syscall
la $a0, v1_value
li $v0, 4
syscall
li $a0, '\n'
li $v0, 11
syscall

# Check $v1 isn't -1
li $t1, -1
beq $v1, $t1, endProgram

# Print bot_mancala
lbu $a0, 0($t0)
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall

# Print top_mancala
lbu $a0, 1($t0)
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall

# Print bot_pockets
lbu $a0, 2($t0)
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall

# Print top_pockets
lbu $a0, 3($t0)
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall

# Print moves_executed
lbu $a0, 4($t0)
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall

# Print player_turn
lbu $a0, 5($t0)
li $v0, 11
syscall
li $a0, '\n'
li $v0, 11
syscall

# Print game_board
addi $a0, $t0, 6
li $v0, 4
syscall
li $a0, '\n'
li $v0, 11
syscall

endProgram:
li $v0, 10
syscall

.include "hw3.asm"
