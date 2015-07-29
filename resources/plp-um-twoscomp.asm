# main source file

.org 0x10000000

# The Example That Ties Everything Together
# A PLPTool Two's Complement Converter
# Give it a number, and PLPTool will negate it and display the result on the seven segment display

# using LEDs and Switches, input 4 byte/1 word number
# because switches and LEDs are only 1 byte a piece, use 4 iterations
# use LEDs to track progress of bytes, similarly to the calculator
 
main:
    li $s0 , 0xf0100000 # use $s0 to store the memory address for Switches
    li $s1 , 0xf0200000 # use $s1 to store the memory address for the LEDs
    li $s2 , 0xf0a00000 # use $s2 to store the memory address for the Seven Segment Displays
    li $sp , 0x10fffffc # load the top of RAM into the stack pointer

    li $t0 , 0b1000     # use $t0 with the LEDs for byte input indicator
    li $t3 , 0xFFFFFFFF # clear the sseg value(1 is off for the sseg)

inp-loop:
# $t1 is the value of the inputted byte
# $t2 is the current total value
# $t4 is the temp shift dest
# $t5 is the two's compliment value

# put a breakpoint on the line below for best results
    sw $t0 , 0($s1) # display the indicator value on the LEDs
#   $t0 --> memory

    lw $t1 , 0($s0) # get the current value of the switches, the current inputted byte from the user
#   $t1 <-- memory

# set the new total value by combining the old total with the inputted byte
    sll $t2 , $t2 , 8   # move old vale over to make room for the new byte
    or $t2 , $t2 , $t1  # combine the old value and the new byte

# turn the top half of the inputted byte into sseg code to display it
    srl $t4 , $t1 , 4   # get the top 4 bits by shifting right
    jal sseg-conv   # use the branch delay slot to se the proper sseg-conv arguments
    move $a0 , $t4  # and then jump and link to sseg-conv so we can come back using $ra

# store the sseg coded top 4 bits
    sll $t3 , $t3 , 8   # make room for the new sseg code
    or $t3 , $t3 , $v0  # combine new sseg code with current sseg code

# turn the remaining 4 bits into sseg code to display it
    jal sseg-conv   # use the branch delay slot to set the proper arguments for sseg-conv
    move $a0, $t1   # and jal to sseg-conv so we can come back via $ra

# store the sseg coded bottom 4 bits
    sll $t3 , $t3 , 8   # move the current sseg code over to make room for new sseg code
    or $t3 , $t3 , $v0  # combine new sseg code with current sseg code

    sw $t3 , 0($s2) # display the current sseg code on the sseg
#   $t3 --> memory
    srl $t0 , $t0 , 1   # update the LED indicator value

    beq $t0 , $0 , inp-loop-end # if the indicator value is 0, jump the inp-loop-end
    nop # nop in branch delay slot
    
    j inp-loop  # else, jump to top of loop
    nop # nop in branch delay slot

inp-loop-end:   # when the loop is done, we have a final value
    ori $t0 , $0 , 0b111111111   # set the indicator value to all be on, signaling we are done with input
    sw $t0 , 0($s1) # display the indicator value on the LEDs
#   $t0 --> memory

twos-comp:  # the actually two's compliment calculation
    nor $t1 , $t2 , $t2 # invert(NOT) the current value
    addiu $t1 , $t1 , 1 # add one

    li $t3 , 0xFFFFFFFF # clear the sseg value(1 is off for sseg)
    sw $t3 , 0($s2) # clear the sseg
#   $t3 --> memory

    ori $t0 , $0 , 0b111100000000   # use LEDs as an indicator for which bytes are being shown
    sw $t0 , 0($s1) # display value on the LEDs
#   $t0 --> memory

# the LEDs for this next part will show which bits are being display on the sseg by scrolling across
# since the sseg can only show 4 hex digits, or 2 bytes at a time, we have to be a little creative in how we display the number
# if an LED is lit up, then that 4 bit number is being disaply, at most showing 4 sets

    ori $t4 , $0 , 32 # prime this number for shifting later below
    ori $t6 , $0 , 0b1111   # this is the number we will reach with our indicator when done

disp-loop:

    addiu $t4 , $t4 , -4    # subtract 4 from the shifting amount
# by doing this step first, we avoid errors at the end of our final loop
# we subtract 4 because the sseg can display 4 bits at a time

    srlv $t5 , $t1 , $t4    # shift current two's complement value by shift amount to convert via sseg

    jal sseg-conv # jump to sseg-conv to conver into sseg code
    move $a0 , $t5  # move $t5 into a0(used for sseg-conv)

    sll $t3, $t3 , 8    # shift sseg code over 8 bits left
    or $t3 , $t3 , $v0  # or sseg code with result from sseg-conv
    sw $t3 , 0($s2) # store sseg code into memory of sseg
#   $t3 --> memory

    srl $t0 , $t0 , 1   # shift indicator bits left once

# put a breakpoint on the line below for best results
    sw $t0 , 0($s1) # store into LEDs
#   $t0 --> memory

    beq $t6 , $t0 , end # if the LEDs are set to 1111, jump to end
    nop # nop in branch delay slot

    j disp-loop # jump to top of loop
    nop # nop in branch delay slot


end:
    j end
    nop

# START SSEG-CONV
# Seven Segment Hex Converter
#	input: $a0(4 bit number)
#	output: $v0(sseg code)
#   overwrites:
#       $t9
#       $t8
sseg-conv:
	andi $a0 , $a0 , 0x0000000F	# force $a0 to be only 4 bits(bit masking)
	ori $t8 , $0 , 1	# store 1 used for later addition
	or $t9 , $0 , $0	# clear $t9

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
	or $v0 , $0 , $0	# clear $v0
	jr $ra  # return to where we were when we jal to sseg-conv by using $ra(return address)
	nop # nop in branch delay slot

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
