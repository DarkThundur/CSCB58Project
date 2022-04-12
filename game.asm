##################################################################### 
# 
# CSCB58 Winter 2022 Assembly Final Project 
# University of Toronto, Scarborough 
# 
# Student: MD WASIM ZAMAN, 1007007640, zamanmd5, mdwasim.zaman@mail.utoronto.ca 
# 
# Bitmap Display Configuration: 
# - Unit width in pixels: 4 (update this as needed)  
# - Unit height in pixels: 4 (update this as needed) 
# - Display width in pixels: 256 (update this as needed) 
# - Display height in pixels: 512 (update this as needed) 
# - Base Address for Display: 0x10008000 ($gp) 
# 
# Which milestones have been reached in this submission? 
# (See the assignment handout for descriptions of the milestones) 
# - Milestone 1/2/3 (choose the one the applies) 
# Milestone 3
# Which approved features have been implemented for milestone 3? 
# (See the assignment handout for the list of additional features) 
# 1. Fail Condition: touch the skeleton without last powerup leads to instant gameover [1]
# 2. Win Condition: touch the skeleton with the last powerup [1]
# 3. Moving Object: The skeleton enemy moves towards the player at random intervals [2] 
# 4. Moving Platforms: The middle platform is moving to make it more challenging [2]
# 5. Pick-up effects: The pick ups in order are double jump(can jump midair), midair dash activated by numpad, makes the player white and kills skeleton
# The speed of the enemy also changes depending on which pickup you have [2]
# 6. Double Jump: can just midair once [1]
# 7. Mid air dash: allows you to dash through platforms, and the enemy, makes it easier to avoid the enemy and move [2 or 3]
# the floating platforms are considered special and can be passed through, thus it may be worth 3 marks
# 8. Start Menu: W S to select P to enter selection  [1]
# Link to video demonstration for final submission: 
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it! 
#  https://play.library.utoronto.ca/watch/d18d3e866d2b912e185feed629bc2315
# Are you OK with us sharing the video with people outside course staff? 
# - yes / no / yes, and please share this project github link as well! 
# yes 
# https://github.com/DarkThundur/CSCB58Project
# Any additional information that the TA needs to know: 
# I used this tool made by a previous years student to import sprites: https://github.com/Epicsteve2/CSCB58_Project/blob/main/src/RGBAtoASM.py
# Be sure to have numpad keys on for dashing 7,8,9,4,6,1,2,3 to dash in diagonal and cardinal directions
# Due to sheer amount of code MARS may lag after execution for a long time
# Otherthan numpad im using keys: w,a,s,d,p
#Title Graphic belongs to: InnerSloth LLC
##################################################################### 

.eqv BASE_ADDRESS 0x10008000
.eqv GROUND_ADDRESS 0x1000FD00
.eqv GROUND_LEVEL 125
.eqv MAX_ADDRESS  0x1000FFFC
.eqv WALL_COLOR 0x0D346B
.eqv GROUND_COLOR 0x3A3E42
.eqv PLAYER_START_X 0
.eqv PLAYER_START_Y 117
.eqv REFRESH_RATE  40
.eqv PLAYER_WIDTH 8
.eqv PLAYER_HEIGHT 8
.eqv WIDTH 64
.eqv HEIGHT 128
.eqv DashTime 7
#s0 holds player x s1 holds player y
#s2 holds player x_vel, s3 y_vel
#s4 jump data, s5 direction
.eqv PLAYER_X $s0
.eqv PLAYER_Y $s1
.eqv PLAYER_X_VEL $s2
.eqv PLAYER_Y_VEL $s3
.eqv JUMPS_LEFT $s4
.eqv PLAYER_DIRECTION $s5
.eqv LEFT -1
.eqv RIGHT 1
.eqv DX $t8
.eqv DY $t9
.eqv BASE_COLOR 0xED1C24
.eqv DASH_COLOR 0xC3C3C3
.eqv INVC_COLOR 0xFFFFFF
#use s0-s9 in start screen
.eqv PlayerChoice $s0
#0 for choice 0 , 1 for choice 1

#other s registers are off limits
.data
#these are temporary variables btw
ENEMY_SPEED: 15
PLATFORM_X: 15
PLATFORM_Y: 80
PLATFORM_WIDTH: 32
PLATFORM_HEIGHT: 9
MAX_JUMP_COUNT: 1
PLATFORMS_X: 15,15,15
PLATFORMS_Y: 60,100,20
NO_PLATFORMS: 3
POWERUP_X: 15
POWERUP_Y: 80
POWERUP_HEIGHT: 8
POWERUP_WIDTH: 8
POWERUP_STATE: 3
ENEMY_X: 0
ENEMY_Y: 0
ENEMY_HEIGHT: 16
ENEMY_WIDTH: 16
PLATFORMS_Y_VEL: 1
CHARACTER_COLOR: BASE_COLOR
IsGrounded: 0
IsDashing: 0
CanDash: 0
DashTimeCounter: 0
DashUnlocked: 0
CURSOR_X:5
CURSOR_Y:88
CHOICE:0

#temp variables used for collision detection
Rect_1_x: 0
Rect_1_y: 0
Rect_2_x: 0
Rect_2_y: 0
Rect_1_W: 0
Rect_1_H: 0
Rect_2_W: 0
Rect_2_H: 0
FRAME_COUNT: 0
printer: .asciiz "Collision\n"

.text
.globl main



CollisionDetection:
	lw $t0 Rect_1_x
	lw $t1 Rect_2_x
	lw $t2 Rect_1_W
	lw $t3 Rect_2_W
	add $t4 $t0 $t2
	sgt $v0 $t4 $t1
	add $t4 $t1 $t3
	sgt $v1 $t4 $t0
	and $t5 $v0 $v1
	
	lw $t0 Rect_1_y
	lw $t1 Rect_2_y
	lw $t2 Rect_1_H
	lw $t3 Rect_2_H
	add $t4 $t0 $t2
	sgt $v0 $t4 $t1
	add $t4 $t1 $t3
	sgt $v1 $t4 $t0
	and $t6 $v0 $v1
	
	and $v0 $t5 $t6

	jr $ra

clear_screen:
	li $t0 BASE_ADDRESS
	li $t1 WALL_COLOR
LOOP_WALL:
	bge $t0 GROUND_ADDRESS END_WALL
	sw $t1 0($t0)
	addi $t0 $t0 4
	j LOOP_WALL
END_WALL:
	li $t1 GROUND_COLOR
LOOP_GROUND:
	bgt $t0 MAX_ADDRESS END
	sw $t1 0($t0)
	addi $t0 $t0 4
	j LOOP_GROUND
END:	
	jr $ra




main:
jal clear_screen
jal draw_startscreen
li $t0 0xFFEA03
sw $t0 CHARACTER_COLOR
li $t0 88
lw $t0 CURSOR_X
li $t0 108
lw $t0 CURSOR_Y
lw $zero CHOICE
startscreen_loop:
lw $a0 CURSOR_X
lw $a1 CURSOR_Y
#clear_cursor
jal clear_8by8
HandleInputStart:
	li $t0, 0xffff0000
	lw $t1, 0($t0)
	beq $t1, 1, KeyPressedStart
	j EndOfStartInput
KeyPressedStart:
	lw $t2, 4($t0) # this assumes $t9 is set to 0xfff0000 from before
	beq $t2, 0x77, respond_to_change_start
	beq $t2, 0x73, respond_to_change_start
	beq $t2, 112, respond_to_p_start
	j EndOfStartInput
respond_to_change_start:
lw $t0 CHOICE
addi $t0 $t0 1
ble $t0 1 CHOICECAP
	li $t0 0
CHOICECAP:
sw $t0 CHOICE

beqz $t0 FIRST_CHOICE
li $t4 108
sw $t4 CURSOR_Y 
j EndOfStartInput
FIRST_CHOICE:
li $t4 88
sw $t4 CURSOR_Y 
j EndOfStartInput

respond_to_p_start:
lw $t0 CHOICE
beqz $t0 init
beq $t0 1 SHUTDOWN
j EndOfStartInput

EndOfStartInput:
lw $a0 CURSOR_X
lw $a1 CURSOR_Y
jal draw_char_right
	li $v0, 32		
	li $a0, REFRESH_RATE
	syscall
j startscreen_loop
end_startscreen_loop:

init:	
	jal clear_screen
	li $s0 PLAYER_START_X
	li $s1 PLAYER_START_Y
	li PLAYER_X_VEL 0
	li PLAYER_Y_VEL 0
	li $v0 1
	sw $v0 MAX_JUMP_COUNT
	li $v0 1
	sw $v0 POWERUP_STATE
	lw $t0 MAX_JUMP_COUNT
	move JUMPS_LEFT $t0
	li PLAYER_DIRECTION RIGHT
	sw $zero ENEMY_X
	sw $zero ENEMY_Y
	li $t0 0
	sw $t0 FRAME_COUNT
	li $t0 1
	sw $t0 PLATFORMS_Y_VEL
	li $t0 60
	sw $t0 PLATFORMS_Y
	li $t0 0
	sw $t0 IsGrounded
		li $t0 0
	sw $t0 IsDashing
		li $t0 0
	sw $t0 CanDash
		li $t0 0
	sw $t0 DashTimeCounter
		li $t0 0
	sw $t0 DashUnlocked
		li $t0 30
	sw $t0 POWERUP_X
		li $t0 80
	sw $t0 POWERUP_Y
	li $t0 7
	sw $t0 ENEMY_SPEED
	


#This is the main gameloop
GAMELOOP:

	
CLEAROLD:
	move $a0 PLAYER_X
	move $a1 PLAYER_Y
	jal clear_8by8
	lw $a0 POWERUP_X
	lw $a1 POWERUP_Y
	jal clear_8by8
	lw $a0 ENEMY_X
	lw $a1 ENEMY_Y
	jal clear_16by16
	lw $a0 PLATFORMS_X
lw $a1 PLATFORMS_Y
jal platform_clear
#here we handle input and update parameters as needed

#Using $t8 and $t9 to hold change in x and y

#dx , dy =0
li DX 0
li DY 0

HandleInput:
	li $t0, 0xffff0000
	lw $t1, 0($t0)
	beq $t1, 1, KeyPressed
	j NoKeyPressed
KeyPressed:
	lw $t2, 4($t0) # this assumes $t9 is set to 0xfff0000 from before
	
	lw $t0 IsDashing
	beq $t0 1 IgnoreInputs 
	beq $t2, 0x77, respond_to_w
	beq $t2, 0x61, respond_to_a
	beq $t2, 0x73, respond_to_s
	beq $t2, 0x64, respond_to_d
	lw $t0 CanDash
	lw $t1 IsGrounded
	not $t1 $t1
	and $t0 $t1 $t0
	beqz $t0 IgnoreInputs
	beq $t2, 0x37, respond_to_7
	beq $t2, 0x38, respond_to_8
	beq $t2, 0x39, respond_to_9
	beq $t2, 0x34, respond_to_4
	beq $t2, 0x36, respond_to_6
	beq $t2, 0x31, respond_to_1
	beq $t2, 0x32, respond_to_2
	beq $t2, 0x33, respond_to_3

IgnoreInputs:	beq $t2,  0x70 ,RESET
	j EndofHandleInput
respond_to_w:

	blez JUMPS_LEFT EndofHandleInput
	lw $t0 MAX_JUMP_COUNT
	beq $t0 2 DOUBLE_JUMP
NORMAL_JUMP:
	lw $t0 IsGrounded
	beqz $t0 EndofHandleInput
DOUBLE_JUMP:
	subi JUMPS_LEFT JUMPS_LEFT 1
	li PLAYER_Y_VEL -8
	lw $t0 IsGrounded
	bnez $t0 EndofHandleInput
	li JUMPS_LEFT 0
NO_MORE_JUMPS:	j EndofHandleInput
respond_to_a:
	li PLAYER_X_VEL -7
	#addi DX DX -10
	li PLAYER_DIRECTION LEFT
	j EndofHandleInput
respond_to_s:
	#nothing for now
	li PLAYER_Y_VEL 10
	j EndofHandleInput

	
respond_to_d:
	li PLAYER_DIRECTION RIGHT
	li PLAYER_X_VEL 7
	#addi DX DX 10
	j EndofHandleInput
respond_to_7:
li PLAYER_X_VEL -5
li PLAYER_Y_VEL -5
j DashHelper
respond_to_8:
li PLAYER_X_VEL 0
li PLAYER_Y_VEL -5

j DashHelper
respond_to_9:
li PLAYER_X_VEL 5
li PLAYER_Y_VEL -5
j DashHelper
respond_to_4:
li PLAYER_X_VEL -5
li PLAYER_Y_VEL 0

j DashHelper

respond_to_6:
li PLAYER_X_VEL 5
li PLAYER_Y_VEL 0
j DashHelper
respond_to_1:
li PLAYER_X_VEL -5
li PLAYER_Y_VEL 5
j DashHelper
respond_to_2:
li PLAYER_X_VEL 0
li PLAYER_Y_VEL 5
j DashHelper

respond_to_3:
li PLAYER_X_VEL 5
li PLAYER_Y_VEL 5
j DashHelper
RESET:
	j main
NoKeyPressed:
	j EndofHandleInput
EndofHandleInput:



GAMELOGIC:



#ignore acceleration if you are dashing
lw $t0 IsDashing
bnez $t0 EndOfAcceleration
#decellerate
bgtz PLAYER_X_VEL RED_VEL_X
bltz PLAYER_X_VEL INC_VEL_X
	j END_OF_DECELLERATE
RED_VEL_X:
	addi  PLAYER_X_VEL PLAYER_X_VEL -1
	j END_OF_DECELLERATE
INC_VEL_X:
	addi  PLAYER_X_VEL PLAYER_X_VEL 1
END_OF_DECELLERATE:
#Handle animation / frame data

#add gravity, and check for terminal velocity
addi PLAYER_Y_VEL PLAYER_Y_VEL 1
bgt PLAYER_Y_VEL 5 MAX_FALL
		j MAX_FALL_END
MAX_FALL:	
	li PLAYER_Y_VEL 5
MAX_FALL_END:
EndOfAcceleration:
#add velocities to dx dy
add DX DX PLAYER_X_VEL
add DY DY PLAYER_Y_VEL


#update enemy position
li $v0 42
lw $a1 ENEMY_SPEED
#li $a1 10#1/10 chance to move enemy
syscall
div $a0 $a1
mfhi $t0 
bnez $t0 END_UPDATES_ENEMY
lw $t0 ENEMY_X
lw $t1 ENEMY_Y
bgt PLAYER_X $t0 INC_X
blt PLAYER_X $t0 DEC_X
INC_X:
	addi $t0 $t0 1
	j END_X_UPDATES
DEC_X:
	addi $t0 $t0 -1
END_X_UPDATES:

bgt PLAYER_Y $t1  INC_Y
blt PLAYER_Y $t1  DEC_Y
INC_Y:
	addi $t1 $t1 1
	j END_Y_UPDATES
DEC_Y:
	addi $t1 $t1 -1
END_Y_UPDATES:


sw $t0 ENEMY_X
sw $t1 ENEMY_Y
END_UPDATES_ENEMY:
#collision check 
#colision with enemy
lw $t0 IsDashing
bnez $t0 NO_ENEMY_COLLISION
	add $t0 PLAYER_X $zero
	sw $t0 Rect_1_x
	sw PLAYER_Y Rect_1_y
	li $t0 PLAYER_WIDTH
	sw $t0 Rect_1_W
	li $t0 PLAYER_HEIGHT
	sw $t0 Rect_1_H
	lw $t0 ENEMY_X
	sw $t0 Rect_2_x
	lw $t0 ENEMY_Y
	sw $t0 Rect_2_y
	lw $t0 ENEMY_WIDTH
	sw $t0 Rect_2_W
	lw $t0 ENEMY_HEIGHT
	sw $t0 Rect_2_H
	jal CollisionDetection
	#check v0 for collision
	beqz $v0 NO_ENEMY_COLLISION
	lw $t0 POWERUP_STATE
	beqz $t0 KILL_ENEMY
	j lose_screen
KILL_ENEMY:
	j win_screen
NO_ENEMY_COLLISION:
#collision with powerups
lw $v0 POWERUP_STATE
beqz $v0 NO_POWERUP_COLLISION
	add $t0 PLAYER_X $zero
	sw $t0 Rect_1_x
	sw PLAYER_Y Rect_1_y
	li $t0 PLAYER_WIDTH
	sw $t0 Rect_1_W
	li $t0 PLAYER_HEIGHT
	sw $t0 Rect_1_H
	lw $t0 POWERUP_X
	sw $t0 Rect_2_x
	lw $t0 POWERUP_Y
	sw $t0 Rect_2_y
	lw $t0 POWERUP_WIDTH
	sw $t0 Rect_2_W
	lw $t0 POWERUP_HEIGHT
	sw $t0 Rect_2_H
	jal CollisionDetection
	#check v0 for collision
	beqz $v0 NO_POWERUP_COLLISION
	lw $t0 POWERUP_STATE
	beq $t0 1 D_JUMP_COLLECTED
	beq $t0 2 DASH_COLLECTED
	beq $t0 3 INV_COLLECTED
D_JUMP_COLLECTED:
	li $t0 10
	sw $t0 POWERUP_Y
	li $t0 2
	sw $t0 POWERUP_STATE
	li $v0 2
	sw $v0 MAX_JUMP_COUNT
	j NO_POWERUP_COLLISION
DASH_COLLECTED:
	li $t0 110
	sw $t0 POWERUP_Y
	li $t0 3
	sw $t0 POWERUP_STATE
	li $v0 1
	sw $v0 DashUnlocked
	li $v0 2
	sw $v0 ENEMY_SPEED
	j NO_POWERUP_COLLISION
INV_COLLECTED:
	li $t0 80
	sw $t0 POWERUP_Y
	li $t0 0
	sw $t0 POWERUP_STATE
	li $v0 50
	sw $v0 ENEMY_SPEED
	j NO_POWERUP_COLLISION
NO_POWERUP_COLLISION:
#check for collision with platforms
li $t0 0
sw $t0 IsGrounded
#load platformX and Y into PLATFORMS X AND Y
lw $t0 IsDashing
bnez $t0 COLLISION_LOOP_DONE
li $s6 0
lw $s7 NO_PLATFORMS
COLLISION_LOOP:
	beq $s6 $s7 COLLISION_LOOP_DONE
	la $t2 PLATFORMS_X
	la $t3 PLATFORMS_Y
	mul $v0 $s6 4
	add $t2 $t2 $v0
	add $t3 $t3 $v0
	lw $t4 0($t2)
	sw $t4 PLATFORM_X 
	lw $t4 0($t3)
	sw $t4 PLATFORM_Y
	jal platform_collide
COLLISION_DONE:
	addi $s6 $s6 1
	j COLLISION_LOOP	
COLLISION_LOOP_DONE:
#Update player x and y values based on dx and dy
add PLAYER_X PLAYER_X $t8
add PLAYER_Y PLAYER_Y $t9 

#check if player is in legal coords(final collision check)


#if PLAYER_X < 0 set it to 0
	bltz PLAYER_X X_L_BOUND
	j X_L_BOUND_END
X_L_BOUND: li PLAYER_X 0
X_L_BOUND_END:
#if PLAYER_X +PLAYER_WIDTH>= WIDTH set PLAYER_X to WIDTH-PLAYER_WIDTH
	add $t0 PLAYER_X PLAYER_WIDTH
	bge $t0 WIDTH X_U_BOUND
	j X_U_BOUND_END
X_U_BOUND:	li $t0 WIDTH
		subi $t0 $t0 PLAYER_WIDTH
		move PLAYER_X $t0
X_U_BOUND_END:
#if PLAYER_Y < 0 set it to 0
	bltz PLAYER_Y Y_L_BOUND
	j Y_L_BOUND_END
Y_L_BOUND:	li PLAYER_Y 0
		li PLAYER_Y_VEL 0
Y_L_BOUND_END:
#if PLAYER_Y+PLAYER_HEIGHT>=  GROUND_LEVEL set it to GROUND_LEVEL-PLAYER_HEIGHT\
#and reset jumps left
		add $t0 PLAYER_Y PLAYER_HEIGHT
	bge $t0 GROUND_LEVEL Y_U_BOUND
	j Y_U_BOUND_END
Y_U_BOUND:	li $t0 GROUND_LEVEL
		subi $t0 $t0 PLAYER_HEIGHT
		move PLAYER_Y $t0
		li PLAYER_Y_VEL 0
		lw $t0 MAX_JUMP_COUNT
		move JUMPS_LEFT $t0
		li $t0 1
		sw $t0 IsGrounded
		lw $t0 DashUnlocked
		sw $t0 CanDash
Y_U_BOUND_END:


#update platform position





#moving platform collision and clearing

lw $t0 IsDashing
bnez $t0 MovingPlatformCollisionDone
	j MovingPlatformCollision
MovingPlatformCollisionDone:

#update platform pos
lw $t0 PLATFORMS_Y
lw $t1 PLATFORMS_Y_VEL
add $t2 $t0 $t1
sw $t2 PLATFORMS_Y

bgt $t2 40 NEGVELEND
li $t0 1
sw $t0 PLATFORMS_Y_VEL
NEGVELEND:

blt $t2 80 POSVELEND
li $t0 -1
sw $t0 PLATFORMS_Y_VEL
POSVELEND:

#Draw the updated frame
DRAW:
	move $a0 PLAYER_X
	move $a1 PLAYER_Y
	jal draw_char
	
	lw $a0 POWERUP_X
	lw $a1 POWERUP_Y
	lw $a2 POWERUP_STATE
	beqz $a2 SKIP_DRAWING_POWERUP
	jal draw_powerup
SKIP_DRAWING_POWERUP:
	lw $a0 ENEMY_X
	lw $a1 ENEMY_Y
	jal draw_enemy


#draw platforms
	li $s6 0
lw $s7 NO_PLATFORMS
DRAW_LOOP:
	beq $s6 $s7 DRAW_LOOP_END
	la $t2 PLATFORMS_X
	la $t3 PLATFORMS_Y
	mul $v0 $s6 4
	add $t2 $t2 $v0
	add $t3 $t3 $v0
	lw $a0 0($t2)
	lw $a1 0($t3)
	jal draw_platforms
DRAW_DONE:
	addi $s6 $s6 1
	j DRAW_LOOP	
DRAW_LOOP_END:


#if dash time ==0 set candash =0
#else decrease dashtime and candash =1
lw $t0 DashTimeCounter

bnez $t0 DecreaseCounter
li $t0 0
sw $t0 IsDashing
j EndofDecreaseCounter
DecreaseCounter:
	addi $t0 $t0 -1
	sw $t0 DashTimeCounter
EndofDecreaseCounter:

SLEEP:
	li $v0, 32		
	li $a0, REFRESH_RATE
	syscall
	
	j GAMELOOP


SHUTDOWN:
	li $v0, 10
	syscall

draw_enemy:
mul $t0 $a1 WIDTH
add $t0 $t0 $a0
mul $t0 $t0 4
add $t0 $t0 BASE_ADDRESS
move $t4, $t0
addi $t3, $t4,4
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,8
sw $t5, 0($t3)
addi $t3, $t4,12
sw $t5, 0($t3)
addi $t3, $t4,16
sw $t5, 0($t3)
addi $t3, $t4,20
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,24
sw $t5, 0($t3)
addi $t3, $t4,28
sw $t5, 0($t3)
addi $t3, $t4,32
sw $t5, 0($t3)
addi $t3, $t4,36
sw $t5, 0($t3)
addi $t3, $t4,40
sw $t5, 0($t3)
addi $t3, $t4,44
sw $t5, 0($t3)
addi $t3, $t4,48
sw $t5, 0($t3)
addi $t3, $t4,52
sw $t5, 0($t3)
addi $t3, $t4,56
sw $t5, 0($t3)
addi $t3, $t4,260
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,264
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,268
sw $t5, 0($t3)
addi $t3, $t4,272
sw $t5, 0($t3)
addi $t3, $t4,276
sw $t5, 0($t3)
addi $t3, $t4,280
sw $t5, 0($t3)
addi $t3, $t4,284
sw $t5, 0($t3)
addi $t3, $t4,288
sw $t5, 0($t3)
addi $t3, $t4,292
sw $t5, 0($t3)
addi $t3, $t4,296
sw $t5, 0($t3)
addi $t3, $t4,300
sw $t5, 0($t3)
addi $t3, $t4,304
sw $t5, 0($t3)
addi $t3, $t4,308
sw $t5, 0($t3)
addi $t3, $t4,312
sw $t5, 0($t3)
addi $t3, $t4,512
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,516
sw $t5, 0($t3)
addi $t3, $t4,520
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,524
sw $t5, 0($t3)
addi $t3, $t4,528
sw $t5, 0($t3)
addi $t3, $t4,532
sw $t5, 0($t3)
addi $t3, $t4,536
sw $t5, 0($t3)
addi $t3, $t4,540
sw $t5, 0($t3)
addi $t3, $t4,544
sw $t5, 0($t3)
addi $t3, $t4,548
sw $t5, 0($t3)
addi $t3, $t4,552
sw $t5, 0($t3)
addi $t3, $t4,556
sw $t5, 0($t3)
addi $t3, $t4,560
sw $t5, 0($t3)
addi $t3, $t4,564
sw $t5, 0($t3)
addi $t3, $t4,568
sw $t5, 0($t3)
addi $t3, $t4,572
sw $t5, 0($t3)
addi $t3, $t4,768
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,772
sw $t5, 0($t3)
addi $t3, $t4,776
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,792
sw $t5, 0($t3)
addi $t3, $t4,796
sw $t5, 0($t3)
addi $t3, $t4,800
sw $t5, 0($t3)
addi $t3, $t4,804
sw $t5, 0($t3)
addi $t3, $t4,808
sw $t5, 0($t3)
addi $t3, $t4,824
sw $t5, 0($t3)
addi $t3, $t4,828
sw $t5, 0($t3)
addi $t3, $t4,1024
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,1028
sw $t5, 0($t3)
addi $t3, $t4,1032
sw $t5, 0($t3)
addi $t3, $t4,1048
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,1052
sw $t5, 0($t3)
addi $t3, $t4,1056
sw $t5, 0($t3)
addi $t3, $t4,1060
sw $t5, 0($t3)
addi $t3, $t4,1064
sw $t5, 0($t3)
addi $t3, $t4,1080
sw $t5, 0($t3)
addi $t3, $t4,1084
sw $t5, 0($t3)
addi $t3, $t4,1280
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,1284
sw $t5, 0($t3)
addi $t3, $t4,1288
sw $t5, 0($t3)
addi $t3, $t4,1304
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,1308
sw $t5, 0($t3)
addi $t3, $t4,1312
sw $t5, 0($t3)
addi $t3, $t4,1316
sw $t5, 0($t3)
addi $t3, $t4,1320
sw $t5, 0($t3)
addi $t3, $t4,1336
sw $t5, 0($t3)
addi $t3, $t4,1340
sw $t5, 0($t3)
addi $t3, $t4,1536
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,1540
sw $t5, 0($t3)
addi $t3, $t4,1544
sw $t5, 0($t3)
addi $t3, $t4,1548
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,1552
sw $t5, 0($t3)
addi $t3, $t4,1556
sw $t5, 0($t3)
addi $t3, $t4,1560
sw $t5, 0($t3)
addi $t3, $t4,1572
sw $t5, 0($t3)
addi $t3, $t4,1576
sw $t5, 0($t3)
addi $t3, $t4,1580
sw $t5, 0($t3)
addi $t3, $t4,1584
sw $t5, 0($t3)
addi $t3, $t4,1588
sw $t5, 0($t3)
addi $t3, $t4,1592
sw $t5, 0($t3)
addi $t3, $t4,1596
sw $t5, 0($t3)
addi $t3, $t4,1792
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,1796
sw $t5, 0($t3)
addi $t3, $t4,1800
sw $t5, 0($t3)
addi $t3, $t4,1804
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,1808
sw $t5, 0($t3)
addi $t3, $t4,1812
sw $t5, 0($t3)
addi $t3, $t4,1816
sw $t5, 0($t3)
addi $t3, $t4,1828
sw $t5, 0($t3)
addi $t3, $t4,1832
sw $t5, 0($t3)
addi $t3, $t4,1836
sw $t5, 0($t3)
addi $t3, $t4,1840
sw $t5, 0($t3)
addi $t3, $t4,1844
sw $t5, 0($t3)
addi $t3, $t4,1848
sw $t5, 0($t3)
addi $t3, $t4,1852
sw $t5, 0($t3)
addi $t3, $t4,2052
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,2056
sw $t5, 0($t3)
addi $t3, $t4,2060
sw $t5, 0($t3)
addi $t3, $t4,2064
sw $t5, 0($t3)
addi $t3, $t4,2068
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,2072
sw $t5, 0($t3)
addi $t3, $t4,2076
sw $t5, 0($t3)
addi $t3, $t4,2080
sw $t5, 0($t3)
addi $t3, $t4,2084
sw $t5, 0($t3)
addi $t3, $t4,2088
sw $t5, 0($t3)
addi $t3, $t4,2092
sw $t5, 0($t3)
addi $t3, $t4,2096
sw $t5, 0($t3)
addi $t3, $t4,2100
sw $t5, 0($t3)
addi $t3, $t4,2320
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,2324
sw $t5, 0($t3)
addi $t3, $t4,2328
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,2332
sw $t5, 0($t3)
addi $t3, $t4,2336
sw $t5, 0($t3)
addi $t3, $t4,2340
sw $t5, 0($t3)
addi $t3, $t4,2344
sw $t5, 0($t3)
addi $t3, $t4,2348
sw $t5, 0($t3)
addi $t3, $t4,2832
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,2840
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,2852
sw $t5, 0($t3)
addi $t3, $t4,2860
sw $t5, 0($t3)
addi $t3, $t4,3088
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,3096
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,3108
sw $t5, 0($t3)
addi $t3, $t4,3116
sw $t5, 0($t3)
addi $t3, $t4,3344
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,3348
sw $t5, 0($t3)
addi $t3, $t4,3352
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,3356
sw $t5, 0($t3)
addi $t3, $t4,3360
sw $t5, 0($t3)
addi $t3, $t4,3364
sw $t5, 0($t3)
addi $t3, $t4,3368
sw $t5, 0($t3)
addi $t3, $t4,3372
sw $t5, 0($t3)
addi $t3, $t4,3600
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,3604
sw $t5, 0($t3)
addi $t3, $t4,3608
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,3612
sw $t5, 0($t3)
addi $t3, $t4,3616
sw $t5, 0($t3)
addi $t3, $t4,3620
sw $t5, 0($t3)
addi $t3, $t4,3624
sw $t5, 0($t3)
addi $t3, $t4,3628
sw $t5, 0($t3)
addi $t3, $t4,3856
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,3860
sw $t5, 0($t3)
addi $t3, $t4,3864
sw $t5, 0($t3)
addi $t3, $t4,3868
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,3872
sw $t5, 0($t3)
addi $t3, $t4,3876
sw $t5, 0($t3)
addi $t3, $t4,3880
sw $t5, 0($t3)
addi $t3, $t4,3884
sw $t5, 0($t3)
jr $ra
clear_16by16:
li $v0 16
li $v1 16
j clear
draw_powerup:
lw $t0 POWERUP_STATE
beq $t0 1 D_JUMP_POWR
beq $t0 2 DASH_POWR
beq $t0 3 INV_POWR
D_JUMP_POWR:
j draw_d_jump_powr
DASH_POWR:
j draw_dash_powr
INV_POWR:
j draw_inv_powr
jr $ra
draw_d_jump_powr:
mul $t0 $a1 WIDTH
add $t0 $t0 $a0
mul $t0 $t0 4
add $t0 $t0 BASE_ADDRESS
move $t4, $t0
addi $t3, $t4,12
li $t5,0xb5e61d
sw $t5, 0($t3)
addi $t3, $t4,16
sw $t5, 0($t3)
addi $t3, $t4,264
sw $t5, 0($t3)
addi $t3, $t4,268
sw $t5, 0($t3)
addi $t3, $t4,272
sw $t5, 0($t3)
addi $t3, $t4,276
sw $t5, 0($t3)
addi $t3, $t4,520
sw $t5, 0($t3)
addi $t3, $t4,524
sw $t5, 0($t3)
addi $t3, $t4,528
sw $t5, 0($t3)
addi $t3, $t4,532
sw $t5, 0($t3)
addi $t3, $t4,768
sw $t5, 0($t3)
addi $t3, $t4,772
sw $t5, 0($t3)
addi $t3, $t4,776
sw $t5, 0($t3)
addi $t3, $t4,780
sw $t5, 0($t3)
addi $t3, $t4,784
sw $t5, 0($t3)
addi $t3, $t4,788
sw $t5, 0($t3)
addi $t3, $t4,792
sw $t5, 0($t3)
addi $t3, $t4,796
sw $t5, 0($t3)
addi $t3, $t4,1024
sw $t5, 0($t3)
addi $t3, $t4,1028
sw $t5, 0($t3)
addi $t3, $t4,1032
sw $t5, 0($t3)
addi $t3, $t4,1036
sw $t5, 0($t3)
addi $t3, $t4,1040
sw $t5, 0($t3)
addi $t3, $t4,1044
sw $t5, 0($t3)
addi $t3, $t4,1048
sw $t5, 0($t3)
addi $t3, $t4,1052
sw $t5, 0($t3)
addi $t3, $t4,1292
sw $t5, 0($t3)
addi $t3, $t4,1296
sw $t5, 0($t3)
addi $t3, $t4,1548
sw $t5, 0($t3)
addi $t3, $t4,1552
sw $t5, 0($t3)
addi $t3, $t4,1804
sw $t5, 0($t3)
addi $t3, $t4,1808
sw $t5, 0($t3)
jr $ra
draw_dash_powr:
mul $t0 $a1 WIDTH
add $t0 $t0 $a0
mul $t0 $t0 4
add $t0 $t0 BASE_ADDRESS
move $t4, $t0
addi $t3, $t4,0
li $t5,0x7092be
sw $t5, 0($t3)
addi $t3, $t4,4
sw $t5, 0($t3)
addi $t3, $t4,8
sw $t5, 0($t3)
addi $t3, $t4,12
sw $t5, 0($t3)
addi $t3, $t4,16
sw $t5, 0($t3)
addi $t3, $t4,256
sw $t5, 0($t3)
addi $t3, $t4,272
sw $t5, 0($t3)
addi $t3, $t4,276
sw $t5, 0($t3)
addi $t3, $t4,512
sw $t5, 0($t3)
addi $t3, $t4,532
sw $t5, 0($t3)
addi $t3, $t4,536
sw $t5, 0($t3)
addi $t3, $t4,768
sw $t5, 0($t3)
addi $t3, $t4,792
sw $t5, 0($t3)
addi $t3, $t4,1024
sw $t5, 0($t3)
addi $t3, $t4,1048
sw $t5, 0($t3)
addi $t3, $t4,1280
sw $t5, 0($t3)
addi $t3, $t4,1300
sw $t5, 0($t3)
addi $t3, $t4,1304
sw $t5, 0($t3)
addi $t3, $t4,1536
sw $t5, 0($t3)
addi $t3, $t4,1552
sw $t5, 0($t3)
addi $t3, $t4,1556
sw $t5, 0($t3)
addi $t3, $t4,1792
sw $t5, 0($t3)
addi $t3, $t4,1796
sw $t5, 0($t3)
addi $t3, $t4,1800
sw $t5, 0($t3)
addi $t3, $t4,1804
sw $t5, 0($t3)
addi $t3, $t4,1808
sw $t5, 0($t3)
jr $ra
draw_inv_powr:
mul $t0 $a1 WIDTH
add $t0 $t0 $a0
mul $t0 $t0 4
add $t0 $t0 BASE_ADDRESS
move $t4, $t0
addi $t3, $t4,0
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,4
sw $t5, 0($t3)
addi $t3, $t4,8
sw $t5, 0($t3)
addi $t3, $t4,12
sw $t5, 0($t3)
addi $t3, $t4,16
sw $t5, 0($t3)
addi $t3, $t4,20
sw $t5, 0($t3)
addi $t3, $t4,24
sw $t5, 0($t3)
addi $t3, $t4,28
sw $t5, 0($t3)
addi $t3, $t4,268
sw $t5, 0($t3)
addi $t3, $t4,272
sw $t5, 0($t3)
addi $t3, $t4,524
sw $t5, 0($t3)
addi $t3, $t4,528
sw $t5, 0($t3)
addi $t3, $t4,780
sw $t5, 0($t3)
addi $t3, $t4,784
sw $t5, 0($t3)
addi $t3, $t4,1036
sw $t5, 0($t3)
addi $t3, $t4,1040
sw $t5, 0($t3)
addi $t3, $t4,1292
sw $t5, 0($t3)
addi $t3, $t4,1296
sw $t5, 0($t3)
addi $t3, $t4,1548
sw $t5, 0($t3)
addi $t3, $t4,1552
sw $t5, 0($t3)
addi $t3, $t4,1792
sw $t5, 0($t3)
addi $t3, $t4,1796
sw $t5, 0($t3)
addi $t3, $t4,1800
sw $t5, 0($t3)
addi $t3, $t4,1804
sw $t5, 0($t3)
addi $t3, $t4,1808
sw $t5, 0($t3)
addi $t3, $t4,1812
sw $t5, 0($t3)
addi $t3, $t4,1816
sw $t5, 0($t3)
addi $t3, $t4,1820
sw $t5, 0($t3)
jr $ra
platform_collide:
		#check for collision along X axis
	add $t0 PLAYER_X DX
	sw $t0 Rect_1_x
	sw PLAYER_Y Rect_1_y
	li $t0 PLAYER_WIDTH
	sw $t0 Rect_1_W
	li $t0 PLAYER_HEIGHT
	sw $t0 Rect_1_H
	lw $t0 PLATFORM_X
	sw $t0 Rect_2_x
	lw $t0 PLATFORM_Y
	sw $t0 Rect_2_y
	lw $t0 PLATFORM_WIDTH
	sw $t0 Rect_2_W
	lw $t0 PLATFORM_HEIGHT
	sw $t0 Rect_2_H
	jal CollisionDetection
	#check v0 for collision
	beqz $v0 NO_X_COLLISION
	#check which side we collide
	#reset Xvelocity
	#change DX values
	add $t0 PLAYER_X PLAYER_WIDTH
	lw $t2 PLATFORM_X
	lw $t3 PLATFORM_WIDTH
	ble $t0 $t2 LEFT_COLLISION
	add $t4 $t2 $t3
	bge PLAYER_X $t4 RIGHT_COLLISION
	j NO_X_COLLISION
RIGHT_COLLISION:#player_x>= platform_X+WIDTH
	li PLAYER_X_VEL 0
	add $t4 $t2 $t3
	sub $t5 $t4 PLAYER_X
	move DX $t5 
	j NO_X_COLLISION
LEFT_COLLISION:
	li PLAYER_X_VEL 0
	sub $t5 $t2 $t0
	move DX $t5
NO_X_COLLISION:
		#check for collision along X axis
	add $t0 PLAYER_X DX
	sw $t0 Rect_1_x
	add $t0 PLAYER_Y DY
	sw $t0 Rect_1_y
	li $t0 PLAYER_WIDTH
	sw $t0 Rect_1_W
	li $t0 PLAYER_HEIGHT
	sw $t0 Rect_1_H
	lw $t0 PLATFORM_X
	sw $t0 Rect_2_x
	lw $t0 PLATFORM_Y
	sw $t0 Rect_2_y
	lw $t0 PLATFORM_WIDTH
	sw $t0 Rect_2_W
	lw $t0 PLATFORM_HEIGHT
	sw $t0 Rect_2_H
	jal CollisionDetection
	#check v0 for collision
	beqz $v0 NO_Y_COLLISION
	#check which side we collide
	#reset Xvelocity
	#change DX values
	add $t0 PLAYER_Y PLAYER_HEIGHT
	lw $t2 PLATFORM_Y
	lw $t3 PLATFORM_HEIGHT
	ble $t0 $t2 UP_COLLISION
	add $t4 $t2 $t3
	bge PLAYER_Y $t4 DOWN_COLLISION
	j NO_Y_COLLISION
DOWN_COLLISION:#player_x>= platform_X+WIDTH
	add $t0 PLAYER_Y PLAYER_HEIGHT
	li PLAYER_Y_VEL 0
	add $t4 $t2 $t3
	sub $t5 $t4 PLAYER_Y
	move DY $t5 
	j NO_Y_COLLISION
UP_COLLISION:
	add $t0 PLAYER_Y PLAYER_HEIGHT
	li PLAYER_Y_VEL 0
	sub $t5 $t2 $t0
	move DY $t5
	li $t0 1
	sw $t0 IsGrounded
	lw $t0 MAX_JUMP_COUNT
	move JUMPS_LEFT $t0
		lw $t0 DashUnlocked
		sw $t0 CanDash
NO_Y_COLLISION:
	j COLLISION_DONE
	
#All drawing stuff here
draw_char:

li $t1 BASE_COLOR

lw $t0 POWERUP_STATE
bnez $t0 SKIP_THIS
li $t1 INVC_COLOR
SKIP_THIS:
lw $t0 IsDashing
beqz $t0 SKIPCOLORCHANGE
li $t1 DASH_COLOR
SKIPCOLORCHANGE:

sw $t1 CHARACTER_COLOR
beq PLAYER_DIRECTION RIGHT draw_char_right
beq PLAYER_DIRECTION LEFT draw_char_left

draw_char_left:
mul $t0 $a1 WIDTH
add $t0 $t0 $a0
mul $t0 $t0 4
add $t0 $t0 BASE_ADDRESS
move $t4, $t0
lw $t6 CHARACTER_COLOR
addi $t3, $t4,4
sw $t6 0($t3)
addi $t3, $t4,8
sw $t6 0($t3)
addi $t3, $t4,12
sw $t6 0($t3)
addi $t3, $t4,16
sw $t6 0($t3)
addi $t3, $t4,20
sw $t6 0($t3)
addi $t3, $t4,256
li $t5,0x99d9ea
sw $t5, 0($t3)
addi $t3, $t4,260
sw $t5, 0($t3)
addi $t3, $t4,264
li $t5,0x00a2e8
sw $t5, 0($t3)
addi $t3, $t4,268
sw $t6 0($t3)
addi $t3, $t4,272
sw $t6 0($t3)
addi $t3, $t4,276
sw $t6 0($t3)
addi $t3, $t4,512
li $t5,0x99d9ea
sw $t5, 0($t3)
addi $t3, $t4,516
sw $t5, 0($t3)
addi $t3, $t4,520
li $t5,0x00a2e8
sw $t5, 0($t3)
addi $t3, $t4,524
sw $t5, 0($t3)
addi $t3, $t4,528
sw $t6 0($t3)
addi $t3, $t4,532
sw $t6 0($t3)
addi $t3, $t4,536
li $t5,0x880015
sw $t5, 0($t3)
addi $t3, $t4,540
sw $t6 0($t3)
addi $t3, $t4,768
li $t5,0x99d9ea
sw $t5, 0($t3)
addi $t3, $t4,772
sw $t5, 0($t3)
addi $t3, $t4,776
sw $t5, 0($t3)
addi $t3, $t4,780
li $t5,0x00a2e8
sw $t5, 0($t3)
addi $t3, $t4,784
sw $t6 0($t3)
addi $t3, $t4,788
sw $t6 0($t3)
addi $t3, $t4,792
li $t5,0x880015
sw $t5, 0($t3)
addi $t3, $t4,796
sw $t6 0($t3)
addi $t3, $t4,1024
sw $t6 0($t3)
addi $t3, $t4,1028
sw $t6 0($t3)
addi $t3, $t4,1032
sw $t6 0($t3)
addi $t3, $t4,1036
sw $t6 0($t3)
addi $t3, $t4,1040
sw $t6 0($t3)
addi $t3, $t4,1044
sw $t6 0($t3)
addi $t3, $t4,1048
sw $t5, 0($t3)
addi $t3, $t4,1052
sw $t6 0($t3)
addi $t3, $t4,1284
sw $t6 0($t3)
addi $t3, $t4,1288
sw $t6 0($t3)
addi $t3, $t4,1292
sw $t6 0($t3)
addi $t3, $t4,1296
sw $t6 0($t3)
addi $t3, $t4,1300
sw $t6 0($t3)
addi $t3, $t4,1304
sw $t5, 0($t3)
addi $t3, $t4,1308
sw $t6 0($t3)
addi $t3, $t4,1540
sw $t6 0($t3)
addi $t3, $t4,1544
sw $t6 0($t3)
addi $t3, $t4,1552
sw $t6 0($t3)
addi $t3, $t4,1556
sw $t6 0($t3)
addi $t3, $t4,1796
sw $t6 0($t3)
addi $t3, $t4,1800
sw $t6 0($t3)
addi $t3, $t4,1808
sw $t6 0($t3)
addi $t3, $t4,1812
sw $t6 0($t3)

jr $ra
draw_char_right:
mul $t0 $a1 WIDTH
add $t0 $t0 $a0
mul $t0 $t0 4
add $t0 $t0 BASE_ADDRESS
move $t4, $t0
lw $t6 CHARACTER_COLOR
addi $t3, $t4,8
sw $t6 0($t3)
addi $t3, $t4,12
sw $t6 0($t3)
addi $t3, $t4,16
sw $t6 0($t3)
addi $t3, $t4,20
sw $t6 0($t3)
addi $t3, $t4,24
sw $t6 0($t3)
addi $t3, $t4,264
sw $t6 0($t3)
addi $t3, $t4,268
sw $t6 0($t3)
addi $t3, $t4,272
sw $t6 0($t3)
addi $t3, $t4,276
li $t5,0x00a2e8
sw $t5, 0($t3)
addi $t3, $t4,280
li $t5,0x99d9ea
sw $t5, 0($t3)
addi $t3, $t4,284
sw $t5, 0($t3)
addi $t3, $t4,512
sw $t6 0($t3)
addi $t3, $t4,516
li $t5,0x880015
sw $t5, 0($t3)
addi $t3, $t4,520
sw $t6 0($t3)
addi $t3, $t4,524
sw $t6 0($t3)
addi $t3, $t4,528
li $t5,0x00a2e8
sw $t5, 0($t3)
addi $t3, $t4,532
sw $t5, 0($t3)
addi $t3, $t4,536
li $t5,0x99d9ea
sw $t5, 0($t3)
addi $t3, $t4,540
sw $t5, 0($t3)
addi $t3, $t4,768
sw $t6 0($t3)
addi $t3, $t4,772
li $t5,0x880015
sw $t5, 0($t3)
addi $t3, $t4,776
sw $t6 0($t3)
addi $t3, $t4,780
sw $t6 0($t3)
addi $t3, $t4,784
li $t5,0x00a2e8
sw $t5, 0($t3)
addi $t3, $t4,788
li $t5,0x99d9ea
sw $t5, 0($t3)
addi $t3, $t4,792
sw $t5, 0($t3)
addi $t3, $t4,796
sw $t5, 0($t3)
addi $t3, $t4,1024
sw $t6 0($t3)
addi $t3, $t4,1028
li $t5,0x880015
sw $t5, 0($t3)
addi $t3, $t4,1032
sw $t6 0($t3)
addi $t3, $t4,1036
sw $t6 0($t3)
addi $t3, $t4,1040
sw $t6 0($t3)
addi $t3, $t4,1044
sw $t6 0($t3)
addi $t3, $t4,1048
sw $t6 0($t3)
addi $t3, $t4,1052
sw $t6 0($t3)
addi $t3, $t4,1280
sw $t6 0($t3)
addi $t3, $t4,1284
sw $t5, 0($t3)
addi $t3, $t4,1288
sw $t6 0($t3)
addi $t3, $t4,1292
sw $t6 0($t3)
addi $t3, $t4,1296
sw $t6 0($t3)
addi $t3, $t4,1300
sw $t6 0($t3)
addi $t3, $t4,1304
sw $t6 0($t3)
addi $t3, $t4,1544
sw $t6 0($t3)
addi $t3, $t4,1548
sw $t6 0($t3)
addi $t3, $t4,1556
sw $t6 0($t3)
addi $t3, $t4,1560
sw $t6 0($t3)
addi $t3, $t4,1800
sw $t6 0($t3)
addi $t3, $t4,1804
sw $t6 0($t3)
addi $t3, $t4,1812
sw $t6 0($t3)
addi $t3, $t4,1816
sw $t6 0($t3)

	jr $ra

clear_8by8:
li $v0 8
li $v1 8
j clear

clear:
li $t0 0
FOR_X:
beq $t0 $v0 END_FOR_X
li $t1 0
FOR_Y:
beq $t1 $v1 END_FOR_Y
add $t2 $t0 $a0
add $t3 $t1 $a1
mul $t3 $t3 WIDTH
add $t3 $t3 $t2
mul $t3 $t3 4
addi $t3 $t3 BASE_ADDRESS
li $t5 WALL_COLOR
sw $t5 0($t3)
UPDATE_Y:addi $t1 $t1 1
j FOR_Y
END_FOR_Y: 

UPDATE_X: addi $t0 $t0 1
j FOR_X
END_FOR_X:

	jr $ra

draw_platforms:
mul $t0 $a1 WIDTH
add $t0 $t0 $a0
mul $t0 $t0 4
add $t0 $t0 BASE_ADDRESS
move $t4, $t0
addi $t3, $t4,0
li $t5,0x7f7f7f
sw $t5, 0($t3)
addi $t3, $t4,4
sw $t5, 0($t3)
addi $t3, $t4,8
sw $t5, 0($t3)
addi $t3, $t4,12
sw $t5, 0($t3)
addi $t3, $t4,16
sw $t5, 0($t3)
addi $t3, $t4,20
sw $t5, 0($t3)
addi $t3, $t4,24
sw $t5, 0($t3)
addi $t3, $t4,28
sw $t5, 0($t3)
addi $t3, $t4,32
sw $t5, 0($t3)
addi $t3, $t4,36
sw $t5, 0($t3)
addi $t3, $t4,40
sw $t5, 0($t3)
addi $t3, $t4,44
sw $t5, 0($t3)
addi $t3, $t4,48
sw $t5, 0($t3)
addi $t3, $t4,52
sw $t5, 0($t3)
addi $t3, $t4,56
sw $t5, 0($t3)
addi $t3, $t4,60
sw $t5, 0($t3)
addi $t3, $t4,64
sw $t5, 0($t3)
addi $t3, $t4,68
sw $t5, 0($t3)
addi $t3, $t4,72
sw $t5, 0($t3)
addi $t3, $t4,76
sw $t5, 0($t3)
addi $t3, $t4,80
sw $t5, 0($t3)
addi $t3, $t4,84
sw $t5, 0($t3)
addi $t3, $t4,88
sw $t5, 0($t3)
addi $t3, $t4,92
sw $t5, 0($t3)
addi $t3, $t4,96
sw $t5, 0($t3)
addi $t3, $t4,100
sw $t5, 0($t3)
addi $t3, $t4,104
sw $t5, 0($t3)
addi $t3, $t4,108
sw $t5, 0($t3)
addi $t3, $t4,112
sw $t5, 0($t3)
addi $t3, $t4,116
sw $t5, 0($t3)
addi $t3, $t4,120
sw $t5, 0($t3)
addi $t3, $t4,124
sw $t5, 0($t3)
addi $t3, $t4,256
sw $t5, 0($t3)
addi $t3, $t4,260
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,264
sw $t5, 0($t3)
addi $t3, $t4,268
sw $t5, 0($t3)
addi $t3, $t4,272
sw $t5, 0($t3)
addi $t3, $t4,276
sw $t5, 0($t3)
addi $t3, $t4,280
sw $t5, 0($t3)
addi $t3, $t4,284
sw $t5, 0($t3)
addi $t3, $t4,288
sw $t5, 0($t3)
addi $t3, $t4,292
sw $t5, 0($t3)
addi $t3, $t4,296
sw $t5, 0($t3)
addi $t3, $t4,300
sw $t5, 0($t3)
addi $t3, $t4,304
sw $t5, 0($t3)
addi $t3, $t4,308
sw $t5, 0($t3)
addi $t3, $t4,312
sw $t5, 0($t3)
addi $t3, $t4,316
sw $t5, 0($t3)
addi $t3, $t4,320
sw $t5, 0($t3)
addi $t3, $t4,324
sw $t5, 0($t3)
addi $t3, $t4,328
sw $t5, 0($t3)
addi $t3, $t4,332
sw $t5, 0($t3)
addi $t3, $t4,336
sw $t5, 0($t3)
addi $t3, $t4,340
sw $t5, 0($t3)
addi $t3, $t4,344
sw $t5, 0($t3)
addi $t3, $t4,348
sw $t5, 0($t3)
addi $t3, $t4,352
sw $t5, 0($t3)
addi $t3, $t4,356
sw $t5, 0($t3)
addi $t3, $t4,360
sw $t5, 0($t3)
addi $t3, $t4,364
sw $t5, 0($t3)
addi $t3, $t4,368
sw $t5, 0($t3)
addi $t3, $t4,372
sw $t5, 0($t3)
addi $t3, $t4,376
sw $t5, 0($t3)
addi $t3, $t4,380
li $t5,0x7f7f7f
sw $t5, 0($t3)
addi $t3, $t4,512
sw $t5, 0($t3)
addi $t3, $t4,516
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,520
sw $t5, 0($t3)
addi $t3, $t4,524
sw $t5, 0($t3)
addi $t3, $t4,528
sw $t5, 0($t3)
addi $t3, $t4,532
sw $t5, 0($t3)
addi $t3, $t4,536
sw $t5, 0($t3)
addi $t3, $t4,540
sw $t5, 0($t3)
addi $t3, $t4,544
sw $t5, 0($t3)
addi $t3, $t4,548
sw $t5, 0($t3)
addi $t3, $t4,552
sw $t5, 0($t3)
addi $t3, $t4,556
sw $t5, 0($t3)
addi $t3, $t4,560
sw $t5, 0($t3)
addi $t3, $t4,564
sw $t5, 0($t3)
addi $t3, $t4,568
sw $t5, 0($t3)
addi $t3, $t4,572
sw $t5, 0($t3)
addi $t3, $t4,576
sw $t5, 0($t3)
addi $t3, $t4,580
sw $t5, 0($t3)
addi $t3, $t4,584
sw $t5, 0($t3)
addi $t3, $t4,588
sw $t5, 0($t3)
addi $t3, $t4,592
sw $t5, 0($t3)
addi $t3, $t4,596
sw $t5, 0($t3)
addi $t3, $t4,600
sw $t5, 0($t3)
addi $t3, $t4,604
sw $t5, 0($t3)
addi $t3, $t4,608
sw $t5, 0($t3)
addi $t3, $t4,612
sw $t5, 0($t3)
addi $t3, $t4,616
sw $t5, 0($t3)
addi $t3, $t4,620
sw $t5, 0($t3)
addi $t3, $t4,624
sw $t5, 0($t3)
addi $t3, $t4,628
sw $t5, 0($t3)
addi $t3, $t4,632
sw $t5, 0($t3)
addi $t3, $t4,636
li $t5,0x7f7f7f
sw $t5, 0($t3)
addi $t3, $t4,768
sw $t5, 0($t3)
addi $t3, $t4,772
sw $t5, 0($t3)
addi $t3, $t4,776
sw $t5, 0($t3)
addi $t3, $t4,780
sw $t5, 0($t3)
addi $t3, $t4,784
sw $t5, 0($t3)
addi $t3, $t4,788
sw $t5, 0($t3)
addi $t3, $t4,792
sw $t5, 0($t3)
addi $t3, $t4,796
sw $t5, 0($t3)
addi $t3, $t4,800
sw $t5, 0($t3)
addi $t3, $t4,804
sw $t5, 0($t3)
addi $t3, $t4,808
sw $t5, 0($t3)
addi $t3, $t4,812
sw $t5, 0($t3)
addi $t3, $t4,816
sw $t5, 0($t3)
addi $t3, $t4,820
sw $t5, 0($t3)
addi $t3, $t4,824
sw $t5, 0($t3)
addi $t3, $t4,828
sw $t5, 0($t3)
addi $t3, $t4,832
sw $t5, 0($t3)
addi $t3, $t4,836
sw $t5, 0($t3)
addi $t3, $t4,840
sw $t5, 0($t3)
addi $t3, $t4,844
sw $t5, 0($t3)
addi $t3, $t4,848
sw $t5, 0($t3)
addi $t3, $t4,852
sw $t5, 0($t3)
addi $t3, $t4,856
sw $t5, 0($t3)
addi $t3, $t4,860
sw $t5, 0($t3)
addi $t3, $t4,864
sw $t5, 0($t3)
addi $t3, $t4,868
sw $t5, 0($t3)
addi $t3, $t4,872
sw $t5, 0($t3)
addi $t3, $t4,876
sw $t5, 0($t3)
addi $t3, $t4,880
sw $t5, 0($t3)
addi $t3, $t4,884
sw $t5, 0($t3)
addi $t3, $t4,888
sw $t5, 0($t3)
addi $t3, $t4,892
sw $t5, 0($t3)
addi $t3, $t4,1024
sw $t5, 0($t3)
addi $t3, $t4,1028
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,1032
sw $t5, 0($t3)
addi $t3, $t4,1036
sw $t5, 0($t3)
addi $t3, $t4,1040
sw $t5, 0($t3)
addi $t3, $t4,1044
sw $t5, 0($t3)
addi $t3, $t4,1048
sw $t5, 0($t3)
addi $t3, $t4,1052
sw $t5, 0($t3)
addi $t3, $t4,1056
sw $t5, 0($t3)
addi $t3, $t4,1060
sw $t5, 0($t3)
addi $t3, $t4,1064
sw $t5, 0($t3)
addi $t3, $t4,1068
sw $t5, 0($t3)
addi $t3, $t4,1072
sw $t5, 0($t3)
addi $t3, $t4,1076
sw $t5, 0($t3)
addi $t3, $t4,1080
sw $t5, 0($t3)
addi $t3, $t4,1084
sw $t5, 0($t3)
addi $t3, $t4,1088
sw $t5, 0($t3)
addi $t3, $t4,1092
sw $t5, 0($t3)
addi $t3, $t4,1096
sw $t5, 0($t3)
addi $t3, $t4,1100
sw $t5, 0($t3)
addi $t3, $t4,1104
sw $t5, 0($t3)
addi $t3, $t4,1108
sw $t5, 0($t3)
addi $t3, $t4,1112
sw $t5, 0($t3)
addi $t3, $t4,1116
sw $t5, 0($t3)
addi $t3, $t4,1120
sw $t5, 0($t3)
addi $t3, $t4,1124
sw $t5, 0($t3)
addi $t3, $t4,1128
sw $t5, 0($t3)
addi $t3, $t4,1132
sw $t5, 0($t3)
addi $t3, $t4,1136
sw $t5, 0($t3)
addi $t3, $t4,1140
sw $t5, 0($t3)
addi $t3, $t4,1144
sw $t5, 0($t3)
addi $t3, $t4,1148
li $t5,0x7f7f7f
sw $t5, 0($t3)
addi $t3, $t4,1280
sw $t5, 0($t3)
addi $t3, $t4,1284
sw $t5, 0($t3)
addi $t3, $t4,1288
sw $t5, 0($t3)
addi $t3, $t4,1292
sw $t5, 0($t3)
addi $t3, $t4,1296
sw $t5, 0($t3)
addi $t3, $t4,1300
sw $t5, 0($t3)
addi $t3, $t4,1304
sw $t5, 0($t3)
addi $t3, $t4,1308
sw $t5, 0($t3)
addi $t3, $t4,1312
sw $t5, 0($t3)
addi $t3, $t4,1316
sw $t5, 0($t3)
addi $t3, $t4,1320
sw $t5, 0($t3)
addi $t3, $t4,1324
sw $t5, 0($t3)
addi $t3, $t4,1328
sw $t5, 0($t3)
addi $t3, $t4,1332
sw $t5, 0($t3)
addi $t3, $t4,1336
sw $t5, 0($t3)
addi $t3, $t4,1340
sw $t5, 0($t3)
addi $t3, $t4,1344
sw $t5, 0($t3)
addi $t3, $t4,1348
sw $t5, 0($t3)
addi $t3, $t4,1352
sw $t5, 0($t3)
addi $t3, $t4,1356
sw $t5, 0($t3)
addi $t3, $t4,1360
sw $t5, 0($t3)
addi $t3, $t4,1364
sw $t5, 0($t3)
addi $t3, $t4,1368
sw $t5, 0($t3)
addi $t3, $t4,1372
sw $t5, 0($t3)
addi $t3, $t4,1376
sw $t5, 0($t3)
addi $t3, $t4,1380
sw $t5, 0($t3)
addi $t3, $t4,1384
sw $t5, 0($t3)
addi $t3, $t4,1388
sw $t5, 0($t3)
addi $t3, $t4,1392
sw $t5, 0($t3)
addi $t3, $t4,1396
sw $t5, 0($t3)
addi $t3, $t4,1400
sw $t5, 0($t3)
addi $t3, $t4,1404
sw $t5, 0($t3)
addi $t3, $t4,1536
sw $t5, 0($t3)
addi $t3, $t4,1540
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,1544
sw $t5, 0($t3)
addi $t3, $t4,1548
sw $t5, 0($t3)
addi $t3, $t4,1552
sw $t5, 0($t3)
addi $t3, $t4,1556
sw $t5, 0($t3)
addi $t3, $t4,1560
sw $t5, 0($t3)
addi $t3, $t4,1564
sw $t5, 0($t3)
addi $t3, $t4,1568
sw $t5, 0($t3)
addi $t3, $t4,1572
sw $t5, 0($t3)
addi $t3, $t4,1576
sw $t5, 0($t3)
addi $t3, $t4,1580
sw $t5, 0($t3)
addi $t3, $t4,1584
sw $t5, 0($t3)
addi $t3, $t4,1588
sw $t5, 0($t3)
addi $t3, $t4,1592
sw $t5, 0($t3)
addi $t3, $t4,1596
sw $t5, 0($t3)
addi $t3, $t4,1600
sw $t5, 0($t3)
addi $t3, $t4,1604
sw $t5, 0($t3)
addi $t3, $t4,1608
sw $t5, 0($t3)
addi $t3, $t4,1612
sw $t5, 0($t3)
addi $t3, $t4,1616
sw $t5, 0($t3)
addi $t3, $t4,1620
sw $t5, 0($t3)
addi $t3, $t4,1624
sw $t5, 0($t3)
addi $t3, $t4,1628
sw $t5, 0($t3)
addi $t3, $t4,1632
sw $t5, 0($t3)
addi $t3, $t4,1636
sw $t5, 0($t3)
addi $t3, $t4,1640
sw $t5, 0($t3)
addi $t3, $t4,1644
sw $t5, 0($t3)
addi $t3, $t4,1648
sw $t5, 0($t3)
addi $t3, $t4,1652
sw $t5, 0($t3)
addi $t3, $t4,1656
sw $t5, 0($t3)
addi $t3, $t4,1660
li $t5,0x7f7f7f
sw $t5, 0($t3)
addi $t3, $t4,1792
sw $t5, 0($t3)
addi $t3, $t4,1796
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4,1800
sw $t5, 0($t3)
addi $t3, $t4,1804
sw $t5, 0($t3)
addi $t3, $t4,1808
sw $t5, 0($t3)
addi $t3, $t4,1812
sw $t5, 0($t3)
addi $t3, $t4,1816
sw $t5, 0($t3)
addi $t3, $t4,1820
sw $t5, 0($t3)
addi $t3, $t4,1824
sw $t5, 0($t3)
addi $t3, $t4,1828
sw $t5, 0($t3)
addi $t3, $t4,1832
sw $t5, 0($t3)
addi $t3, $t4,1836
sw $t5, 0($t3)
addi $t3, $t4,1840
sw $t5, 0($t3)
addi $t3, $t4,1844
sw $t5, 0($t3)
addi $t3, $t4,1848
sw $t5, 0($t3)
addi $t3, $t4,1852
sw $t5, 0($t3)
addi $t3, $t4,1856
sw $t5, 0($t3)
addi $t3, $t4,1860
sw $t5, 0($t3)
addi $t3, $t4,1864
sw $t5, 0($t3)
addi $t3, $t4,1868
sw $t5, 0($t3)
addi $t3, $t4,1872
sw $t5, 0($t3)
addi $t3, $t4,1876
sw $t5, 0($t3)
addi $t3, $t4,1880
sw $t5, 0($t3)
addi $t3, $t4,1884
sw $t5, 0($t3)
addi $t3, $t4,1888
sw $t5, 0($t3)
addi $t3, $t4,1892
sw $t5, 0($t3)
addi $t3, $t4,1896
sw $t5, 0($t3)
addi $t3, $t4,1900
sw $t5, 0($t3)
addi $t3, $t4,1904
sw $t5, 0($t3)
addi $t3, $t4,1908
sw $t5, 0($t3)
addi $t3, $t4,1912
sw $t5, 0($t3)
addi $t3, $t4,1916
li $t5,0x7f7f7f
sw $t5, 0($t3)
addi $t3, $t4,2048
sw $t5, 0($t3)
addi $t3, $t4,2052
sw $t5, 0($t3)
addi $t3, $t4,2056
sw $t5, 0($t3)
addi $t3, $t4,2060
sw $t5, 0($t3)
addi $t3, $t4,2064
sw $t5, 0($t3)
addi $t3, $t4,2068
sw $t5, 0($t3)
addi $t3, $t4,2072
sw $t5, 0($t3)
addi $t3, $t4,2076
sw $t5, 0($t3)
addi $t3, $t4,2080
sw $t5, 0($t3)
addi $t3, $t4,2084
sw $t5, 0($t3)
addi $t3, $t4,2088
sw $t5, 0($t3)
addi $t3, $t4,2092
sw $t5, 0($t3)
addi $t3, $t4,2096
sw $t5, 0($t3)
addi $t3, $t4,2100
sw $t5, 0($t3)
addi $t3, $t4,2104
sw $t5, 0($t3)
addi $t3, $t4,2108
sw $t5, 0($t3)
addi $t3, $t4,2112
sw $t5, 0($t3)
addi $t3, $t4,2116
sw $t5, 0($t3)
addi $t3, $t4,2120
sw $t5, 0($t3)
addi $t3, $t4,2124
sw $t5, 0($t3)
addi $t3, $t4,2128
sw $t5, 0($t3)
addi $t3, $t4,2132
sw $t5, 0($t3)
addi $t3, $t4,2136
sw $t5, 0($t3)
addi $t3, $t4,2140
sw $t5, 0($t3)
addi $t3, $t4,2144
sw $t5, 0($t3)
addi $t3, $t4,2148
sw $t5, 0($t3)
addi $t3, $t4,2152
sw $t5, 0($t3)
addi $t3, $t4,2156
sw $t5, 0($t3)
addi $t3, $t4,2160
sw $t5, 0($t3)
addi $t3, $t4,2164
sw $t5, 0($t3)
addi $t3, $t4,2168
sw $t5, 0($t3)
addi $t3, $t4,2172
sw $t5, 0($t3)
jr $ra


platform_clear:
lw $v0 PLATFORM_WIDTH
lw $v1 PLATFORM_HEIGHT
j clear

	
MovingPlatformCollision:
		#check for collision along X axis
	add $t0 PLAYER_X $zero
	sw $t0 Rect_1_x
	add $t0 PLAYER_Y $zero
	sw $t0 Rect_1_y
	li $t0 PLAYER_WIDTH
	sw $t0 Rect_1_W
	li $t0 PLAYER_HEIGHT
	sw $t0 Rect_1_H
	lw $t0 PLATFORMS_X
	sw $t0 Rect_2_x
	lw $t0 PLATFORMS_Y
	lw $t1 PLATFORMS_Y_VEL
	add $t0 $t1 $t0
	sw $t0 Rect_2_y
	lw $t0 PLATFORM_WIDTH
	sw $t0 Rect_2_W
	lw $t0 PLATFORM_HEIGHT
	sw $t0 Rect_2_H
	jal CollisionDetection
	#check v0 for collision
	beqz $v0 NO_Y_COLLISION_M
	#check which side we collide
	#reset Xvelocity
	#change DX values
	add $t0 PLAYER_Y PLAYER_HEIGHT
	lw $t2 PLATFORMS_Y
	lw $t3 PLATFORM_HEIGHT
	ble $t0 $t2 UP_COLLISION_M
	add $t4 $t2 $t3
	bge PLAYER_Y $t4 DOWN_COLLISION_M
	j NO_Y_COLLISION_M
DOWN_COLLISION_M:#player_x>= platform_X+WIDTH
	
	li PLAYER_Y_VEL 0
	addi PLAYER_Y PLAYER_Y 1
	j NO_Y_COLLISION_M
UP_COLLISION_M:
	
	li PLAYER_Y_VEL 0
	addi PLAYER_Y PLAYER_Y -1
	li $t0 1
	sw $t0 IsGrounded
	lw $t0 MAX_JUMP_COUNT
	move JUMPS_LEFT $t0
		lw $t0 DashUnlocked
		sw $t0 CanDash
NO_Y_COLLISION_M:
	j MovingPlatformCollisionDone


lose_screen:
	li $a0 0
	li $a1 0
	jal clear_screen
	jal draw_lose_screen
	li $v0, 32		
	li $a0, 1000
	syscall
	j main
draw_lose_screen:
#paste it here
mul $t0 $a1 WIDTH
add $t0 $t0 $a0
mul $t0 $t0 4
add $t0 $t0 BASE_ADDRESS
move $t4, $t0
addi $t3, $t4,12364
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,12368
li $t5,0x92e1e7
sw $t5, 0($t3)
addi $t3, $t4,12372
li $t5,0x927f6b
sw $t5, 0($t3)
addi $t3, $t4,12388
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,12392
li $t5,0xdce1d0
sw $t5, 0($t3)
addi $t3, $t4,12396
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,12408
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,12412
li $t5,0xb8e1e7
sw $t5, 0($t3)
addi $t3, $t4,12416
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,12420
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,12424
li $t5,0xdcc1b9
sw $t5, 0($t3)
addi $t3, $t4,12428
li $t5,0x6b5b6b
sw $t5, 0($t3)
addi $t3, $t4,12440
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,12444
li $t5,0xb8e1d0
sw $t5, 0($t3)
addi $t3, $t4,12448
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,12464
li $t5,0x6bc1e7
sw $t5, 0($t3)
addi $t3, $t4,12468
li $t5,0xb8a186
sw $t5, 0($t3)
addi $t3, $t4,12624
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,12628
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,12632
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,12644
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,12648
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,12660
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,12664
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,12668
li $t5,0xb8a186
sw $t5, 0($t3)
addi $t3, $t4,12672
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,12676
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,12680
li $t5,0x6ba1e7
sw $t5, 0($t3)
addi $t3, $t4,12684
li $t5,0xffffd0
sw $t5, 0($t3)
addi $t3, $t4,12688
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,12696
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,12700
li $t5,0xdcffe7
sw $t5, 0($t3)
addi $t3, $t4,12704
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,12720
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,12724
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,12880
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,12884
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,12888
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,12896
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,12900
li $t5,0xdcffe7
sw $t5, 0($t3)
addi $t3, $t4,12904
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,12916
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,12920
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,12940
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,12944
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,12952
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,12956
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,12960
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,12976
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,12980
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,13140
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,13144
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,13148
li $t5,0x3f3486
sw $t5, 0($t3)
addi $t3, $t4,13152
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,13156
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,13168
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,13172
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,13176
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,13196
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,13200
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,13204
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,13208
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,13212
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,13216
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,13232
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,13236
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,13396
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,13400
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,13404
li $t5,0xdcc1d0
sw $t5, 0($t3)
addi $t3, $t4,13408
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,13412
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,13424
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,13428
li $t5,0xdcffe7
sw $t5, 0($t3)
addi $t3, $t4,13432
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,13452
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,13456
li $t5,0xffffd0
sw $t5, 0($t3)
addi $t3, $t4,13460
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,13464
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,13468
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,13472
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,13488
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,13492
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,13656
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,13660
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,13664
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,13680
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,13684
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,13688
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,13708
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,13712
li $t5,0xffffd0
sw $t5, 0($t3)
addi $t3, $t4,13716
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,13720
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,13724
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,13728
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,13744
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,13748
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,13912
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,13916
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,13920
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,13936
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,13940
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,13944
li $t5,0xffe1d0
sw $t5, 0($t3)
addi $t3, $t4,13948
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,13956
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,13960
li $t5,0x3f7fb9
sw $t5, 0($t3)
addi $t3, $t4,13964
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,13968
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,13976
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,13980
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,13984
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,13996
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,14000
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,14004
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,14168
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,14172
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14176
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,14196
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,14200
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14204
sw $t5, 0($t3)
addi $t3, $t4,14208
sw $t5, 0($t3)
addi $t3, $t4,14212
sw $t5, 0($t3)
addi $t3, $t4,14216
sw $t5, 0($t3)
addi $t3, $t4,14220
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,14224
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,14232
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,14236
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,14240
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14244
li $t5,0xdce1d0
sw $t5, 0($t3)
addi $t3, $t4,14248
li $t5,0xb8c1d0
sw $t5, 0($t3)
addi $t3, $t4,14252
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,14256
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14260
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,14424
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,14428
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14432
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,14456
li $t5,0x3f7fd0
sw $t5, 0($t3)
addi $t3, $t4,14460
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,14464
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14468
sw $t5, 0($t3)
addi $t3, $t4,14472
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,14476
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,14492
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,14496
li $t5,0xb8e1ff
sw $t5, 0($t3)
addi $t3, $t4,14500
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14504
sw $t5, 0($t3)
addi $t3, $t4,14508
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,14512
li $t5,0xb8a186
sw $t5, 0($t3)
addi $t3, $t4,14720
li $t5,0x0d5b86
sw $t5, 0($t3)
addi $t3, $t4,14724
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,14756
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,14760
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,15936
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,15940
li $t5,0xb8e1d0
sw $t5, 0($t3)
addi $t3, $t4,15944
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,15972
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,15976
li $t5,0xb8e1e7
sw $t5, 0($t3)
addi $t3, $t4,15980
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,15984
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,15988
li $t5,0xdcc1b9
sw $t5, 0($t3)
addi $t3, $t4,15992
li $t5,0x6b5b6b
sw $t5, 0($t3)
addi $t3, $t4,16008
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,16012
li $t5,0x92e1e7
sw $t5, 0($t3)
addi $t3, $t4,16016
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,16020
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,16024
li $t5,0xdce1d0
sw $t5, 0($t3)
addi $t3, $t4,16028
li $t5,0x927f86
sw $t5, 0($t3)
addi $t3, $t4,16036
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,16040
li $t5,0xb8e1e7
sw $t5, 0($t3)
addi $t3, $t4,16044
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,16048
sw $t5, 0($t3)
addi $t3, $t4,16052
sw $t5, 0($t3)
addi $t3, $t4,16056
sw $t5, 0($t3)
addi $t3, $t4,16060
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,16192
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,16196
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,16200
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,16224
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,16228
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,16232
li $t5,0xb8a186
sw $t5, 0($t3)
addi $t3, $t4,16236
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,16240
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,16244
li $t5,0x6ba1e7
sw $t5, 0($t3)
addi $t3, $t4,16248
li $t5,0xffffd0
sw $t5, 0($t3)
addi $t3, $t4,16252
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,16260
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,16264
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,16268
li $t5,0xdca19f
sw $t5, 0($t3)
addi $t3, $t4,16272
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,16280
li $t5,0x3f5b9f
sw $t5, 0($t3)
addi $t3, $t4,16284
li $t5,0x6b7f86
sw $t5, 0($t3)
addi $t3, $t4,16292
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,16296
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,16300
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,16304
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,16308
sw $t5, 0($t3)
addi $t3, $t4,16312
sw $t5, 0($t3)
addi $t3, $t4,16448
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,16452
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,16456
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,16480
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,16484
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,16504
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,16508
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,16516
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,16520
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,16524
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,16548
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,16552
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,16556
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,16704
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,16708
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,16712
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,16732
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,16736
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,16740
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,16760
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,16764
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,16768
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,16772
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,16776
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,16780
li $t5,0xdcc19f
sw $t5, 0($t3)
addi $t3, $t4,16784
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,16804
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,16808
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,16812
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,16816
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,16820
sw $t5, 0($t3)
addi $t3, $t4,16824
sw $t5, 0($t3)
addi $t3, $t4,16960
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,16964
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,16968
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,16988
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,16992
li $t5,0xdcffe7
sw $t5, 0($t3)
addi $t3, $t4,16996
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,17016
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,17020
li $t5,0xffffd0
sw $t5, 0($t3)
addi $t3, $t4,17024
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,17032
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,17036
li $t5,0xb8e1ff
sw $t5, 0($t3)
addi $t3, $t4,17040
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,17044
sw $t5, 0($t3)
addi $t3, $t4,17048
li $t5,0xdcc1b9
sw $t5, 0($t3)
addi $t3, $t4,17052
li $t5,0x6b5b6b
sw $t5, 0($t3)
addi $t3, $t4,17060
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,17064
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,17068
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,17072
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,17076
sw $t5, 0($t3)
addi $t3, $t4,17080
li $t5,0xdce1d0
sw $t5, 0($t3)
addi $t3, $t4,17084
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,17216
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,17220
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,17224
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,17244
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,17248
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,17252
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,17272
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,17276
li $t5,0xffffd0
sw $t5, 0($t3)
addi $t3, $t4,17280
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,17300
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,17304
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,17308
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,17312
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,17316
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,17320
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,17324
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,17472
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,17476
li $t5,0xdcffe7
sw $t5, 0($t3)
addi $t3, $t4,17480
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,17500
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,17504
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,17508
li $t5,0xffe1d0
sw $t5, 0($t3)
addi $t3, $t4,17512
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,17520
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,17524
li $t5,0x3f7fb9
sw $t5, 0($t3)
addi $t3, $t4,17528
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,17532
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,17560
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,17564
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,17568
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,17572
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,17576
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,17580
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,17728
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,17732
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,17736
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,17740
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,17744
sw $t5, 0($t3)
addi $t3, $t4,17748
sw $t5, 0($t3)
addi $t3, $t4,17752
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,17760
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,17764
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,17768
sw $t5, 0($t3)
addi $t3, $t4,17772
sw $t5, 0($t3)
addi $t3, $t4,17776
sw $t5, 0($t3)
addi $t3, $t4,17780
sw $t5, 0($t3)
addi $t3, $t4,17784
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,17788
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,17796
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,17800
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,17804
li $t5,0xdcc1b9
sw $t5, 0($t3)
addi $t3, $t4,17808
li $t5,0x927f9f
sw $t5, 0($t3)
addi $t3, $t4,17812
li $t5,0x92a1d0
sw $t5, 0($t3)
addi $t3, $t4,17816
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,17820
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,17824
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,17828
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,17832
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,17836
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,17840
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,17844
sw $t5, 0($t3)
addi $t3, $t4,17848
sw $t5, 0($t3)
addi $t3, $t4,17852
li $t5,0xb8a186
sw $t5, 0($t3)
addi $t3, $t4,17984
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,17988
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,17992
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,17996
sw $t5, 0($t3)
addi $t3, $t4,18000
sw $t5, 0($t3)
addi $t3, $t4,18004
sw $t5, 0($t3)
addi $t3, $t4,18008
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,18020
li $t5,0x3f7fd0
sw $t5, 0($t3)
addi $t3, $t4,18024
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,18028
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,18032
sw $t5, 0($t3)
addi $t3, $t4,18036
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,18040
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,18052
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,18056
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,18060
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,18064
sw $t5, 0($t3)
addi $t3, $t4,18068
sw $t5, 0($t3)
addi $t3, $t4,18072
li $t5,0xffe1d0
sw $t5, 0($t3)
addi $t3, $t4,18076
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,18084
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,18088
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,18092
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,18096
sw $t5, 0($t3)
addi $t3, $t4,18100
sw $t5, 0($t3)
addi $t3, $t4,18104
sw $t5, 0($t3)
addi $t3, $t4,18108
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,18284
li $t5,0x0d5b86
sw $t5, 0($t3)
addi $t3, $t4,18288
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,18320
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,18324
li $t5,0x3f346b
sw $t5, 0($t3)

jr $ra
draw_startscreen:
li $a0 0
li $a1 0
#paste it here
mul $t0 $a1 WIDTH
add $t0 $t0 $a0
mul $t0 $t0 4
add $t0 $t0 BASE_ADDRESS
move $t4, $t0
addi $t3, $t4,3600
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,3604
li $t5,0x6bc1e7
sw $t5, 0($t3)
addi $t3, $t4,3608
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,3856
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,3860
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,3864
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,3868
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,4112
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,4116
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,4120
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,4124
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,4140
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,4144
li $t5,0x6ba1b9
sw $t5, 0($t3)
addi $t3, $t4,4148
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,4152
li $t5,0x92c1e7
sw $t5, 0($t3)
addi $t3, $t4,4156
li $t5,0xdce1d0
sw $t5, 0($t3)
addi $t3, $t4,4160
li $t5,0x927f86
sw $t5, 0($t3)
addi $t3, $t4,4164
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,4168
li $t5,0x6ba1d0
sw $t5, 0($t3)
addi $t3, $t4,4172
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,4176
li $t5,0xb8a186
sw $t5, 0($t3)
addi $t3, $t4,4196
li $t5,0x3f7fb9
sw $t5, 0($t3)
addi $t3, $t4,4200
li $t5,0xb8e1e7
sw $t5, 0($t3)
addi $t3, $t4,4204
li $t5,0xdcc1d0
sw $t5, 0($t3)
addi $t3, $t4,4208
li $t5,0x927f86
sw $t5, 0($t3)
addi $t3, $t4,4220
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,4224
li $t5,0x92c1b9
sw $t5, 0($t3)
addi $t3, $t4,4228
li $t5,0x6b5b9f
sw $t5, 0($t3)
addi $t3, $t4,4232
li $t5,0x92c1d0
sw $t5, 0($t3)
addi $t3, $t4,4236
li $t5,0xdce1d0
sw $t5, 0($t3)
addi $t3, $t4,4240
li $t5,0x927f86
sw $t5, 0($t3)
addi $t3, $t4,4256
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,4260
li $t5,0x6ba1d0
sw $t5, 0($t3)
addi $t3, $t4,4264
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,4268
li $t5,0xb8a19f
sw $t5, 0($t3)
addi $t3, $t4,4272
li $t5,0x3f5b9f
sw $t5, 0($t3)
addi $t3, $t4,4276
li $t5,0x92a19f
sw $t5, 0($t3)
addi $t3, $t4,4280
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,4284
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,4288
li $t5,0x92a19f
sw $t5, 0($t3)
addi $t3, $t4,4292
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,4300
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,4304
li $t5,0x6ba1d0
sw $t5, 0($t3)
addi $t3, $t4,4308
li $t5,0x927f86
sw $t5, 0($t3)
addi $t3, $t4,4316
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,4320
li $t5,0x92c1d0
sw $t5, 0($t3)
addi $t3, $t4,4324
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,4328
li $t5,0xb8c1d0
sw $t5, 0($t3)
addi $t3, $t4,4332
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,4364
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,4368
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,4372
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,4376
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,4380
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,4396
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,4400
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,4404
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,4408
li $t5,0x6b5b6b
sw $t5, 0($t3)
addi $t3, $t4,4412
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,4416
li $t5,0x92e1e7
sw $t5, 0($t3)
addi $t3, $t4,4420
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,4424
li $t5,0xb87f86
sw $t5, 0($t3)
addi $t3, $t4,4428
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,4432
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,4436
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,4448
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,4452
li $t5,0xdcc19f
sw $t5, 0($t3)
addi $t3, $t4,4456
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,4460
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,4464
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,4468
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,4476
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,4480
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,4484
li $t5,0xffe1d0
sw $t5, 0($t3)
addi $t3, $t4,4488
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,4492
li $t5,0x3f5b9f
sw $t5, 0($t3)
addi $t3, $t4,4496
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,4500
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,4512
li $t5,0x6bc1d0
sw $t5, 0($t3)
addi $t3, $t4,4516
li $t5,0x927f86
sw $t5, 0($t3)
addi $t3, $t4,4520
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,4524
li $t5,0x6ba1e7
sw $t5, 0($t3)
addi $t3, $t4,4528
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,4532
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,4536
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,4540
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,4544
li $t5,0xdce1b9
sw $t5, 0($t3)
addi $t3, $t4,4548
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,4556
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,4560
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,4564
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,4568
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,4572
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,4576
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,4584
li $t5,0x0d5b86
sw $t5, 0($t3)
addi $t3, $t4,4588
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,4620
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,4624
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,4628
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,4632
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,4636
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,4640
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,4652
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,4656
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,4660
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,4672
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,4676
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,4688
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,4692
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,4700
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,4704
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,4708
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,4720
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,4724
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,4728
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,4732
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,4736
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,4740
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,4752
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,4756
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,4764
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,4768
li $t5,0xb8c19f
sw $t5, 0($t3)
addi $t3, $t4,4780
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,4784
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,4788
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,4792
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,4796
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,4800
li $t5,0xdce1b9
sw $t5, 0($t3)
addi $t3, $t4,4804
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,4812
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,4816
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,4820
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,4824
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,4828
li $t5,0xb8ffd0
sw $t5, 0($t3)
addi $t3, $t4,4832
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,4876
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,4880
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,4892
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,4896
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,4908
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,4912
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,4916
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,4928
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,4932
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,4944
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,4948
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,4956
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,4960
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,4964
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,4976
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,4980
li $t5,0xdce1b9
sw $t5, 0($t3)
addi $t3, $t4,4984
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,4988
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,4992
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,4996
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,5008
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,5012
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,5020
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,5024
li $t5,0xb8a186
sw $t5, 0($t3)
addi $t3, $t4,5036
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,5040
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,5044
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,5048
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,5052
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,5056
li $t5,0xdce1b9
sw $t5, 0($t3)
addi $t3, $t4,5060
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,5068
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,5072
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,5076
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,5084
li $t5,0x3f7fd0
sw $t5, 0($t3)
addi $t3, $t4,5088
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,5092
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,5096
li $t5,0xb8a19f
sw $t5, 0($t3)
addi $t3, $t4,5100
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,5128
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,5132
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,5136
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,5140
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,5144
sw $t5, 0($t3)
addi $t3, $t4,5148
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,5152
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,5156
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,5164
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,5168
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,5172
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,5184
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,5188
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,5200
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,5204
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,5212
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,5216
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,5220
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,5232
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,5236
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,5240
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,5244
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,5248
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,5252
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,5264
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,5268
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,5276
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,5280
li $t5,0xb8c19f
sw $t5, 0($t3)
addi $t3, $t4,5292
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,5296
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,5300
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,5308
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,5312
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,5316
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,5324
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,5328
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,5332
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,5348
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,5352
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,5356
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,5360
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,5384
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,5388
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,5392
li $t5,0xb8c1d0
sw $t5, 0($t3)
addi $t3, $t4,5396
sw $t5, 0($t3)
addi $t3, $t4,5400
sw $t5, 0($t3)
addi $t3, $t4,5404
li $t5,0xb8c1e7
sw $t5, 0($t3)
addi $t3, $t4,5408
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,5412
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,5420
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,5424
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,5428
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,5436
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,5440
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,5444
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,5456
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,5460
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,5468
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,5472
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,5476
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,5480
li $t5,0xdce1d0
sw $t5, 0($t3)
addi $t3, $t4,5484
li $t5,0xb8e1e7
sw $t5, 0($t3)
addi $t3, $t4,5488
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,5492
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,5500
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,5504
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,5508
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,5520
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,5524
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,5536
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,5540
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,5544
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,5548
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,5552
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,5556
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,5564
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,5568
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,5572
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,5576
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,5580
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,5584
sw $t5, 0($t3)
addi $t3, $t4,5588
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,5592
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,5596
li $t5,0xb8c1b9
sw $t5, 0($t3)
addi $t3, $t4,5600
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,5604
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,5608
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,5612
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,5616
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,5636
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,5640
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,5644
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,5660
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,5664
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,5668
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,5676
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,5680
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,5684
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,5692
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,5696
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,5700
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,5708
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,5712
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,5716
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,5728
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,5732
li $t5,0xb8e1ff
sw $t5, 0($t3)
addi $t3, $t4,5736
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,5740
sw $t5, 0($t3)
addi $t3, $t4,5744
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,5748
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,5756
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,5760
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,5764
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,5776
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,5780
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,5784
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,5792
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,5796
li $t5,0xb8e1ff
sw $t5, 0($t3)
addi $t3, $t4,5800
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,5804
li $t5,0xffe1d0
sw $t5, 0($t3)
addi $t3, $t4,5808
li $t5,0x92c1e7
sw $t5, 0($t3)
addi $t3, $t4,5812
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,5824
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,5828
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,5832
sw $t5, 0($t3)
addi $t3, $t4,5836
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,5840
li $t5,0x92c1ff
sw $t5, 0($t3)
addi $t3, $t4,5844
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,5848
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,5852
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,5856
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,5860
sw $t5, 0($t3)
addi $t3, $t4,5864
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,5868
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,5992
li $t5,0x0d5b86
sw $t5, 0($t3)
addi $t3, $t4,5996
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,6060
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,6064
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,6068
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,6084
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,6088
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,6112
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,6116
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,6304
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,6308
li $t5,0xffe1d0
sw $t5, 0($t3)
addi $t3, $t4,6312
li $t5,0xb8c1d0
sw $t5, 0($t3)
addi $t3, $t4,6316
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,6320
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,6324
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,7204
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,7208
li $t5,0xb8e1e7
sw $t5, 0($t3)
addi $t3, $t4,7212
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,7216
sw $t5, 0($t3)
addi $t3, $t4,7220
sw $t5, 0($t3)
addi $t3, $t4,7224
sw $t5, 0($t3)
addi $t3, $t4,7228
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,7460
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,7464
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,7468
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,7472
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,7476
sw $t5, 0($t3)
addi $t3, $t4,7480
sw $t5, 0($t3)
addi $t3, $t4,7716
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,7720
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,7724
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,7748
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,7752
li $t5,0x92c1d0
sw $t5, 0($t3)
addi $t3, $t4,7756
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,7760
li $t5,0xb8c1d0
sw $t5, 0($t3)
addi $t3, $t4,7764
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,7780
li $t5,0x3f7fb9
sw $t5, 0($t3)
addi $t3, $t4,7784
li $t5,0xb8c1e7
sw $t5, 0($t3)
addi $t3, $t4,7788
li $t5,0xdce1d0
sw $t5, 0($t3)
addi $t3, $t4,7792
li $t5,0xb8a19f
sw $t5, 0($t3)
addi $t3, $t4,7796
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,7804
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,7808
li $t5,0x92c1d0
sw $t5, 0($t3)
addi $t3, $t4,7812
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,7816
li $t5,0xb8c1b9
sw $t5, 0($t3)
addi $t3, $t4,7820
li $t5,0x6b5b6b
sw $t5, 0($t3)
addi $t3, $t4,7832
li $t5,0x3f5b9f
sw $t5, 0($t3)
addi $t3, $t4,7836
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,7840
li $t5,0x6ba1d0
sw $t5, 0($t3)
addi $t3, $t4,7844
li $t5,0xdce1d0
sw $t5, 0($t3)
addi $t3, $t4,7848
li $t5,0xb8a186
sw $t5, 0($t3)
addi $t3, $t4,7868
li $t5,0x3f7fb9
sw $t5, 0($t3)
addi $t3, $t4,7872
li $t5,0xb8c1d0
sw $t5, 0($t3)
addi $t3, $t4,7876
sw $t5, 0($t3)
addi $t3, $t4,7880
li $t5,0x927f86
sw $t5, 0($t3)
addi $t3, $t4,7972
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,7976
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,7980
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,7984
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,7988
sw $t5, 0($t3)
addi $t3, $t4,7992
sw $t5, 0($t3)
addi $t3, $t4,8000
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,8004
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,8008
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,8016
li $t5,0x0d5b86
sw $t5, 0($t3)
addi $t3, $t4,8020
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,8032
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,8036
li $t5,0xffe1d0
sw $t5, 0($t3)
addi $t3, $t4,8040
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,8044
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,8048
li $t5,0x3f7f9f
sw $t5, 0($t3)
addi $t3, $t4,8052
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,8060
li $t5,0x3f7f9f
sw $t5, 0($t3)
addi $t3, $t4,8064
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,8072
li $t5,0x3f7fb9
sw $t5, 0($t3)
addi $t3, $t4,8076
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,8080
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,8088
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,8092
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,8096
li $t5,0xb87f86
sw $t5, 0($t3)
addi $t3, $t4,8104
li $t5,0x3f7fb9
sw $t5, 0($t3)
addi $t3, $t4,8108
li $t5,0xb8a186
sw $t5, 0($t3)
addi $t3, $t4,8120
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,8124
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,8136
li $t5,0x3fa1e7
sw $t5, 0($t3)
addi $t3, $t4,8140
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,8228
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,8232
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,8236
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,8240
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,8244
sw $t5, 0($t3)
addi $t3, $t4,8248
li $t5,0xdce1d0
sw $t5, 0($t3)
addi $t3, $t4,8252
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,8256
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,8260
li $t5,0xb8ffd0
sw $t5, 0($t3)
addi $t3, $t4,8264
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,8284
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,8288
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,8292
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,8324
li $t5,0x0d5b86
sw $t5, 0($t3)
addi $t3, $t4,8328
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,8332
li $t5,0x92c1ff
sw $t5, 0($t3)
addi $t3, $t4,8336
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,8344
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,8348
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,8352
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,8364
li $t5,0x6bc1d0
sw $t5, 0($t3)
addi $t3, $t4,8368
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,8372
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,8376
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,8380
li $t5,0xb8a19f
sw $t5, 0($t3)
addi $t3, $t4,8384
li $t5,0x6b7f9f
sw $t5, 0($t3)
addi $t3, $t4,8388
sw $t5, 0($t3)
addi $t3, $t4,8392
li $t5,0x6b7fd0
sw $t5, 0($t3)
addi $t3, $t4,8396
li $t5,0xdce1b9
sw $t5, 0($t3)
addi $t3, $t4,8400
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,8484
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,8488
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,8492
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,8516
li $t5,0x3f7fd0
sw $t5, 0($t3)
addi $t3, $t4,8520
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,8524
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,8528
li $t5,0xb8a19f
sw $t5, 0($t3)
addi $t3, $t4,8532
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,8540
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,8544
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,8548
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,8572
li $t5,0x3fa1d0
sw $t5, 0($t3)
addi $t3, $t4,8576
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,8580
li $t5,0xb8c1d0
sw $t5, 0($t3)
addi $t3, $t4,8584
li $t5,0xb8e1e7
sw $t5, 0($t3)
addi $t3, $t4,8588
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,8592
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,8600
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,8604
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,8620
li $t5,0x6bc1e7
sw $t5, 0($t3)
addi $t3, $t4,8624
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,8628
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,8632
li $t5,0xdcffe7
sw $t5, 0($t3)
addi $t3, $t4,8636
li $t5,0x927f9f
sw $t5, 0($t3)
addi $t3, $t4,8640
li $t5,0x6b7f9f
sw $t5, 0($t3)
addi $t3, $t4,8644
sw $t5, 0($t3)
addi $t3, $t4,8648
sw $t5, 0($t3)
addi $t3, $t4,8652
li $t5,0x6b7f86
sw $t5, 0($t3)
addi $t3, $t4,8740
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,8744
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,8748
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,8780
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,8784
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,8788
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,8792
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,8796
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,8800
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,8804
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,8824
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,8828
li $t5,0xb8e1b9
sw $t5, 0($t3)
addi $t3, $t4,8832
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,8840
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,8844
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,8848
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,8856
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,8860
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,8864
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,8876
li $t5,0x6bc1d0
sw $t5, 0($t3)
addi $t3, $t4,8880
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,8884
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,8888
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,8892
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,8996
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,9000
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,9004
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,9008
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,9012
sw $t5, 0($t3)
addi $t3, $t4,9016
sw $t5, 0($t3)
addi $t3, $t4,9020
li $t5,0xb8a186
sw $t5, 0($t3)
addi $t3, $t4,9024
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,9028
li $t5,0xb8c1b9
sw $t5, 0($t3)
addi $t3, $t4,9032
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,9036
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,9040
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,9044
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,9048
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,9052
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,9056
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,9060
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,9064
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,9068
li $t5,0xb8c1d0
sw $t5, 0($t3)
addi $t3, $t4,9072
li $t5,0xdce1d0
sw $t5, 0($t3)
addi $t3, $t4,9076
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,9080
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,9084
li $t5,0xdcffe7
sw $t5, 0($t3)
addi $t3, $t4,9088
li $t5,0xb8a1b9
sw $t5, 0($t3)
addi $t3, $t4,9092
li $t5,0x6b7fb9
sw $t5, 0($t3)
addi $t3, $t4,9096
li $t5,0xb8e1ff
sw $t5, 0($t3)
addi $t3, $t4,9100
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,9104
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,9112
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,9116
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,9120
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,9124
li $t5,0xb8c1d0
sw $t5, 0($t3)
addi $t3, $t4,9128
li $t5,0xb8e1e7
sw $t5, 0($t3)
addi $t3, $t4,9132
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,9136
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,9144
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,9148
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,9152
li $t5,0xb8a1b9
sw $t5, 0($t3)
addi $t3, $t4,9156
li $t5,0x6b7f9f
sw $t5, 0($t3)
addi $t3, $t4,9160
li $t5,0x6b7fb9
sw $t5, 0($t3)
addi $t3, $t4,9164
li $t5,0xb8a19f
sw $t5, 0($t3)
addi $t3, $t4,9252
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,9256
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,9260
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,9264
sw $t5, 0($t3)
addi $t3, $t4,9268
sw $t5, 0($t3)
addi $t3, $t4,9272
sw $t5, 0($t3)
addi $t3, $t4,9276
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,9280
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,9284
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,9288
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,9292
sw $t5, 0($t3)
addi $t3, $t4,9296
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,9300
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,9312
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,9316
li $t5,0xb8e1ff
sw $t5, 0($t3)
addi $t3, $t4,9320
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,9324
sw $t5, 0($t3)
addi $t3, $t4,9328
li $t5,0xffffd0
sw $t5, 0($t3)
addi $t3, $t4,9332
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,9340
li $t5,0x6bc1e7
sw $t5, 0($t3)
addi $t3, $t4,9344
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,9348
sw $t5, 0($t3)
addi $t3, $t4,9352
li $t5,0xffe1d0
sw $t5, 0($t3)
addi $t3, $t4,9356
li $t5,0xb8c1ff
sw $t5, 0($t3)
addi $t3, $t4,9360
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,9368
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,9372
li $t5,0xb8c1d0
sw $t5, 0($t3)
addi $t3, $t4,9376
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,9380
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,9384
li $t5,0xffe1d0
sw $t5, 0($t3)
addi $t3, $t4,9388
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,9400
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,9404
li $t5,0x92c1e7
sw $t5, 0($t3)
addi $t3, $t4,9408
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,9412
sw $t5, 0($t3)
addi $t3, $t4,9416
sw $t5, 0($t3)
addi $t3, $t4,9420
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,9544
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,9548
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,9576
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,9580
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,9600
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,9604
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,9620
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,9624
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,9628
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,9636
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,9668
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,9876
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,9880
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,9884
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,11888
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4,11892
li $t5,0x3a0b11
sw $t5, 0($t3)
addi $t3, $t4,11896
li $t5,0x5c0919
sw $t5, 0($t3)
addi $t3, $t4,11900
li $t5,0x650813
sw $t5, 0($t3)
addi $t3, $t4,11904
li $t5,0x570615
sw $t5, 0($t3)
addi $t3, $t4,11908
li $t5,0x0c0000
sw $t5, 0($t3)
addi $t3, $t4,11912
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4,11916
li $t5,0x020001
sw $t5, 0($t3)
addi $t3, $t4,12128
li $t5,0x100001
sw $t5, 0($t3)
addi $t3, $t4,12132
li $t5,0x6f0310
sw $t5, 0($t3)
addi $t3, $t4,12136
li $t5,0xf88333
sw $t5, 0($t3)
addi $t3, $t4,12140
li $t5,0xff8031
sw $t5, 0($t3)
addi $t3, $t4,12144
li $t5,0xfc8134
sw $t5, 0($t3)
addi $t3, $t4,12148
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,12152
sw $t5, 0($t3)
addi $t3, $t4,12156
sw $t5, 0($t3)
addi $t3, $t4,12160
sw $t5, 0($t3)
addi $t3, $t4,12164
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,12168
li $t5,0xfdd54f
sw $t5, 0($t3)
addi $t3, $t4,12172
li $t5,0xfed44e
sw $t5, 0($t3)
addi $t3, $t4,12176
li $t5,0x72040f
sw $t5, 0($t3)
addi $t3, $t4,12180
li $t5,0x1f0101
sw $t5, 0($t3)
addi $t3, $t4,12380
li $t5,0x480911
sw $t5, 0($t3)
addi $t3, $t4,12384
li $t5,0xfed150
sw $t5, 0($t3)
addi $t3, $t4,12388
li $t5,0xfd8435
sw $t5, 0($t3)
addi $t3, $t4,12392
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,12396
sw $t5, 0($t3)
addi $t3, $t4,12400
sw $t5, 0($t3)
addi $t3, $t4,12404
sw $t5, 0($t3)
addi $t3, $t4,12408
sw $t5, 0($t3)
addi $t3, $t4,12412
sw $t5, 0($t3)
addi $t3, $t4,12416
sw $t5, 0($t3)
addi $t3, $t4,12420
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,12424
sw $t5, 0($t3)
addi $t3, $t4,12428
sw $t5, 0($t3)
addi $t3, $t4,12432
li $t5,0xfed74c
sw $t5, 0($t3)
addi $t3, $t4,12436
li $t5,0xfdd64d
sw $t5, 0($t3)
addi $t3, $t4,12440
li $t5,0x580b15
sw $t5, 0($t3)
addi $t3, $t4,12628
li $t5,0x680a18
sw $t5, 0($t3)
addi $t3, $t4,12632
li $t5,0xfcd14f
sw $t5, 0($t3)
addi $t3, $t4,12636
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,12640
sw $t5, 0($t3)
addi $t3, $t4,12644
li $t5,0xfdb346
sw $t5, 0($t3)
addi $t3, $t4,12648
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,12652
sw $t5, 0($t3)
addi $t3, $t4,12656
sw $t5, 0($t3)
addi $t3, $t4,12660
sw $t5, 0($t3)
addi $t3, $t4,12664
sw $t5, 0($t3)
addi $t3, $t4,12668
sw $t5, 0($t3)
addi $t3, $t4,12672
sw $t5, 0($t3)
addi $t3, $t4,12676
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,12680
sw $t5, 0($t3)
addi $t3, $t4,12684
sw $t5, 0($t3)
addi $t3, $t4,12688
sw $t5, 0($t3)
addi $t3, $t4,12692
sw $t5, 0($t3)
addi $t3, $t4,12696
sw $t5, 0($t3)
addi $t3, $t4,12700
li $t5,0xfdd752
sw $t5, 0($t3)
addi $t3, $t4,12704
li $t5,0x710213
sw $t5, 0($t3)
addi $t3, $t4,12876
li $t5,0x010302
sw $t5, 0($t3)
addi $t3, $t4,12880
li $t5,0x6f0312
sw $t5, 0($t3)
addi $t3, $t4,12884
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,12888
sw $t5, 0($t3)
addi $t3, $t4,12892
sw $t5, 0($t3)
addi $t3, $t4,12896
sw $t5, 0($t3)
addi $t3, $t4,12900
li $t5,0xffd54e
sw $t5, 0($t3)
addi $t3, $t4,12904
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,12908
sw $t5, 0($t3)
addi $t3, $t4,12912
sw $t5, 0($t3)
addi $t3, $t4,12916
sw $t5, 0($t3)
addi $t3, $t4,12920
sw $t5, 0($t3)
addi $t3, $t4,12924
sw $t5, 0($t3)
addi $t3, $t4,12928
sw $t5, 0($t3)
addi $t3, $t4,12932
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,12936
sw $t5, 0($t3)
addi $t3, $t4,12940
sw $t5, 0($t3)
addi $t3, $t4,12944
sw $t5, 0($t3)
addi $t3, $t4,12948
sw $t5, 0($t3)
addi $t3, $t4,12952
sw $t5, 0($t3)
addi $t3, $t4,12956
sw $t5, 0($t3)
addi $t3, $t4,12960
li $t5,0xffd54d
sw $t5, 0($t3)
addi $t3, $t4,12964
li $t5,0x6e040e
sw $t5, 0($t3)
addi $t3, $t4,12968
li $t5,0x000302
sw $t5, 0($t3)
addi $t3, $t4,13132
li $t5,0xf4c45e
sw $t5, 0($t3)
addi $t3, $t4,13136
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,13140
sw $t5, 0($t3)
addi $t3, $t4,13144
sw $t5, 0($t3)
addi $t3, $t4,13148
sw $t5, 0($t3)
addi $t3, $t4,13152
sw $t5, 0($t3)
addi $t3, $t4,13156
sw $t5, 0($t3)
addi $t3, $t4,13160
li $t5,0xfd8336
sw $t5, 0($t3)
addi $t3, $t4,13164
li $t5,0xff8135
sw $t5, 0($t3)
addi $t3, $t4,13168
li $t5,0xfc8334
sw $t5, 0($t3)
addi $t3, $t4,13172
li $t5,0x230006
sw $t5, 0($t3)
addi $t3, $t4,13176
li $t5,0x240105
sw $t5, 0($t3)
addi $t3, $t4,13180
li $t5,0x2a0105
sw $t5, 0($t3)
addi $t3, $t4,13184
li $t5,0x250208
sw $t5, 0($t3)
addi $t3, $t4,13188
li $t5,0x431e0b
sw $t5, 0($t3)
addi $t3, $t4,13192
li $t5,0xfdd64b
sw $t5, 0($t3)
addi $t3, $t4,13196
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,13200
sw $t5, 0($t3)
addi $t3, $t4,13204
sw $t5, 0($t3)
addi $t3, $t4,13208
sw $t5, 0($t3)
addi $t3, $t4,13212
sw $t5, 0($t3)
addi $t3, $t4,13216
li $t5,0xfd8330
sw $t5, 0($t3)
addi $t3, $t4,13220
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,13224
li $t5,0xfb8136
sw $t5, 0($t3)
addi $t3, $t4,13228
li $t5,0x000304
sw $t5, 0($t3)
addi $t3, $t4,13384
li $t5,0x520610
sw $t5, 0($t3)
addi $t3, $t4,13388
li $t5,0xfed74e
sw $t5, 0($t3)
addi $t3, $t4,13392
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,13396
sw $t5, 0($t3)
addi $t3, $t4,13400
sw $t5, 0($t3)
addi $t3, $t4,13404
sw $t5, 0($t3)
addi $t3, $t4,13408
sw $t5, 0($t3)
addi $t3, $t4,13412
sw $t5, 0($t3)
addi $t3, $t4,13416
li $t5,0xfb8134
sw $t5, 0($t3)
addi $t3, $t4,13420
li $t5,0x330004
sw $t5, 0($t3)
addi $t3, $t4,13424
li $t5,0x3d0100
sw $t5, 0($t3)
addi $t3, $t4,13428
li $t5,0xc90101
sw $t5, 0($t3)
addi $t3, $t4,13432
li $t5,0xc70102
sw $t5, 0($t3)
addi $t3, $t4,13436
li $t5,0xc40001
sw $t5, 0($t3)
addi $t3, $t4,13440
li $t5,0xc70100
sw $t5, 0($t3)
addi $t3, $t4,13444
li $t5,0xd10002
sw $t5, 0($t3)
addi $t3, $t4,13448
li $t5,0x2d0100
sw $t5, 0($t3)
addi $t3, $t4,13452
li $t5,0xebae5d
sw $t5, 0($t3)
addi $t3, $t4,13456
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,13460
sw $t5, 0($t3)
addi $t3, $t4,13464
sw $t5, 0($t3)
addi $t3, $t4,13468
li $t5,0xfed74e
sw $t5, 0($t3)
addi $t3, $t4,13472
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,13476
sw $t5, 0($t3)
addi $t3, $t4,13480
li $t5,0xfd8232
sw $t5, 0($t3)
addi $t3, $t4,13484
li $t5,0x76020f
sw $t5, 0($t3)
addi $t3, $t4,13636
li $t5,0x5b0512
sw $t5, 0($t3)
addi $t3, $t4,13640
li $t5,0xfd832d
sw $t5, 0($t3)
addi $t3, $t4,13644
li $t5,0xfcd44e
sw $t5, 0($t3)
addi $t3, $t4,13648
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,13652
sw $t5, 0($t3)
addi $t3, $t4,13656
sw $t5, 0($t3)
addi $t3, $t4,13660
sw $t5, 0($t3)
addi $t3, $t4,13664
sw $t5, 0($t3)
addi $t3, $t4,13668
li $t5,0xffd54b
sw $t5, 0($t3)
addi $t3, $t4,13672
li $t5,0x740704
sw $t5, 0($t3)
addi $t3, $t4,13676
li $t5,0xc60001
sw $t5, 0($t3)
addi $t3, $t4,13680
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,13684
sw $t5, 0($t3)
addi $t3, $t4,13688
sw $t5, 0($t3)
addi $t3, $t4,13692
sw $t5, 0($t3)
addi $t3, $t4,13696
sw $t5, 0($t3)
addi $t3, $t4,13700
sw $t5, 0($t3)
addi $t3, $t4,13704
sw $t5, 0($t3)
addi $t3, $t4,13708
li $t5,0xc90302
sw $t5, 0($t3)
addi $t3, $t4,13712
li $t5,0x774d1b
sw $t5, 0($t3)
addi $t3, $t4,13716
li $t5,0xffd54d
sw $t5, 0($t3)
addi $t3, $t4,13720
li $t5,0xf9d950
sw $t5, 0($t3)
addi $t3, $t4,13724
li $t5,0xfe8536
sw $t5, 0($t3)
addi $t3, $t4,13728
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,13732
sw $t5, 0($t3)
addi $t3, $t4,13736
sw $t5, 0($t3)
addi $t3, $t4,13740
sw $t5, 0($t3)
addi $t3, $t4,13744
li $t5,0x6e050a
sw $t5, 0($t3)
addi $t3, $t4,13888
li $t5,0x400410
sw $t5, 0($t3)
addi $t3, $t4,13892
li $t5,0xfd8232
sw $t5, 0($t3)
addi $t3, $t4,13896
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,13900
sw $t5, 0($t3)
addi $t3, $t4,13904
li $t5,0xf8d94d
sw $t5, 0($t3)
addi $t3, $t4,13908
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,13912
sw $t5, 0($t3)
addi $t3, $t4,13916
sw $t5, 0($t3)
addi $t3, $t4,13920
li $t5,0xf7d162
sw $t5, 0($t3)
addi $t3, $t4,13924
li $t5,0x740305
sw $t5, 0($t3)
addi $t3, $t4,13928
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,13932
sw $t5, 0($t3)
addi $t3, $t4,13936
sw $t5, 0($t3)
addi $t3, $t4,13940
sw $t5, 0($t3)
addi $t3, $t4,13944
sw $t5, 0($t3)
addi $t3, $t4,13948
sw $t5, 0($t3)
addi $t3, $t4,13952
sw $t5, 0($t3)
addi $t3, $t4,13956
sw $t5, 0($t3)
addi $t3, $t4,13960
sw $t5, 0($t3)
addi $t3, $t4,13964
sw $t5, 0($t3)
addi $t3, $t4,13968
li $t5,0xc60204
sw $t5, 0($t3)
addi $t3, $t4,13972
li $t5,0x2c080a
sw $t5, 0($t3)
addi $t3, $t4,13976
li $t5,0xfc8334
sw $t5, 0($t3)
addi $t3, $t4,13980
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,13984
sw $t5, 0($t3)
addi $t3, $t4,13988
sw $t5, 0($t3)
addi $t3, $t4,13992
sw $t5, 0($t3)
addi $t3, $t4,13996
sw $t5, 0($t3)
addi $t3, $t4,14000
sw $t5, 0($t3)
addi $t3, $t4,14004
li $t5,0x6f0313
sw $t5, 0($t3)
addi $t3, $t4,14144
li $t5,0xc45027
sw $t5, 0($t3)
addi $t3, $t4,14148
li $t5,0xfd8232
sw $t5, 0($t3)
addi $t3, $t4,14152
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,14156
sw $t5, 0($t3)
addi $t3, $t4,14160
sw $t5, 0($t3)
addi $t3, $t4,14164
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,14168
sw $t5, 0($t3)
addi $t3, $t4,14172
sw $t5, 0($t3)
addi $t3, $t4,14176
li $t5,0x2a0306
sw $t5, 0($t3)
addi $t3, $t4,14180
li $t5,0xc60203
sw $t5, 0($t3)
addi $t3, $t4,14184
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,14188
sw $t5, 0($t3)
addi $t3, $t4,14192
sw $t5, 0($t3)
addi $t3, $t4,14196
sw $t5, 0($t3)
addi $t3, $t4,14200
sw $t5, 0($t3)
addi $t3, $t4,14204
sw $t5, 0($t3)
addi $t3, $t4,14208
sw $t5, 0($t3)
addi $t3, $t4,14212
sw $t5, 0($t3)
addi $t3, $t4,14216
sw $t5, 0($t3)
addi $t3, $t4,14220
sw $t5, 0($t3)
addi $t3, $t4,14224
sw $t5, 0($t3)
addi $t3, $t4,14228
li $t5,0x900b0e
sw $t5, 0($t3)
addi $t3, $t4,14232
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,14236
sw $t5, 0($t3)
addi $t3, $t4,14240
sw $t5, 0($t3)
addi $t3, $t4,14244
sw $t5, 0($t3)
addi $t3, $t4,14248
sw $t5, 0($t3)
addi $t3, $t4,14252
sw $t5, 0($t3)
addi $t3, $t4,14256
sw $t5, 0($t3)
addi $t3, $t4,14260
li $t5,0xfd8336
sw $t5, 0($t3)
addi $t3, $t4,14396
li $t5,0x030301
sw $t5, 0($t3)
addi $t3, $t4,14400
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,14404
sw $t5, 0($t3)
addi $t3, $t4,14408
sw $t5, 0($t3)
addi $t3, $t4,14412
sw $t5, 0($t3)
addi $t3, $t4,14416
sw $t5, 0($t3)
addi $t3, $t4,14420
li $t5,0xf78431
sw $t5, 0($t3)
addi $t3, $t4,14424
li $t5,0xffd74f
sw $t5, 0($t3)
addi $t3, $t4,14428
li $t5,0xa47f38
sw $t5, 0($t3)
addi $t3, $t4,14432
li $t5,0xc50303
sw $t5, 0($t3)
addi $t3, $t4,14436
li $t5,0xc10303
sw $t5, 0($t3)
addi $t3, $t4,14440
li $t5,0x1a1624
sw $t5, 0($t3)
addi $t3, $t4,14444
li $t5,0x131927
sw $t5, 0($t3)
addi $t3, $t4,14448
li $t5,0x0d1c21
sw $t5, 0($t3)
addi $t3, $t4,14452
li $t5,0x081b1f
sw $t5, 0($t3)
addi $t3, $t4,14456
li $t5,0x0e191f
sw $t5, 0($t3)
addi $t3, $t4,14460
li $t5,0x0e191d
sw $t5, 0($t3)
addi $t3, $t4,14464
li $t5,0x0b1a1f
sw $t5, 0($t3)
addi $t3, $t4,14468
li $t5,0x0c1a27
sw $t5, 0($t3)
addi $t3, $t4,14472
li $t5,0x111b27
sw $t5, 0($t3)
addi $t3, $t4,14476
li $t5,0x141821
sw $t5, 0($t3)
addi $t3, $t4,14480
li $t5,0xb60801
sw $t5, 0($t3)
addi $t3, $t4,14484
li $t5,0xc60203
sw $t5, 0($t3)
addi $t3, $t4,14488
li $t5,0x3b0400
sw $t5, 0($t3)
addi $t3, $t4,14492
li $t5,0xfc8235
sw $t5, 0($t3)
addi $t3, $t4,14496
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,14500
sw $t5, 0($t3)
addi $t3, $t4,14504
sw $t5, 0($t3)
addi $t3, $t4,14508
sw $t5, 0($t3)
addi $t3, $t4,14512
sw $t5, 0($t3)
addi $t3, $t4,14516
sw $t5, 0($t3)
addi $t3, $t4,14520
li $t5,0x37020a
sw $t5, 0($t3)
addi $t3, $t4,14652
li $t5,0x7b0d00
sw $t5, 0($t3)
addi $t3, $t4,14656
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,14660
sw $t5, 0($t3)
addi $t3, $t4,14664
sw $t5, 0($t3)
addi $t3, $t4,14668
sw $t5, 0($t3)
addi $t3, $t4,14672
sw $t5, 0($t3)
addi $t3, $t4,14676
li $t5,0xfd8336
sw $t5, 0($t3)
addi $t3, $t4,14680
li $t5,0xfc822f
sw $t5, 0($t3)
addi $t3, $t4,14684
li $t5,0x8c090f
sw $t5, 0($t3)
addi $t3, $t4,14688
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,14692
li $t5,0x051a1f
sw $t5, 0($t3)
addi $t3, $t4,14696
li $t5,0x98c4cf
sw $t5, 0($t3)
addi $t3, $t4,14700
li $t5,0xbbe7f2
sw $t5, 0($t3)
addi $t3, $t4,14704
li $t5,0x8fc3d1
sw $t5, 0($t3)
addi $t3, $t4,14708
li $t5,0xadd9e6
sw $t5, 0($t3)
addi $t3, $t4,14712
li $t5,0x8fc4d2
sw $t5, 0($t3)
addi $t3, $t4,14716
li $t5,0x8fc3d0
sw $t5, 0($t3)
addi $t3, $t4,14720
sw $t5, 0($t3)
addi $t3, $t4,14724
sw $t5, 0($t3)
addi $t3, $t4,14728
li $t5,0x8ac6d0
sw $t5, 0($t3)
addi $t3, $t4,14732
li $t5,0xdffbfe
sw $t5, 0($t3)
addi $t3, $t4,14736
li $t5,0x739ba7
sw $t5, 0($t3)
addi $t3, $t4,14740
li $t5,0xc10400
sw $t5, 0($t3)
addi $t3, $t4,14744
li $t5,0xb90409
sw $t5, 0($t3)
addi $t3, $t4,14748
li $t5,0xf87f3a
sw $t5, 0($t3)
addi $t3, $t4,14752
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,14756
sw $t5, 0($t3)
addi $t3, $t4,14760
sw $t5, 0($t3)
addi $t3, $t4,14764
sw $t5, 0($t3)
addi $t3, $t4,14768
sw $t5, 0($t3)
addi $t3, $t4,14772
sw $t5, 0($t3)
addi $t3, $t4,14776
li $t5,0xfa7f3c
sw $t5, 0($t3)
addi $t3, $t4,14904
li $t5,0x200001
sw $t5, 0($t3)
addi $t3, $t4,14908
li $t5,0xfb8233
sw $t5, 0($t3)
addi $t3, $t4,14912
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,14916
sw $t5, 0($t3)
addi $t3, $t4,14920
sw $t5, 0($t3)
addi $t3, $t4,14924
sw $t5, 0($t3)
addi $t3, $t4,14928
sw $t5, 0($t3)
addi $t3, $t4,14932
sw $t5, 0($t3)
addi $t3, $t4,14936
li $t5,0x220404
sw $t5, 0($t3)
addi $t3, $t4,14940
li $t5,0xc70102
sw $t5, 0($t3)
addi $t3, $t4,14944
li $t5,0x0c1b22
sw $t5, 0($t3)
addi $t3, $t4,14948
li $t5,0x6b9aaa
sw $t5, 0($t3)
addi $t3, $t4,14952
li $t5,0x8ec2d0
sw $t5, 0($t3)
addi $t3, $t4,14956
li $t5,0x5f889a
sw $t5, 0($t3)
addi $t3, $t4,14960
li $t5,0x62889d
sw $t5, 0($t3)
addi $t3, $t4,14964
li $t5,0x5d8b9b
sw $t5, 0($t3)
addi $t3, $t4,14968
li $t5,0x5e8b9e
sw $t5, 0($t3)
addi $t3, $t4,14972
sw $t5, 0($t3)
addi $t3, $t4,14976
li $t5,0x5f8c9f
sw $t5, 0($t3)
addi $t3, $t4,14980
li $t5,0x5f8a9b
sw $t5, 0($t3)
addi $t3, $t4,14984
li $t5,0x60899b
sw $t5, 0($t3)
addi $t3, $t4,14988
li $t5,0x8fc3d1
sw $t5, 0($t3)
addi $t3, $t4,14992
li $t5,0x87b8c6
sw $t5, 0($t3)
addi $t3, $t4,14996
li $t5,0x061826
sw $t5, 0($t3)
addi $t3, $t4,15000
li $t5,0xc70102
sw $t5, 0($t3)
addi $t3, $t4,15004
li $t5,0x290205
sw $t5, 0($t3)
addi $t3, $t4,15008
li $t5,0xfc8134
sw $t5, 0($t3)
addi $t3, $t4,15012
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,15016
sw $t5, 0($t3)
addi $t3, $t4,15020
sw $t5, 0($t3)
addi $t3, $t4,15024
sw $t5, 0($t3)
addi $t3, $t4,15028
sw $t5, 0($t3)
addi $t3, $t4,15032
li $t5,0xfd8232
sw $t5, 0($t3)
addi $t3, $t4,15036
li $t5,0x5c0d12
sw $t5, 0($t3)
addi $t3, $t4,15160
li $t5,0x730214
sw $t5, 0($t3)
addi $t3, $t4,15164
li $t5,0xff8135
sw $t5, 0($t3)
addi $t3, $t4,15168
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,15172
sw $t5, 0($t3)
addi $t3, $t4,15176
sw $t5, 0($t3)
addi $t3, $t4,15180
sw $t5, 0($t3)
addi $t3, $t4,15184
sw $t5, 0($t3)
addi $t3, $t4,15188
li $t5,0xfc8235
sw $t5, 0($t3)
addi $t3, $t4,15192
li $t5,0xc80607
sw $t5, 0($t3)
addi $t3, $t4,15196
li $t5,0xc50303
sw $t5, 0($t3)
addi $t3, $t4,15200
li $t5,0x577e8d
sw $t5, 0($t3)
addi $t3, $t4,15204
li $t5,0x567a90
sw $t5, 0($t3)
addi $t3, $t4,15208
li $t5,0x557b90
sw $t5, 0($t3)
addi $t3, $t4,15212
li $t5,0x567c91
sw $t5, 0($t3)
addi $t3, $t4,15216
sw $t5, 0($t3)
addi $t3, $t4,15220
sw $t5, 0($t3)
addi $t3, $t4,15224
sw $t5, 0($t3)
addi $t3, $t4,15228
sw $t5, 0($t3)
addi $t3, $t4,15232
sw $t5, 0($t3)
addi $t3, $t4,15236
sw $t5, 0($t3)
addi $t3, $t4,15240
sw $t5, 0($t3)
addi $t3, $t4,15244
li $t5,0x547d91
sw $t5, 0($t3)
addi $t3, $t4,15248
li $t5,0x578092
sw $t5, 0($t3)
addi $t3, $t4,15252
li $t5,0x567c8f
sw $t5, 0($t3)
addi $t3, $t4,15256
li $t5,0xc50304
sw $t5, 0($t3)
addi $t3, $t4,15260
li $t5,0xad0908
sw $t5, 0($t3)
addi $t3, $t4,15264
li $t5,0xfc8438
sw $t5, 0($t3)
addi $t3, $t4,15268
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,15272
sw $t5, 0($t3)
addi $t3, $t4,15276
sw $t5, 0($t3)
addi $t3, $t4,15280
sw $t5, 0($t3)
addi $t3, $t4,15284
sw $t5, 0($t3)
addi $t3, $t4,15288
li $t5,0xfc8332
sw $t5, 0($t3)
addi $t3, $t4,15292
li $t5,0x690c07
sw $t5, 0($t3)
addi $t3, $t4,15416
li $t5,0xf88044
sw $t5, 0($t3)
addi $t3, $t4,15420
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,15424
sw $t5, 0($t3)
addi $t3, $t4,15428
sw $t5, 0($t3)
addi $t3, $t4,15432
sw $t5, 0($t3)
addi $t3, $t4,15436
sw $t5, 0($t3)
addi $t3, $t4,15440
sw $t5, 0($t3)
addi $t3, $t4,15444
li $t5,0x270307
sw $t5, 0($t3)
addi $t3, $t4,15448
li $t5,0xc60203
sw $t5, 0($t3)
addi $t3, $t4,15452
li $t5,0x630716
sw $t5, 0($t3)
addi $t3, $t4,15456
li $t5,0x456780
sw $t5, 0($t3)
addi $t3, $t4,15460
li $t5,0x44667f
sw $t5, 0($t3)
addi $t3, $t4,15464
li $t5,0x4b5366
sw $t5, 0($t3)
addi $t3, $t4,15468
li $t5,0x456981
sw $t5, 0($t3)
addi $t3, $t4,15472
li $t5,0x46667f
sw $t5, 0($t3)
addi $t3, $t4,15476
sw $t5, 0($t3)
addi $t3, $t4,15480
li $t5,0x456780
sw $t5, 0($t3)
addi $t3, $t4,15484
li $t5,0x44667f
sw $t5, 0($t3)
addi $t3, $t4,15488
sw $t5, 0($t3)
addi $t3, $t4,15492
sw $t5, 0($t3)
addi $t3, $t4,15496
sw $t5, 0($t3)
addi $t3, $t4,15500
sw $t5, 0($t3)
addi $t3, $t4,15504
sw $t5, 0($t3)
addi $t3, $t4,15508
sw $t5, 0($t3)
addi $t3, $t4,15512
li $t5,0x1d161e
sw $t5, 0($t3)
addi $t3, $t4,15516
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,15520
li $t5,0x280408
sw $t5, 0($t3)
addi $t3, $t4,15524
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,15528
sw $t5, 0($t3)
addi $t3, $t4,15532
li $t5,0xfd8336
sw $t5, 0($t3)
addi $t3, $t4,15536
li $t5,0xf38a2e
sw $t5, 0($t3)
addi $t3, $t4,15540
li $t5,0xfdd64b
sw $t5, 0($t3)
addi $t3, $t4,15544
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,15548
li $t5,0xfdd448
sw $t5, 0($t3)
addi $t3, $t4,15672
li $t5,0xfdaa40
sw $t5, 0($t3)
addi $t3, $t4,15676
li $t5,0xfd8336
sw $t5, 0($t3)
addi $t3, $t4,15680
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,15684
sw $t5, 0($t3)
addi $t3, $t4,15688
sw $t5, 0($t3)
addi $t3, $t4,15692
sw $t5, 0($t3)
addi $t3, $t4,15696
sw $t5, 0($t3)
addi $t3, $t4,15700
li $t5,0xc10207
sw $t5, 0($t3)
addi $t3, $t4,15704
li $t5,0xbd0402
sw $t5, 0($t3)
addi $t3, $t4,15708
li $t5,0x0b1c24
sw $t5, 0($t3)
addi $t3, $t4,15712
li $t5,0x8cc5d0
sw $t5, 0($t3)
addi $t3, $t4,15716
li $t5,0x44667f
sw $t5, 0($t3)
addi $t3, $t4,15720
li $t5,0x2a0203
sw $t5, 0($t3)
addi $t3, $t4,15724
sw $t5, 0($t3)
addi $t3, $t4,15728
li $t5,0x4b637d
sw $t5, 0($t3)
addi $t3, $t4,15732
li $t5,0x46667f
sw $t5, 0($t3)
addi $t3, $t4,15736
sw $t5, 0($t3)
addi $t3, $t4,15740
sw $t5, 0($t3)
addi $t3, $t4,15744
sw $t5, 0($t3)
addi $t3, $t4,15748
sw $t5, 0($t3)
addi $t3, $t4,15752
sw $t5, 0($t3)
addi $t3, $t4,15756
li $t5,0x486680
sw $t5, 0($t3)
addi $t3, $t4,15760
li $t5,0x46667f
sw $t5, 0($t3)
addi $t3, $t4,15764
li $t5,0x8ec2cf
sw $t5, 0($t3)
addi $t3, $t4,15768
li $t5,0x293c4b
sw $t5, 0($t3)
addi $t3, $t4,15772
li $t5,0x9b000c
sw $t5, 0($t3)
addi $t3, $t4,15776
li $t5,0xac090a
sw $t5, 0($t3)
addi $t3, $t4,15780
li $t5,0xfc8036
sw $t5, 0($t3)
addi $t3, $t4,15784
li $t5,0xffc44c
sw $t5, 0($t3)
addi $t3, $t4,15788
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,15792
sw $t5, 0($t3)
addi $t3, $t4,15796
sw $t5, 0($t3)
addi $t3, $t4,15800
sw $t5, 0($t3)
addi $t3, $t4,15804
sw $t5, 0($t3)
addi $t3, $t4,15928
li $t5,0xfed74e
sw $t5, 0($t3)
addi $t3, $t4,15932
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,15936
sw $t5, 0($t3)
addi $t3, $t4,15940
li $t5,0xfdd14e
sw $t5, 0($t3)
addi $t3, $t4,15944
li $t5,0xfb832d
sw $t5, 0($t3)
addi $t3, $t4,15948
li $t5,0xfc8235
sw $t5, 0($t3)
addi $t3, $t4,15952
li $t5,0xf78434
sw $t5, 0($t3)
addi $t3, $t4,15956
li $t5,0xc80002
sw $t5, 0($t3)
addi $t3, $t4,15960
li $t5,0x77030e
sw $t5, 0($t3)
addi $t3, $t4,15964
li $t5,0x435a6c
sw $t5, 0($t3)
addi $t3, $t4,15968
li $t5,0xdaf9fb
sw $t5, 0($t3)
addi $t3, $t4,15972
li $t5,0x8bc5d1
sw $t5, 0($t3)
addi $t3, $t4,15976
li $t5,0x2a0203
sw $t5, 0($t3)
addi $t3, $t4,15980
li $t5,0xc70304
sw $t5, 0($t3)
addi $t3, $t4,15984
li $t5,0x2a0107
sw $t5, 0($t3)
addi $t3, $t4,15988
li $t5,0x8fc5d1
sw $t5, 0($t3)
addi $t3, $t4,15992
sw $t5, 0($t3)
addi $t3, $t4,15996
sw $t5, 0($t3)
addi $t3, $t4,16000
sw $t5, 0($t3)
addi $t3, $t4,16004
li $t5,0x8dc6d1
sw $t5, 0($t3)
addi $t3, $t4,16008
sw $t5, 0($t3)
addi $t3, $t4,16012
sw $t5, 0($t3)
addi $t3, $t4,16016
li $t5,0x90c4d1
sw $t5, 0($t3)
addi $t3, $t4,16020
li $t5,0xa3c3d0
sw $t5, 0($t3)
addi $t3, $t4,16024
li $t5,0xc0e3f9
sw $t5, 0($t3)
addi $t3, $t4,16028
li $t5,0x580a17
sw $t5, 0($t3)
addi $t3, $t4,16032
li $t5,0xc40401
sw $t5, 0($t3)
addi $t3, $t4,16036
li $t5,0xfbd448
sw $t5, 0($t3)
addi $t3, $t4,16040
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,16044
sw $t5, 0($t3)
addi $t3, $t4,16048
sw $t5, 0($t3)
addi $t3, $t4,16052
sw $t5, 0($t3)
addi $t3, $t4,16056
sw $t5, 0($t3)
addi $t3, $t4,16060
li $t5,0xfed652
sw $t5, 0($t3)
addi $t3, $t4,16064
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4,16180
li $t5,0x040001
sw $t5, 0($t3)
addi $t3, $t4,16184
li $t5,0xffd749
sw $t5, 0($t3)
addi $t3, $t4,16188
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,16192
sw $t5, 0($t3)
addi $t3, $t4,16196
sw $t5, 0($t3)
addi $t3, $t4,16200
li $t5,0xfed74e
sw $t5, 0($t3)
addi $t3, $t4,16204
li $t5,0xffce4d
sw $t5, 0($t3)
addi $t3, $t4,16208
li $t5,0x9f4f34
sw $t5, 0($t3)
addi $t3, $t4,16212
li $t5,0xc10303
sw $t5, 0($t3)
addi $t3, $t4,16216
li $t5,0x6e0410
sw $t5, 0($t3)
addi $t3, $t4,16220
li $t5,0x0f1925
sw $t5, 0($t3)
addi $t3, $t4,16224
li $t5,0x47677c
sw $t5, 0($t3)
addi $t3, $t4,16228
li $t5,0x8fc0ce
sw $t5, 0($t3)
addi $t3, $t4,16232
li $t5,0x2a0203
sw $t5, 0($t3)
addi $t3, $t4,16236
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,16240
li $t5,0x2a000a
sw $t5, 0($t3)
addi $t3, $t4,16244
li $t5,0x8cc4d1
sw $t5, 0($t3)
addi $t3, $t4,16248
li $t5,0x90c6d2
sw $t5, 0($t3)
addi $t3, $t4,16252
li $t5,0x8fc5d1
sw $t5, 0($t3)
addi $t3, $t4,16256
sw $t5, 0($t3)
addi $t3, $t4,16260
sw $t5, 0($t3)
addi $t3, $t4,16264
sw $t5, 0($t3)
addi $t3, $t4,16268
sw $t5, 0($t3)
addi $t3, $t4,16272
li $t5,0x8fc3d0
sw $t5, 0($t3)
addi $t3, $t4,16276
li $t5,0x426b7f
sw $t5, 0($t3)
addi $t3, $t4,16280
li $t5,0x0d1b26
sw $t5, 0($t3)
addi $t3, $t4,16284
li $t5,0x740015
sw $t5, 0($t3)
addi $t3, $t4,16288
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,16292
li $t5,0xd2aa64
sw $t5, 0($t3)
addi $t3, $t4,16296
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,16300
sw $t5, 0($t3)
addi $t3, $t4,16304
sw $t5, 0($t3)
addi $t3, $t4,16308
sw $t5, 0($t3)
addi $t3, $t4,16312
sw $t5, 0($t3)
addi $t3, $t4,16316
li $t5,0xffd84d
sw $t5, 0($t3)
addi $t3, $t4,16320
li $t5,0x070302
sw $t5, 0($t3)
addi $t3, $t4,16440
li $t5,0xfed84f
sw $t5, 0($t3)
addi $t3, $t4,16444
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,16448
sw $t5, 0($t3)
addi $t3, $t4,16452
sw $t5, 0($t3)
addi $t3, $t4,16456
sw $t5, 0($t3)
addi $t3, $t4,16460
sw $t5, 0($t3)
addi $t3, $t4,16464
li $t5,0x230402
sw $t5, 0($t3)
addi $t3, $t4,16468
li $t5,0xc80002
sw $t5, 0($t3)
addi $t3, $t4,16472
li $t5,0xc90103
sw $t5, 0($t3)
addi $t3, $t4,16476
li $t5,0x6f0313
sw $t5, 0($t3)
addi $t3, $t4,16480
li $t5,0x740110
sw $t5, 0($t3)
addi $t3, $t4,16484
li $t5,0x4c0d16
sw $t5, 0($t3)
addi $t3, $t4,16488
li $t5,0x2a0203
sw $t5, 0($t3)
addi $t3, $t4,16492
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,16496
li $t5,0x290205
sw $t5, 0($t3)
addi $t3, $t4,16500
li $t5,0x1b3041
sw $t5, 0($t3)
addi $t3, $t4,16504
li $t5,0x293c4b
sw $t5, 0($t3)
addi $t3, $t4,16508
li $t5,0x273d4b
sw $t5, 0($t3)
addi $t3, $t4,16512
li $t5,0x173540
sw $t5, 0($t3)
addi $t3, $t4,16516
li $t5,0x0a1a29
sw $t5, 0($t3)
addi $t3, $t4,16520
li $t5,0x0b1926
sw $t5, 0($t3)
addi $t3, $t4,16524
li $t5,0x0d1a22
sw $t5, 0($t3)
addi $t3, $t4,16528
li $t5,0x1c141f
sw $t5, 0($t3)
addi $t3, $t4,16532
li $t5,0x700316
sw $t5, 0($t3)
addi $t3, $t4,16536
li $t5,0x740112
sw $t5, 0($t3)
addi $t3, $t4,16540
li $t5,0xb50603
sw $t5, 0($t3)
addi $t3, $t4,16544
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,16548
li $t5,0x270307
sw $t5, 0($t3)
addi $t3, $t4,16552
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,16556
sw $t5, 0($t3)
addi $t3, $t4,16560
sw $t5, 0($t3)
addi $t3, $t4,16564
sw $t5, 0($t3)
addi $t3, $t4,16568
sw $t5, 0($t3)
addi $t3, $t4,16572
sw $t5, 0($t3)
addi $t3, $t4,16576
li $t5,0x120300
sw $t5, 0($t3)
addi $t3, $t4,16696
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,16700
sw $t5, 0($t3)
addi $t3, $t4,16704
sw $t5, 0($t3)
addi $t3, $t4,16708
sw $t5, 0($t3)
addi $t3, $t4,16712
sw $t5, 0($t3)
addi $t3, $t4,16716
li $t5,0xfed74e
sw $t5, 0($t3)
addi $t3, $t4,16720
li $t5,0x53030c
sw $t5, 0($t3)
addi $t3, $t4,16724
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,16728
sw $t5, 0($t3)
addi $t3, $t4,16732
li $t5,0xc40001
sw $t5, 0($t3)
addi $t3, $t4,16736
li $t5,0xcb0003
sw $t5, 0($t3)
addi $t3, $t4,16740
li $t5,0xc30300
sw $t5, 0($t3)
addi $t3, $t4,16744
li $t5,0x340400
sw $t5, 0($t3)
addi $t3, $t4,16748
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,16752
li $t5,0x650302
sw $t5, 0($t3)
addi $t3, $t4,16756
li $t5,0x720113
sw $t5, 0($t3)
addi $t3, $t4,16760
li $t5,0x710213
sw $t5, 0($t3)
addi $t3, $t4,16764
sw $t5, 0($t3)
addi $t3, $t4,16768
sw $t5, 0($t3)
addi $t3, $t4,16772
sw $t5, 0($t3)
addi $t3, $t4,16776
sw $t5, 0($t3)
addi $t3, $t4,16780
sw $t5, 0($t3)
addi $t3, $t4,16784
li $t5,0x7b0215
sw $t5, 0($t3)
addi $t3, $t4,16788
li $t5,0xb8030a
sw $t5, 0($t3)
addi $t3, $t4,16792
li $t5,0xc70304
sw $t5, 0($t3)
addi $t3, $t4,16796
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,16800
sw $t5, 0($t3)
addi $t3, $t4,16804
li $t5,0x900808
sw $t5, 0($t3)
addi $t3, $t4,16808
li $t5,0xfed652
sw $t5, 0($t3)
addi $t3, $t4,16812
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,16816
sw $t5, 0($t3)
addi $t3, $t4,16820
sw $t5, 0($t3)
addi $t3, $t4,16824
sw $t5, 0($t3)
addi $t3, $t4,16828
sw $t5, 0($t3)
addi $t3, $t4,16832
li $t5,0x200001
sw $t5, 0($t3)
addi $t3, $t4,16948
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4,16952
li $t5,0xfed84f
sw $t5, 0($t3)
addi $t3, $t4,16956
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,16960
sw $t5, 0($t3)
addi $t3, $t4,16964
sw $t5, 0($t3)
addi $t3, $t4,16968
sw $t5, 0($t3)
addi $t3, $t4,16972
li $t5,0xf9d269
sw $t5, 0($t3)
addi $t3, $t4,16976
li $t5,0x720313
sw $t5, 0($t3)
addi $t3, $t4,16980
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,16984
sw $t5, 0($t3)
addi $t3, $t4,16988
sw $t5, 0($t3)
addi $t3, $t4,16992
sw $t5, 0($t3)
addi $t3, $t4,16996
sw $t5, 0($t3)
addi $t3, $t4,17000
li $t5,0x290102
sw $t5, 0($t3)
addi $t3, $t4,17004
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,17008
li $t5,0xae080c
sw $t5, 0($t3)
addi $t3, $t4,17012
li $t5,0xc50301
sw $t5, 0($t3)
addi $t3, $t4,17016
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,17020
sw $t5, 0($t3)
addi $t3, $t4,17024
li $t5,0x910506
sw $t5, 0($t3)
addi $t3, $t4,17028
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,17032
sw $t5, 0($t3)
addi $t3, $t4,17036
sw $t5, 0($t3)
addi $t3, $t4,17040
sw $t5, 0($t3)
addi $t3, $t4,17044
sw $t5, 0($t3)
addi $t3, $t4,17048
sw $t5, 0($t3)
addi $t3, $t4,17052
sw $t5, 0($t3)
addi $t3, $t4,17056
sw $t5, 0($t3)
addi $t3, $t4,17060
li $t5,0xc50301
sw $t5, 0($t3)
addi $t3, $t4,17064
li $t5,0xc9a74e
sw $t5, 0($t3)
addi $t3, $t4,17068
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,17072
sw $t5, 0($t3)
addi $t3, $t4,17076
sw $t5, 0($t3)
addi $t3, $t4,17080
sw $t5, 0($t3)
addi $t3, $t4,17084
sw $t5, 0($t3)
addi $t3, $t4,17088
li $t5,0x0f0100
sw $t5, 0($t3)
addi $t3, $t4,17204
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4,17208
li $t5,0xfed74e
sw $t5, 0($t3)
addi $t3, $t4,17212
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,17216
sw $t5, 0($t3)
addi $t3, $t4,17220
sw $t5, 0($t3)
addi $t3, $t4,17224
sw $t5, 0($t3)
addi $t3, $t4,17228
li $t5,0x4c240a
sw $t5, 0($t3)
addi $t3, $t4,17232
li $t5,0x720113
sw $t5, 0($t3)
addi $t3, $t4,17236
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,17240
sw $t5, 0($t3)
addi $t3, $t4,17244
sw $t5, 0($t3)
addi $t3, $t4,17248
sw $t5, 0($t3)
addi $t3, $t4,17252
sw $t5, 0($t3)
addi $t3, $t4,17256
li $t5,0x2a0203
sw $t5, 0($t3)
addi $t3, $t4,17260
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,17264
li $t5,0xb90300
sw $t5, 0($t3)
addi $t3, $t4,17268
li $t5,0xc70102
sw $t5, 0($t3)
addi $t3, $t4,17272
li $t5,0x380000
sw $t5, 0($t3)
addi $t3, $t4,17276
li $t5,0xc60002
sw $t5, 0($t3)
addi $t3, $t4,17280
li $t5,0xb1080b
sw $t5, 0($t3)
addi $t3, $t4,17284
li $t5,0xc20404
sw $t5, 0($t3)
addi $t3, $t4,17288
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,17292
sw $t5, 0($t3)
addi $t3, $t4,17296
sw $t5, 0($t3)
addi $t3, $t4,17300
sw $t5, 0($t3)
addi $t3, $t4,17304
sw $t5, 0($t3)
addi $t3, $t4,17308
sw $t5, 0($t3)
addi $t3, $t4,17312
sw $t5, 0($t3)
addi $t3, $t4,17316
sw $t5, 0($t3)
addi $t3, $t4,17320
li $t5,0x2b0303
sw $t5, 0($t3)
addi $t3, $t4,17324
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,17328
sw $t5, 0($t3)
addi $t3, $t4,17332
sw $t5, 0($t3)
addi $t3, $t4,17336
sw $t5, 0($t3)
addi $t3, $t4,17340
sw $t5, 0($t3)
addi $t3, $t4,17344
li $t5,0x020001
sw $t5, 0($t3)
addi $t3, $t4,17460
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4,17464
li $t5,0xffd74f
sw $t5, 0($t3)
addi $t3, $t4,17468
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,17472
sw $t5, 0($t3)
addi $t3, $t4,17476
li $t5,0xfdd74e
sw $t5, 0($t3)
addi $t3, $t4,17480
li $t5,0xfdd84c
sw $t5, 0($t3)
addi $t3, $t4,17484
li $t5,0x1f000a
sw $t5, 0($t3)
addi $t3, $t4,17488
li $t5,0x710213
sw $t5, 0($t3)
addi $t3, $t4,17492
li $t5,0xc90103
sw $t5, 0($t3)
addi $t3, $t4,17496
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,17500
sw $t5, 0($t3)
addi $t3, $t4,17504
sw $t5, 0($t3)
addi $t3, $t4,17508
sw $t5, 0($t3)
addi $t3, $t4,17512
li $t5,0x2f0006
sw $t5, 0($t3)
addi $t3, $t4,17516
li $t5,0xbf0705
sw $t5, 0($t3)
addi $t3, $t4,17520
li $t5,0x2a0203
sw $t5, 0($t3)
addi $t3, $t4,17524
sw $t5, 0($t3)
addi $t3, $t4,17528
sw $t5, 0($t3)
addi $t3, $t4,17532
sw $t5, 0($t3)
addi $t3, $t4,17536
sw $t5, 0($t3)
addi $t3, $t4,17540
sw $t5, 0($t3)
addi $t3, $t4,17544
li $t5,0xc70102
sw $t5, 0($t3)
addi $t3, $t4,17548
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,17552
sw $t5, 0($t3)
addi $t3, $t4,17556
sw $t5, 0($t3)
addi $t3, $t4,17560
sw $t5, 0($t3)
addi $t3, $t4,17564
sw $t5, 0($t3)
addi $t3, $t4,17568
sw $t5, 0($t3)
addi $t3, $t4,17572
li $t5,0xab060c
sw $t5, 0($t3)
addi $t3, $t4,17576
li $t5,0x260206
sw $t5, 0($t3)
addi $t3, $t4,17580
li $t5,0xf8d44a
sw $t5, 0($t3)
addi $t3, $t4,17584
li $t5,0xfed74e
sw $t5, 0($t3)
addi $t3, $t4,17588
sw $t5, 0($t3)
addi $t3, $t4,17592
li $t5,0xffd64e
sw $t5, 0($t3)
addi $t3, $t4,17596
sw $t5, 0($t3)
addi $t3, $t4,17720
li $t5,0xf19a33
sw $t5, 0($t3)
addi $t3, $t4,17724
li $t5,0xfb822f
sw $t5, 0($t3)
addi $t3, $t4,17728
li $t5,0xfc8332
sw $t5, 0($t3)
addi $t3, $t4,17732
li $t5,0xfd8232
sw $t5, 0($t3)
addi $t3, $t4,17736
li $t5,0xfc8235
sw $t5, 0($t3)
addi $t3, $t4,17740
li $t5,0x280408
sw $t5, 0($t3)
addi $t3, $t4,17744
li $t5,0x710213
sw $t5, 0($t3)
addi $t3, $t4,17748
li $t5,0xc40403
sw $t5, 0($t3)
addi $t3, $t4,17752
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,17756
sw $t5, 0($t3)
addi $t3, $t4,17760
sw $t5, 0($t3)
addi $t3, $t4,17764
sw $t5, 0($t3)
addi $t3, $t4,17768
li $t5,0x360007
sw $t5, 0($t3)
addi $t3, $t4,17772
li $t5,0x2a0203
sw $t5, 0($t3)
addi $t3, $t4,17776
li $t5,0x9d060d
sw $t5, 0($t3)
addi $t3, $t4,17780
li $t5,0xc40001
sw $t5, 0($t3)
addi $t3, $t4,17784
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,17788
sw $t5, 0($t3)
addi $t3, $t4,17792
li $t5,0xc10400
sw $t5, 0($t3)
addi $t3, $t4,17796
li $t5,0x800206
sw $t5, 0($t3)
addi $t3, $t4,17800
li $t5,0x2a0203
sw $t5, 0($t3)
addi $t3, $t4,17804
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,17808
sw $t5, 0($t3)
addi $t3, $t4,17812
sw $t5, 0($t3)
addi $t3, $t4,17816
sw $t5, 0($t3)
addi $t3, $t4,17820
sw $t5, 0($t3)
addi $t3, $t4,17824
sw $t5, 0($t3)
addi $t3, $t4,17828
li $t5,0x6f0217
sw $t5, 0($t3)
addi $t3, $t4,17832
li $t5,0x380104
sw $t5, 0($t3)
addi $t3, $t4,17836
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,17840
li $t5,0xfd8336
sw $t5, 0($t3)
addi $t3, $t4,17844
li $t5,0xfb8233
sw $t5, 0($t3)
addi $t3, $t4,17848
sw $t5, 0($t3)
addi $t3, $t4,17852
li $t5,0xfe8034
sw $t5, 0($t3)
addi $t3, $t4,17976
li $t5,0x932315
sw $t5, 0($t3)
addi $t3, $t4,17980
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,17984
sw $t5, 0($t3)
addi $t3, $t4,17988
sw $t5, 0($t3)
addi $t3, $t4,17992
sw $t5, 0($t3)
addi $t3, $t4,17996
li $t5,0x280106
sw $t5, 0($t3)
addi $t3, $t4,18000
li $t5,0x6e0313
sw $t5, 0($t3)
addi $t3, $t4,18004
li $t5,0xc20200
sw $t5, 0($t3)
addi $t3, $t4,18008
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,18012
sw $t5, 0($t3)
addi $t3, $t4,18016
sw $t5, 0($t3)
addi $t3, $t4,18020
sw $t5, 0($t3)
addi $t3, $t4,18024
li $t5,0x2a0203
sw $t5, 0($t3)
addi $t3, $t4,18028
li $t5,0xad0409
sw $t5, 0($t3)
addi $t3, $t4,18032
li $t5,0xc60404
sw $t5, 0($t3)
addi $t3, $t4,18036
li $t5,0x9d0206
sw $t5, 0($t3)
addi $t3, $t4,18040
li $t5,0xcc0104
sw $t5, 0($t3)
addi $t3, $t4,18044
li $t5,0x880107
sw $t5, 0($t3)
addi $t3, $t4,18048
li $t5,0xb50507
sw $t5, 0($t3)
addi $t3, $t4,18052
li $t5,0x4b020d
sw $t5, 0($t3)
addi $t3, $t4,18056
li $t5,0x2a0203
sw $t5, 0($t3)
addi $t3, $t4,18060
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,18064
sw $t5, 0($t3)
addi $t3, $t4,18068
sw $t5, 0($t3)
addi $t3, $t4,18072
sw $t5, 0($t3)
addi $t3, $t4,18076
sw $t5, 0($t3)
addi $t3, $t4,18080
sw $t5, 0($t3)
addi $t3, $t4,18084
li $t5,0x710213
sw $t5, 0($t3)
addi $t3, $t4,18088
li $t5,0x4f030d
sw $t5, 0($t3)
addi $t3, $t4,18092
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,18096
sw $t5, 0($t3)
addi $t3, $t4,18100
sw $t5, 0($t3)
addi $t3, $t4,18104
sw $t5, 0($t3)
addi $t3, $t4,18108
li $t5,0xfc8332
sw $t5, 0($t3)
addi $t3, $t4,18232
li $t5,0x550913
sw $t5, 0($t3)
addi $t3, $t4,18236
li $t5,0xfd8232
sw $t5, 0($t3)
addi $t3, $t4,18240
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,18244
sw $t5, 0($t3)
addi $t3, $t4,18248
sw $t5, 0($t3)
addi $t3, $t4,18252
li $t5,0x320107
sw $t5, 0($t3)
addi $t3, $t4,18256
li $t5,0x720113
sw $t5, 0($t3)
addi $t3, $t4,18260
li $t5,0x85020a
sw $t5, 0($t3)
addi $t3, $t4,18264
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,18268
sw $t5, 0($t3)
addi $t3, $t4,18272
sw $t5, 0($t3)
addi $t3, $t4,18276
li $t5,0xbd0400
sw $t5, 0($t3)
addi $t3, $t4,18280
li $t5,0x2a0203
sw $t5, 0($t3)
addi $t3, $t4,18284
li $t5,0xb00106
sw $t5, 0($t3)
addi $t3, $t4,18288
li $t5,0xc70402
sw $t5, 0($t3)
addi $t3, $t4,18292
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,18296
li $t5,0xb5040c
sw $t5, 0($t3)
addi $t3, $t4,18300
li $t5,0xac030a
sw $t5, 0($t3)
addi $t3, $t4,18304
li $t5,0x740110
sw $t5, 0($t3)
addi $t3, $t4,18308
li $t5,0x4f010e
sw $t5, 0($t3)
addi $t3, $t4,18312
li $t5,0xbf050a
sw $t5, 0($t3)
addi $t3, $t4,18316
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,18320
sw $t5, 0($t3)
addi $t3, $t4,18324
sw $t5, 0($t3)
addi $t3, $t4,18328
sw $t5, 0($t3)
addi $t3, $t4,18332
sw $t5, 0($t3)
addi $t3, $t4,18336
li $t5,0xc40203
sw $t5, 0($t3)
addi $t3, $t4,18340
li $t5,0x710213
sw $t5, 0($t3)
addi $t3, $t4,18344
li $t5,0x53010d
sw $t5, 0($t3)
addi $t3, $t4,18348
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,18352
sw $t5, 0($t3)
addi $t3, $t4,18356
sw $t5, 0($t3)
addi $t3, $t4,18360
sw $t5, 0($t3)
addi $t3, $t4,18364
li $t5,0x740013
sw $t5, 0($t3)
addi $t3, $t4,18492
li $t5,0xf7803c
sw $t5, 0($t3)
addi $t3, $t4,18496
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,18500
sw $t5, 0($t3)
addi $t3, $t4,18504
sw $t5, 0($t3)
addi $t3, $t4,18508
li $t5,0x3f030d
sw $t5, 0($t3)
addi $t3, $t4,18512
li $t5,0x6c0314
sw $t5, 0($t3)
addi $t3, $t4,18516
li $t5,0x710213
sw $t5, 0($t3)
addi $t3, $t4,18520
li $t5,0xc90101
sw $t5, 0($t3)
addi $t3, $t4,18524
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,18528
sw $t5, 0($t3)
addi $t3, $t4,18532
li $t5,0xc50200
sw $t5, 0($t3)
addi $t3, $t4,18536
li $t5,0x2a0203
sw $t5, 0($t3)
addi $t3, $t4,18540
li $t5,0xc40001
sw $t5, 0($t3)
addi $t3, $t4,18544
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,18548
li $t5,0xc40403
sw $t5, 0($t3)
addi $t3, $t4,18552
li $t5,0x53010d
sw $t5, 0($t3)
addi $t3, $t4,18556
li $t5,0x6d0212
sw $t5, 0($t3)
addi $t3, $t4,18560
li $t5,0x42030b
sw $t5, 0($t3)
addi $t3, $t4,18564
li $t5,0x4c030e
sw $t5, 0($t3)
addi $t3, $t4,18568
li $t5,0xc20501
sw $t5, 0($t3)
addi $t3, $t4,18572
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,18576
sw $t5, 0($t3)
addi $t3, $t4,18580
sw $t5, 0($t3)
addi $t3, $t4,18584
sw $t5, 0($t3)
addi $t3, $t4,18588
li $t5,0xc40001
sw $t5, 0($t3)
addi $t3, $t4,18592
li $t5,0x720210
sw $t5, 0($t3)
addi $t3, $t4,18596
li $t5,0x710213
sw $t5, 0($t3)
addi $t3, $t4,18600
li $t5,0x500210
sw $t5, 0($t3)
addi $t3, $t4,18604
li $t5,0xfd8234
sw $t5, 0($t3)
addi $t3, $t4,18608
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,18612
sw $t5, 0($t3)
addi $t3, $t4,18616
li $t5,0xfa822c
sw $t5, 0($t3)
addi $t3, $t4,18620
li $t5,0x030102
sw $t5, 0($t3)
addi $t3, $t4,18748
li $t5,0x590914
sw $t5, 0($t3)
addi $t3, $t4,18752
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,18756
sw $t5, 0($t3)
addi $t3, $t4,18760
sw $t5, 0($t3)
addi $t3, $t4,18764
li $t5,0x4a040f
sw $t5, 0($t3)
addi $t3, $t4,18768
li $t5,0x510310
sw $t5, 0($t3)
addi $t3, $t4,18772
li $t5,0x710213
sw $t5, 0($t3)
addi $t3, $t4,18776
sw $t5, 0($t3)
addi $t3, $t4,18780
li $t5,0xc40107
sw $t5, 0($t3)
addi $t3, $t4,18784
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,18788
sw $t5, 0($t3)
addi $t3, $t4,18792
li $t5,0x2a0203
sw $t5, 0($t3)
addi $t3, $t4,18796
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,18800
sw $t5, 0($t3)
addi $t3, $t4,18804
sw $t5, 0($t3)
addi $t3, $t4,18808
li $t5,0x890008
sw $t5, 0($t3)
addi $t3, $t4,18812
li $t5,0x290109
sw $t5, 0($t3)
addi $t3, $t4,18816
li $t5,0x4d040f
sw $t5, 0($t3)
addi $t3, $t4,18820
li $t5,0x2c0002
sw $t5, 0($t3)
addi $t3, $t4,18824
li $t5,0xc60405
sw $t5, 0($t3)
addi $t3, $t4,18828
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,18832
sw $t5, 0($t3)
addi $t3, $t4,18836
sw $t5, 0($t3)
addi $t3, $t4,18840
li $t5,0xc70102
sw $t5, 0($t3)
addi $t3, $t4,18844
li $t5,0x7a0108
sw $t5, 0($t3)
addi $t3, $t4,18848
li $t5,0x710213
sw $t5, 0($t3)
addi $t3, $t4,18852
li $t5,0x740112
sw $t5, 0($t3)
addi $t3, $t4,18856
li $t5,0x500313
sw $t5, 0($t3)
addi $t3, $t4,18860
li $t5,0xfd8330
sw $t5, 0($t3)
addi $t3, $t4,18864
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,18868
sw $t5, 0($t3)
addi $t3, $t4,18872
li $t5,0x720210
sw $t5, 0($t3)
addi $t3, $t4,19004
li $t5,0x020001
sw $t5, 0($t3)
addi $t3, $t4,19008
li $t5,0xfd832d
sw $t5, 0($t3)
addi $t3, $t4,19012
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,19016
sw $t5, 0($t3)
addi $t3, $t4,19020
li $t5,0x4c0513
sw $t5, 0($t3)
addi $t3, $t4,19024
li $t5,0x510310
sw $t5, 0($t3)
addi $t3, $t4,19028
li $t5,0x6f0313
sw $t5, 0($t3)
addi $t3, $t4,19032
li $t5,0x710213
sw $t5, 0($t3)
addi $t3, $t4,19036
sw $t5, 0($t3)
addi $t3, $t4,19040
li $t5,0xc50301
sw $t5, 0($t3)
addi $t3, $t4,19044
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,19048
li $t5,0x230304
sw $t5, 0($t3)
addi $t3, $t4,19052
li $t5,0xc60203
sw $t5, 0($t3)
addi $t3, $t4,19056
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,19060
sw $t5, 0($t3)
addi $t3, $t4,19064
li $t5,0xa7090a
sw $t5, 0($t3)
addi $t3, $t4,19068
li $t5,0x4e020e
sw $t5, 0($t3)
addi $t3, $t4,19072
li $t5,0x54030c
sw $t5, 0($t3)
addi $t3, $t4,19076
li $t5,0xac0d07
sw $t5, 0($t3)
addi $t3, $t4,19080
li $t5,0xc60203
sw $t5, 0($t3)
addi $t3, $t4,19084
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,19088
sw $t5, 0($t3)
addi $t3, $t4,19092
sw $t5, 0($t3)
addi $t3, $t4,19096
li $t5,0xa50a06
sw $t5, 0($t3)
addi $t3, $t4,19100
li $t5,0x720212
sw $t5, 0($t3)
addi $t3, $t4,19104
li $t5,0x710213
sw $t5, 0($t3)
addi $t3, $t4,19108
li $t5,0x670713
sw $t5, 0($t3)
addi $t3, $t4,19112
li $t5,0x510311
sw $t5, 0($t3)
addi $t3, $t4,19116
li $t5,0xfd8330
sw $t5, 0($t3)
addi $t3, $t4,19120
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,19124
sw $t5, 0($t3)
addi $t3, $t4,19128
li $t5,0x020200
sw $t5, 0($t3)
addi $t3, $t4,19264
li $t5,0x7a0412
sw $t5, 0($t3)
addi $t3, $t4,19268
li $t5,0xfd8234
sw $t5, 0($t3)
addi $t3, $t4,19272
li $t5,0xf7832e
sw $t5, 0($t3)
addi $t3, $t4,19276
li $t5,0x4c0611
sw $t5, 0($t3)
addi $t3, $t4,19280
li $t5,0x510310
sw $t5, 0($t3)
addi $t3, $t4,19284
li $t5,0x570310
sw $t5, 0($t3)
addi $t3, $t4,19288
li $t5,0x710213
sw $t5, 0($t3)
addi $t3, $t4,19292
sw $t5, 0($t3)
addi $t3, $t4,19296
li $t5,0x720210
sw $t5, 0($t3)
addi $t3, $t4,19300
li $t5,0x74000d
sw $t5, 0($t3)
addi $t3, $t4,19304
li $t5,0x7d0600
sw $t5, 0($t3)
addi $t3, $t4,19308
li $t5,0x78030c
sw $t5, 0($t3)
addi $t3, $t4,19312
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,19316
sw $t5, 0($t3)
addi $t3, $t4,19320
li $t5,0x6f0215
sw $t5, 0($t3)
addi $t3, $t4,19324
li $t5,0x510313
sw $t5, 0($t3)
addi $t3, $t4,19328
li $t5,0x240105
sw $t5, 0($t3)
addi $t3, $t4,19332
li $t5,0xc50102
sw $t5, 0($t3)
addi $t3, $t4,19336
sw $t5, 0($t3)
addi $t3, $t4,19340
sw $t5, 0($t3)
addi $t3, $t4,19344
sw $t5, 0($t3)
addi $t3, $t4,19348
li $t5,0xaa0408
sw $t5, 0($t3)
addi $t3, $t4,19352
li $t5,0x710012
sw $t5, 0($t3)
addi $t3, $t4,19356
li $t5,0x710213
sw $t5, 0($t3)
addi $t3, $t4,19360
sw $t5, 0($t3)
addi $t3, $t4,19364
li $t5,0x52020f
sw $t5, 0($t3)
addi $t3, $t4,19368
li $t5,0x50020f
sw $t5, 0($t3)
addi $t3, $t4,19372
li $t5,0xfb8233
sw $t5, 0($t3)
addi $t3, $t4,19376
li $t5,0xfd8235
sw $t5, 0($t3)
addi $t3, $t4,19380
li $t5,0x9e280a
sw $t5, 0($t3)
addi $t3, $t4,21820
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,21824
li $t5,0x92e1e7
sw $t5, 0($t3)
addi $t3, $t4,21828
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,21832
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,21836
li $t5,0xdce1d0
sw $t5, 0($t3)
addi $t3, $t4,21840
li $t5,0x927f86
sw $t5, 0($t3)
addi $t3, $t4,21856
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,21932
sw $t5, 0($t3)
addi $t3, $t4,22072
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,22076
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,22080
li $t5,0xdca19f
sw $t5, 0($t3)
addi $t3, $t4,22084
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,22092
li $t5,0x3f5b9f
sw $t5, 0($t3)
addi $t3, $t4,22096
li $t5,0x6b7f86
sw $t5, 0($t3)
addi $t3, $t4,22108
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,22112
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,22116
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,22184
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,22188
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,22192
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,22328
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,22332
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,22336
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,22360
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,22364
li $t5,0x92e1e7
sw $t5, 0($t3)
addi $t3, $t4,22368
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,22372
li $t5,0xb8c1d0
sw $t5, 0($t3)
addi $t3, $t4,22376
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,22388
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,22392
li $t5,0x92c1d0
sw $t5, 0($t3)
addi $t3, $t4,22396
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,22400
li $t5,0xb8c1b9
sw $t5, 0($t3)
addi $t3, $t4,22404
li $t5,0x6b5b6b
sw $t5, 0($t3)
addi $t3, $t4,22416
li $t5,0x3fa1d0
sw $t5, 0($t3)
addi $t3, $t4,22420
li $t5,0x927f86
sw $t5, 0($t3)
addi $t3, $t4,22424
li $t5,0x6ba1d0
sw $t5, 0($t3)
addi $t3, $t4,22428
li $t5,0xb8a19f
sw $t5, 0($t3)
addi $t3, $t4,22432
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,22436
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,22440
li $t5,0x92e1e7
sw $t5, 0($t3)
addi $t3, $t4,22444
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,22448
li $t5,0xb8c1d0
sw $t5, 0($t3)
addi $t3, $t4,22452
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,22584
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,22588
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,22592
li $t5,0xdcc19f
sw $t5, 0($t3)
addi $t3, $t4,22596
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,22620
li $t5,0x3f7fd0
sw $t5, 0($t3)
addi $t3, $t4,22624
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,22628
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,22644
li $t5,0x3f7f9f
sw $t5, 0($t3)
addi $t3, $t4,22648
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,22656
li $t5,0x3f7fb9
sw $t5, 0($t3)
addi $t3, $t4,22660
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,22664
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,22672
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,22676
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,22680
li $t5,0xb8a19f
sw $t5, 0($t3)
addi $t3, $t4,22684
li $t5,0x6b7f86
sw $t5, 0($t3)
addi $t3, $t4,22688
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,22696
li $t5,0x3f7fd0
sw $t5, 0($t3)
addi $t3, $t4,22700
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,22704
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,22844
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,22848
li $t5,0xb8e1ff
sw $t5, 0($t3)
addi $t3, $t4,22852
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,22856
sw $t5, 0($t3)
addi $t3, $t4,22860
li $t5,0xdcc1b9
sw $t5, 0($t3)
addi $t3, $t4,22864
li $t5,0x6b5b6b
sw $t5, 0($t3)
addi $t3, $t4,22876
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,22880
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,22884
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,22908
li $t5,0x0d5b86
sw $t5, 0($t3)
addi $t3, $t4,22912
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,22916
li $t5,0x92c1ff
sw $t5, 0($t3)
addi $t3, $t4,22920
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,22928
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,22932
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,22952
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,22956
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,22960
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,23112
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,23116
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,23120
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,23124
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,23132
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,23136
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,23140
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,23156
li $t5,0x3fa1d0
sw $t5, 0($t3)
addi $t3, $t4,23160
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,23164
li $t5,0xb8c1d0
sw $t5, 0($t3)
addi $t3, $t4,23168
li $t5,0xb8e1e7
sw $t5, 0($t3)
addi $t3, $t4,23172
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,23176
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,23184
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,23188
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,23208
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,23212
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,23216
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,23372
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,23376
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,23380
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,23388
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,23392
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,23396
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,23408
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,23412
li $t5,0xb8e1b9
sw $t5, 0($t3)
addi $t3, $t4,23416
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,23424
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,23428
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,23432
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,23440
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,23444
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,23464
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,23468
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,23472
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,23608
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,23612
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,23616
li $t5,0xdcc1b9
sw $t5, 0($t3)
addi $t3, $t4,23620
li $t5,0x927f9f
sw $t5, 0($t3)
addi $t3, $t4,23624
li $t5,0x92a1d0
sw $t5, 0($t3)
addi $t3, $t4,23628
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,23632
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,23636
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,23644
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,23648
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,23652
li $t5,0xdcc1d0
sw $t5, 0($t3)
addi $t3, $t4,23656
li $t5,0xb8c1b9
sw $t5, 0($t3)
addi $t3, $t4,23660
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,23664
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,23668
li $t5,0xdcffe7
sw $t5, 0($t3)
addi $t3, $t4,23672
li $t5,0xb8a1b9
sw $t5, 0($t3)
addi $t3, $t4,23676
li $t5,0x6b7fb9
sw $t5, 0($t3)
addi $t3, $t4,23680
li $t5,0xb8e1ff
sw $t5, 0($t3)
addi $t3, $t4,23684
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,23688
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,23692
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,23696
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,23700
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,23720
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,23724
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,23728
li $t5,0xdcc1d0
sw $t5, 0($t3)
addi $t3, $t4,23732
li $t5,0xb8c1b9
sw $t5, 0($t3)
addi $t3, $t4,23736
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,23864
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,23868
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,23872
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,23876
sw $t5, 0($t3)
addi $t3, $t4,23880
sw $t5, 0($t3)
addi $t3, $t4,23884
li $t5,0xffe1d0
sw $t5, 0($t3)
addi $t3, $t4,23888
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,23900
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,23904
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,23908
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,23912
li $t5,0xffffd0
sw $t5, 0($t3)
addi $t3, $t4,23916
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,23924
li $t5,0x6bc1e7
sw $t5, 0($t3)
addi $t3, $t4,23928
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,23932
sw $t5, 0($t3)
addi $t3, $t4,23936
li $t5,0xffe1d0
sw $t5, 0($t3)
addi $t3, $t4,23940
li $t5,0xb8c1ff
sw $t5, 0($t3)
addi $t3, $t4,23944
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,23948
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,23952
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,23956
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,23976
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,23980
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,23984
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,23988
li $t5,0xffffd0
sw $t5, 0($t3)
addi $t3, $t4,23992
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,24132
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,24136
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,24184
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,24188
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,26692
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,26696
li $t5,0xb8e1e7
sw $t5, 0($t3)
addi $t3, $t4,26700
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,26704
sw $t5, 0($t3)
addi $t3, $t4,26708
sw $t5, 0($t3)
addi $t3, $t4,26712
sw $t5, 0($t3)
addi $t3, $t4,26716
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,26752
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,26756
li $t5,0xb8ffd0
sw $t5, 0($t3)
addi $t3, $t4,26760
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,26772
li $t5,0x3f5b6b
sw $t5, 0($t3)
addi $t3, $t4,26948
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,26952
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,26956
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,26960
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,26964
sw $t5, 0($t3)
addi $t3, $t4,26968
sw $t5, 0($t3)
addi $t3, $t4,27024
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,27028
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,27032
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,27204
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,27208
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,27212
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,27236
li $t5,0x3fa1d0
sw $t5, 0($t3)
addi $t3, $t4,27240
li $t5,0x927f86
sw $t5, 0($t3)
addi $t3, $t4,27252
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,27256
li $t5,0x6bc1b9
sw $t5, 0($t3)
addi $t3, $t4,27260
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,27264
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,27268
li $t5,0x92c1b9
sw $t5, 0($t3)
addi $t3, $t4,27272
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,27276
li $t5,0x0d5b9f
sw $t5, 0($t3)
addi $t3, $t4,27280
li $t5,0x92e1e7
sw $t5, 0($t3)
addi $t3, $t4,27284
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,27288
li $t5,0xb8c1d0
sw $t5, 0($t3)
addi $t3, $t4,27292
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,27460
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,27464
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,27468
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,27472
li $t5,0x3f5b86
sw $t5, 0($t3)
addi $t3, $t4,27476
sw $t5, 0($t3)
addi $t3, $t4,27480
sw $t5, 0($t3)
addi $t3, $t4,27492
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,27496
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,27500
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,27508
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,27512
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,27520
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,27524
li $t5,0xb8ffd0
sw $t5, 0($t3)
addi $t3, $t4,27528
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,27536
li $t5,0x3f7fd0
sw $t5, 0($t3)
addi $t3, $t4,27540
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,27544
li $t5,0x6b5b86
sw $t5, 0($t3)
addi $t3, $t4,27716
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,27720
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,27724
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,27728
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,27732
sw $t5, 0($t3)
addi $t3, $t4,27736
li $t5,0xdce1d0
sw $t5, 0($t3)
addi $t3, $t4,27740
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,27752
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,27756
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,27760
li $t5,0x3f7fd0
sw $t5, 0($t3)
addi $t3, $t4,27764
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,27768
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,27776
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,27780
li $t5,0xb8ffd0
sw $t5, 0($t3)
addi $t3, $t4,27784
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,27792
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,27796
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,27800
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,27972
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,27976
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,27980
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,28008
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,28012
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,28016
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,28020
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,28032
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,28036
li $t5,0xb8ffd0
sw $t5, 0($t3)
addi $t3, $t4,28040
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,28048
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,28052
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,28056
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,28228
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,28232
li $t5,0xdcffd0
sw $t5, 0($t3)
addi $t3, $t4,28236
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,28264
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,28268
li $t5,0xb8ffff
sw $t5, 0($t3)
addi $t3, $t4,28272
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,28276
li $t5,0xb87f6b
sw $t5, 0($t3)
addi $t3, $t4,28288
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,28292
li $t5,0xb8ffd0
sw $t5, 0($t3)
addi $t3, $t4,28296
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,28304
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,28308
li $t5,0xffe1b9
sw $t5, 0($t3)
addi $t3, $t4,28312
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,28484
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,28488
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,28492
li $t5,0xffe1e7
sw $t5, 0($t3)
addi $t3, $t4,28496
li $t5,0xdce1e7
sw $t5, 0($t3)
addi $t3, $t4,28500
sw $t5, 0($t3)
addi $t3, $t4,28504
sw $t5, 0($t3)
addi $t3, $t4,28508
li $t5,0xb8a186
sw $t5, 0($t3)
addi $t3, $t4,28516
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,28520
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,28524
li $t5,0xffc19f
sw $t5, 0($t3)
addi $t3, $t4,28528
li $t5,0x3f7fd0
sw $t5, 0($t3)
addi $t3, $t4,28532
li $t5,0xffffe7
sw $t5, 0($t3)
addi $t3, $t4,28536
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,28544
li $t5,0x0d349f
sw $t5, 0($t3)
addi $t3, $t4,28548
li $t5,0xb8ffe7
sw $t5, 0($t3)
addi $t3, $t4,28552
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,28560
li $t5,0x0d7fd0
sw $t5, 0($t3)
addi $t3, $t4,28564
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,28568
li $t5,0xdcc1d0
sw $t5, 0($t3)
addi $t3, $t4,28572
li $t5,0xb8c1b9
sw $t5, 0($t3)
addi $t3, $t4,28576
li $t5,0x3f346b
sw $t5, 0($t3)
addi $t3, $t4,28740
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,28744
li $t5,0xdcffff
sw $t5, 0($t3)
addi $t3, $t4,28748
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,28752
sw $t5, 0($t3)
addi $t3, $t4,28756
sw $t5, 0($t3)
addi $t3, $t4,28760
sw $t5, 0($t3)
addi $t3, $t4,28764
li $t5,0xdca186
sw $t5, 0($t3)
addi $t3, $t4,28768
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,28772
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,28776
li $t5,0xffffd0
sw $t5, 0($t3)
addi $t3, $t4,28780
li $t5,0x6b346b
sw $t5, 0($t3)
addi $t3, $t4,28788
li $t5,0x6bc1ff
sw $t5, 0($t3)
addi $t3, $t4,28792
li $t5,0xffffd0
sw $t5, 0($t3)
addi $t3, $t4,28796
li $t5,0x6b5b6b
sw $t5, 0($t3)
addi $t3, $t4,28800
li $t5,0x0d5bb9
sw $t5, 0($t3)
addi $t3, $t4,28804
li $t5,0xdcffe7
sw $t5, 0($t3)
addi $t3, $t4,28808
li $t5,0x925b6b
sw $t5, 0($t3)
addi $t3, $t4,28816
li $t5,0x0d3486
sw $t5, 0($t3)
addi $t3, $t4,28820
li $t5,0x92e1ff
sw $t5, 0($t3)
addi $t3, $t4,28824
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,28828
li $t5,0xffffd0
sw $t5, 0($t3)
addi $t3, $t4,28832
li $t5,0x6b346b
sw $t5, 0($t3)

jr $ra
win_screen:
	li $a0 0
	li $a1 0
	jal clear_screen
	jal draw_win_screen
	li $v0, 32		
	li $a0, 1000
	syscall
	j main
draw_win_screen:
#paste it here
mul $t0 $a1 WIDTH
add $t0 $t0 $a0
mul $t0 $t0 4
add $t0 $t0 BASE_ADDRESS
move $t4, $t0
addi $t3, $t4,12872
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,12876
li $t5,0x90dbdb
sw $t5, 0($t3)
addi $t3, $t4,12880
li $t5,0x906600
sw $t5, 0($t3)
addi $t3, $t4,12896
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,12900
li $t5,0xdbdbb6
sw $t5, 0($t3)
addi $t3, $t4,12904
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,12916
li $t5,0x003a66
sw $t5, 0($t3)
addi $t3, $t4,12920
li $t5,0xb6dbdb
sw $t5, 0($t3)
addi $t3, $t4,12924
li $t5,0xdbffff
sw $t5, 0($t3)
addi $t3, $t4,12928
li $t5,0xffdbdb
sw $t5, 0($t3)
addi $t3, $t4,12932
li $t5,0xdbb690
sw $t5, 0($t3)
addi $t3, $t4,12936
li $t5,0x663a00
sw $t5, 0($t3)
addi $t3, $t4,12948
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,12952
li $t5,0xb6dbb6
sw $t5, 0($t3)
addi $t3, $t4,12956
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,12972
li $t5,0x66b6db
sw $t5, 0($t3)
addi $t3, $t4,12976
li $t5,0xb6903a
sw $t5, 0($t3)
addi $t3, $t4,13132
li $t5,0x3a90db
sw $t5, 0($t3)
addi $t3, $t4,13136
li $t5,0xffdb90
sw $t5, 0($t3)
addi $t3, $t4,13140
li $t5,0x3a0000
sw $t5, 0($t3)
addi $t3, $t4,13152
li $t5,0x66b6ff
sw $t5, 0($t3)
addi $t3, $t4,13156
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,13168
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,13172
li $t5,0xdbffff
sw $t5, 0($t3)
addi $t3, $t4,13176
li $t5,0xb6903a
sw $t5, 0($t3)
addi $t3, $t4,13180
li $t5,0x3a0000
sw $t5, 0($t3)
addi $t3, $t4,13184
li $t5,0x00003a
sw $t5, 0($t3)
addi $t3, $t4,13188
li $t5,0x6690db
sw $t5, 0($t3)
addi $t3, $t4,13192
li $t5,0xffffb6
sw $t5, 0($t3)
addi $t3, $t4,13196
li $t5,0x660000
sw $t5, 0($t3)
addi $t3, $t4,13204
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,13208
li $t5,0xdbffdb
sw $t5, 0($t3)
addi $t3, $t4,13212
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,13228
li $t5,0x66b6ff
sw $t5, 0($t3)
addi $t3, $t4,13232
li $t5,0xdb903a
sw $t5, 0($t3)
addi $t3, $t4,13388
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,13392
li $t5,0xb6ffff
sw $t5, 0($t3)
addi $t3, $t4,13396
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,13404
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,13408
li $t5,0xdbffdb
sw $t5, 0($t3)
addi $t3, $t4,13412
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,13424
li $t5,0x66b6ff
sw $t5, 0($t3)
addi $t3, $t4,13428
li $t5,0xdb903a
sw $t5, 0($t3)
addi $t3, $t4,13448
li $t5,0x66b6ff
sw $t5, 0($t3)
addi $t3, $t4,13452
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,13460
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,13464
li $t5,0xdbffb6
sw $t5, 0($t3)
addi $t3, $t4,13468
li $t5,0x660000
sw $t5, 0($t3)
addi $t3, $t4,13484
li $t5,0x66b6ff
sw $t5, 0($t3)
addi $t3, $t4,13488
li $t5,0xdb903a
sw $t5, 0($t3)
addi $t3, $t4,13648
li $t5,0x3a90db
sw $t5, 0($t3)
addi $t3, $t4,13652
li $t5,0xffdb90
sw $t5, 0($t3)
addi $t3, $t4,13656
li $t5,0x3a003a
sw $t5, 0($t3)
addi $t3, $t4,13660
li $t5,0x90dbff
sw $t5, 0($t3)
addi $t3, $t4,13664
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,13676
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,13680
li $t5,0xb6ffdb
sw $t5, 0($t3)
addi $t3, $t4,13684
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,13704
li $t5,0x0066b6
sw $t5, 0($t3)
addi $t3, $t4,13708
li $t5,0xffdb90
sw $t5, 0($t3)
addi $t3, $t4,13712
li $t5,0x3a0000
sw $t5, 0($t3)
addi $t3, $t4,13716
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,13720
li $t5,0xdbffb6
sw $t5, 0($t3)
addi $t3, $t4,13724
li $t5,0x660000
sw $t5, 0($t3)
addi $t3, $t4,13740
li $t5,0x66b6ff
sw $t5, 0($t3)
addi $t3, $t4,13744
li $t5,0xdb903a
sw $t5, 0($t3)
addi $t3, $t4,13904
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,13908
li $t5,0xb6ffff
sw $t5, 0($t3)
addi $t3, $t4,13912
li $t5,0xdbb6b6
sw $t5, 0($t3)
addi $t3, $t4,13916
li $t5,0xffffdb
sw $t5, 0($t3)
addi $t3, $t4,13920
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,13932
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,13936
li $t5,0xdbffdb
sw $t5, 0($t3)
addi $t3, $t4,13940
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,13960
li $t5,0x0066b6
sw $t5, 0($t3)
addi $t3, $t4,13964
li $t5,0xffffb6
sw $t5, 0($t3)
addi $t3, $t4,13968
li $t5,0x660000
sw $t5, 0($t3)
addi $t3, $t4,13972
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,13976
li $t5,0xdbffb6
sw $t5, 0($t3)
addi $t3, $t4,13980
li $t5,0x660000
sw $t5, 0($t3)
addi $t3, $t4,13996
li $t5,0x3a90db
sw $t5, 0($t3)
addi $t3, $t4,14000
li $t5,0xdb903a
sw $t5, 0($t3)
addi $t3, $t4,14164
li $t5,0x3a90db
sw $t5, 0($t3)
addi $t3, $t4,14168
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14172
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,14188
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,14192
li $t5,0xb6ffdb
sw $t5, 0($t3)
addi $t3, $t4,14196
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,14216
li $t5,0x0066b6
sw $t5, 0($t3)
addi $t3, $t4,14220
li $t5,0xffffb6
sw $t5, 0($t3)
addi $t3, $t4,14224
li $t5,0x660000
sw $t5, 0($t3)
addi $t3, $t4,14228
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,14232
li $t5,0xdbffb6
sw $t5, 0($t3)
addi $t3, $t4,14236
li $t5,0x660000
sw $t5, 0($t3)
addi $t3, $t4,14252
li $t5,0x66b6ff
sw $t5, 0($t3)
addi $t3, $t4,14256
li $t5,0xdb903a
sw $t5, 0($t3)
addi $t3, $t4,14420
li $t5,0x0066b6
sw $t5, 0($t3)
addi $t3, $t4,14424
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14428
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,14444
li $t5,0x00003a
sw $t5, 0($t3)
addi $t3, $t4,14448
li $t5,0x90dbff
sw $t5, 0($t3)
addi $t3, $t4,14452
li $t5,0xffdbb6
sw $t5, 0($t3)
addi $t3, $t4,14456
li $t5,0x663a3a
sw $t5, 0($t3)
addi $t3, $t4,14464
li $t5,0x00003a
sw $t5, 0($t3)
addi $t3, $t4,14468
li $t5,0x3a6690
sw $t5, 0($t3)
addi $t3, $t4,14472
li $t5,0xdbffff
sw $t5, 0($t3)
addi $t3, $t4,14476
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,14484
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,14488
li $t5,0xb6ffff
sw $t5, 0($t3)
addi $t3, $t4,14492
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,14504
li $t5,0x00003a
sw $t5, 0($t3)
addi $t3, $t4,14508
li $t5,0x90dbff
sw $t5, 0($t3)
addi $t3, $t4,14512
li $t5,0xdb903a
sw $t5, 0($t3)
addi $t3, $t4,14676
li $t5,0x0066b6
sw $t5, 0($t3)
addi $t3, $t4,14680
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14684
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,14704
li $t5,0x0066b6
sw $t5, 0($t3)
addi $t3, $t4,14708
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14712
sw $t5, 0($t3)
addi $t3, $t4,14716
sw $t5, 0($t3)
addi $t3, $t4,14720
sw $t5, 0($t3)
addi $t3, $t4,14724
sw $t5, 0($t3)
addi $t3, $t4,14728
li $t5,0xffffdb
sw $t5, 0($t3)
addi $t3, $t4,14732
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,14740
li $t5,0x00003a
sw $t5, 0($t3)
addi $t3, $t4,14744
li $t5,0x90dbff
sw $t5, 0($t3)
addi $t3, $t4,14748
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14752
li $t5,0xdbdbb6
sw $t5, 0($t3)
addi $t3, $t4,14756
li $t5,0xb6b6b6
sw $t5, 0($t3)
addi $t3, $t4,14760
li $t5,0xdbffff
sw $t5, 0($t3)
addi $t3, $t4,14764
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14768
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,14932
li $t5,0x0066b6
sw $t5, 0($t3)
addi $t3, $t4,14936
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14940
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,14964
li $t5,0x3a66b6
sw $t5, 0($t3)
addi $t3, $t4,14968
li $t5,0xdbffff
sw $t5, 0($t3)
addi $t3, $t4,14972
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,14976
sw $t5, 0($t3)
addi $t3, $t4,14980
li $t5,0xffffdb
sw $t5, 0($t3)
addi $t3, $t4,14984
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,15000
li $t5,0x003a66
sw $t5, 0($t3)
addi $t3, $t4,15004
li $t5,0xb6dbff
sw $t5, 0($t3)
addi $t3, $t4,15008
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,15012
sw $t5, 0($t3)
addi $t3, $t4,15016
li $t5,0xffffdb
sw $t5, 0($t3)
addi $t3, $t4,15020
li $t5,0xb6903a
sw $t5, 0($t3)
addi $t3, $t4,15228
li $t5,0x003a3a
sw $t5, 0($t3)
addi $t3, $t4,15232
li $t5,0x3a3a00
sw $t5, 0($t3)
addi $t3, $t4,15264
li $t5,0x00003a
sw $t5, 0($t3)
addi $t3, $t4,15268
li $t5,0x3a3a3a
sw $t5, 0($t3)
addi $t3, $t4,16460
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,16464
li $t5,0xb6dbb6
sw $t5, 0($t3)
addi $t3, $t4,16468
li $t5,0x663a00
sw $t5, 0($t3)
addi $t3, $t4,16500
li $t5,0x006690
sw $t5, 0($t3)
addi $t3, $t4,16504
li $t5,0xdbdb90
sw $t5, 0($t3)
addi $t3, $t4,16508
li $t5,0x3a0000
sw $t5, 0($t3)
addi $t3, $t4,16512
li $t5,0x00003a
sw $t5, 0($t3)
addi $t3, $t4,16516
li $t5,0x90b6b6
sw $t5, 0($t3)
addi $t3, $t4,16520
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,16524
li $t5,0x00003a
sw $t5, 0($t3)
addi $t3, $t4,16528
li $t5,0x6690b6
sw $t5, 0($t3)
addi $t3, $t4,16532
li $t5,0xb6903a
sw $t5, 0($t3)
addi $t3, $t4,16548
li $t5,0x3a90b6
sw $t5, 0($t3)
addi $t3, $t4,16552
li $t5,0xdbb666
sw $t5, 0($t3)
addi $t3, $t4,16716
li $t5,0x00003a
sw $t5, 0($t3)
addi $t3, $t4,16720
li $t5,0x90dbff
sw $t5, 0($t3)
addi $t3, $t4,16724
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,16756
li $t5,0x3a90db
sw $t5, 0($t3)
addi $t3, $t4,16760
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,16768
li $t5,0x00003a
sw $t5, 0($t3)
addi $t3, $t4,16772
li $t5,0x90dbdb
sw $t5, 0($t3)
addi $t3, $t4,16776
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,16780
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,16784
li $t5,0xb6ffff
sw $t5, 0($t3)
addi $t3, $t4,16788
li $t5,0xffffdb
sw $t5, 0($t3)
addi $t3, $t4,16792
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,16804
li $t5,0x3a90db
sw $t5, 0($t3)
addi $t3, $t4,16808
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,16976
li $t5,0x66b6ff
sw $t5, 0($t3)
addi $t3, $t4,16980
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,16992
li $t5,0x003a66
sw $t5, 0($t3)
addi $t3, $t4,16996
li $t5,0xb6b666
sw $t5, 0($t3)
addi $t3, $t4,17000
li $t5,0x3a0000
sw $t5, 0($t3)
addi $t3, $t4,17008
li $t5,0x00003a
sw $t5, 0($t3)
addi $t3, $t4,17012
li $t5,0x90dbff
sw $t5, 0($t3)
addi $t3, $t4,17016
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,17024
li $t5,0x00003a
sw $t5, 0($t3)
addi $t3, $t4,17028
li $t5,0x90dbdb
sw $t5, 0($t3)
addi $t3, $t4,17032
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,17036
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,17040
li $t5,0xb6ffb6
sw $t5, 0($t3)
addi $t3, $t4,17044
li $t5,0x9090db
sw $t5, 0($t3)
addi $t3, $t4,17048
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,17060
li $t5,0x3a90db
sw $t5, 0($t3)
addi $t3, $t4,17064
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,17232
li $t5,0x0066b6
sw $t5, 0($t3)
addi $t3, $t4,17236
li $t5,0xffffb6
sw $t5, 0($t3)
addi $t3, $t4,17240
li $t5,0x660000
sw $t5, 0($t3)
addi $t3, $t4,17248
li $t5,0x66b6ff
sw $t5, 0($t3)
addi $t3, $t4,17252
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,17256
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,17264
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,17268
li $t5,0xdbffdb
sw $t5, 0($t3)
addi $t3, $t4,17272
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,17280
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,17284
li $t5,0xb6ffdb
sw $t5, 0($t3)
addi $t3, $t4,17288
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,17292
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,17296
li $t5,0xb6ffdb
sw $t5, 0($t3)
addi $t3, $t4,17300
li $t5,0x903a66
sw $t5, 0($t3)
addi $t3, $t4,17304
li $t5,0xb6ffff
sw $t5, 0($t3)
addi $t3, $t4,17308
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,17316
li $t5,0x3a90db
sw $t5, 0($t3)
addi $t3, $t4,17320
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,17488
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,17492
li $t5,0xdbffdb
sw $t5, 0($t3)
addi $t3, $t4,17496
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,17500
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,17504
li $t5,0xdbffff
sw $t5, 0($t3)
addi $t3, $t4,17508
li $t5,0xdbdbdb
sw $t5, 0($t3)
addi $t3, $t4,17512
li $t5,0xffdb90
sw $t5, 0($t3)
addi $t3, $t4,17516
li $t5,0x3a0000
sw $t5, 0($t3)
addi $t3, $t4,17520
li $t5,0x3a90db
sw $t5, 0($t3)
addi $t3, $t4,17524
li $t5,0xffdb90
sw $t5, 0($t3)
addi $t3, $t4,17528
li $t5,0x3a0000
sw $t5, 0($t3)
addi $t3, $t4,17536
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,17540
li $t5,0xb6ffdb
sw $t5, 0($t3)
addi $t3, $t4,17544
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,17548
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,17552
li $t5,0xb6ffdb
sw $t5, 0($t3)
addi $t3, $t4,17556
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,17560
li $t5,0x3a90db
sw $t5, 0($t3)
addi $t3, $t4,17564
li $t5,0xffdb90
sw $t5, 0($t3)
addi $t3, $t4,17568
li $t5,0x3a0000
sw $t5, 0($t3)
addi $t3, $t4,17572
li $t5,0x3a90db
sw $t5, 0($t3)
addi $t3, $t4,17576
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,17744
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,17748
li $t5,0xb6ffff
sw $t5, 0($t3)
addi $t3, $t4,17752
li $t5,0xdb903a
sw $t5, 0($t3)
addi $t3, $t4,17756
li $t5,0x66b6ff
sw $t5, 0($t3)
addi $t3, $t4,17760
li $t5,0xffffb6
sw $t5, 0($t3)
addi $t3, $t4,17764
li $t5,0x663a90
sw $t5, 0($t3)
addi $t3, $t4,17768
li $t5,0xdbffff
sw $t5, 0($t3)
addi $t3, $t4,17772
li $t5,0xb6663a
sw $t5, 0($t3)
addi $t3, $t4,17776
li $t5,0x90dbff
sw $t5, 0($t3)
addi $t3, $t4,17780
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,17792
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,17796
li $t5,0xb6ffdb
sw $t5, 0($t3)
addi $t3, $t4,17800
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,17804
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,17808
li $t5,0xb6ffdb
sw $t5, 0($t3)
addi $t3, $t4,17812
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,17816
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,17820
li $t5,0xb6ffff
sw $t5, 0($t3)
addi $t3, $t4,17824
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,17828
li $t5,0x66b6ff
sw $t5, 0($t3)
addi $t3, $t4,17832
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,18004
li $t5,0x66b6ff
sw $t5, 0($t3)
addi $t3, $t4,18008
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,18012
sw $t5, 0($t3)
addi $t3, $t4,18016
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,18020
li $t5,0x00003a
sw $t5, 0($t3)
addi $t3, $t4,18024
li $t5,0x90dbff
sw $t5, 0($t3)
addi $t3, $t4,18028
li $t5,0xffdbdb
sw $t5, 0($t3)
addi $t3, $t4,18032
li $t5,0xdbffff
sw $t5, 0($t3)
addi $t3, $t4,18036
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,18048
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,18052
li $t5,0xb6ffdb
sw $t5, 0($t3)
addi $t3, $t4,18056
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,18060
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,18064
li $t5,0xb6ffff
sw $t5, 0($t3)
addi $t3, $t4,18068
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,18076
li $t5,0x3a90db
sw $t5, 0($t3)
addi $t3, $t4,18080
li $t5,0xffdb90
sw $t5, 0($t3)
addi $t3, $t4,18084
li $t5,0x90b6ff
sw $t5, 0($t3)
addi $t3, $t4,18088
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,18260
li $t5,0x3a90db
sw $t5, 0($t3)
addi $t3, $t4,18264
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,18268
li $t5,0xffffdb
sw $t5, 0($t3)
addi $t3, $t4,18272
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,18280
li $t5,0x3a90db
sw $t5, 0($t3)
addi $t3, $t4,18284
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,18288
li $t5,0xffffdb
sw $t5, 0($t3)
addi $t3, $t4,18292
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,18304
li $t5,0x000066
sw $t5, 0($t3)
addi $t3, $t4,18308
li $t5,0xb6ffdb
sw $t5, 0($t3)
addi $t3, $t4,18312
li $t5,0x903a00
sw $t5, 0($t3)
addi $t3, $t4,18316
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,18320
li $t5,0xdbffff
sw $t5, 0($t3)
addi $t3, $t4,18324
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,18332
li $t5,0x00003a
sw $t5, 0($t3)
addi $t3, $t4,18336
li $t5,0x90dbff
sw $t5, 0($t3)
addi $t3, $t4,18340
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,18344
li $t5,0xffb666
sw $t5, 0($t3)
addi $t3, $t4,18516
li $t5,0x0066b6
sw $t5, 0($t3)
addi $t3, $t4,18520
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,18524
li $t5,0xffdb90
sw $t5, 0($t3)
addi $t3, $t4,18528
li $t5,0x3a0000
sw $t5, 0($t3)
addi $t3, $t4,18536
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,18540
li $t5,0xdbffff
sw $t5, 0($t3)
addi $t3, $t4,18544
li $t5,0xffdb90
sw $t5, 0($t3)
addi $t3, $t4,18548
li $t5,0x3a0000
sw $t5, 0($t3)
addi $t3, $t4,18560
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,18564
li $t5,0xdbffff
sw $t5, 0($t3)
addi $t3, $t4,18568
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,18572
li $t5,0x003a90
sw $t5, 0($t3)
addi $t3, $t4,18576
li $t5,0xdbffff
sw $t5, 0($t3)
addi $t3, $t4,18580
li $t5,0xb66600
sw $t5, 0($t3)
addi $t3, $t4,18592
li $t5,0x0066b6
sw $t5, 0($t3)
addi $t3, $t4,18596
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4,18600
li $t5,0xffb666
sw $t5, 0($t3)

jr $ra
DashHelper:
li $t0 1
sw $t0 IsDashing
li $t0 DashTime
sw $t0 DashTimeCounter
sw $zero CanDash
bltz PLAYER_X_VEL NEG_VEL_X
bgtz PLAYER_X_VEL POS_VEL_X
NEG_VEL_X:
	li PLAYER_DIRECTION LEFT
	j EndofHandleInput
POS_VEL_X:
	li PLAYER_DIRECTION RIGHT
	j EndofHandleInput

