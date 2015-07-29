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
#this is the first comment 
addu $s0, $s0, $s1 #this is the second comment
</code></pre>

_Note:_ Comments are very helpful for debugging and helping others who read the code to understand what a certain segment of code is supposed to do.

[Back to the top](#top)


## Numbers ##
{:.ancs}

In many cases, you will have to use a number for a command or operation.  PLPTool has 3 different methods of writing numbers: binary, decimal, and hexadecimal.  Each has its own purpose, though most can be interchanged, with some exceptions.

* To enter a binary number, prefix it with `0b` and make sure to only use `1` or `0`.
* To enter a decimal number, just type the number.  *NOTE:* Leading zeros will not affect the number: `1241` is the same as `0001241`.
* To enter a hexadecimal number, use either the `0x` prefix or the `0h` prefix.  *NOTE:* The `0x` prefix is more common and widely accepted in other applications.

Binary numbers are mostly used for clarification, or for emphasis on the bits instead of as a number.  Decimal numbers are used for immediate and regular vaues.  Hexadecimal numberrs are usually memory addresses or large values.

<pre><code class="language-plp">
124 # this is a decimal number
0152    # this is a decimal number
0x15ff  # this is a hexadecimal number
0hf222  # this is a hexadecimal number, though not a very common notation 
0b1001011   # this is a binary number
</code></pre>

[Back to the top](#top)


## Symbols ##
{:.ancs}

This document uses the following symbols and expressions throughout, refer here if you come accross something that is not familiar.

* `=` - equals
* `+` - plus
* `-` - minus/subtract
* `*` - multiply
* `>>` - signed shift right
* `>>>` - unsigned shift right
* `<<` - shift left
* `&` - bitwise AND
* `|` - bitwise OR
* `~` - inverse/bitwise NOR
* `val = (expr) ? tr : fl` - this is a simplified version of an if-then-else statement
    * if `(expr)` is true, then `val` is set to `tr`. if `(expr)` is false, then `val` is set to `fl`
* `<` - less than
* `<=` - less than or equal to
* `>` - greater than
* `>=` - greater than or equal to
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

_**IMPORTANT NOTE:**_ This must be the first non-comment line in the main source file.  It is possible however to have multiple .org statements throughout the program.

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

PLPTool supports allocating space by taking the number of words to allocated by using the `.space` directive, as opposed to a single word with the `.word` directive.

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

PLPTool supports two types of string allocation:

  * `.ascii`
    * This allocates a packed array of characters without a trailing null character (terminator), which indicates the end of the string

For example, if you wanted to allocate a variable with a string using the `.ascii` directive, the code would be:

<pre><code class="language-plp">
my_string_ascii:
     .ascii "example string"  # no null terminator
</code></pre>


  * `.asciiz`
    * This allocates a packed array of characters with a trailing null character that indicated the end of the string.

For example, if you wanted to allocate a variable with a string using the `.asciiz` directive, the code would be:

<pre><code class="language-plp">
my_string_asciiz:
     .asciiz "example string" # null terminator inserted at end of string
</code></pre>


  * `.asciiw`
    * This allocates a word alligned array of characters with a trailing null character that indicated the end of the string.

For example, if you wanted to allocate a variable with a string using the `.asciiw` directive, the code would be:

<pre><code class="language-plp">
my_string_asciiw:
     .asciiw "example string" # word alligned, null terminator inserted at end of string
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
    &lt;instructions&gt;
</code></pre>

  * It is the standard convention to have the first label in a program titled "main".

_Note:_ It is possible to load a pointer to a label using the load immediate instruction `li`.

<pre><code class="language-plp">
.org 0x10000000

main: 
    &lt;instructions&gt;

label2:
    li $t0 , main
</code></pre>

[Back to the top](#top)


## Operations ##
{:.ancs}

Below is the list of all operations within PLP, broken down into sections via their type. Their syntax, and example, the expression, and any notes are provided. Hover over the operation to see the exapanded title.

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
    mullo $t4 , $t3 , $t3	# mulltiply $t3(27) and $t3(27), store the LOWER 8 bytes(1 word)
    li $t0 , 65535	# load 65535 into $t0 (0xFFFF)
    li $t1 , 65535	# load 65535 into $t1 (0xFFFF)
    mullo $t2 , $t0 , $t1	# multiply $t0 and $t1, store LOWER word into $t2
    mulhi $t3 , $t0 , $t1	# multiply $t0 and $t1, store UPPER word into $t3
    # it should be noted that mullo and mulhi are deeply related
    # if the product of mullo overflows(is higher than you can represented with a signed integer), mulhi will return the sign bit, along with the rest of the bits
    # $t2 will have 4294836225(0xFFFE0001)
    # $t2 will have 0(0x00000000)
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
| <span title="bitwise AND immediate">`andi  $rd, $rs, imm`</span> | `rd = rs & ZeroExtend(imm);`           | `andi  $v0, $a0, 1337`   | Bitwise Logical AND                                       |
| <span title="bitwise OR">`or    $rd, $rs, $rt`</span>	| `rd = rs | rt;`		         | `or    $v0, $a0, $a1`    | Bitwise logical OR		                        |
| <span title="bitwise OR immediate">`ori   $rd, $rs, imm`</span> | `rd = rs  |  ZeroExtend(imm);`         | `ori   $v0, $a0, 0x0539` | Bitwise Logical OR                                        |
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
	ori $t3 , $t1 , 0b111111	# OR $t0 and 0b111111 to get 0b111111 (63)
        or $t3 , $t0 , $t1  # AND $t0 and $t1 to get 0b111101 (61)

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


### Jump and Branch Operations ###
{:.ancs}

These operations allow for the traversal of programs, sometimes when certain parameters are met, via labels.

<div class="mobile" markdown="1">

| Syntax		| Expression			    | Sample Usage          | Notes				                                        |
| :-------------------- | :-------------------------------- | :-------------------- | :--------------------------------                                         |
| <span title="jump">`j label`</span>             | `PC = jump_target;`               | `j loop`              | Jump to loop label                                                        |
| <span title="jump to register">`jr $rs`</span>              | `PC = rs;`                        | `jr $ra`              | Load the content of $ra into PC register                                  |
| <span title="jump and link">`jal label`</span>           | `ra = PC + 4; PC = jump_target;`  | `jal read_serial`     | Jump to read_serial after saving return address to $ra                    |
| <span title="jump to register and link">`jalr $rd, $rs`</span>       | `rd = PC + 4; PC = rs;`           | `jalr $s5, $t0`       | Jump to location gien by contents of `rs`, save return address in `rd`.   |
| <span title="branch if equal">`beq $rt, $rs, label`</span> | `if(rt == rs) PC = PC + 4 + imm;` | `beq $a0, $a1, done`  | Branch to done if $a0 and $a1 are equal                                   |
| <span title="branch if not equal">`bne $rt, $rs, label`</span> | `if(rt != rs) PC = PC + 4 + imm;` | `bne $a0, $a1, error` | Branch to error if $a0 and $a1 are NOT equal                              |
{:.mobile}

</div>

`label` is the name of a label somewhere in the program, usually a string.<br/>
`$rs` is the source registers: this is the value that the operation acts upon.<br/>
`$rd` is the destination register, where the resulting value will go.<br/>
`$rt` is the target register: this is the value that the operation uses.

**_IMPORTANT NOTE:_** After every jump/branch instruction, there is a "branch delay slot" immediately after.  The next line of code following the jump/branch will also get executed along with the jump/branch.  To avoid complications, it is generally advisable to put a no operation instruction (nop) immediately after the jump/branch instruction, unless the branch delay slot needs to be utilized.

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
	addu $t1 , $t1 , $t4	$ # add $t4 to $t1, store result in $t1
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
	#	$t1 is the register in which the value will be loaded into
	#	$t0 is the register where the memory location is located
	#	0 is the byte offset
	# in the end, the value of $t1 will be loaded from the memory location of $t0 + 0
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

**EXAMPLE**

<pre><code class="language-plp" id="clipboard-content-pseudo-ex">
# main source file

.org 0x10000000

main:

	li $sp , 0x10fffffc	# load a memory location(in this case, end/top of RAM) into $sp, the stack pointer register

	# NOP - no op(eration), useful in the branch delay slot
	# b - branch always
	b label2	# branch always, branch to label2 unconditionally
	nop	# in branch delay slot, does essentially nothing
	
label2:
	# move - copies content from one register to another
	li $t0 , 0x2	# load 2 into $t0
	move $t1 , $t0	# copy $t0s value(2) into $t1

	# push and pop
	#	push stores the data into the memory address of $sp, then increments $sp so it points to the new top
	#	pop decrements $sp and then restores data from the address, note that values are not overriden with pop, they just become inaccessible
	li $t0 , 0x25	# load 37 into $t0
	li $t1 , 0x25	# load 32 into $t1
	push $t0	# push the value of $t0 (37) onto the stack, increment stack pointer
	push $t1	# push the value of $t1 (32) onto the stack, increment stack pointer
	pop $t0	# pop the value at the top of the stack (32), place into $t0, decrement stack pointer
	pop $t1	# pop the value at the top of the stack (37), place into $t1, decrement stack pointer

	# li - load immediate, loads a 32-bit value into a register, can also load a label(the memory location) into a register
	li $t0 , 0x10052ff3	# load a large value into $t0 by using lui and ori
	li $t1 , label2	# loads the memory location of label2 into $t1

	# call and return
	#	call will push the $a, $t, $s, and $ra registers on the stack, then jump to the label provided
	#	return will jump to the addres in $ra, then pop the $a, $t, $s, and $ra registers from the stack in reverse order
	call label3	# save registers, jump to label, no the absense of nop
	
	# save and restore
	#	save pushes EVERY register(except $0) onto the stack
	#	restore pops every register off the stack in reverse order
	save	# saves all registers to stack
	restore	# restores all registers from stack

	# lwm and swm - loard word memory and store word memory
	#	lwm will load a value from the immediate memory location into the register
	#	swm will store a value from a register into the immediate memory location
	lwm $t0 , 0xf0100000	# loads the value of the switches' memory location into $t0
	swm $t0 , 0xf0200000	# stores the value of $t0 into the LEDs memory location

label3:
	return	# will return to where the progam was before last call, restores registers, note no nop
</code></pre>
<button title="Note: clipboard access is not available on all platforms, results may vary." id="clipboard-button-pseudo-ex" class="tiny copy-button" data-clipboard-target="clipboard-content-pseudo-ex">Copy to clipboard</button>

<p class="panel show-for-touch">Note: clipboard access is not available on all platforms, results may vary.</p>

[Back to the top](#top)



## Notes on Register Usage ##
{:.ancs}

Aside from $zero, $i0, $i1, and $ra, PLP does not explicitly assign special functions to a register.  This section lays down some conventions on how the other registers should be used.  All the supplied libraries adhere to this guideline.

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

## I/O Examples ##
{:.ancs}

Below are some short examples on how to properly use each I/O device coupled with PLPTool. For additional examples, in video form, [visit the PLP youtube channel](https://www.youtube.com/channel/UCX-QCwA9DCvMA4DTXv7_tuQ).

### LEDs ###
{:.ancs}

To use the LEDs, simple store a word into the memory address at `0xf0200000`.  <br>
*Note:* the LEDs will only represent the lowest 8 bits of information.

Example:

<pre><code class="language-plp" id="clipboard-content-leds">
.org 0x10000000

main:
    li $t0 , 0  # setting $t0 to 0
    li $t1 , 0xf0200000 # setting $t1 to the memory address of the LEDs

loop:
    sw $t0 , 0($t1) # store the value of $t0 into the LEDs memory address
    addiu $t0 , $t0 , 1 # increment $t0 by 1
    j loop  # jump to the loop 
    nop # nop after jump
</code></pre>
<button title="Note: clipboard access is not available on all platforms, results may vary." id="clipboard-button-leds" class="tiny copy-button" data-clipboard-target="clipboard-content-leds">Copy to clipboard</button>

<p class="panel show-for-touch">Note: clipboard access is not available on all platforms, results may vary.</p>

This program will continuously increment a counter and display it on the LEDs.  When the number reaches 256, the LEDs will read 0 and start the cycle over again because they only show the least significant byte.

Additional tutorial: [PLP Basic I/O Tutorial](https://www.youtube.com/watch?v=ddDRRAzlGKk)

[Back to the top](#top)


### Switches ###
{:.ancs}

To use the switches, load a word from the memory address at `0xf0100000` into a register.  You can then use this value within other parts of your program.

Example:

<pre><code class="language-plp" id="clipboard-content-switches">
.org 0x10000000

main: 
    li $t0 , 0xf0100000 # load the memory address for the switches into $t0
    li $t1 , 0xf0200000 # load the memory address for the LEDs into $t1

start:
    lw $t2 , 0($t0) # load the value of the switches into $t1
    sw $t2 , 0($t1) # using code from the example above, store the value of the switches into the LEDs

    j start # jump to the start label
    nop
</code></pre>
<button title="Note: clipboard access is not available on all platforms, results may vary." id="clipboard-button-switches" class="tiny copy-button" data-clipboard-target="clipboard-content-switches">Copy to clipboard</button>

<p class="panel show-for-touch">Note: clipboard access is not available on all platforms, results may vary.</p>

This program will read in the value of the switches, then display that value on the LEDs.  The switches and LEDs have a 1-to-1 relation so pressing 0 and 1 on the switches will light up 0 and 1 on the LEDs.

Additional tutorial: [PLP Basic I/O Tutorial](https://www.youtube.com/watch?v=ddDRRAzlGKk)

[Back to the top](#top)


### Seven Segment Displays ###
{:.ancs}

To use the Seven Segment Displays, you must store a value into the memory address of `0xf0a00000`.  This value is broken into 4 bytes: 1 for each seven segment display.
Each byte section is further broken down into bits, where one bit corresponds for one of the seven(plus decimal point) segments.  This breakdown can be seen here: 

![sseg2_fixed.png]({{site.baseurl}}/resources/users_manual_sseg2_fixed.png)

We can write these segments as binary, where 0 is the least significant bit of a btye and 7 is the most significant bit.

<pre><code class="language-plp">
0b11111111
  76543210
</code></pre>>

Using this format, and adding 3 more bytes to the front(because the Seven Segment Displays panel has 4 actual displays), we can display a wide range of characters on the Seven Segment Displays, although we mostly use it for hexadecimal numbers.  Using the Seven Segment Displays often requires the use of a bit of "translating" code to map a decimal value to a seven segment value.

Example:

<pre><code class="language-plp" id="clipboard-content-sseg">
.org 0x10000000

main:
    li $t0 , 0xf0a00000 # load the memory address for the switches into $t0

    li $t1 , 0xf9a4808e
    # this hex number can be broken into fourths
    #   0xf9 - for the first(left, most significant) digit
    #   this is 0b11111001 in binary
    #   0xa4 - for the second digit
    #   0b10100100
    #   0x80 - for the third digit
    #   0b10000000
    #   0x8e - for the fourth(last, right, least significant digit)
    #   0b10001110
    sw $t1 , 0($t0) # this stores the value into the memory address of the seven segment display
</code></pre>
<button title="Note: clipboard access is not available on all platforms, results may vary." id="clipboard-button-sseg " class="tiny copy-button" data-clipboard-target="clipboard-content-sseg">Copy to clipboard</button>

<p class="panel show-for-touch">Note: clipboard access is not available on all platforms, results may vary.</p>

Beacause the Seven Segment Displays has an internal inverter(in the actual PLP board), we use 1's to denote a disabled segment and 0's to denote enabled segents.  That means, this above example would display '128f' on the seven segments.

Additional tutorial: [PLP Basic I/O Tutorial](https://www.youtube.com/watch?v=ddDRRAzlGKk)

[Back to the top](#top)


### UART ###
{:.ancs}

temp

Additional tutorial: [PLP UART and Interrupt Tutorial](https://www.youtube.com/watch?v=ZrlY5B6h8fA)

[Back to the top](#top)


### VGA ###
{:.ancs}

temp

[Back to the top](#top)


### PLPID ###
{:.ancs}

temp

[Back to the top](#top)


### GPIO ###
{:.ancs}

temp

[Back to the top](#top)


### Button Interrupt ###
{:.ancs}

temp

[Back to the top](#top)


## Comprehensive Examples ##
{:.ancs}

Below are some examples combining most of the techniques and operations noted above. These range from beginner to advanced, although looking at them and reading them carefully can prove beneficial to users of all skill levels.

### Seven Segment Scroll ###
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
	li $sp, SSEG_LUT	# Lookup table address
	loop:
		lw $t2, 0($sp)	# Read value from lookup table
		sll $t1, $t1, 8	# Shift digit encodings left 1 byte (8 bits)
		or $t1, $t1, $t2	# Set least significant digit to value from lookup table
		sw $t1, 0($s0)	# Set value on seven segment display
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


### Switches to Seven Segment Display ###
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


### Switches Two's Compliment ###
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


### 4 byte Switch Input Two's Compliment ###
{:.ancs}

This program is more complicated than the above examples. In this program, the user will enter a 4 byte number by using the Switches one byte at a time. The resulting value will be display on the Seven Segment Display as it is being entered. It will then negate the value via Two's Compliment, and display the final result on the Seven Segment Display.

<a href="{{site.baseurl}}/resources/plp-um-twoscomp.plp" download="twos-comp.plp"><button type="button" class="tiny button secondary">Download</button></a>

[Back to the top](#top)


### Opcodes temporary home ###
{:.noanchor .no_toc}

<div class="mobile" markdown="1">

| Syntax		| Opcode/Function   |
| :-------------------- | :------------     |
| addu  $rd, $rs, $rt	| 0x00 / 0x21	    |
| addiu $rd, $rs, imm | 0x09 | 
| subu  $rd, $rs, $rt	| 0x00 / 0x23     |
| mullo $rd, $rs, $rt	| 0x00 / 0x10     |
| mulhi $rd, $rs, $rt	| 0x00 / 0x11     |
| and   $rd, $rs, $rt	| 0x00 / 0x24     |
| andi  $rd, $rs, imm | 0x0c | 
| or    $rd, $rs, $rt	|  0x00 / 0x25     |
| ori   $rd, $rs, imm |  0x0d | 
| nor   $rd, $rs, $rt	|  0x00 / 0x27     |
| slt   $rd, $rs, $rt	| 0x00 / 0x2a     |
| slti  $rd, $rs, imm | 0x0a | 
| sltu  $rd, $rs, $rt	| 0x00 / 0x2b     |
| sltiu $rd, $rs, imm | 0x0b | 
| sll $rd, $rt, shamt | 0x00 / 0x00   |
| sllv $rd, $rs, $rt  | 0x00 / 0x01 |
| srl $rd, $rt, shamt | 0x00 / 0x02   |
| srlv $rd, $rs, $rt  | 0x00 / 0x03 |
| j label |  0x02 |
| jr $rs          |  0x00 / 0x08       | 
| jal label |  0x03 | 
| jalr $rd, $rs   |  0x00 / 0x09       | 
| beq $rt, $rs, label   |  0x04  | 
| bne $rt, $rs, label   |  0x05  | 
| lw $rt, imm($rs) |  0x23 | 
| sw $rt, imm($rs) |  0x2b | 
| lui $rt, imm |  0x0f | 
{:.mobile}

</div>

</div>



