---
title: PLP Implementation
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

# Hardware Description and Implementation Overview#
{:.no_toc}
{:.ancs}

The following sections describe the individual hardware components of the PLP Board that can be accessed and utilized. These components are memory mapped. This section also goes over how specific elements are implemented in PLP.

[Back to the top](#top)


## Memory Map ##
{:.ancs}

The table below indicates where a certain memory mapped device begins, how many bytes are allocated to that device, and the name of the device.

<div class="mobile" markdown="1">

| **Beginning Address** | **Length in Bytes** | Device |
|:----------------------|:--------------------|:-------|
| `0x00000000` | 2048 | Boot/ROM |
| `0x10000000` | 16777216 | RAM |
| `0xf0000000` | 16 | UART |
| `0xf0100000` | 4 | Switches |
| `0xf0200000` | 4 | LEDs |
| `0xf0300000` | 12 | GPIO |
| `0xf0400000` | 8 | VGA |
| `0xf0500000` | 8 | PLPID |
| `0xf0600000` | 4 | Timer |
| `0xf0700000` | 8 | Interrupt Controller |
| `0xf0800000` | ? | Performance Counter Hardware |
| `0xf0a00000` | 4 | Seven Segment Displays |
{:.mobile}

</div>

Each of these devices will be discussed in the following sections.


[Back to the top](#top)



## ROM ##
{:.ancs}

The ROM module is a non-volatile, read-only memory that stores the bootloader (fload). The bootloader is used with PLPTool to load programs over the serial port. The PLP Board starts at the memory address 0x00000000 on start up and upon reset, causing the bootloader to execute.

[Back to the top](#top)



## RAM ##
{:.ancs}

The RAM module is a volatile, random access memory that stores all the downloaded program code and data. Generally, the programmer with place their program at the beginning of the RAM using the directive `.org 0x10000000` . Additionally, the stack is generally initialized at the "top" of RAM by using the directive `$sp = 0x10fffffc`  .

[Back to the top](#top)



## UART ##
{:.ancs}

The UART module is running at 57600 baud, with 8 data bits, 1 stop bit, and no parity. The UART module is connected to the serial port on the PLP Board.

The UART module is designed to send or receive a single byte at a time, and can only store one byte in the send and receive buffer. This means that you must first either send the data in the buffer before reloading the buffer and you must retrieve the data in the receive buffer (by polling) before the next byte is available.

There are four registers that are memory mapped that the UART module uses:

<div class="mobile" markdown="1">

| Address | Description |
|:--------|:------------|
|`0xf0000000` | Command Register |
|`0xf0000004` | Status Register|
|`0xf0000008` | Receive Buffer|
|`0xf000000c` | Send Buffer|
{:.mobile}

</div>

The command register's default value is 0. Writing the value `0x01` will initiate a send operation using the lowest byte in the send buffer. Writing `0x02` will clear the ready flag in the status register, thus preparing for the cycle again.

The status register uses only the bottom two bits, with the remaining bits reading 0.

  * The value `0x00` in the status register is the **clear to send bit** (CTS bit), which is set after a successful transfer of data from the send buffer. It indicates that another transmission can now be made.
    * The CTS bit is `0x00` is during a transmission, and the data in the send buffer must not be modified during the transmission.
  * The value `0x01` in the status register is the **ready bit**, which is set when a new byte has been successfully received.
    * The ready bit can be cleared by writing `0x02` to the command register.

The receive buffer holds the last received byte. On a successful receive, the ready bit will be set, allowing the user to poll the status register for incoming data. When the ready bit is not set, the receive buffer should not be read as any data contained within is invalid.

The send buffer holds the byte that will be sent or is ready to be sent. During a send operation (CTS bit = `0x00`), the data in the send buffer **MUST NOT** be modified. The user should only update the send buffer when the CTS bit is reset.

The UART module supports interrupts, and will trigger an interrupt whenever data is available in the receive buffer.

**_IMPORTANT NOTE:_** The user must complete a receive cycle (including clearing the ready bit) before clearing the interrupt status bit for the UART.


[Back to the top](#top)



## Switches ##
{:.ancs}

The Switches module is a read-only register that always holds the current value of the switch positions on the PLP Board. There are 8 switches on the PLP Board, which are mapped to the lowest byte of the register. Writing to this register will have no effect.


[Back to the top](#top)



## LEDs ##
{:.ancs}

The LEDs module is a read-write register that stores the value of the LEDs on the PLP Board. There are 8 LEDs, mapped to the lowest byte of the register. Reading the register will provide the current status of the LEDs, and writing to the register will update the LEDs' status.


[Back to the top](#top)



## GPIO ##
{:.ancs}

The GPIO module connects two of the PLP Board's I/O connectors to the PLP System, enabling 16 GPIO ports.

There are three registers that are used with the GPIO module:

<div class="mobile" markdown="1">

| Address | Description |
|:--------|:------------|
| `0xf0300000` | Tristate register |
| `0xf0300004` | GPIO Block A |
| `0xf0300008` | GPIO Block B |
{:.mobile}

</div>

Each block of GPIO ports on the PLP Board has 12 pins: 8 I/O, 2 ground, and 2 Vdd.

The tristate register controls the direction of data on each of the GPIO pins. At startup and on reset, all GPIO are set to be inputs (the tristate register is zeroed). This protects circuits that are driving any pins on the GPIO ports. The user can set GPIO to be outputs by enabling the tristate pins for those outputs. The tristate bits map to GPIO pins in the following table.

<div class="mobile" markdown="1">

| Tristate Register Bit | GPIO Pin |
|:----------------------|:---------|
| 0 | A0 |
| 1 | A1 |
| 2 | A2 |
| 3 | A3 |
| 4 | A4 |
| 5 | A5 |
| 6 | A6 |
| 7 | A7 |
| 8 | B0 |
| 9 | B1 |
| 10 | B2 |
| 11 | B3 |
| 12 | B4 |
| 13 | B5 |
| 14 | B6 |
| 15 | B7 |
{:.mobile}

</div>

The GPIO registers use the bottom 8 bits of the data word. The other bits are always read `0`.

![{{site.baseurl}}/resources/users_manual_gpio2.png]({{site.baseurl}}/resources/users_manual_gpio2.png)

The figure above shows the pin mappings to the below table.

<div class="mobile" markdown="1">

| Pin | Mapping/Bit Position |
|:----|:---------------------|
| 1 | 0 |
| 2 | 1 |
| 3 | 2 |
| 4 | 3 |
| 5 | GND |
| 6 | Vdd |
| 7 | 4 |
| 8 | 5 |
| 9 | 6 |
| 10 | 7 |
| 11 | GND |
| 12 | Vdd |
{:.mobile}

</div>


[Back to the top](#top)



## VGA ##
{:.ancs}

The VGA module controls a 640x480 display with an 8-bit color depth.

An 8-bit color depth provides 3 red bits, 3 green bits, and 2 blue bits per pixel. The blue channel only has two bits because of a bit-depth limitation as well as the human eye's poor sensitivity to blue intensity.

The VGA module has two registers:

<div class="mobile" markdown="1">

| Address | Description |
|:--------|:------------|
| `0xf0400000` | Control |
| `0xf0400004` | Frame Buffer Pointer |
{:.mobile}

</div>

The control register uses only the least significant bit, which enables or disables the VGA controller output. When the control register is 0, the VGA module is disabled. When the control register is 0x1, the VGA module is enabled.

_Enabling the VGA module has significant impact on memory performance._ The VGA module uses RAM as VGA memory, and has a higher priority to the RAM bus than the CPU. During a draw cycle, the CPU will not be able to access the SRAM for a short period of time.

The frame buffer pointer is a pointer to the pixel data to draw in memory. For example, if your pixel data begins at 0x100f0000, you would set the frame buffer pointer to that location. The frame buffer must be 307,200 bytes long. The pixel data is arranged as starting from the upper left hand corner of the screen (0,0), and drawing to the right, one row at a time (like reading a book). That is, the zeroth pixel in the pixel data is the upper left hand corner. The upper right hand corner is the 639th pixel, and the left most pixel of the second row is the 640th pixel.

A pixel can be indexed by its row and column address (with 0,0 being the upper left hand corner) with : address = base\_address + (640\*row) + column.

The chart below displays the order of the color bits in the byte.

<div class="mobile" markdown="1">

| Bit | Color |
|:----|:------|
| 7 | `red[2]` |
| 6 | `red[1] `|
| 5 | `red[0]` |
| 4 | `green[2]` |
| 3 | `green[1]` |
| 2 | `green[0]` |
| 1 | `blue[1]` |
| 0 | `blue[0]` |
{:.mobile}

</div>

  * For example, to create a purely red pixel, the code would be `0b11100000` in binary, or `0xE0` in hexadecimal.


[Back to the top](#top)



## PLPID ##
{:.ancs}

The PLPID module contains two registers that describe the board identity and frequency. Writing to either register has no effect.

`0xf0500000` - PLPID (0xdeadbeef for this version)
`0xf0500004` - Board frequency (50MHz, 0x2faf080, for the reference design)

The CPUID module is useful for dynamically calculating wait time in a busy-wait loop. For example, if you wanted to wait .5 seconds, you could read the board frequency, shift right by 1 bit, and call the libplp\_wait function.


[Back to the top](#top)



## Timer ##
{:.ancs}

The timer module is a single 32-bit counter that increments by one every clock cycle. It can be written to at any time. At overflow, the timer will continue counting. The timer module is useful for waiting a specific amount of time with high resolution (20ns on the reference design).

The timer module supports interrupts, and will trigger an interrupt when the timer overflows. The user can configure a specific timed interrupt by presetting the timer value to N cycles before the overflow condition.


[Back to the top](#top)



## Seven Segment Displays ##
{:.ancs}

The Seven Segment Displays module exposes the raw seven segment LEDs to the user, allowing for specialized output. There are `libplp` wrappers that exist for various abstractions.

There are 4 seven segment displays (seven segments plus a dot), mapped to four bytes in the register listed in the [Memory Map](UserManual#Memory_Map.md) section.

The byte order is:

<div class="mobile" markdown="1">

| `[31:24]` | `[23:16]` | `[15:8]` | `[7:0]` |
|:----------|:----------|:---------|:--------|
| Left-most  |  |  | Right-most |
{:.mobile}

</div>

The bits of each byte map to each of the segments as indicated by the figure below.

![{{site.baseurl}}/resources/users_manual_sseg2_fixed.png]({{site.baseurl}}/resources/users_manual_sseg2_fixed.png)

**_IMPORTANT NOTE:_** The seven segment displays have a built-in inverter that requires the user to invert the bits in the byte before converting to hexadecimal.

  * For example, to program the seven segment displays to display the letter "F", the portions of the seven segment display that would light up would be 0, 4, 5, and 6. This would make the byte `0b01110001`. Remember, the bits must be inverted before converting to hexadecimal. This makes the byte `0b10001110`, which in hexadecimal is `0x8E`. Thus, the code for "F" is `0x8E`.


[Back to the top](#top)



## Interrupt Controller ##
{:.ancs}

<div class="mobile" markdown="1">

| Register | Description |
|:---------|:------------|
| `0xf0700000` | Mask |
| `0xf0700004` | Status |
{:.mobile}

</div>

Mask Register:

<div class="mobile" markdown="1">

| bit | Description |
|:----|:------------|
| 31-4 | Reserved |
| 3 | Button Interrupt |
| 2 | UART Interrupt |
| 1 | Timer Interrupt |
| 0 | Global Interrupt Enable |
{:.mobile}

</div>

Status Register:

<div class="mobile" markdown="1">

| bit | Interrupt Reason |
|:----|:-----------------|
| 31-4 | Reserved (Always 0) |
| 3 | Button Interrupt |
| 2 | UART Interrupt |
| 1 | Timer Interrupt |
| 0 | Always 1 |
{:.mobile}

</div>

The interrupt controller marshals the interrupt behavior of the PLP system.

The user uses the two registers in the interrupt controller, mask and status, along with the interrupt registers, $i0 and $i1, to control all interrupt behavior.

Before enabling interrupts, the user must supply a pointer to the interrupt vector in register $i0.

<textarea class="code" rows="5" wrap="off">
main:
  li $i0, isr # put a pointer to our isr in $i0

isr: ...
</textarea>


When an interrupt occurs, the interrupt controller sets the corresponding bit in the status register. Before returning from an interrupt the user must clear any status bits that are resolved or unwanted.

The user enables interrupts by setting any desired interrupts in the mask register, as well as setting the global interrupt enable (GIE) bit. When an interrupt occurs, the GIE bit is automatically cleared and must be set on interrupt exit.

**_IMPORTANT NOTE:_** When returning from an interrupt, set the Global Interrupt Enable (GIE) bit in the delay slot of the returning jump instruction. This is necessary to prevent any interrupts from occurring while still in the interrupt vector.

When an interrupt occurs, the return address is stored in $i1.

A typical interrupt vector:

<textarea class="code" rows="15" wrap="off">
isr:
	li $t0, 0xf0700000
	lw $t1, 4($t0)     # read the status register
	  
	#check status bits and handle any pending interrupts
	#clear any handled interrupts in $t1

	sw $t1, 4($t0)     # clear any handled interrupts in the status register
	lw $t1, 0($t0)     # get the mask register
	ori $t1, $t1, 1    # set GIE

	jr $i1
	sw $t1, 0($t0)     # store the mask register in the delay slot to guarantee proper exit
</textarea>



[Back to the top](#top)



## Performance Counters ##
{:.ancs}

<div class="mobile" markdown="1">

| Address | Description |
|:--------|:------------|
| `0xf0800000` | Interrupts |
| `0xf0800004` | I-cache Misses |
| `0xf0800008` | I-cache Accesses |
| `0xf080000c` | D-cache Misses |
| `0xf0800010` | D-cache Accesses |
| `0xf0800014` | UART Bytes Received |
| `0xf0800018` | UART Bytes Sent |
{:.mobile}

</div>

The performance counter module stores a number of registers that keep count of various events, as shown above. Performance counters are read-only and reset only during board reset.


[Back to the top](#top)



# Hardware Configuration and Bootloader #
{:.ancs}

The PLP Board comes with the `fload` bootloader programmed to the board's ROM, which starts at power-on and board reset.

The bootloader currently supports three functions:

  * Loading data from the UART
  * Memory test
  * Memory test with VGA module enabled

These three functions are initiated by setting the appropriate switch after power-up. When all switches are unset, the LEDs will scroll indefinitely. When one of the above functions is enabled, only LED 0 will be illuminated.

<div class="mobile" markdown="1">

| Switch | Function |
|:-------|:---------|
| 0 | UART Boot / Programming Mode |
| 1 | Memory Test |
| 2 | Memory Test with VGA Module Enabled |
{:.mobile}

</div>

The board can be reset at any time by pressing button 0 or BTNL (depending on model) on the PLP Board . This causes all modules and the CPU to reset, setting the PC to 0. This will restart the bootloader.


[Back to the top](#top)



## Loading the Hardware Configuration and Bootloader ##
{:.ancs}


If the PLP Board does not have this programmed to the board's ROM, you must program it before the PLP Board will accept programming from PLPTool or the command line.

To program the PLP Board with the correct hardware configuration and bootloader, you must first download and install the [Adept Software](http://www.digilentinc.com/Products/Detail.cfm?Prod=ADEPT2) required to program the PLP Board.

**Before running Adept**, you must first make sure that your PLP Board has the correct jumper position so that you are programming the ROM of the PLP Board. To do this, make sure the jumper labeled "**MODE**" is set to _ROM_. The picture below displays how it should look.

![{{site.baseurl}}/resources/users_manual_jumper.png]({{site.baseurl}}/resources/users_manual_jumper.png)

After ensuring the jumper is in the right position, connect the PLP Board to your computer with a micro-USB cable and power on the PLP Board. If the board does not power on once connected and the power switch is in the on position, check to make sure the **POWER SELECT** jumper is in the _USB_ position. The image below shows how that the jumper should be positioned to receive power from the micro-USB cable.

![{{site.baseurl}}/resources/users_manual_jumper2.png]({{site.baseurl}}/resources/users_manual_jumper2.png)

Next, run the Adept software. Adept will bring a window that looks like the one below.

![{{site.baseurl}}/resources/users_manual_adept.png]({{site.baseurl}}/resources/users_manual_adept.png)

If it does not display the proper board in the "Connect:" dialog box in the upper right-hand corner of the window, then the board has not been connected properly. Make sure that the board is connected and powered on before running Adept.

Next, click _Browse..._ on the line with the box labeled **PROM**. Navigate to your the directory where PLP is located. The bootloader is located in /hw/.


The file you select will depend on the board you have:

  * If you have a Nexys 2 (500k), select the file named `nexys2_500k.bit`
  * If you have a Nexys 2 (1200k), select the file named `nexys2_1200k.bit`
  * If you have a Nexys 3, select the file named `nexys3.bit`

Once you've selected the correct bootloader file, click the _Program_ button on the same line as **PROM**. This will load the bootloader onto the PLP Board.

If there are no error messages, the dialog box at the bottom of the Adept window will display `Programming Successful`. Once the programming is complete, turn the PLP Board off, close Adept, and turn the board back on. Your PLP Board now has the proper hardware configuration and `fload` bootloader loaded into the ROM and you are ready to program the board using PLP.

[Back to the top](#top)

## Programming the PLP Board ##
{:.ancs}

In order to program the PLP Board, the PLP Board must be powered on and connected to the computer via a serial connection. It must also have the correct hardware configuration and bootloader (fload) on the board, as well as be in programming mode.  If your PLP Board is not correctly programmed, refer to this [section](UserManual#Loading_the_Hardware_Configuration_and_Bootloader.md) which details how to program the PLP Board with the proper hardware configuration and `fload` bootloader.  To enter programming mode, switch 0 (indicated by SW0 above the switch) must be up/on.

After this is all completed, press the `Program PLP Board` button. This will bring up the window below.

![{{site.baseurl}}/resources/users_manual_program.png]({{site.baseurl}}/resources/users_manual_program.png)

This window allows you to select which port your PLP Board is connected to. There are four preloaded options (COM1, COM2, COM3, and COM4) that can be selected via the drop down menu. If the port you are using isn't listed, you can enter in the port by clicking in the text box and typing the port&#8217;s name.

Once you have selected the correct port, click `Download Program`, and the program will be loaded onto the PLP Board. If there are any errors, they will be displayed in the Output Pane of PLPTool.


[Back to the top](#top)

</div>
