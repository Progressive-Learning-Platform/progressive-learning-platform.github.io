# main source file

.org 0x10000000

# The Example That Ties Everything Together
# A PLPTool Two's Complement Converter
# Give it a number, and PLPTool will negate it and display the result on the seven segment display

# using LEDs and Switches, input 4 byte/1 word number
# because switches and LEDs are only 1 byte a piece, use 4 iterations
# use LEDs to track progress of bytes, similarly to the calculator
 
main:
#SCOPE: $s0 is memory of switches
    li $s0 , 0xf0100000 # load memory address for Switches
#SCOPE: $s1 is memory for LEDs
    li $s1 , 0xf0200000 # load memory address for LEDs
#SCOPE: $s2 is memory for SSEG
    li $s2 , 0xf0a00000 # load memory address for SSeg
#SCOPE: $sp is stack pointer
    li $sp , 0x10fffffc # load stack pointer to top of RAM

#SCOPE: $t0 used as LED designator
    li $t0 , 0b1000
#SCOPE: $t3 used as SSEG display
    li $t3 , 0xFFFFFFFF # load all 1s into $t3 for sseg displaying

inp-loop:
# $t1 is the value of the inputted byte
# $t2 is the current total value
# $t4 is the temp shift dest
# $t5 is the two's compliment value
    sw $t0 , 0($s1) # store the value of $t0 into the LEDs, designates which byte we are working on

#SCOPE: $t1 used as value of switches(current byte)
    lw $t1 , 0($s0) # load the value of the switches, current byte

# set the new total value
#SCOPE: $t2 used as total value
    sll $t2 , $t2 , 8   # shift current value left by 8, make space for new byte
    or $t2 , $t2 , $t1  # combine current value with new byte via or

# code the top 4 bits of the inputted byte
#SCOPE: $t4 used as shift destination
    srl $t4 , $t1 , 4   # shift the inputted byte to remove half
    jal sseg-conv   # jump/call the sseg conversion protocol
    move $a0 , $t4  # use the branch delay slot to load $t4 into $a0
#SCOPE: $t4 now unused
    sll $t3 , $t3 , 8   # shift the current sseg code left by 8, make room for a new byte
    or $t3 , $t3 , $v0  # combine new sseg code with current sseg code

# code the bottom 4 bits of the inputted byte
    jal sseg-conv   # call the sseg conversion protocol
    move $a0, $t1   # use branch delay slot to move current inputted byte into $a0
#SCOPE: $t1 now unused
    sll $t3 , $t3 , 8   # shift current sseg code left by 8
    or $t3 , $t3 , $v0  # combine new sseg code with current sseg code

# 
    sw $t3 , 0($s2) # store the current sseg code into the sseg
    srl $t0 , $t0 , 1   # move the indicator bit right one
    beq $t0 , $0 , inp-loop-end # if 0, end the loop
    nop # nop in branch delay slot
    j inp-loop  # else, jump to top of loop
    nop # nop in branch delay slot

inp-loop-end:
    ori $t0 , $0 , 0b111111111   # set byte designator to all 1's
    sw $t0 , 0($s1) # store value into LEDs

twos-comp:
#SCOPE: $t1 now used as two's compliment dest
    nor $t1 , $t2 , $t2 # the process of two's compliment
    addiu $t1 , $t1 , 1 # the process of two's compliment

    ori $t0 , $0 , 0b10101010   # set the byte desinator to a patter: finished with calculation
    sw $t0 , 0($s1) # store value into LEDs

    li $t3 , 0xFFFFFFFF # set sseg to all 1's, disabling all the segments
    sw $t3 , 0($s2) # store sseg code into the sseg
    

    ori $t0 , $0 , 0b111100000000 # load display code into the LEDs
    sw $t0 , 0($s1) # store into the LEDs
#SCOPE: $t4 used as shift amount holder
    ori $t4 , $0 , 32 # load the shift amount for lower calculations
#SCOPE: $t6 used as LED expected value
    ori $t6 , $0 , 0b1111   # load the final value for shifting LED code

disp-loop:

    addiu $t4 , $t4 , -4    # subtract 4 from the shifting amount
#SCOPE: $t5 now used as temp dest of shifted value
    srlv $t5 , $t1 , $t4    # shift current two's complement value by shift amount to convert via sseg

    jal sseg-conv # jump to sseg-conv to conver into sseg code
    move $a0 , $t5  # move $t5 into a0(used for sseg-conv)

    sll $t3, $t3 , 8    # shift sseg code over 8 bits left
    or $t3 , $t3 , $v0  # or sseg code with result from sseg-conv
    sw $t3 , 0($s2) # store sseg code into memory of sseg

    srl $t0 , $t0 , 1   # shift indicator bits left once
    sw $t0 , 0($s1) # store into LEDs

    beq $t6 , $t0 , end # if the LEDs are set to 1111, jump to end
    nop # nop in branch delay slot

    j disp-loop # jump to top of loop
    nop # nop in branch delay slot


end:
    j end
    nop

# START SSEG-CONV
# Seven Segment Hex Converter
#	takes in hex number(4 bits) and returns the sseg code
#	$a0 is the hex number
#	$v0 is the sseg cod
#   overwrites:
#       $t9
#       $t8
sseg-conv:
	andi $a0 , $a0 , 0x0000000F	# force $a0 to be only 4 bits
	ori $t8 , $0 , 1	# load 1 into $t8
	or $t9 , $0 , $0	# load 0 into $t9

	beq $a0 , $t9 , sseg-zero	# if $a0(our parameter) is zero, jump to zero label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-one	# if $a0(our parameter) is zero, jump to one label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-two	# if $a0(our parameter) is zero, jump to two label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-three	# if $a0(our parameter) is zero, jump to three label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-four	# if $a0(our parameter) is zero, jump to four label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-five	# if $a0(our parameter) is zero, jump to five label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-six	# if $a0(our parameter) is zero, jump to six label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-seven	# if $a0(our parameter) is zero, jump to seven label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-eight	# if $a0(our parameter) is zero, jump to eight label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-nine	# if $a0(our parameter) is zero, jump to nine label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-a	# if $a0(our parameter) is zero, jump to a label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-b	# if $a0(our parameter) is zero, jump to b label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-c	# if $a0(our parameter) is zero, jump to c label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-d	# if $a0(our parameter) is zero, jump to d label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-e	# if $a0(our parameter) is zero, jump to e label
	addu $t9 , $t9 , $t8	# increment $t9 by one in the branch delay slot, improves performance over time
	beq $a0 , $t9 , sseg-f	# if $a0(our parameter) is zero, jump to f label
	nop	# final jump does not need to increment
	
	# this code will only get accessed if the number fails(should not happen, ever)
	or $v0 , $0 , $0	# load 0 into $v0
	jr $ra
	nop

sseg-zero:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b11000000	# sseg code for 0 character, using branch delay slot for max efficiency

sseg-one:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b11111001	# sseg code for 1 character, using branch delay slot for max efficiency

sseg-two:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b10100100	# sseg code for 2 character, using branch delay slot for max efficiency

sseg-three:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b10110000	# sseg code for 3 character, using branch delay slot for max efficiency

sseg-four:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b10011001	# sseg code for 4 character, using branch delay slot for max efficiency

sseg-five:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b10010010	# sseg code for 5 character, using branch delay slot for max efficiency

sseg-six:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b10000010	# sseg code for 6 character, using branch delay slot for max efficiency

sseg-seven:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b11111000	# sseg code for 7 character, using branch delay slot for max efficiency

sseg-eight:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b10000000	# sseg code for 8 character, using branch delay slot for max efficiency

sseg-nine:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b10010000	# sseg code for 9 character, using branch delay slot for max efficiency

sseg-a:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b10001000	# sseg code for a character, using branch delay slot for max efficiency

sseg-b:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b10000011	# sseg code for b character, using branch delay slot for max efficiency

sseg-c:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b11000110	# sseg code for c character, using branch delay slot for max efficiency

sseg-d:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b10100001	# sseg code for d character, using branch delay slot for max efficiency

sseg-e:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b10000110	# sseg code for e character, using branch delay slot for max efficiency

sseg-f:
	jr $ra	# jump to $ra(will have last position in program)
	ori $v0 , $0 , 0b10001110	# sseg code for f character, using branch delay slot for max efficiency
# END of SSEG-CONV
