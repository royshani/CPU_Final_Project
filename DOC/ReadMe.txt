Final Project - MIPS-Based Microcontroller Architecture
This project involves designing a MIPS CPU core with a single-cycle architecture, including Memory Mapped I/O, interrupt handling, and a serial communication peripheral.

Microcontroller Unit 
This is the main control unit of the microcontroller.

Basic Timer The basic timer, or counter, is a specialized hardware component within many microcontrollers. Its primary function is to count, either up or down, based on configuration. For instance, an 8-bit timer counts from 0 to 255 and will reset to 0 after reaching its maximum value.

Timers offer various configurable options, such as setting a custom rollover value, where instead of resetting at 255, the timer might reset at 100. Timers can also be linked with other microcontroller hardware, like automatically toggling a pin when the timer rolls over.

Common hardware functions associated with timers include:

Output Compare (OC): Toggles a pin when the timer hits a specified value.
Input Capture (IC): Measures the timer counts between events on a pin.
Pulse Width Modulation (PWM): Toggles a pin at a certain timer value and on rollover, allowing control of power delivery to other devices by adjusting the duty cycle.
In this project, the timer is configured to count upwards and utilize the output compare mode in continuous mode.

General-Purpose Input/Output 
To create a user interface, we integrated an input and output interface into the MCU, which can include elements like LEDs, enclosures, and buttons. Communication with the GPIO components occurs through the system's bus lines as needed. Additionally, this interface can generate interrupts, such as a button press, triggering an interrupt service routine (ISR) to execute specific tasks.

Interrupt Controller 
External interrupt support has been added to handle signals from hardware peripherals. These interrupts are prioritized according to the project's task requirements. An interrupt occurs when a hardware component raises an interrupt request (IRQ) signal, provided the corresponding interrupt is enabled and no other interrupts are currently being processed.


Unsigned Binary Division Multicycle Accelerator
The division operation is completed after N DIVCLK cycles, where N=32 for this project, meaning the results are ready after 32 DIVCLK cycles once the second operand (DIVISOR) is loaded.

Optimized Address Decoder 
This component determines the chip select signal for the appropriate component based on the given address.

Output Peripheral 
Responsible for managing output operations within the GPIO components.

Input Peripheral 
Responsible for managing input operations within the GPIO components.

7-Segment Decoder 
This component decodes a given hexadecimal value to the appropriate signal combination for the seven-segment display on the DE10 board.