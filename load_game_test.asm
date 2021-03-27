.data
board_filename: .asciiz "gameE3.txt"
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
    "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    
.text
.globl main
main:
la $a0, state
la $a1, board_filename
jal load_game
# You must write your own code here to check the correctness of the function implementation.
la $t0, state

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

li $v0, 10
syscall

.include "hw3.asm"
