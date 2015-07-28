---
title: General CS Overview/Review
layout: main
---

<div class="hide-for-small-only">
    <div class="medium-3 columns">
	<div class="panel">

	
<!-- NOTE: the following block must not be indented or it isn't properly recognized as markdown -->

<h3 class="noanchor"> Table of Contents </h3>

<div class="toc" markdown="1">

1. TOC
{:toc}

</div>
<!-- END OF MARKDOWN BLOCK -->


        </div>
    </div>
</div>

<div class="medium-9 columns my-content" markdown="1">
<div class="ancs" id="top"></div>

# General Computer Science Concepts #
{:.no_toc .ancs}

This section will discuss some general computer science topics you may or may not have encountered previously.  Some of this may be review, and some of it may be new.  This section is intended to leave no knowledge blanks when learning about PLPTool and its usage details.

[Back to top](#top)


## Binary ##
{:.ancs}

Every number, when used by a computer, is represented as binary.  Binary is a base-2 numbering system, the one most humans use is decimal, a base-10 numbering system. This means, each place value is a 10(in decimal) raised to a power and a 2(in binary) raised to a power.

Below is a table containing a few examples of binary and decimal numbers.

| Decimal   | Binary    |
|-----------|----------:|
| 1         | 1         |
| 2         | 10        |
| 5         | 101       |
| 10        | 1010      |
| 13        | 1101      |
| 20        | 10100     |


This table shows the nth place(from the right) and its representative place in decimal and binary. Decimal has the familiar 1's, 10's, 100's, etc. places while Binary has 1's, 2's, 4's, 8's, and so on. The base of the number decides the base of the power. Other bases, such as Octal or Hexadecimal, also follow this rule, being base 8 and base 16 respectively. Hexadecimal is covered below.

| nth place     | Decimal place     | Binary place  |
|---------------|-------------------|---------------|
| 1             | `10^0 = 1`        | `2^0 = 1`     |
| 2             | `10^1 = 10`       | `2^1 = 2`     |
| 3             | `10^2 = 100`      | `2^2 = 4`     |
| 4             | `10^3 = 1000`     | `2^3 = 8`     |
| 5             | `10^4 = 10000`    | `2^4 = 16`    |

Now say we want to represent 42 in binary. Using the knowledge from above, this should be simple. The easiest way to translate is to kind of work backwards. We start by finding the highest digit(left most) that we can use. In this case, it's `2^5` or `32`. One more would be `2^6 = 64`, which is too large for 42. So now we know it is 6 digits long with a leading 1. <br>
Next, we step down the line(to the right) and see if we can add the next highest number, `16` in our case. `32 + 16` is `48`, which is larger than our goal, so the 16's digit is a `0`. <br>
Now we have `10----`. Next digit is `2^3 = 8`. `32 + 8 = 40`, which fits. This gives us `101---`. <br>
`2^2 = 4`, too much. `1010--`. `2^1 = 2`, perfect. `101001-` is 42, which means the lest significant bit(the right most) is a 0. So, `42` written in decimal is `1010010`.

We can go the other way as well, translating from binary to decimal. Take `10010111` for example. We start again from the left most digit and add it up, going to the right, keeping a total sum. This can also be done right to left, if it seems easier.

<pre><code class="language-">
10010111
||||||||
|||||||+- 2^0 * 1 = 1
||||||+-- 2^1 * 1 = 2
|||||+--- 2^2 * 1 = 4
||||+---- 2^3 * 0 = 0
|||+----- 2^4 * 1 = 16
||+------ 2^5 * 0 = 0
|+------- 2^6 * 0 = 0
+-------- 2^7 * 1 = 128
                    -----
10010111          = 151
</code></pre>

[Back to the top](#top)


## Hexadecimal ##

Similar to Binary, Hexadecimal is another base of numbering that is common in the world of Computer Science. It is often used to display very large numbers, memory addresses, or other notable numbers like colors. Instead of being base 2(Binary) or base 10(Decimal), Hexadecimal is base 16. Hexadecimal numbers are often preceeded by a `0x` prefix, due to the possibility of them looking like decimal numbers.

Since Hexadecimal is base 16, it requires more cyphers(characters) than Decimal or Binary. In Binary, you only need two characters: 0 and 1. In Decimal, you need 0-9. In Hexadecimal, we use the first 6 characters of the alphabet for the additional numbers.<br>
0-9 are still used, but when we get to 10, we use A. B is 11, C is 12, D is 13, E is 14, and F is 15. 16 would be 10, since we have 0 for the 16th digit.

Below are a few examples of hexadecimal numbers and their decimal counterparts.

| Decimal   | Hexadecimal   |
|-----------|---------------|
| 1         | 0x1           |
| 3         | 0x3           |
| 11        | 0xB           |
| 15        | 0xF           |
| 16        | 0x10          |
| 255       | 0xFF          |
| 16746496  | 0xFF8800      |

Much like binary, each place value is different than decimal. However, unlike binary, the place values are much larger.

| nth place     | Decimal Place     | Hexadecimal place     |
|---------------|-------------------|-----------------------|
| 1             | `10^0 = 1`        | `16^0 = 1`            |
| 2             | `10^1 = 10`       | `16^1 = 16`           |
| 3             | `10^2 = 100`      | `16^2 = 256`          |
| 4             | `10^3 = 1000`     | `16^3 = 4096`         |
| 5             | `10^4 = 10000`    | `16^4 = 65536`        |

Representing a number requires a similar process as binary. Take, for example, 42. We start the same way, finding the most significant bit that we need. From right to left, we have 1's, 16's, 256's. 256 is too large, so we know it must take some 16's and some 1's to make 42. Then, find out how many 16's it takes. `16*1 = 16`. `16*2 = 32`. `16*3 = 48`. 3 is too many, so the first digit is 2. So we have `0x2-`. There is only 10 left over, so we have 10 1's. The final result comes out to `0x2A`.

This works for larger numbers as well, which are not an uncommon occurance in hexadecimal. A value like 6536 might show up, but it is translated the same way. This time, we start with `16^3`. Since it equals 4096, we only need one of them. So now we have `0x1---`. `6536-4096` leaves us with 2440. We can use 9 256s. This brings us to `0x19--` and a sub-total of 6400. With only 136 remaining, we can use 8 16's to get `0x198-` and 8 left over. So, at the end, we have `0x1988` which represents 6536 in hexadeimal.

We can translate back using the same strategy as Binary. An example hex number might be `0x15F4DA`.

<pre><code class="language-">
0x15F4DA
  ||||||
  |||||+- A(10) * 16^0 =      10
  ||||+-- D(13) * 16^1 =     208
  |||+--- 4     * 16^2 =    1024
  ||+---- F(15) * 16^3 =   61440
  |+----- 5     * 16^4 =  327680
  +------ 1     * 16^5 = 1048576
                         -------
                       = 1438938
</code></pre>


[Back to the top](#top)


## Sign ##
{:.ancs}

### Signed Extends and Zero Extends ###
{:.ancs}

## Bitwise Operations ##
{:.ancs}

## Shifting ##
{:.ancs}

## Bit Masking ##
{:.ancs}

</div>
