.data
player: .byte 'T' 
stones: .word -2
.align 2
state:        
    .byte 4         # bot_mancala       	(byte #0)
    .byte 0         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 2         # moves_executed	(byte #4)
    .byte 'B'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0008070601000404040404040404"
.text
.globl main
main:
la $t0, state		
lbu $a0, 0($t0)		# bot_mancala old
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall

lbu $a0, 1($t0)		# top_mancala old
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall

la $t0, state		# state old
addi $a0, $t0, 6
li $v0, 4
syscall
li $a0, '\n'
li $v0, 11
syscall

la $a0, state
lb $a1, player
lb $a2, stones
jal collect_stones
# You must write your own code here to check the correctness of the function implementation.
move $a0, $v0		# $v0 return value
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall

la $t0, state		
lbu $a0, 0($t0)		# bot_mancala new
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall

lbu $a0, 1($t0)		# top_mancala new
li $v0, 1
syscall
li $a0, '\n'
li $v0, 11
syscall

la $t0, state		# state new
addi $a0, $t0, 6
li $v0, 4
syscall

collect_stones_test_end:
li $v0, 10
syscall

.include "hw3.asm"
