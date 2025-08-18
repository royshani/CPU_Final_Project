----------------------------------------------------------------------------------
				Description of the source code test0.asm:
----------------------------------------------------------------------------------
Output: PORT_LEDG[7-0], PORT_LEDR[7-0], PORT_HEX0, PORT_HEX1, PORT_HEX2, PORT_HEX3
RESET:  Pushbutton KEY0

1) counting up by 1 (every 4 MCLK cycles), shown separately onto all output devices
2) On RESET: clear all outputs
----------------------------------------------------------------------------------
				Description of the source code test1.asm:
----------------------------------------------------------------------------------
Input:  PORT_SW[7-0] 
Output: PORT_LEDG[7-0], PORT_LEDR[7-0], PORT_HEX0, PORT_HEX1, PORT_HEX2, PORT_HEX3
RESET:  Pushbutton KEY0

The program execution:
1) if SW0 is set(other SW1-SW7 don't matter):
		counting up by 2, shown separately onto all output devices
   if SW1 is set(other SW0,SW2-SW7 don't matter):
		counting down by 2, shown separately onto all output devices
   else
		do nothing (output state preserved)
2) On RESET: clear all outputs
----------------------------------------------------------------------------------
				Description of the source code test2.asm:
----------------------------------------------------------------------------------
Input:  PORT_SW[7-0] 
Output: PORT_LEDG[7-0], PORT_LEDR[7-0], PORT_HEX0, PORT_HEX1, PORT_HEX2, PORT_HEX3
RESET:  Pushbutton KEY0

The program execution:
1) if SW0 is set(other SW1-SW7 don't matter):
		sll by 1 of [ind_7 <- ind_1] in serial once, shown separately onto output devices
   if SW1 is set(other SW0,SW2-SW7 don't matter):
		srl by 1 of [ind_6 -> ind_0] in serial once, shown separately onto output devices
   else
		doing nothing (output state saved)
2) On RESET: clear all outputs
----------------------------------------------------------------------------------
