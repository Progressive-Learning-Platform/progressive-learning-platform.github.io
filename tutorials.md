---
title: Tutorials
layout: main
---
<head>
    <title>{{ page.title }}</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <script src="{{site.baseurl}}/js/vendor/modernizr.js"></script>
</head>

<div class="hide-for-small-only">
    <div class="medium-3 columns">
	<div class="panel">

	
<!-- NOTE: the following block must not be indented or it isn't properly recognized as markdown -->
<div markdown="1">

<h3 class="noanchor"> Table of Contents </h3>
{:.no_toc}

1. TOC
{:toc}

</div>
<!-- END OF MARKDOWN BLOCK -->


        </div>
    </div>
</div>

<div class="row">
	<div class="small-12 medium-9 columns end">
		<div markdown="1">

<div style="display: none;"> <!-- this is just test code, it will not affect anything --!>
    <ul class="toctest">
        <li>Item</li>
        <li>Item 2</li>
    </ul>
</div>

<div class="tocplace"></div>

# Tutorials #

This section contains example PLP programs along with explainations about how they work and how they were written. Everything in this section is a 
work in progress so if something appears to be missing or doesn't make sense, feel free to post on the [PLP Google Group Forum](https://groups.google.com/forum/#!forum/progressive-learning-platform).

This is being updated in version 2 of the PLP Manual

## Seven Segment Scroll ##
{:.ancs}

This program loops through a [lookup table]({{site.baseurl}}/secret.html#lookup-table) of number encodings for a seven segment display and uses shifts to create a scrolling effect

<pre><code class="language-plp" id="clipboard-content-ssegscroll-ex">
.org 0x10000000

# DESCRIPTION:
# This program loops through a lookup table of number encodings for a seven
# segment display and uses shifts to create a scrolling effect

# Initializations
li $s0, 0xf0a00000	# Seven segment display address
li $s1, 20		# Used for branch comparison
li $t1, 0xffffffff	# Value written to seven segment display

main:
	li $t0, 0		# Counter
	li $sp, SSEG_LUT		# Lookup table address
	loop:
		lw $t2, 0($sp)		# Read value from lookup table
		sll $t1, $t1, 8		# Shift digit encodings left 1 byte (8 bits)
		or $t1, $t1, $t2	# Set least significant digit to value from lookup table
		sw $t1, 0($s0)		# Set value on seven segment display
		addiu $t0, $t0, 1	# Increment counter
		addiu $sp, $sp, 4	# Increase address by 1 word (4 bytes)
		bne $t0, $s1, loop	# Return to loop label if $t0 != $s1
		nop
	j main
	nop

# Seven segment display lookup table
SSEG_LUT:
.word 	0xc0	# 0
.word	0xf9	# 1
.word	0xa4	# 2
.word	0xb0	# 3
.word	0x99	# 4
.word	0x92	# 5
.word	0x82	# 6
.word	0xf8	# 7
.word	0x80	# 8
.word	0x90	# 9
.word	0x88	# a
.word	0x83	# b
.word	0xc6	# c
.word	0xa1	# d
.word	0x86	# e
.word	0x8e	# f
.word	0xff	# All segments off
.word	0xff	# All segments off
.word	0xff	# All segments off
.word	0xff	# All segments off
</code></pre>
<button title="Note: clipboard access is not available on all platforms, results may vary." id="clipboard-button-ssegscroll-ex" class="tiny copy-button" data-clipboard-target="clipboard-content-ssegscroll-ex">Copy to clipboard</button>
<a href="{{site.baseurl}}/resources/plp-um-sseg_scroll.plp" download="sseg-scroll.plp"><button type="button" class="tiny button secondary">Download</button></a>

<p class="panel show-for-touch">Note: clipboard access is not available on all platforms, reesults may vary.</p>

[Back to the top](#top)


## Switches to Seven Segment Display ##
{:.ancs}

This program reads the first 4 switches and uses a lookup table to convert the value to a encodings to be shown on a seven segment display

<pre><code class="language-plp" id="clipboard-content-swtosseg-ex">
.org 0x10000000

# DESCRIPTION:
# This program reads the first 4 switches and uses a lookup table to 
# convert the value to a encodings to be shown on a seven segment display

# Initializations
li $s0, 0xf0a00000	# Seven segment display address
li $s1, 0xf0100000	# Switch address

main:
	li $t0, 0		# Counter
	li $t1, 0xffffff00	# Value written to seven segment display
	li $t2, SSEG_LUT	# Lookup Table (LUT) address 
	lw $t3, 0($s1)	# Read value from switches
	andi $t3, $t3, 0xf	# Mask least significant 4 bits
	sll $t3, $t3, 2	# Multiply switch value by 2^2 to get LUT address offset
	addu $t3, $t3, $t2	# Add offset to LUT address
	lw $t4, 0($t3)	# Read value from lookup table
	or $t1, $t1, $t4	# Set least significant digit to value from lookup table
	sw $t1, 0($s0)	# Set value on seven segment display
	j main
	nop

# Seven segment display lookup table
SSEG_LUT:
.word 	0xc0	# 0
.word	0xf9	# 1
.word	0xa4	# 2
.word	0xb0	# 3
.word	0x99	# 4
.word	0x92	# 5
.word	0x82	# 6
.word	0xf8	# 7
.word	0x80	# 8
.word	0x90	# 9
.word	0x88	# a
.word	0x83	# b
.word	0xc6	# c
.word	0xa1	# d
.word	0x86	# e
.word	0x8e	# f
.word	0xff	# All segments off
</code></pre>
<button title="Note: clipboard access is not available on all platforms, results may vary." id="clipboard-button-swtosseg-ex" class="tiny copy-button" data-clipboard-target="clipboard-content-swtosseg-ex">Copy to clipboard</button>
<a href="{{site.baseurl}}/resources/plp-um-switch_to_sseg.plp" download="switch-to-sseg.plp"><button type="button" class="tiny button secondary">Download</button></a>

<p class="panel show-for-touch">Note: clipboard access is not available on all platforms, results may vary.</p>


[Back to the top](#top)


## Switches Two's Compliment ##
{:.ancs}

This program reads the switches and treats their value as a 1 byte (8 bit), 2's compliment value.  It converts this value into a signed hexadecimal output for the seven segment display.

<pre><code class="language-plp" id="clipboard-content-swtwos-ex">
.org 0x10000000

# DESCRIPTION:
# This program reads the switches and treats their value as a 1 byte (8 bit), 2's compliment
# value.  It converts this value into a signed hexadecimal output for the seven segment display.

# NOTE: 	In order to reduce the delay before the result is updated on the display, increase
#	the cycles per step to 20 while in simulation mode (Simulation -> Cycles/Step).

# Initializations
li $s0, 0xf0a00000	# Seven segment display address
li $s1, 0xf0100000	# Switch address
li $s2, SSEG_LUT	# Lookup Table (LUT) address
li $sp , 0x10fffffc	# Set stack pointer to last address in RAM

# Main loop
main:
	# Store address of next instruction in $ra (Return Address) and jump to label
	jal convert_to_twos_compliment
	nop
	jal display_result
	nop
	j main
	nop


# Function: Reads switch value, convert's from 2's compliment to magnitude and sign
#	Input:  	none
#	Output:	$a0 = sign bit
#		$a1 = magnitude
convert_to_twos_compliment:
	lw $a1, 0($s1)	# Read value from switches
	andi $a0, $a1, 0x80	# Mask for 2's compliment sign bit
	
	# If value is negative, convert from 2's compliment
	beq $a0, $0, is_positive	# if sign bit was not set, branch to "is_positive" label
		nop
		nor $a1 , $a1 , $a1	# NOT (invert) all bits
		addiu $a1 , $a1 , 1	# Add 1
	is_positive:
	jr $ra		# Jump to address stored in $ra
	nop


# Function: Display converted value on seven segment display
#	Input: 	$a0 = sign bit
#		$a1 = magnitude
#	Output:	none
display_result:
	push $ra		# Save return address by pushing to stack
	li $t1, 0xFFFFBF00	# Value for 7-seg with upper 3 digits set to "  -"

	# If sign bit is 0 (value is positive), jump to label
	bne $a0, $0, display_negative
		nop
		ori $t1, $t1, 0xFF00	# remove negative sign
	display_negative:
	andi $a0, $a1, 0xF0	# Mask second least significant digit

	# If the second least significant digit is 0, leave blank and do not convert
	beq $a0, $0, second_digit_blank
		srl $a0, $a0, 4	# Shift right to least significant digit position for conversion
		jal convert_hex_digit	# Call function to convert to 7-seg encoding
		nop
		or $t1, $t1, $v0	# Set second least significant digit
		sll $t1, $t1, 8	# Shift encoded result by one byte 
	second_digit_blank:
	andi $a0, $a1, 0xF	# Mask least significant digit
	jal convert_hex_digit	# Call function to convert to 7-seg encoding
	nop
	or $t1, $t1, $v0	# Set least significant digit
	sw $t1, 0($s0)	# Set 7-segment display to result
	pop $ra		# Restore return address by popping it from stack
	jr $ra		# Jump to address stored in $ra
	nop


# Function: Convert's 4 bits from hex to 7-segment encoding
#	Input: 	$a0 = 4 bit hex value
#	Output:	$v0 = 8 bit 7 segment display encoding
convert_hex_digit:
	sll $a0, $a0, 2	# Multiply value by 2^2 to get LUT address offset
	addu $t0, $a0, $s2	# Add offset to LUT address
	lw $v0, 0($t0)	# Read value from lookup table
	jr $ra		# Jump to address stored in $ra
	nop

# Seven segment display lookup table
SSEG_LUT:
.word 	0xc0	# 0
.word	0xf9	# 1
.word	0xa4	# 2
.word	0xb0	# 3
.word	0x99	# 4
.word	0x92	# 5
.word	0x82	# 6
.word	0xf8	# 7
.word	0x80	# 8
.word	0x90	# 9
.word	0x88	# a
.word	0x83	# b
.word	0xc6	# c
.word	0xa1	# d
.word	0x86	# e
.word	0x8e	# f
</code></pre>
<button title="Note: clipboard access is not available on all platforms, results may vary." id="clipboard-button-swtwos-ex" class="tiny copy-button" data-clipboard-target="clipboard-content-swtwos-ex">Copy to clipboard</button>
<a href="{{site.baseurl}}/resources/plp-um-switch_twos_comp.plp" download="switch-twos-comp.plp"><button type="button" class="tiny button secondary">Download</button></a>

<p class="panel show-for-touch">Note: clipboard access is not available on all platforms, results may vary.</p>

[Back to the top](#top)


## 4 byte Switch Input Two's Compliment ##
{:.ancs}

This program is more complicated than the above examples. In this program, the user will enter a 4 byte number by using the Switches one byte at a time. The resulting value will be display on the Seven Segment Display as it is being entered. It will then negate the value via Two's Compliment, and display the final result on the Seven Segment Display.

<a href="{{site.baseurl}}/resources/plp-um-twoscomp.plp" download="twos-comp.plp"><button type="button" class="tiny button secondary">Download</button></a>

[Back to the top](#top)

</div>
</div>
</div>
