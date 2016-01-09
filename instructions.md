---
title: ISA, Syntax, & I/O
layout: main
---

<div class="show-for-medium-up" style="display: none">
    <div class="medium-3 columns">
	<div class="panel">

	
<!-- NOTE: the following block must not be indented or it isn't properly recognized as markdown -->

<h3 class="noanchor"> Table of Contents </h3>

<div markdown="1" class="toc">

1. TOC
{:toc}

</div>
<!-- END OF MARKDOWN BLOCK -->


        </div>
    </div>
</div>

<div class="medium-9 columns my-content" markdown="1">
<div class="ancs" id="top"></div>

# Instruction Set and Assembly Language #
{:.no_toc}
{:.ancs}

This section describes all the instructions and pseudo-instructions supported by the PLP system.  It also gives examples on how to use each instruction and notes on any limitations.


## Comments ##
{:.ancs}

Comments may appear anywhere in the program's code, including on label, instruction, and directive lines.

To use a comment, type `#` before your comment.  All text after the `#` until the end of the line is ignored by the assembler.

  * For example, if you wanted to put a comment on a blank line as well as a instruction line, the code would be:

<pre><code class="language-plp">
# This is the first comment 
addu $s0, $s0, $s1	# This is the second comment
</code></pre>

_Note:_ Comments are very helpful for debugging and helping others who read the code to understand what a certain segment of code is supposed to do.

[Back to the top](#top)


## Values ##
{:.ancs}

Some instructions require a value to be given.  PLPTool will accept values in 4 formats: binary (base 2), decimal (base 10), hexadecimal (base 16), and ASCII (converts from ascii encoding to a value). The representation is indicated using a prefix before the value.


| Representation	| Format					| Sample Usage	| Notes			|
| :---------------- | :------------------------ | :------------ | :------------ |
| Binary			| `0b`&lt;value&gt;			| 0b10110		| Binary values can only contain 1's and 0's	|
| Decimal			| &lt;value&gt;				| 1975			| A negative value can be represented by including a `-` symbol before the value. The value will be represented in two's complement |
| Hexadecimal		| `0x`&lt;value&gt;			| 0xfc10		| The prefix, `0h`, can also be used for hexadecimal values	|
| ASCII				| `'`&lt;character&gt;`'`	| 'a'			| ASCII strings (more than one ASCII character) can only be used with [assembler directives](#data-and-string-allocation)	|


[Back to the top](#top)


## Symbols ##
{:.ancs}

This document uses the following symbols and expressions throughout, refer here if you come accross something that is not familiar.

* `=` - equals
* `+` - plus
* `-` - minus/subtract
* `*` - multiply
* `>>` - signed shift right
* `<<` - shift left
* `&` - bitwise AND
* `|` - bitwise OR
* `~` - inverse/bitwise NOT
* `val = (expr) ? tr : fl` - this is a simplified version of an if-then-else statement
    * if `(expr)` is true, then `val` is set to `tr`. if `(expr)` is false, then `val` is set to `fl`
* `<` - less than
* `==` - is equal to
* `!=` - is NOT equal to
* `SignExtend(val)` - take the value `val` and sign extend it to the required bit size(see [Signed & Unsigned]({{site.baseurl}}/secret.html#sign) for more info)
* `ZeroExtend(val)` - take the value `val` and zero extend it to the required bit size(see [Signed & Unsigned]({{site.baseurl}}/secret.html#sign) for more info)

[Back to the top](#top)


## Assembler Directives ##


### Memory Organization ###
{:.ancs}

In order to resolve branch and jump targets, the user must inform the assembler where program starts in memory before any instructions, labels, or includes are written/executed.

The format for this would be `.org` followed by the address in memory desired.  The address must be word aligned, meaning it must a 32-bit number that is a multiple of 4.

  * For example, to begin the program at the address 0x10000000, the code would be:

<pre><code class="language-plp">
.org 0x10000000
</code></pre>

_**IMPORTANT NOTE:**_ This must be the first non-comment line in the main source file.  It is possible, however, to have multiple .org statements throughout the program.

[Back to the top](#top)


### Data and String Allocation ###
{:.ancs}

There are three ways to allocate space for data with PLPTool:

  * A single word
  * Space in terms of numbers of words
  * A string

[Back to the top](#top)



#### Single Word Allocation ####
{:.ancs}

The `.word` directive allocates a single word with or without an initial value.  This is especially useful after a label for ease of access.

  * For example, to allocate a variable and initialize it to the value `4`, the code would be:

<pre><code class="language-plp">
.org 0x10000000

my_variable:
     .word 4

main:

    li $t0, my_variable     # get a pointer to my_variable
    lw $t1, 0($t0)          # $t1 has the value of my_variable (4) now
</code></pre>



[Back to the top](#top)


#### Space Allocation ####
{:.ancs}

PLPTool supports allocating space by taking the number of words to be allocated by using the `.space` directive, as opposed to a single word with the `.word` directive.

  * For example, to allocate a variable with a length of 2 words, the code would be:

<pre><code class="language-plp">
.org 0x10000000 

long_variable:
     .space 2  

main:

    li $t0, long_variable    # get a pointer to the variable
    lw $t1, 0($t0)           # get the first word
    lw $t2, 4($t0)           # get the second word
</code></pre>


[Back to the top](#top)



#### String Allocation ####
{:.ancs}

PLPTool supports three types of string allocation:

  * `.ascii`
    * This allocates a packed array of characters without a trailing null character (terminator) to indicate the end of the string.

For example, if you wanted to allocate a variable with a string using the `.ascii` directive, the code would be:

<pre><code class="language-plp">
my_string_ascii:
     .ascii "example string"  # no null terminator
</code></pre>


  * `.asciiz`
    * This allocates a packed array of characters with a trailing null character that indicates the end of the string.

For example, if you wanted to allocate a variable with a string using the `.asciiz` directive, the code would be:

<pre><code class="language-plp">
my_string_asciiz:
     .asciiz "example string" # null terminator inserted at end of string
</code></pre>


  * `.asciiw`
    * This allocates a word aligned array of characters with a trailing null character that indicates the end of the string.

For example, if you wanted to allocate a variable with a string using the `.asciiw` directive, the code would be:

<pre><code class="language-plp">
my_string_asciiw:
     .asciiw "example string" # word aligned, null terminator inserted at end of string
</code></pre>


_Note:_ PLPTool also supports escaping newline characters with **`\n`** .

[Back to the top](#top)

## Labels ##
{:.ancs}

Labels allow the programmer to use branch and jump instructions.  A label is used to mark sections of code within the program.

To implement a label, type the name of label you wish to use followed by a colon.

  * For example, to create a label called "main", the code would be:  

<pre><code class="language-plp">
.org 0x10000000

main:
    # PLP instructions here
</code></pre>

  * It is the standard convention to have the first label in a program titled "main".

_Note:_ It is possible to load a pointer to a label using the load immediate instruction `li`.

<pre><code class="language-plp">
.org 0x10000000

main: 
    # PLP instructions here

label2:
    li $t0 , main
</code></pre>

[Back to the top](#top)


## Operations ##
{:.ancs}

Below is the list of all operations within PLP, broken down into sections by their type. The syntax, an example, a representative expression, and any notes are provided. Hover over the operation to see the exapanded title.

### Arithmetic Operations ###
{:.ancs}

These operations allow for basic arithmetic, such as addition and subtraction, within PLP.<br/>
**IT SHOULD BE NOTED** that `addu`, `addiu`, and `subu` are mislabeled. The trailing `u` normally implies *unsigned*. However, all three of these operations are signed.

<div class="mobile" markdown="1">

| Syntax		| Expression			    | Sample Usage             | Notes				        |
| :-------------------- | :-------------------------------- | :--------------------    | :--------------------------------      |
| <span title="Add unsigned">`addu  $rd, $rs, $rt`</span>	| `rd = rs + rt;`		    | `addu  $v0, $a0, $a1`    | Unsigned addition(see above)		|
| <span title="Add immediate unsigned">`addiu $rd, $rs, imm`</span> | `rd = rs + SignExtend(imm);`      | `addiu $v0, $a0, 0xFEED` | Unsigned addition(see above), add $a0 with 65261  |
| <span title="Subtract unsigned">`subu  $rd, $rs, $rt`</span>	| `rd = rs - rt;`		    | `subu  $v0, $a0, $a1`    | Unsigned subtraction(see above)		        |
| <span title="Multiply, low order">`mullo $rd, $rs, $rt`</span>	| `rd = (rs * rt) & 0xFFFFFFFF;`    | `mullo $v0, $a0, $a1`    | Multiply (return low order bits)	|
| <span title="Multiply, high order">`mulhi $rd, $rs, $rt`</span>	| `rd = (rs * rt) >> 32;`	    | `mulhi $v0, $a0, $a1`    | Multiply (return high order bits)	|
| <span title="Load upper immediate">`lui $rt, imm`</span>        | `rt = imm << 16;`                 | `lui $a0, 0xFEED`        | Write 0xFEED0000 to $a0 register.      |
{:.mobile}

</div>

`$rd` is the destination register, where the resulting value will go.<br/>
`$rs` is the source registers: this is the value that the operation acts upon.<br/>
`$rt` is the target register: this is the value that the operation uses.<br/>
`imm` is a 16-bit integer that can be represented by any of the methods given by PLPTool.

It should be noted that `lui` is not used by itself very often.  Instead, `ori` is used in its place, or `lui` is used as part of the [psuedo-operation](#pseudo-operations) `li`.

_**IMPORTANT NOTE:**_ If `imm` is greater than 16 bits, the assembler will truncate the more significant bit positions beyond the sixteenth place. This means the maximum immediate value is 65535.


**Example**

<pre><code class="language-plp" id="clipboard-content-arith-ex">
# main source file

.org 0x10000000

# Arithmetic Examples
main:
# Load values to use
    li $t0 , 0b100	# loading 4 into $t0 using binary notation
    li $t1 , 0xF	# loading 15 into $t1 using hex notation
    li $t2 , 8		# loading 8 into $t2

# add
    addu $t3 , $t1 , $t0	# adds $t1(15) and $t0(4) and stores into $t3
    # result in $t3 is now 19
    addu $t3 , $t3 , $t2	# adds $t3(19) and $t2(8) and stores into $t3
    # note, you can use the same register for deistination, source, and target
    # result in $t3 is now 27
    addiu $t3 , $t3 , 3 # add an immediate value to $t3, making it 30, storing ing $t3
    addiu $t3 , $t3 , -10   # add a negative ten to $t3, store in $t3, now 20
    # note the lack of subiu, add handles both immediate value operations
    
# multiply
    mullo $t4 , $t3 , $t3	# multiply $t3(27) and $t3(27), store the LOWER 8 bytes(1 word)
    li $t0 , 65535	# load 65535 into $t0 (0xFFFF)
    li $t1 , 65535	# load 65535 into $t1 (0xFFFF)
    mullo $t2 , $t0 , $t1	# multiply $t0 and $t1, store LOWER word into $t2
    mulhi $t3 , $t0 , $t1	# multiply $t0 and $t1, store UPPER word into $t3
    # it should be noted that mullo and mulhi are deeply related
    # if the product of mullo overflows(is higher than you can represented with a signed integer), mulhi will return the sign bit, along with the rest of the bits
    # $t2 will have 4294836225(0xFFFE0001)
    # $t3 will have 0(0x00000000)
    #	NOTE: the most significant bit here is the sign bit(0) due to overflow
    # to read the whole number, stack the hex digits like so
    #	0x00000000 0xFFFE0001
    #	UPPER      LOWER
    #	0x00000000FFFE0001 (4294836225)
    #	TOTAL

    # another example, using negatives
    li $t0 , -45	# load a negative value(-45) into $t0
    li $t1 , 295	# load 295 into $t1
    mulhi $t3 , $t0 , $t1	# multiply $t0 and $t1, store HIGH order bits in $t3
    mullo $t2 , $t0 , $t1	# multiply $t0 and $t1, store LOW order bits in $t2
    
    # here, we get a negative result. since mullo and mulhi are SIGNED operations, the result will be represented in two's complement
    # $t2 will have 0xFFFFCC25(-13275)	this is the lower bits of the result, in two's complement
    # $t3 will have 0xFFFFFFFF(-1)		this is the higher bits of the result, in two's complements, this value is not used alone
    #	note that $t3 is all 1's(F is 1111 in decimal). these leading 1's do not modify the value of a negative number, just as leading 0's do not modify the value of a positive number
    # the final result would be 0xFFFFFFFFFFFFCC25(-13275)

    # one more example, with large numbers and a negative output
    li $t0 , 87578778	# load a large number into $t0	
    li $t1 , -87578778	# load a large negative number(small) into $t1
    mullo $t2 , $t0 , $t1	# multiply, low order bits
    mulhi $t2 , $t0 , $t1	# multiply, high order bits

    # here, the upper bits are neccessary to properly represent the value
    # $t2 will have 0x19F5C35C(435536732)	note how this is not negative by itself, it needs the upper bits to be complete
    # $t3 will have 0xFFE4C023(-1785821)	these two numbers, when combined, show the real result
    # 0xFFE4C02319F5C35C(-7670042355973284)	this is the real result

</code></pre>
<button title="Note: clipboard access is not available on all platforms, results may vary." id="clipboard-button-arith-ex" class="tiny copy-button" data-clipboard-target="clipboard-content-arith-ex">Copy to clipboard</button>

<p class="panel show-for-touch">Note: clipboard access is not available on all platforms, results may vary.</p>

[Back to the top](#top)


### Logical/Bitwise Operations ###
{:.ancs}

These operations allow for basic logical/bitwise operations, such as AND or OR, to be preformed on values and registers.

<div class="mobile" markdown="1">

| Syntax		| Expression			         | Sample Usage             | Notes				                        |
| :-------------------- | :--------------------------------      | :--------------------    | :--------------------------------                         |
| <span title="bitwise AND">`and   $rd, $rs, $rt`</span>	| `rd = rs & rt;`		         | `and   $v0, $a0, $a1`    | Bitwise logical AND		                        |
| <span title="bitwise AND immediate">`andi  $rd, $rs, imm`</span> | `rd = rs & ZeroExtend(imm);`           | `andi  $v0, $a0, 1337`   | Bitwise logical AND                                       |
| <span title="bitwise OR">`or    $rd, $rs, $rt`</span>	| `rd = rs | rt;`		         | `or    $v0, $a0, $a1`    | Bitwise logical OR		                        |
| <span title="bitwise OR immediate">`ori   $rd, $rs, imm`</span> | `rd = rs  |  ZeroExtend(imm);`         | `ori   $v0, $a0, 0x0539` | Bitwise logical OR                                        |
| <span title="bitwise NOR">`nor   $rd, $rs, $rt`</span>	| `rd = ~(rs | rt);`	                 | `nor   $v0, $a0, $a1`    | Bitwise logical NOR		                        |
| <span title="is less than">`slt   $rd, $rs, $rt`</span>	| `rd = (rs < rt) ? 1 : 0;`	         | `slt   $v0, $a0, $a1`    | Signed compare			                        |
| <span title="is less than immediate">`slti  $rd, $rs, imm`</span> | `rd = (rs < SignExtend(imm)) ? 1 : 0;` | `slti  $v0, $a0, 0xDEAD` | Signed compare                                            |
| <span title="is less than unsigned">`sltu  $rd, $rs, $rt`</span>	| `rd = (rs < rt) ? 1 : 0;`              | `sltu  $v0, $a0, $a1`    | Unsigned compare			                        |
| <span title="is less than immediate unsigned">`sltiu $rd, $rs, imm`</span> | `rd = (rs < SignExtend(imm)) ? 1 : 0;` | `sltiu $v0, $a0, 0xDEAD` | Unsigned compare                                          |
| <span title="shift left logical">`sll $rd, $rt, shamt`</span> | `rd = rt << shamt;`                    | `sll $v0, $a0, 0x12`     | Shift $a0 by 18 to the left and store the result in $v0   |
| <span title="shift left logical register">`sllv $rd, $rs, $rt`</span>  | `rd = rs << rt;`                       | `sllv $v0 , $a0 , $a1`   | Shift $a0 by $a1 to the left and store the result in $v0  |
| <span title="shift right logical">`srl $rd, $rt, shamt`</span> | `rd = rt >> shamt;`                    | `srl $v0, $a0, 18`       | Shift $a0 by 18 to the right and store the result in $v0  |
| <span title="shift right logical register">`srlv $rd, $rs, $rt`</span>  | `rd = rs >> rt;`                       | `srlv $v0 , $a0 , $a1`   | Shift $a0 by $a1 to the right and store the result in $v0 |
{:.mobile}

</div>

`$rd` is the destination register, where the resulting value will go.<br/>
`$rs` is the source registers: this is the value that the operation acts upon.<br/>
`$rt` is the target register: this is the value that the operation uses.<br/>
`imm` is a 16-bit integer that can be represented by any of the methods given by PLPTool.<br/>
`shamt` is a 5-bit integer that can be represented by any of the methods given by PLPTool.

_**IMPORTANT NOTE:**_ If the shift amount value is greater than 5 bits, the assembler will truncate the more significant positions beyond the fifth bit. This means the maximum shift amount is 31.

_**IMPORTANT NOTE:**_ If `imm` is greater than 16 bits, the assembler will truncate the more significant bit positions beyond the sixteenth place. This means the maximum immediate value is 65535.

**EXAMPLE**

<pre><code id="clipboard-content-logic-ex" class="language-plp">
# main source file

.org 0x10000000

# Logical Examples
main:
# load values to use below
	li $t0 , 0b110101
	li $t1 , 0b001100
	
# AND
	and $t2 , $t0 , $t1	# ANDs $t0 and $t1 to get 0b000100 (8)
        andi $t2 , $t0 , 0b000011   # and $t0 with 0b000011 to get 0b000001 (1)

# OR
	ori $t3 , $t0 , 0b111111	# OR $t0 and 0b111111 to get 0b111111 (63)
        or $t3 , $t0 , $t1  # OR $t0 and $t1 to get 0b111101 (61)

# NOR
	nor $t4 , $t0 , $t1	# NOR $t0 and $t1 to get 0b000010 with leading 1s

# less than
	li $t0 , 30
	li $t1 , -16
	slt $t5 , $t0 , $t1	# if $t0 is less than $t1, $t5 will be 1, else it will be 0
	# since slt is signed, this will return 0
	sltiu $t5 , $t0 , -2		# unsigned comparison means that -2 is greater than 30, $t5 will be 1
	# -2 is 0xFFFFFFFE and 30 is 0x00000000E

# shift
	li $t0 , 0b10001101	# load $t0 with a value, represented in binary
	li $t1 , 4		# load $t1 with a value to shift by
	li $t6 , 0x8000000F	# load negative value 
	sllv $t7 , $t0 , $t1		# shift $t0(0b10001101) left $t1(4) bits, result will be 0b100011010000
	srl $t8 , $t6 , 3	# shift $t6(0x8000000F) right 3 bits, should result in (0x10000001)
	srlv $t9 , $t6 , $t1		# shift $t6 right 4 bits
	# note the result of this is NOT negativem srl and sll are UNSIGNED operations
</code></pre>
<button title="Note: clipboard access is not available on all platforms, results may vary." id="clipboard-button-logic-ex" class="tiny copy-button" data-clipboard-target="clipboard-content-logic-ex">Copy to clipboard</button>

<p class="panel show-for-touch">Note: clipboard access is not available on all platforms, results may vary.</p>


[Back to the top](#top)

### Control Flow Operations ###

These operations allow for a program to execute instructions in a non-linear fashion. Without them it would only be possible to run instructions in order from the first instruction to the last instruction in memory. Control flow operations allow a program to execute instructions from a specified location in a program either conditional or unconditionally.

**_IMPORTANT NOTE:_** There is a "branch delay slot" immediately after all control flow instruction (jumps and branchs).  The next line of code following the jump/branch will always be executed along with the jump/branch.  To avoid complications, it is generally advisable to put a no-operation instruction (`nop`) immediately after the jump/branch instruction, unless the branch delay slot needs to be utilized.

#### Conditional (Branch) ####
{:.ancs}

In a high level language, conditional statements are typically written as *if* statements. In PLP, **branch** instructions are used for conditional execution. Branch instructions use two registers and a label. They check the equalitiy of the value in two specified registers. There are two types of branch instructions, *branch-if-equal* (`beq`) and *branch-if-not-equal* (`bne`). A `beq` instruction will begin executing instructions at the specified label if the two register values are equal. A `bne` instruction will begin executing instructions at the specified label if the two register values are *not* equal. If the condition of a branch instruction was met then it is common to say, "the branch was taken".

Branching based on an inequality requires the use of two instructions, a *set-less-than* instruction ([`slt`](#logicalbitwise-operations)) and a branch instruction. The branch instruction can be used to compare the result of the `slt` with the zero register (`$0`).

<div class="mobile" markdown="1">
| Syntax		| Expression			    | Sample Usage          | Notes				                                        |
| :-------------------- | :-------------------------------- | :-------------------- | :--------------------------------         |
| <span title="branch if equal">`beq $rt, $rs, label`</span> | `if(rt == rs) PC = PC + 4 + imm;` | `beq $a0, $a1, done`  | Branch to `done` if $a0 and $a1 are equal                                   |
| <span title="branch if not equal">`bne $rt, $rs, label`</span> | `if(rt != rs) PC = PC + 4 + imm;` | `bne $a0, $a1, error` | Branch to `error` if $a0 and $a1 are NOT equal                              |

{:.mobile}

</div>

#### Unconditional (Jump) ####
{:.ancs}

A jump instruction always goes to a given in the instruction (some languages call this a *GOTO* instruction). PLP has several types of jump instructions. The simplist jump (`j`) goes to the label given in the instruction. The other jump instructions use registers and allow for more sophisticated control flow.

The jump-and-link (`jal`) instruction saves the address of the instruction following the instruction's branch delay slot into register `$ra` (return address). The jump-register (`jr`) instruction can be used to jump back to this return address. This can be taken advantage of to write pieces of code, after a label, that can be used from multiple locations in the program. This reusable piece of code is often called a *subroutine*.

<div class="mobile" markdown="1">

| Syntax		| Expression			    | Sample Usage          | Notes				                                        |
| :-------------------- | :-------------------------------- | :-------------------- | :--------------------------------         |
| <span title="jump">`j label`</span>             | `PC = jump_target;`               | `j loop`              | Jump to loop label                                                        |
| <span title="jump and link">`jal label`</span>           | `ra = PC + 4; PC = jump_target;`  | `jal read_serial`     | Jump to read_serial after saving return address to $ra |
| <span title="jump to register">`jr $rs`</span>              | `PC = rs;`                        | `jr $ra`              | Load the content of $ra into PC register  |
| <span title="jump to register and link">`jalr $rd, $rs`</span>       | `rd = PC + 4; PC = rs;`           | `jalr $s5, $t0`       | Jump to location gien by contents of `rs`, save return address in `rd`. |

{:.mobile}

</div>

`label` is the name of a label somewhere in the program, usually a string.<br/>
`$rs` is the source registers: this is the value that the operation acts upon.<br/>
`$rd` is the destination register, where the resulting value will go.<br/>
`$rt` is the target register: this is the value that the operation uses.

**EXAMPLE**

<pre><code class="language-plp" id="clipboard-content-jump-ex">
# main source file

.org 0x10000000

# Jump and Branch examples

	li $t0 , 250	# load 250 into $t0
	li $t1 , 100	# load 100 into $t1
	li $t3 , 300	# load 300 into $t3
	li $s4 , fun2	# load the address of fun2 into $s4
	li $s0 , main	# load the address of main into $s0
main:

	beq $t0 , $t1 , end	# if $t0 and $t1 are equal, branch to end label
	nop	# nop in branch delay slot

	jalr $ra, $s4	# jump and link to the label in $s4, store the current PC in $ra
	ori $t4 , $0 , 5	# use branch delay slot to load 5 into $t4 using ori

	slt $t4 , $t0 , $t3	# compare $t0 to $t3, store result(0 or 1) in $t4
	bne $t4 , $zero , func1	# if $t4 is NOT 0, branch to func1
	nop	# nop in branch delay slot

	j main
	nop

fun2:
	addu $t1 , $t1 , $t4 # add $t4 to $t1, store result in $t1
	jr $ra	# jump to the memory address in $ra
	nop	# nop in branch delay slot


end:
	j end	# an infinite loop
	nop	# common in programs that use interrupts

func1:
	addiu $t3 , $t3 , -10	# add -10 to $t3, store value in $t3
	jal fun2	# jump and link to fun2
	ori $t4 , $zero , 5	# branch delay slot to load 5 into $t4
	j main	# jump to main
	nop	# nop in branch delay slot

</code></pre>
<button title="Note: clipboard access is not available on all platforms, results may vary." id="clipboard-button-jump-ex" class="tiny copy-button" data-clipboard-target="clipboard-content-jump-ex">Copy to clipboard</button>

<p class="panel show-for-touch">Note: clipboard access is not available on all platforms, results may vary.</p>


[Back to the top](#top)


### Memory-focused Operations ###
{:.ancs}

These operations allow for the manipulation of memory and values within.

<div class="mobile" markdown="1">

| Syntax		| Expression			    | Sample Usage          | Notes				            |
| :-------------------- | :-------------------------------- | :-------------------- | :--------------------------------             |
| <span title="load word from memory">`lw $rt, imm($rs)`</span>    | `rt = SignExtend(imm)[rs];`       | `lw $v0, 0x4000($a1)` | Load contents of 0x4000 + $a1 into $v0        |
| <span title="store word into memory">`sw $rt, imm($rs)`</span>    | `SignExtend(imm)[rs] = rt;`       | `sw $a0, 128($v0)`    | Store contents of register $a0 to 128 + $v0   |
{:.mobile}

</div>

`$rt` is the target register: where the value will be.<br/>
`imm` is the offset of memory, in bytes.<br/>
`$rs` is the source register, holds a memory location.

**EXAMPLE**

<pre><code class="language-plp" id="clipboard-content-mem-ex">
# main source file

.org 0x10000000

main:

	li $t0 , 0x1000F000	# load a memory address into $t0
	li $t1 , 0x55	# load a value into $t1

	sw $t1 , 0($t0)	# store the value from $t1 into the memory location in $t0 with an offset of 0
	# to break this down a bit
	#	$t1 is the register in which the value is located
	#	$t0 is the register where the memory location is located
	#	0 is the byte offset
	# in the end, the value of $t1 will be placed in the memory location of $t0 + 0

	lw $t2 , 0($t1)	# load the value from the memory address stored in $t1 with an offset of 0 into the $t2 register
	# to break this down a bit
	#	$t2 is the register in which the value will be loaded into
	#	$t1 is the register where the memory location is located
	#	0 is the byte offset
	# in the end, the value of $t2 will be loaded from the memory location of $t1 + 0
</code></pre>
<button title="Note: clipboard access is not available on all platforms, results may vary." id="clipboard-button-mem-ex" class="tiny copy-button" data-clipboard-target="clipboard-content-mem-ex">Copy to clipboard</button>

<p class="panel show-for-touch">Note: clipboard access is not available on all platforms, results may vary.</p>

[Back to the top](#top)



## Pseudo-Operations ##
{:.ancs}

The PLP assembler supports several pseudo-operations to make programming easier.  The following pseudo-operations are supported by PLP:

<div class="mobile" markdown="1">

| Pseudo-op              | Equivalent instruction(s)                              | Notes                                                               | 
| :--------              | :------------------------                              | :----------------------------------------------------------------   | 
| `nop`                  | `sll $0, $0, 0`                                        | No-operation.  Can be used for branch delay slots                   | 
| `b label`              | `beq $0, $0, label`                                    | Branch always to label                                              | 
| `move $rd, $rs`        | `add $rd, $0, $rs`                                     | Copy $rs to $rd                                                     | 
| `push $rt`             | `addiu $sp, $sp, -4; sw $rt, 0($sp)`                   | Push $rt into the stack                                             | 
| `pop $rt`              | `lw $rt, 0($sp); addiu $sp, $sp, 4`                    | Pop data from the top of the stack to $rt                           | 
| `li $rd, imm`          | `lui $rd, (imm & 0xff00) >> 16; ori $rd, imm & 0x00ff` | Load a 32-bit number to $rd                                         | 
| `li $rd, label`        | `lui $rd, (imm & 0xff00) >> 16; ori $rd, imm & 0x00ff` | Load the address of a label to a register to be used as a pointer.  | 
| `call label`           |                                                        | Save $aX, $tX, $sX, and $ra to stack and call function              | 
| `return`               |                                                        | Restore $aX, $tX, $sX, and $ra from stack and return                | 
| `save`                 |                                                        | Save all registers except for $zero to stack                        | 
| `restore`              |                                                        | Restore all registers saved by 'save' in reverse order              | 
| `lwm $rt, imm32/label` |                                                        | Load the value from a memory location into $rt                      | 
| `swm $rt, imm32/label` |                                                        | Store the value in $rt to a memory location                         | 
{:.mobile}

</div>


[Back to the top](#top)



## Registers Names and Conventions ##
{:.ancs}

Aside from $zero, $at, $iv, $ir, $sp and $ra, PLP does not explicitly assign special functions to a register.  This section lays down some conventions on how the other registers should be used.  All libraries included with PLPTool adhere to these conventions.

<div class="mobile" markdown="1">

| Register    	| Usage                     				| Notes 	| 
| :---------------- | :---------------------------------- | :--------- |
| `$zero`    		| Constant value 0          		| This register can not be written to and always returns the value 0 	| 
| `$at`       		| Assembler temporary       | Assembler reserved, do not use 															| 
| `$v0 - $v1` 	| Values for results        		| Use for return values of functions 															| 
| `$a0 - $a3` 	| Arguments                 			| Use for arguments of functions 																| 
| `$t0 - $t9` 		| Temporaries               			| Do not use these registers across function calls, as they will most likely be corrupted 	| 
| `$s0 - $s7` 	| Saved temporaries         	| These registers should be saved and restored after function calls	| 
| `$i0 - $i1`   	| Interrupt temporaries     	| Use inside Interrupt Service Routine (ISR) 											| 
| `$iv`       		|  Interrupt vector          		| The CPU jumps to the address pointed by this register when an interrupt occurs	| 
| `$sp`       		| Stack pointer             			| Use this register to implement a stack	| 
| `$ir`       			| Interrupt return address	| Written by the CPU when an interrupt occurs	| 
| `$ra`       		| Return address            		| Do not manually write to this register unless restoring from the stack for nested function calls.  Use this register to return from a function using the jump register instruction | 
{:.mobile}

</div>

[Back to the top](#top)


</div>



