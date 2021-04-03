.data
moves_filename: .asciiz "moves02.txt"
board_filename: .asciiz "game01.txt"
num_moves_to_execute: .word 50
moves: .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.align 2
state:        
    .byte 55         # bot_mancala       	(byte #0)
    .byte 55        	 # top_mancala       	(byte #1)
    .byte 55       	 # bot_pockets       	(byte #2)
    .byte 55        	 # top_pockets        	(byte #3)
    .byte 55        	 # moves_executed	(byte #4)
    .byte 'T'	    	# player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "01080706010004040404040404000"
.text
.globl main
main:
la $a0, moves_filename
la $a1, board_filename
la $a2, state
la $a3, moves
addi $sp, $sp, -4
lw $t0, num_moves_to_execute
sw $t0, 0($sp)
jal play_game
addi $sp, $sp, 4
# You must write your own code here to check the correctness of the function implementation.
move $a0, $v0
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall

move $a0, $v1
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "hw3.asm"
