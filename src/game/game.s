/*
This file is part of gamelib-x64.

Copyright (C) 2014 Tim Hegeman

gamelib-x64 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

gamelib-x64 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with gamelib-x64. If not, see <http://www.gnu.org/licenses/>.
*/
.include "src/game/constants.s"
.include "src/game/macros.s"
.include "src/game/graphics.s"

.include "src/game/debug.s"

.include "src/game/functions.s"
.include "src/game/random.s"
.include "src/game/keyboard.s"
.include "src/game/snake.s"

.file "src/game/game.s"

.global gameInit
.global gameLoop

.section .game.rodata

DIRSTR:	.asciz	"Direction\: "
Title:	.asciz	"SNAKE"
seedstr:	.asciz	"Seed\:"
bitself:	.asciz	"BIT SELF!"
notbit:	.asciz	"Not bit"

spawn:	.asciz	"SPAWN!!!"

TitleStr:	.asciz	"Snake by Jim"
startStr:	.asciz	"Press any key to start..."
gameover:	.asciz	"GAME OVER"
gamewin:	.asciz	"YOU WON!"
continueStr:	.asciz	"Press any key to continue..."

# Strings
HIGH_SCORE:	.asciz	"High score:"
CUR_SCORE:	.asciz	"Current score:"

moved:	.asciz	"Moved!"

horstr:	.asciz	"Top/Bottom hit"
vertstr:	.asciz	"Left/Right hit"

# Scan codes for arrow keys
UP_ARROW:	.byte	0x48
DOWN_ARROW:	.byte	0x50
LEFT_ARROW:	.byte	0x4B
RIGHT_ARROW:	.byte	0x4D

.section .game.data

gameState:	.byte	0	# global game state indicator 0 = start, 1 = running, 2 = game over

seed:	.word	12345 # seed for pseudo-random number generation gets updated every keystroke by irq1

dir:	.byte	3		# Direction of movement: 0=up, 1=down, 2=left, 3=right

snake:	.skip	GRID_cells * 2	# Snake array[225][2]: head first represented as two bytes (coord)
				# after that the individual body part coords follow
				# Start with length of INIT_SIZE

snakeSize:	.word INIT_SIZE	# See constants.s

lastElement:	.byte 2, 2	# last removed element of snake, used in check_food

empty:		.skip	GRID_cells * 2	# maximum amount is GRID cells * 2 for two coords

emptySize:	.word GRID_cells - INIT_SIZE	# amount of empty cells

foodPos:	.byte FF_X, FF_Y	# food coords (255, 255) aka (-1, -1) means no food

high:	.word	0	# Word to store high score in

last:	.word 0	# word to store last score in

.section .game.bss

grid:	.skip	GRID_cells	# 15x15 = 255 bytes

.section .game.text

# Shows the titlescreen
startScreen:
	enter	$0, $0

	movb	$0, (gameState)	# set game state to title screen
	call	cls
	scall	printString, $33, $10, $TitleStr, $G_B	# Print the title
	scall	printString, $28, $13, $startStr, $W_B	# Print start condition (keypress)

	leave
	ret

# Starts the game
startGame:
	enter	$0, $0
	
	call	cls
	call	gameInit	# set starting variables

	leave
	ret

# Shows game over / win screen
gameOver:
	enter	$0, $0

	pushq	%r9	# Push r9 so we can use it
	movzwq	(high), %rax
	movzwq	(last), %r9
	cmpq	%rax, %r9
	jle	3f
		# Last score was higher than high score
		movw	%r9w, (high)	# store new high score in memory
	3:
	popq	%r9	# restore register

	mcall	cls
	test	%rdi, %rdi
	jz	1f
		scall	printString, $35, $10, $gameover, $R_B	# game over text
		jmp	2f
	1:
		scall	printString, $35, $10, $gamewin, $Y_B	# win text
		jmp	2f
	2:
	scall	printString, $27, $12, $continueStr, $W_B	# continue text
	movq	$2, (gameState)	# set gamestate to game over

	leave
	ret

# (Re)initializes global vars
gameInit:
	enter	$0, $0

	pushq	%rbx		# reset snake size
	movw	$INIT_SIZE, %bx
	andq	$0xFFFF, %rbx
	movw	%bx, (snakeSize)
	popq	%rbx

	movb	$3, (dir)	# reset direction

	movb	$FF_X, (foodPos)	# reset food
	movb	$FF_Y, (foodPos+1)	# reset food

	movb	$0, (snake)	#x1
	movb	$1, (snake+1)	#y1
	movb	$1, (snake+2)	#x2
	movb	$1, (snake+3)	#y2

	movb	$1, (gameState)	# set gamestate to running

	leave
	ret

gameLoop:
	# Check if a key has been pressed
	#call	readKeyCode	# Get keycode from "buffer" in rax
	#test	%rax, %rax	# set zero flag to appropiate value for rax
	#jz	1f	# If a key was not pressed return from loop
	call	cls

	call	move_snake	# move the snake

	call	check_bound	# check if border has been hit
	cmpq	$1, %rax
	je	2f
	call	check_self	# Check if hit self
	cmpq	$1, %rax
	je	2f

	call	check_food	# handle food check
	cmpq	$1, %rax
	je	3f

	# Printing
	call	printFood	# print the food

	call	printSnake	# print the snake

	call	printBorders	# print the borders

	#scall	printString, $0, $11, $seedstr, $W_B	# print seed
	#pushq	%rdx
	#movzwq	(seed), %rdx
	#scall	putNum, $6, $11, %rdx, $W_B
	#popq	%rdx

	scall	printString, $0, $0, $CUR_SCORE, $W_B	# Current score
	call	getScore	# get the current score
	scall	putNum, $15, $0, %rax, $W_B

	scall	printString, $0, $1, $HIGH_SCORE, $W_B	# High score
	movzwq	(high), %rax
	scall	putNum, $12, $1, %rax, $W_B	# Print high score

	#pushq	%rsi
	#movzwq	(snakeSize), %rsi
	#shl	%rsi
	#scall	arrPrint, $snake, %rsi, $24	# print snake array

	#movzwq	(emptySize), %rsi
	#scall	arrPrint, $empty, %rsi, $23	# print snake array
	#popq	%rsi

	scall	printString, $37, $0, $Title, $G_B	# title print

	#scall	printString, $0, $2, $DIRSTR, $W_B	# Direction print
	#movzbq	(dir), %rdx
	#scall	putNum, $12, $2, %rdx, $W_B

1:
	ret

2:
	movq	$1, %rdi
	call	gameOver
	ret

3:
	movq	$0, %rdi
	call	gameOver
	ret
