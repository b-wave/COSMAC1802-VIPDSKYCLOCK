;_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
;
;	File:		VIPDSKYCLOCKP2.asm
;
;_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
; 	Author:	S. Botts
;	Size:		81.2 KB (83,181 bytes)
;	Copyright: (c)2015 by SBOTTS - All righty then.
;
;	Purpose:	Demonstrates an Apollo Guidence Computor (AGC) 
;			(DSKY)Display Keyboard Unit with VIP.  
;	Checksum:	688D
;	CRC-32:	E571B87A
;	Versions:
;	Date:		Tuesday, July 21, 2015, 11:10:53 PM 
;	CPU:		RCA 1802 (1802 COSMAC family)
;
;_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

;--------------------------------------------------------------------------
;	Versions:
;	1.3	Date:	Tuesday, July 21, 2015, 11:10:53 PM - Added NOUNs 65, 36, Keys:  "D", "E", "F" 
;	1.2 	Date:	Sunday, July 19, 2015, 09:44:35 PM - First Release. Only VERBs 16, 35, 36, KEYs "A", "B"
;	1.1 	Date:	Saturday, July 11, 2015, 12:43:52 PM - MET Clock with formatting
;	1.0 	Date:	Sunday, Sunday, June 28, 2015, 8:16:02 AM - MET Clock Display only
;
;****************************(DO NOT MODIFY)**************************************
r0		EQU	0	;DMA address 
r1		EQU	1	;Interrupt Address 
r2		EQU	2	;Stack 
r3		EQU	3	;MAIN Program Counter (PC)
;****************************(DO NOT MODIFY)**************************************
r4		EQU	4	;INDEX
r5		EQU	5	;COUNTERs
r6		EQU	6	;Memory Pointer #1- ALSO USED TO STOrE VAr INST
r7		EQU	7	;Memory Pointer #2- HOLDS VAr INSTrUCTION
r8		EQU	8	;counter in display routine
r9		EQU	9	;INTERRUPT COUNTER  - 61 times per sec in interrupt (DO NOT MODIFY)
ra		EQU	10	;
rb		EQU	11	;
rc		EQU	12	;Second PC -> Returns control to MAIN PC (R3)
rd		EQU	13	;Third PC -> Returns control to RC
re		EQU	14	;KEY Press Result
rf		EQU	15	;
; Redundant reg defines...
r10		EQU	10	;
r11		EQU	11	;
r12		EQU	12	;
r13		EQU	13	;
r14		EQU	14	;
r15		EQU	15	;

;
;=========================================================================
;=============================PAGE 0000===================================
;=========================================================================
	org	$0000
;
start:
	ldi	LOW TV_INT	;Point to 1861 video interrupt $8D
	plo	r1
	ldi	HIGH TV_INT	;Point to 1861 video interrupt $8D
	phi	r1

	ldi	LOW STACK	;R2 is stack in RAM $4D
	plo	r2 
	ldi	HIGH STACK
	phi	r2	;Stack

	ldi	LOW L0014		;Make R3 the PC 
	plo	r3	;Preset all these RN.1 registers to this page.
	ldi	HIGH L0014		;Should be page zero...
	phi	r3	;PC

;	ghi	r0	;DMA - Should be Page 0
	ldi	$00
;	phi	r1	;Point to Interrupt page
;	phi	r2	;Point to Stack page

;continue clearing the R(N).1 (MSB) counters 
	phi	r4	;pointer
	phi	r5	;pointer
	phi	r6	;Self mod code pointer	
	phi	r7	;vAR instruction
	phi	r8	;Clear R8.1 counter in Display
	phi	r9	;Clear R9.1 61 counts/set
	phi	ra
	phi 	rb
;	phi 	rc	;point to key page
	phi 	rd
	phi 	re
	phi 	rf
;**********************REG initializations are complete**********************


;Switch PC to R(3)
	sep	r3		; SET PC to R3 HERE
;Switch INDEX Counter to R(2)
L0014:
	sex	r2		; SET X to R2 HERE

;************************************************************************
; Real Time Clock - Mission Elapsed Time (MET)
;************************************************************************
;
;Description: 
;This is the master background task for VIP_DSKY updated by teh VIDEO 
;Interrupt.
; 
;
;Registers Used:
;	R(9) = Interrupt timer (Do not modify - Read only )
;	R(3) = HHHMMSS Pointer	
;	R(4) = Index Reg R(X)
;	R(5) = NA
;	R(A) = Counter
;
;************************************************************************


STARTCLK:
	inp	1		; Ready to start clock -> Turn ON TV!

L0024:
	ldi	HIGH KEYS	;
 	phi 	r4		;Use R(4)
 	ldi	LOW KEYS	;KEY Buffer
 	plo 	r4

 	ldi	$10
 	plo	re
KES:	
	dec	re

	glo	re
	ani	$0F	;mask off msb
	str	r4	;store on stack
	sex	4
    	out	2	;output via R(x) -> BUS

   	sex	2

 	dec	r4	;point back to buffer

 	b3	KEY	;key pressed?

 	glo	re
 	bnz	KES	;no - scan keys
	
	glo	r9		;get interrupt timer (R9.0) 
	xri	$3D		;61 counts?
	bnz	L0024		;Nope - check again (key in here?)
	plo	r9		;YES it is! - Reset interrupt timer and proceed...

;*************************************************************************
; 1 HZ LOOP Begins here... FLASH Q LED to indicate
;*************************************************************************
;First check for key command...
;*************************************************************************
 	br	NOKEY

KEY:
;======================TEST====================================

; 	ldi	HIGH NOUN_VERB	;point it to some place to store key
; 	phi 	r4			;Use R(4)
; 	ldi	LOW NOUN_VERB+1	;Point to a good screen location
; 	plo 	r4;
;
;
;	glo	re		;use switches for test
;  	ani	$0F		;mask off msb
; 	str	r4
;======================TEST====================================
	
	b3	$		;Wait here for the key to get released!

	ldi	HIGH	CPROC
	phi	rc
	ldi	LOW	CPROC
	plo	rc
	sep	rc

	ldi	$00		;yes since there was a pressed key 
	phi	r9		;lets reset the clock timer again
	plo	r9		;so no overflow occurs

NOKEY:

;*****************FLASH Q LED ********************************
; this is a 1 sec on off flash... 
; heart beat used to show RTC is running
; and updates and Display Flashing Digits as needed.
;**************************************************************
;
	bnq	L001C		; is Q ON?
	req			;YES - turn it off
	br	L001D
L001C:	
	seq			;NO - Turn it on

;*************************************************************
;***************** TIMER LOOP ********************************
;*************************************************************
;
;This is the Main Clock loop. It does not display the time, but
;it maintains an elapsed timer.  It Does the HH:MM:SS count in 
;RAM and controls the rollovers to xx:59:59 
;Zero Hour is checked on exit and gets reset then if needed.
;

L001D:
;	ghi	r3		;Reset Rx.1 to Current page (0)
	ldi	$00		;Reset Rx.1 to page (0)
	phi	r5		;R5.1 
	phi	r4		;R4.1 
	phi	r6		;R6.1 
	phi	r7		;R7.1 

	ldi	HHMMSS+5	;Time stored in RAM (HH:MM:SS))
	plo	r4		;R(4) will be the index
;	plo	r5
 	sex	r4	 	;make R(4) the X Reg
DIGIT:
	ldx			;get time_LSD(x) -> RA.0
	plo	ra
	inc 	ra		;Increment the counter in R(A)
	glo	ra
	str	r4		;put it back in RAM
 	glo	ra
	xri	$0A		;is it 10? 
	bnz	FXDISP	;Not yet - but we are done here no MSD to increment
				;Yes = 0  
	stxd			;then store it time(x) and decrement pointer to point to MSB

	ldx			;get time_MSD(x) -> RA.0
	plo	ra
	inc 	ra		;Increment the counter in R(A)
	glo	ra
	str	r4		;put it back in RAM
 	glo	ra
	xri	$06		;is it 60? (NOTE:even though we check for 60 hours we'll never get there)
	bnz	FXDISP	;Not yet - but we are done here but hours need checking
				;Yes = 0  
	stxd			;then store it time(x) and decrement pointer
	glo	r4		;check was this the last digit? (x=HHMMSS)
NEXTDIG:
	xri	HHMMSS-1
	bnz	DIGIT		;No, get next digit
;	br	FXDISP	;Yes, check if Hours = 24

;
;********************************************
;		FXDISP
;**NOTE** this can move to Main Clock Loop
;********************************************
;Fix the HH display and counters for 24 Hr 
;clock rollover. 23:59:59 -> 00:00:00
;********************************************
;

FXDISP:			; fix for current display move mem into RA -> RF
	ldi	HHMMSS
	plo	r4
	ldxa			;Pick up 10's hours digit
	shr			;01 >> 0 + DF
	shr			;check for hour 20: (Bit 0010)
	bnf	DISPLAY 	;still <20: - not there yet just update the display!

	ldxa			;Pick up 1's Hours
	xri	$04		;is it the hour 24:00?
	bnz	DISPLAY 	; Nope keep going...

;... it's zero hour midnight!

	ldi 	HHMMSS
	plo	r4	;then store it time(x) and decrement pointer
	ldi 	$00
	str	r4
	inc	r4
	str	r4	; fall through to display... 
	br	DISPLAY
;======================================================
;
;		PAGE 0 RAM BUFFERS
;
;======================================================

;********************************************
;		IRQ STACK BUFFER
;********************************************
;these next three locations are the stack for 
;the intrerrupt in RAM ...
;********************************************

	db	$00, $00, $00, $00
STACK:
	db	$00
KEYS:
	db 	$00, $00, $00
CMD:
	db 	$00
CDEX:
	db 	$00
CCNT:
	db 	$00
;********************************************
;		RTC COUNTERS
;********************************************
;Maximum count is 23:59:59 -> 00:00:00
; Note: it is set to 23:59:58 on reset 
;       to test the big rollover
;********************************************
HHMMSS:
HH:
	db	$02, $03	;Hours HH
MM:
	db 	$05, $09	;Minutes MM
SS:
	db	$05, $08	;Seconds SS

;******DAY COUNTER 000 -> 365(6) can go here...
;but remember 366 day leap years? 2016, 2020, 2024,2028, 2032...

;*********************************************************************************
;			DSKY DISPLAY FORMAT
;*********************************************************************************
;This is the BUFFER in RAM that the command and prog processes control the values here.  
;It calls VIP_DIS to format and display for the 1861 PIXIE display.
;The upper nibbles control how the output is displayed and special (+/-_) chars are shown
;
; The DISPLAY REGISTERS1-3. ACTY, NOUN, VERB, AND PROG CAN ALL USE THESE FORMAT controls
; All 5 LINES WITH 6 CHARS PER LINE ARE DISPLAYED EACH UPDATE. The formats are:
; $Fn MSB =($F)lash n = digit (flashes this digit alternating the pattern and $00
; $Cn MSB =($C)LEAR n = digit (does not show this digit)
; for (S)ign:
; $0n MSB =($0)CLEAR (OCTAL), n = digit -> CLEARS THE PATTERN NONE OR THIRD "F" KEY
; $1n MSB =($1)"-" (NEGITIVE DEC), n = digit -> STORES THE HORIZONTAL MINUS PATTERN FIRST "F" KEY
; $2n MSB =($2)"+" (POSITIVE DEC), n = digit -> ADDS THE  VERTICAL PLUS PATTERN SECOND "F" KEY
;Just store them here with the conrtol bits set and the display formatter will take 
;care of the display behaviour. 
;*********************************************************************************

;     	-------------------------------
;DIGI=	SD5	D5	D4	D3	D2	D1
;+ADD=	+0	+1	+2	+3	+4	+5
;          -------------------------------
PROG_REG:
	db	$C0,	$A1,	$C2,	$C3,	$00,	$00

NOUN_VERB:	
;	db	$C0,	$00,	$00,	$C0,	$00,	$00	;Display default with A=00 and B=00
	db	$C0,	$FA,	$FA,	$C0,	$FB,	$FB	;Display default with flashing AA BB
;
;====================LINE=======================+

;

REG1:
	db	$52,	$00,	$00,	$00,	$00,	$00	
REG2:
	db	$51,	$00,	$00,	$00,	$00,	$00
REG3:
	db	$52,	$00,	$00,	$00,	$00,	$00

;**** Add more VERB/NOUN storage to do more levels...
VERB:
	db	$00,	$00
NOUN:
	db	$00,	$00

PROG0:
	db	$00


;
;************************************************************************
;		DISPLAY PROCESS 
;
;************************************************************************
;Description: 
;This is the Simulation tasks for VIP_DSKY runs with these these two 
;subroutines arebcalled to create and format the desired displays.
;
;1) AGC_PROC1= this subroutine simulates some AGC functions to give the
;               display process somthing to display. 
;2) VIP_DS	 = This subroutine simulates the DIS part of the DSKY on a 
;             COSMAC VIP Display.
;Registers Used:
;
;	R(D) = Program Counter (calls the subroutines)
;    R(C) = Program Counter (calls internal subroutines)
;    R(3) = RETURN PC (DO NOT CHANGE in SUBR)
;    R(E) = Key Found (Use with care)
;
;************************************************************************

DISPLAY:

	ldi 	HIGH AGC_PROC1	;AGC PROCESS DEMO Sub Page
	phi	rd
	ldi 	LOW AGC_PROC1	;AGC PROCESS DEMO Sub entry
	plo	rd
	sep 	rd			;call AGC DEMO PC = R(D) now

	ldi 	LOW VIP_DS		;DSKY DISPLAY Sub Page
	plo	rd
	ldi 	HIGH VIP_DS	;DSKY DISPLAY Sub entry
	phi	rd
	
	sep 	rd			;call DiS play! PC = R(D) now

	br	L0024		; returns here -> continue!

;==============================================================
;======================== CONSTANTS =========================== 
;==============================================================
;
;These are used for memory and display pointers
;
;********************************************

PROG_OFFSET:
	DB	LOW PROG_REG+1	;ACTY
	DB	LOW PROG_REG+4	;P1.D1
	DB	LOW PROG_REG+5	;P1.D0
NV_OFFSETS:
	DB	LOW NOUN_VERB+0
	DB	LOW NOUN_VERB+1
	DB	LOW NOUN_VERB+4
	DB	LOW NOUN_VERB+5
MET_OFFSETS:
	
	DB	LOW REG1+4	;10's HRs R1.D1
	DB	LOW REG1+5	; 1's HRs R1.D0
	DB	LOW REG2+4	;10's MINs R2.D1
	DB	LOW REG2+5	; 1's MINs R2.D0
	DB	LOW REG3+2	;10's SECs R3.D3
	DB	LOW REG3+3	; 1's SECs R3.D2

REG_LINE:
	DB	LOW PROG_REG
	DB	LOW NOUN_VERB
	DB	LOW REG1
	DB	LOW REG2
	DB	LOW REG3
;
;=========================================================================
;=============================PAGE 0100===================================
;=========================================================================
	org	$0100

;************************************************************************
;DSKY Display Formatter for COSMAC VIP TV
;************************************************************************
VIP_DS_RET:
	sep	r3
	db	$00
VIP_DS:
;************************************************************************
;
;Description: This is the DiSplay part of DSKY. Since COSMAC VIP uses
;the 1861 PIXIE display all the registers maintained by the COMMAND Process
;are translated into the video display. It is convenient due to paging to
;use one 256-byte page for this display.  We can fit most of the standard
;DSKY in this space but the horizontal lines between the registers 
;and the NOUN and VERB Lamps are not dispalyed. It is also possible to 
;show the status lamps but this is not implemented in this version, all 
;256 bytes are displayed for each update.  The digits are translated by
;a format code that tells how the display appears:
;
;Use:
;	N = 0 - 9 (Digits)
;	0N = Normal digit
;	CN = Clear the cell (N is not shown on screen)
;	FN = Flash the cell (alternate "N" -> " " based on Q State)
;	5N = Sign  Looks kind of like an "S" 0101b (" ", "+", "-", " ", etc...)
;	50 = x0 (xx00b) = " " (OCTAL)
;	51 = x1 (xx01b) = "-" (DECIMAL NEG)
;	52 = x2 (xx10b) = "+" (DECIMAL POS)
;	53 = x3 (xx11b) = " " (OCTAL)
;	DN = FLASHING SIGN? adds one bit to 5N indicate a flash state (1101b)
;
;The display formatter moves the digits from the OUTPUT_REG and puts them
;in speific locations on the VIDEO_BUF page.  each line is placed as 7 digits
;picked up and stored from R->L pointed to by a column counter by DEC R(x).
;The adddress offsets are added and stored and the R(x) offset is the same
;for REG+R(x) -> VIDEO+R(x) buffer.  The command nybble is masked off and this
;result switch tree determines how the 8 digit bit patterns are stored in the 
;video buffer. Each digit in the OUTPUT_REG translates to 8 video lines in 
;the video buffer.
;
;Registers Used:
;	R(4) = VIDEO_BUFFER Display DESTINATION pointer
;	R(5) = ROM Pattern & Table pointer
;	R(6) = DSKY Registers SOURCE pointer
;	R(7) = Character REG position and DSKY VIDEO COLUMN pointer
;	R(8) = Character display pattern line pointer:
;	R(A) = Temp Storage
;	R(B) = Line Counter?
;	R(C) = Column counter?
;	R(D) = PC for this subroutine
;
;
;VIP MON ROM LOCATIONS USED Defines:
index		EQU	8100h		;Offset to patterns in ROM
bitmap	EQU	8110h		;Top of bit patterns in ROM "0"
;***********************************************************************************


	ldi	HIGH index		;Set ROM table's page (80xx)to convert patterns
	phi	r5			;Display Pattern (get 5)  
	
	ldi	HIGH REG_LINE	;point to RAM regigster page to get digits
	phi	r7			;
	phi	ra
	phi	rc
	ldi	LOW REG_LINE	;First digit's offset
	plo	r7			;DIGIT NIBBLE POINTER (SOURCE)

	ldi	HIGH VIDEO_LINE	;Point to video Page locations
	phi	r6			;
	ldi	LOW VIDEO_LINE	;Point to first location
	plo	r6			;

	ldi	HIGH DSKY_L1	;INDEX point to RAM display page (0300) to store
	phi	r4			; patterns for char PATTERN lines on the DSKY

	
L0066:
	ldi	$06		;Max Columns+1
	plo	rb
	ldi	$00		;clear MSBs too (MAY NOT BE NEEDED)
	phi	rb
	phi	r8

	ldn	r6		;get the DSKY OFFSET
	plo	r4		;storage pointer

	ldn	r7		; Pick up pointer to digit from Source (REG)
	plo	ra		; Pick up pointed digit from Source (REG)
	plo	rc		; character index from sSource (REG)

L0067:
	ldn	ra		;load via R(A) but don't increment...
	plo	ra		;SAVE IT in R(A) for processing

	br	CONTCH	;Process Control Nibble

DISPCH:
	adi	LOW index	;Point to the pattern in ROM was $A9  (xx00)+ N = Digit
	plo	r5		;put it in R(5)
	ldn	r5		;Pick up the Nth byte of the Display RAM pattern from ROM table
	plo	r5
		
	ldi	$05		;Do this for all 5 lines of the character bit pattern
	plo	r8		;Line count in R8.0

L0079:
	lda	r5		;get from ROM pattern
	str	r4		;Store on display page
	dec	r8		;next lines
	glo	r8		;Get next digit
	bz	L0080		;All bit patterns stored? YES- get next digit.
	glo	r4		;No keep storing patterns
	adi	$08		;point to next TV line (this points to the byte directly below the last)
	plo	r4		;on the TV screen
	br	L0079		; get next pattern
L0080:

	glo	r4			;get last displayed digit index  
	xri	LOW DSKY_R3+$26	; all digits & lines?
	bz	VIP_DS_RET		; yes --> get out of here!

	dec	rb		; column counter
	glo	rb
	bnz	NEXCOL	; all 5 digits on this line done? 
	inc	r7		; yes-> index pointers to get next lines
	inc	r6		; (both REG & DSKY Lines)
	br	L0066		;back to outside loop to pick up new pointers

				; no -> keep going on this line
; do some math on indexes to point to the next DSKY Column
; and...to get another digit
NEXCOL:
	glo	r4		; move index R4 to point to next DSKY COLUMN
	adi	$E1		; point to top of next display columnn was e1 (-31)
	plo	r4
	inc 	rc		; next digit in REG	(can just index as they are in order)
	glo	rc		; REG digit index pointer ( may be redundant?)
	plo	ra
	br	L0067		; keep going on the inside loop

;***************************************************
; DISPLAY CONTROL CHAR PROCESSING
;***************************************************
;Assumes entry with byte to be displayed is in R(5)
;with the upper Nibble being the control bits
;and the lower the digit to display
;***************************************************

CONTCH:
	glo	ra	;get the found cont+digit
	ani	$f0	;Mask the random digit
	plo	r5	;save it in RB.0

	glo	r5
	xri	$00		;=none?
	bz	FIXCH 	;just show it...

	glo	r5
	xri	$C0		;=Clear?
	bz	CLRCH		;Clear this char

	glo	r5
	xri	$F0		;=Flash?
	bz	FLASH		;alternate this char

	glo	r5
	xri	$50		;=Sign?
	bz	SIGN		;"+, -" or clear

	glo	r5
	xri	$A0		;"PROG INDIC" 
	bz	INDC_A	;flashing cursor

;************************NOT USED IN THIS VERSION***************************************
;also display indicators "$B0" 
;are the indicator "bulbs"
;these may be 4 lines vs. 5 lines?
;locate on left hand displays
;$FE pattern
;[UPLINK] [NO ATT][KEY REL] [OPR ERR] 
;[TEMP] [PROG] [ALT] [VEL]
;
;	glo	r5
;	xri	$B0		;Status [Bulbs]
;	bz	INDC_B	;
;************************NOT USED IN THIS VERSION***************************************

;ELSE: just fall through here for un implemented or unknown
	
FIXCH:
	glo	ra		;get the found cont+digit
	ani	$0F		;Mask the random control code;
	plo	ra
	br	DISPCH	;just show it..

FLASH:
	bnq	CLRCH	; if Q is off clear it
	br	FIXCH	; if Q is on just show it..	
	
CLRCH:
	ldi	$05		;Do this for all 5 lines of the character bit pattern
	plo	r8		;Line count in R8.0
	ldi	$00		;all lines off
;	plo	 r5
	br	WS000	

;**************************************************************************
;NOTE: this section may be re written to use routine located at WS000
;      enter with R5 = 0 for complete count - should work?
;**************************************************************************
;D0079:
;	glo	r5		;get from ROM pattern
;	str	r4		;Store on display page
;	dec	r8		;next lines
;	glo	r8		;Get next digit
;	bz	L0080		;All bit patterns stored? YES- get next digit.
;	glo	r4		;No keep storing patterns
;	adi	$08		;point to next TV line (this points to the byte directly below the last)
;	plo	r4		;on the TV screen
;	br	D0079		; get next pattern
;**************************************************************************

INDC_A:
	ldi	$05		;Writes 5 lines of bit pattern

	plo	r8		;Line count in R8.0

	LDI	$FF		;1st pattern 
	bnq	WS000		; is Q ON?
	LDI	$00		;YES then turn the 2nd pattern on
	br	WS000
SIGN:
	ldi	$05		;Writes 5 lines of bit pattern
	plo	r8		;Line count in R8.0

	glo	ra		;Get the digit
 	xri	$51		;is it = "-" ?
 	bz	MINUS

	glo	ra		;Get the digit
	xri	$52		; is it = "+" ?
	bz	PLUS		; Yes it is


	br	CLRCH		; No anything else - Just clear it
PLUS:
	LDI	$20		;write center vert line [|]for "+"
	BR 	WS000
MINUS:
	LDI	$00		;CLEAR ALL for "-" or unknown

;****************NOTE: **************************
;Almost the same as DISPCH but puts fixed patterns 
;at location R(4) on the screen vs. from a table...
;also the number of lines must be set 
;****************NOTE: **************************
	
WS000:			;
	plo	r5		; fixed pattern is in R5.0
				;
WS001:
	glo	r5		;max count is set above...
	str	r4		;put  fixed pattern on screen
	glo	r4		;point to next TV line 
	adi	$08		;this points to the byte directly below the last
	plo	r4		;on the TV screen

	dec	r8		;next lines (5 lines high)
	glo	r8		;All lines filled (or cleared)
	bz	WS002		;Yes -> done with lines
	br 	WS001		;No -> next line

WS002:
	glo	r4		;fix pozition
	adi	$F8
	plo	r4

	glo	ra		;Get the digit
 	xri	$51		;is it = "-" ?
 	bz	WSBAR		;needs a bar

	glo	ra		;Get the digit
	xri	$52		; is it = "+" ?
	bnz 	L0080		;no then just blank -> next digit
	

; for a sign always put a cross bar up two lines

WSBAR:
	glo	r4		;point to last TV line 
	adi	$F0		;move to the 2 (3?) lines above the last (-24)Was E8
	plo	r4		;line on the TV screen
	ldi	$F8		;[-] pattern
	str	r4		;put it on screen
	glo	r4
	adi	$10		;Put the index back? was 18
	plo	r4		;yup.
	br 	L0080		;DONE! get next digit


;************************NOT USED IN THIS VERSION***************************************
;This is the table of locations we will pick up and store the digits for display on the 
;TV screen They are defined in DSKY pattern and should not change.  these are the locations
;for V35N16 in AGC running PROG00 - this will display all the regs
;************************NOT USED IN THIS VERSION***************************************

;VIDEO_OFFSET:
;	DB	LOW DSKY_L1+2	; A.1 = 0202 (PROG ACTY) 
;	DB	LOW DSKY_L1+5	; P.1
;	DB	LOW DSKY_L1+6	; P.0

;	DB	LOW DSKY_L2+2	; VERB.1
;	DB	LOW DSKY_L2+3	; VERB.0
;	DB	LOW DSKY_L2+5	; NOUN.1
;	DB	LOW DSKY_L2+6	; NOUN.0

;	DB	LOW DSKY_R1+5	;10HR
;	DB	LOW DSKY_R1+6	;01HR
;	DB	LOW DSKY_R2+5	;10MIN
;	DB	LOW DSKY_R2+6	;01MIN
;	DB	LOW DSKY_R3+3	;10SEC
;	DB	LOW DSKY_R3+4	;01SEC
;************************NOT USED IN THIS VERSION***************************************

VIDEO_LINE:
	DB	LOW DSKY_L1+1	;+1 to skip first column
	DB	LOW DSKY_L2+1
	DB	LOW DSKY_R1+1
	DB	LOW DSKY_R2+1
	DB	LOW DSKY_R3+1

;*********************************************************************************
; 1861 DISPLAY INTERRUPT
;*********************************************************************************
; Description:
; interrupt routine for 64x32 format (1 page display memory)  
; Output 1: disable graphics, input 1: enable graphics, EF 1: in frame indicator              
;
;Registers Used:
;	R(0) = DMA pointer
;	R(1) = IRQ vector pointer
;	R(2) = STACK pointer
;	R(9) = Counter (1/61 Sec)
;Hardware:
;	EF1 = In-Frame indicator
;
;**********************************************************************************
TV_INT_ret:
	ldxa		;-> RETURN FROM INTERRUPT (restore pointer)
	ret
;
TV_INT:		;<-Entry on INT
	nop		;Sync
	dec	r2	;point to free location on stack	
	sav		;push T
	dec	r2
	str	r2	;save D

	sex	r2	;Cycles for timing
	sex	r2	;Set D=line start address (6 cycles)

	inc	r9	;increment at 1/61 sec count

	ldi	HIGH DSKY_L1	; Point to Page # of VIDEO DISP
	phi	r0			; display RAM
	ldi	$00
	plo	r0
L009A:
	glo	r0	;1861 displays a line 1st time (8 cycles)
	sex	r2	;SYNC
	sex	r2	;reset line start address (6 cycles)
	dec	r0
			;1861 displays line 2nd time (8 cycles)
	plo	r0
	sex	r2
	dec	r0
			;1861 displays line 3rd time (8 cycles)
	plo	r0
	sex	r2	;reset line start address (6 cycles)
	dec	r0	;

	plo	r0
	bn1	L009A			;Keep looping until EF1 = 1 (loops 32 times)

	br	TV_INT_ret		;Exit on top to restore pointer	
	
;=========================================================================
;=============================PAGE 0200===================================
;=========================================================================

	org	$0200

;************************************************************************
; 						VIP_KY
;************************************************************************
;Description: This is the KeY part of DSKY. Since COSMAC VIP only has 16
; keys, some are reused  The secondary command keys (& Key) are contextual
; depending on what state the key command processor is in.
; 
;Use: This computer use a series of commands in the format
; 	Vxx <Enter>  Nxx <enter>
; 
;EXAMPLES:
;  "A", (V1V2 go blank) V1, V2,"C"(Clear: start over), V1, V2... 
;  "E" (Enter: Saves it)
;    -> if a "D" is entered before "E" the original V1V2 will remain...
;    -> if no NOUN is needed "E" will run the VERB command
;    -> if a NOUN is needed N1N2 will flash until a "B" or "D" is entered ...
;   "B", (N1N2 go blank) N1, N2..as before with VERBs "E" (Enter: Saves it)
;    -> if the V+N is not known both will flash 
;    -> If P1 P2 flash indicates another prog needs the display (except idle?)
;   "D" will release the display to that prog.
;
;************************************************************************


;****************************************************************
; COMMAND PROCESSING (PINBALL)
;****************************************************************
;PURPOSE:
;
;Test for the 6 non-numeric (HEX) keys:
;A = VERB
;B = NOUN
;C = REL/Clear
;D = PROCEED
;E = Enter 
;F = +/-
;
;Enter: with found key in RE
;Exit: command 
;REGISTERS USED:
;
;  R(3) = Calling PC (Do not change!)
;  R(4) = Mem Pointer (X)
;  R(5) = Mem Pointer (Storage pointer)
;  R(D) = prog counter
;  R(E) = Character found by key 

;****************************************************************

CPRET:
	sep	r3
CPROC:
	glo	re
	ani	$0f	;Mask any control bits
	plo	re	;save the key for test

	glo	re
	xri	$0A	;A = VERB
	bz	VERBS	

	glo	re
	xri	$0B	;B = NOUN
	bz	NOUNS

	glo	re
	xri	$0C	;C = CLEAR or REL
	bz	CONS

	glo	re
	xri	$0D	;D = PROCEED
	bz	PROS
	
	glo	re
	xri	$0E	;E = Enter
	bz	ENTER

	glo	re
	xri	$0F	;F = +/-
	bz	SIGNS

 	br	NOHEX ;(return)
;	br	CPRET		
VERBS:
	ldi	HIGH NOUN_VERB	;Get the pointer to Verb Reg
	phi	r4			;to R(4.1)
	ldi	LOW NOUN_VERB+1
	plo	r4			;to R(4.0)
	br 	NV001
NOUNS:
	ldi	HIGH NOUN_VERB
	phi	r4
	ldi	LOW NOUN_VERB+4
	plo	r4			;to R(4.0)

NV001:
	ldn	r4	;get first digit M[R(4)] -> D
	ani	$0f	;Mask any control bits
	adi	$C0	;Set to flash (or clear) 
	str	r4
	inc	r4	;get next digit 
	ldn	r4
	ani	$0f	;Mask any control bits
	adi	$C0
	str	r4	


; this section was put in to stop flash on NN
; not needed *ONLY for test*

;	ldi	LOW NOUN_VERB+4 ; Point to Nouns;
;	plo	r4
;	ldn	r4		;get N1.1
;	ani	$0F		;Clear any control bits
;	str	r4
;	inc	r4		;...and N1.0
;	ldn	r4
;	ani	$0F	
;	str	r4

;===========================================================
;CMD byte works like this:
;===========================================================
;(1) the hex DIGIT is the CMD to execure a command process. 
; The command process follows this process so all HEX chars 
; are filtered and only digits will be used.
;(2) As the command processed it takes needed digits
; and puts them in registers, pointed to by the base CMD
; it only puts chars in slots with control nibbles
; 0xFn, 0xCn etc.  The new digit overwrites the control,
;if the slot has no control it skips to next reg.
;(3) CMD then gets cleared so no further processing takes 
;place...i.e. digits with no where to go get ignored!
;===========================================================

	ldi	HIGH CMD	;put in CMD storage (PAGE 0)
	phi	r5		;Index in R(4.1)
	ldi	LOW CMD	;put in CMD storage 
	plo	r5		;Index in R(4,0)
	glo	re		;Verb or Noun Command 
	str	r5
;///NEW///
	ldi	LOW CCNT	;Make sure we are not storing digits
	plo	r5	
	ghi	r5		;should be 0
	str	r5
;///NEW///
	br	CPRET	


;************************************************
;*************[C] CLEAR KEY**********************
;************************************************
;USE: This key clears the current register 
;it Restarts the last input "2x" command in VERB  
;the display gets clear and restarts the REG line.
;************************************************

CONS:
	ldi	HIGH CFLASHVN
	phi	rd
	ldi	LOW CFLASHVN	; 
	plo	rd	
	sep	rd

	ldi	LOW SAVTIME
	plo	rd	
	sep	rd

	br	CPRET		;No -  just exit
;	br	ENTER		;Reset the line	

;************************************************
;*************[D] PROCEED KEY********************
;************************************************
;This key kills the last command in VERB+1 
;so the display gets returned to the original task.
;in VERB+0.  It should also clear the warning indic
;and any flashing VERB/NOUN +-
;NOTE: V33E does the same thing...
;
;*************************************************


PROS:
	ldi	LOW VERB+1		; CLEAR VERB+1 (last command running)
	plo	r5
	ldi	HIGH $00		;these are on page 0
 	phi	r5
	str	r5
	ldi	LOW NOUN+1		;Clear that Noun too.
	plo	r5
	str	r5

	ldi	NOUN_VERB+1	;If Recent TEST LAMPS
	plo	r4			;YES- "D" KEY will stop it now
	ldn	r4	
	xri	$F8		;Yes- CLEARS the ALL BALLS NOUN
	bz	CLRTST	;are we doing a lamp test?
	br	CPRET		;No -  just exit

CLRTST:			
;	ldi	$00
	str	r4		;R(4) should be pointing to VERB
	inc	r4		;CLEARS the ALL BALLS in VERB	
	str	r4

	inc	r4		
	inc	r4	
	str	r4
	inc	r4	
	str	r4

	ldi	PROG_REG+4	;Point to prog
	plo	r4

	ldi	$00		;ZERO to PROG
	str	r4
	inc	r4	
	str	r4
	br	CPRET	



;************************************************
;*************[E] ENTER KEY**********************
;************************************************
;(1)Assemble VERB and NOUN Bytes and flag to 
;execute! putting a non-zero in the VERB will be 
;the FLAG for it to run
;(2) Also used to {E}nter the REG line in 2N VERBs
;************************************************
ENTER:
	ldi	HIGH CFLASHVN
	phi	rd
	ldi	LOW CFLASHVN	; 
	plo	rd	
	sep	rd
;this is to store REG will go here
;	
;	ghi	r5		;should be 0
;;	str	r5
;	br	CPRET	
ASSEM:
	ldi	HIGH $00		;these are on page 0
 	phi	r5
	ldi	LOW NOUN_VERB+1	; Get current VERB Nybbles
	plo	r5
	ldi	LOW VERB		; VERB storage 
	plo	r4
	sex	r5
;assemble the VERB
	LDXA			;load via R5(X) -> X+1 point to next
	shl             ;shift it into high nibble
	shl
	shl	
	shl
	or			;combine nibbles
	str	r4		;store via R(4)

;assemble the NOUN
	ldi	LOW NOUN_VERB+4	; Get current VERB Nybbles
	plo	r5
	ldi	LOW NOUN		; NOUN storage 
	plo	r4
	LDXA
	shl             	;shift it into high nibble
	shl
	shl	
	shl
	or
	str	r4		;store via x
	sex	r2		;Reset X


	br	CPRET	
;************************************************
;*************[F] +/-SIGN KEY********************
;************************************************
;Processes the a change of SIGN
;Pressing the F key cycles thru all combinations
;of the SIGN in the REGisters it only works on
;digits that have 5X Control byte set. 
;************************************************

SIGNS:

	ldi	HIGH REG1 ; Let's use 1st sign for test....
	phi	r4
	phi	r5
	ldi	LOW CDEX
	plo	r5

	ldn	r5		; get the digit pointer
	plo	r4
	ldn	r4		;pick up the current char
	
	ani	$f0		; mask off type
	xri	$50		;are you really a sign?
	bnz	CPRET 	;NO - then i don't care

	ldn	r4		;YES- increment the current sign
	adi	$01		; increment
	ani	$F3		;mask off 1111 0011 for rollover
	str	r4		;put new sign back to (M)[ R(4) ]

	ldn	r4		;was this the 4th count?
	xri	$53		;need to Get rid of extra key stroke
	bnz	CPRET		;no -  we are good

	ldi	$50		;yes - back to zero!
	str	r4		;
	br	CPRET	

;So now that we sorted all possible HEX - it must be a digit
;but we need tocheck to see if a command needs a digit...

NOHEX:


;Check if we need to store a register digit
	ldi	LOW CCNT	;Do We need a DIGIT in REG?
	plo	r5			;to R(5.0)
	ldi	HIGH CCNT	;Do We need a DIGIT in REG?
	phi	r5			;to R(5.1)
	ldn	r5

	bz	VNCMD		;No - check for VERB or NOUN
	
GETDIG:
	ldi	LOW WRDEC	;Yes - store it in REG RxDx	
	plo	rd
	ldi	HIGH WRDEC
	phi	rd
	sep	rd
 	br	CPRET
;

VNCMD:
	;////////NEW///////
	ldi	LOW CHKCMD	;Yes - store it in REG RxDx	
	plo	rd
	ldi	HIGH CHKCMD
	phi	rd
	sep	rd

 	br	CPRET
	;////////NEW///////
;
;=========================================================================
;=============================PAGE 0300===================================
;=========================================================================	
	org	$0300	
;************************************************************************
; CMD_PROC  - This page does stuff
;************************************************************************
;The command processor detrmines what is displayed. Each display state is
;Based on the V+N entered by the KEY commands, switch statement jumps to
;active process.  The RTC runs in the background updated by the video interrupt
;from the PIXIE display runs in background all the time the user can choose to 
;show the time (MET or RTC)  or do a couple other things. Not all the 
;AGC commands work, the ones not implemented will be ignored.
;These are to be implemented (demonstrated):
;
;	COMMAND	DISCRIPTION
;Set DECIMAL Commands:
;	V21NxxE =	Enter DECIMAL in R1
;	V22NxxE =	Enter DECIMAL in R2
;	V23NxxE =	Enter DECIMAL in R3
;	V25N36E = 	Set Clock (SET TIME = RTC)
;Test Commands:
;	V35E = 	Lamp test (LAMPS)
;	V36E = 	Clear Displays (CLEAR)
;	V37E00E = 	Program 0 (P00h) Note: N00E can be 00 - 99
;Monitor R1, R2, R3 in Decimal
; 	V16N65E = 	Mission Elapsed Time(MET) 
;	V16N36E = 	Real Time Clock (RTC) 
;************************************************************************	

;***************************NOTE**************************************	
;There may also be a fictious command soon:
;	V20N15E = 	YEAR (YY = 15 will update to next year after 365(6) 
;	This causes the days counter on REG1  to update as well as 
;	the MET clock.  It also incremente PROG 0 -> 7 (Day of week) and
;	the day counter resets at 365 and 366 on the next several LYs
;	Note: if you use this as a clock for several years you will burn
;	the display!
;***************************NOTE**************************************	


AGC_RET:
	sep	r3		;all done with AGC result display to process
AGC_PROC1:
	ldi	$00		;all registers are on PAGE 0
	phi	r4
	phi	r5

	ldi	LOW	VERB	; Get the current verb
	plo	r4
	ldn	r4
	bz	AGC_RET	;nothing get out of processing

	xri	$16		;VERB 16 =  Decimal Display R1,R2, R3 
	bz	V16
	
	ldn	r4
	xri	$21		; VERB 21 = Decimal LOAD R1
	bz	V21

	ldn	r4
	xri	$22		; VERB 22 = Decimal LOAD R2 
	bz	V22

	ldn	r4
	xri	$23		; VERB 23 = Decimal LOAD R3 
	bz	V23

	ldn	r4
	xri	$35		; VERB 35 = LAMP TEST
	bz	V35

	ldn	r4
	xri	$36		; VERB 36 = set all REG to 0
	bz	V36
		
	br	NOGO	; not a known process

;**************VERB 16**********************
;Moves the counters to display for V=16 N=35E
;Moves the counters to display for V=16 N=65E
;from Mission Elapse Time (MET) counters on 
;Page 0000 to show Real Time Clock on the DSKY
;
;********************************************
V16:
	ldi	$00	;Put ZEROs in
	plo	rf
	br	CLR3	;clear all 

;**************VERB 36**********************
;Clears all the displays 
;********************************************
V36:
;..............NOTE.............
;need to clear the signs still
;..............NOTE.............

	ldi	$C0	;Put CLEARs in 
	plo	rf

CLR3:
;Set all REGs
	ldi	LOW	SET3
	plo	rc
	ldi	HIGH	SET3
	phi	rc


	ldi	LOW	REG3	;Set REG3
	sep	rc

	ldi	LOW	REG2	;Set REG2
	sep	rc

	ldi	LOW	REG1	;Set REG1
	sep	rc

	ldi	HIGH	VERB	;make Same page 0 (needed?)
	phi	r4
	ldi	LOW	VERB	; Get the current verb
	plo	r4

	ldn	r4		;get current VERB
	xri	$36		;was it VERB 36?
	bnz	CHK_NOUNS	;No - Check some nouns... 
	ldi	$00		;Yes - Clear the VERB
	str	r4
	inc	r4
	inc	r4
	str	r4

	ldi	LOW	NOUN_VERB+1 ; "00" -> VERB
	plo	r4
	ghi	r4
	str	r4
	inc	r4
	str	r4

	inc	r4	; "00" -> VERB	
	inc	r4	
	str	r4
	inc	r4	
	str	r4

	br	AGC_RET	;Done -> Exit

CHK_NOUNS:
	ldi	LOW	NOUN	; Get the current noun
	plo	r4

	ldn	r4
	xri	$36		;NOUN 36?
	bz	LOAD_MET	;YES -> get RTC

	ldn	r4
	xri	$65		;NOUN = 65?
	bz	LOAD_MET	;YES -> Get MET

;..............NOTE.....................................
;If we don't clear VERB here we can keep entering nouns.
;and don't consider it an error... and start flashing
;we can just exit here
;..............NOTE.....................................

	br	AGC_RET	;Every other NOUN -> Exit

	
LOAD_MET:
 	ldi	LOW HHMMSS ;No, Load source is clock
 	plo	r4
	ldi	LOW MET_OFFSETS	;destination is REG1 - REG3
	plo	r5


NEXT_DIG:

	ldn	r5		;get the display pointer
	plo	r6		;R6.0
	ldxa			;Pick up HHMMSS digit, increment index  X+1
	str	r6		;store them in register locations
;	
	inc	r5			; point to next
	glo	r4			;test for done with moves
	xri	LOW HHMMSS+6 
	bnz	NEXT_DIG		;nope - get next one

	br	AGC_RET

;**************VERB 21**********************
;Clear R1 ($0xC0->R1D1 to R1D5)
;Set Sign 
;Load DECIMAL into R1D1 -> R1D5
;
;********************************************
V21:
	ldi	LOW	REG1
	br	V2N

;**************VERB 22**********************
;Load DECIMAL into R2D1 -> R2D5
;SAME AS ABOVE
;*******************************************
V22:
	ldi	LOW	REG2
	br	V2N

;**************VERB 22**********************
;Load DECIMAL into R3D1 -> R3D5
;SAME AS ABOVE
;*******************************************
V23:
	ldi	LOW	REG3

V2N:
	plo	r4
	ldi	$00
	phi	r4
	phi	r5

	ldi	LOW	CDEX	;put the index in memory for later
	plo	r5
	glo	r4
	str	r5

	ldi	$50	;clear the sign
	str	r4
	inc	r4

;Load the counter - NOTE that this is also the flg to process
	ldi	LOW CCNT
	plo	r6	;use as mem pointer 
	ldi	$05	;char count -> CCNT (sign+5 digits)
	plo	r5	;loop counter = R5
	str	r6	;M[R6] = CCNT 

V2XCLRL:			;clear the register 
	ldi	$C0		;Clear command
	str	r4
	inc	r4
	dec	r5		;Decrement Loop Count
	glo	r5
	bnz	V2XCLRL

	br	CLRVN		;Done with this verb
	

NOGO:
;assuming still  PAGE 0000 here...

	ldi	LOW NOUN_VERB+1
	plo	r4			;to R(4.0)

	ldn	r4	;get first digit M[R(4)] -> D
	ani	$0f	;Mask any control bits
	adi	$F0	;Set to flash 
	str	r4
	inc	r4	;get next digit 
	ldn	r4
	ani	$0f	;Mask any control bits
	adi	$F0
	str	r4

CLRVN:	
	ldi	VERB	;Done- clear out old verb

	plo	r4
	ldi	$00
	str	r4
;//NEW
	ldi	LOW FLASHVN
	plo	rc
	ldi	HIGH FLASHVN
	phi	rc
	sep	rc

	br	AGC_RET

V35:
	ldi	LOW	SET3
	plo	rc
	ldi	HIGH	SET3
	phi	rc

	ldi	$08	;<<<this can be changed to use a variable
	plo	rf

	ldi	LOW	REG3	;Set REG3
	sep	rc

	ldi	LOW	REG2	;Set REG2
	sep	rc

	ldi	LOW	REG1	;Set REG1
	sep	rc

	ldi	VERB	;TESTVERB LAMPS
	plo	r4
	ldi	$88
	str	r4

	ldi	NOUN_VERB+1
	plo	r4
	ldi	$F8	;flashing 88 in VERB
	str	r4
	inc	r4
	str	r4

	inc	r4	;Point to NOUN
	inc	r4	
	str	r4
	inc	r4	
	str	r4

	ldi	PROG_REG+4	;Point to prog
	plo	r4

	ldi	$F8	;flashing 88 in PROG
	str	r4
	inc	r4	
	str	r4

	br	AGC_RET


;=========================================================================
;=============================PAGE 0400===================================
;=========================================================================
	org	$0400

;*********************************************************************
;                      SUBROUTINE: SET3
;*********************************************************************
;USE: Load  Registers SUBR
;
;CDEX= REG Addr (on PAGE 0)
;R(C) = PC
;R(D) = CALLING PC (Don't Use)
;*********************************************************************
SET3_RET:
	sep	rd	;Restore CALLING PC
SET3:
	plo	r4	;Register address in POINTER
	ldi	$00	;Assuming PAGE 0
	phi	r4
	phi	r5
	ldi	LOW	CDEX	; Character Pointer on PAGE 0
	plo	r5
	glo	r4
	str	r5

;DO the SIGN for this REG..	
	glo	rf
	xri	$C0
	bnz	SETPLS
	ldi	$50		;CLR Sign
	br	SETCLR
SETPLS:
	ldi	$52		;set (+) Sign
SETCLR:
	str	r4
	inc	r4

;SET the rest of the five digits in the REG
	ldi	$05	;char counter
	plo	r5
	

S3LOOP:			;clear the register 
;	ldi	$08	;<<<this can be changed to use a variable
	glo	rf
	str	r4
	inc	r4
	dec	r5
	glo	r5
	bnz	S3LOOP	;all 5 set?
	br	SET3_RET	;yes! Done RETURN

;*********************************************************************
;                      SUBROUTINE: WRDEC
;*********************************************************************
;USE: Load DECIMAL Register SUBR
;CALL: From NO HEX (Only digits 0 -9 should be passed 
;CDEX = REG Addr (on PAGE 0)
;CCNT = COUNTER Addr (on PAGE 0)
;R(D) = PC
;R(C) = CALLING PC (Don't Use)
;R(4) = MEMORY location for INDEX
;R(6) = INDEX pointer REG
;R(5) = MEMORY location for COUNTER
;R(7) = COUNTER REG
;
;MEMORY STORAGE:
;CDEX = Pointer to Current Register location
; If it is 0\clear we don't need any digits
; if M(RX) = $Cx then store
; DEC CCNT
; IF CCNT = 0 then done
;CCNT = Counter 5 -> 0 
; 
;*********************************************************************
RET_WRDEC:
	sep	rc
WRDEC:
	ldi	HIGH CDEX	;Get the REG pointer to RegN
	phi	r4			;to R(4.1)
	phi	r5			;to R(5.1)
 	phi	r6			;to R(6.1)
	ldi	LOW CDEX	;index storage
	plo	r4			;to R(4.0)
	plo	r6		;index

;	ldi	HIGH CCNT	;Get the REG Counter ->Page Zero?
;	phi	r5
			;to R(5.1)
	ldi	LOW CCNT
	plo	r5			;to R(5.0)
	ldn	r5
	plo	r7
	bz	RET_WRDEC		;all digits? Yes exit.

	ldn	r6		;point to reg location
	plo	r6
	ldn	r6		;now get current reg contents
	ani	$F0		;
	xri	$C0		; is the Space clear? 
	bz	SAVDIG	;Yes - we can use it -> save it
	inc	r6		;No - this will skip over sign and digit
;	dec	r7		;this may have been the last needed?

SAVDIG:
	glo	re		;get the last key
	str	r6		;SAVE DIGIT NOW!
	

	inc	r6		;point to next
	glo	r6
	str	r4		;put it in index storage
	
	glo	r7		;if it is already zero don't dec
	bz	RET_WRDEC

	dec	r7		;Dec and Save the count
	glo	r7		;
	str	r5		;Save it in memory R7 -> M[R5]
	br	RET_WRDEC	;Done with this digit

;*********************************************************************
;                      SUBROUTINE: CHKCMD
;*********************************************************************
;USE: Checks for "A" VERB or "B" NOUN Command 
;CALL: From HEX (Only digits A - F should be passed 
;REG Used:
;R(D) = PC
;R(C) = CALLING PC (Don't Use)
;R(4) = MEMORY location for INDEX
;R(5) = MEMORY location for COUNTER
;R(6) = INDEX pointer REG
;*********************************************************************

CMRET:
	sep	rc
CHKCMD:
;Check if we need a VERB or NOUN  Digit
	ldi	LOW CMD	;CMD pointer 
	plo	r5		;Index in R(5.0)
	ldi	HIGH CMD	;CMD pointer 
	phi	r5		;Index in R(5.1)

	ldn	r5
	bz	CMRET		; No command to process - check if data is needed
	xri	$0A
	bz	VERCMD	;VERB

	ldn	r5
	xri	$0B
	bz	NOUCMD	;NOUN

	ldi	$00	;clear it out if it was 
	str	r5	;not a known command...
;****NOTE this may be the issue causing DEC store to over write VERB.
;     BUT there is  no more room on Page 0400 we are at 04FF 
;     May be able to put the R4.1 initialize  after R5.1 above will get the 2 bytes needed to fixit
;`````.....`````.....`````.....`````.....`````.....`````.....`````.....`````.....`````.....`````.....
;	br	CMRET	;  Without the BR it drops into VERBs not exit
;`````.....`````.....`````.....`````.....`````.....`````.....`````.....`````.....`````.....`````.....

;OK so we need a VERB Digit...
VERCMD:
	ldi	HIGH NOUN_VERB	;Get the pointer to Verb Reg
	phi	r4			;to R(4.1)
	ldi	LOW NOUN_VERB+1
	plo	r4			;to R(4.0)
	br	NVCM1

;OK so we need a NOUN Digit...
NOUCMD:
	ldi	HIGH NOUN_VERB
	phi	r4
	ldi	LOW NOUN_VERB+4
	plo	r4			;to R(4.0)

NVCM1:
	ldn	r4	;get the storage location
	ani	$F0	;check to see if new digit is needed	
	bz	NEXNV	; no - control is clear so it is loaded
	br	WRTNV

NEXNV:
	inc	r4	;increment storage pointer
	ldn	r4	;get the next storage location
	ani	$F0	; check for need...	
	bnz	WRTNV	; yes control is there write new one
	ldi	$00	; no control -  then we are done... 
	str	r5	; kill the command via CMD pointer
	br	CMRET	

WRTNV:
	glo	re	;finally, get our digit an put it in REG
	ani	$0F	; make double sure no control in MSB
	str	r4
	br	CMRET
;*********************************************************************
;                      SUBROUTINE: FLASHVN
;*********************************************************************
;USE: Sets the 
;CALL: From CMD Processing
;REG Used:
;R(D) = PC
;R(C) = CALLING PC (Don't Use)
;R(4) = MEMORY POINTER
;*********************************************************************


FLASHVN:
	ldi	HIGH NOUN_VERB
	phi	r4
	ldi	LOW NOUN_VERB+1
	plo	r4

	ldn	r4
	ani	$0f	;Mask any control bits
	adi	$F0	;FLASH VERB MSB
	str	r4

	inc	r4
	ldn	r4
	ani	$0f	;Mask any control bits
	adi	$F0	;FLASH VERB LSB
	str	r4

	inc	r4	;Point to NOUN
	inc	r4
	ldn	r4
	ani	$0F	;FLASH NOUN MSB
	adi	$F0
	str	r4

	inc	r4	;FLASH NOUN LSB
	ldn	r4
	ani	$0F
	adi	$F0	
	str	r4

	sep	rd

;*********************************************************************
;                      SUBROUTINE: FLASHVN
;*********************************************************************
;USE: Sets the 
;CALL: From CMD Processing
;REG Used:
;R(D) = PC
;R(C) = CALLING PC (Don't Use)
;R(5) = MEMORY POINTER
;*********************************************************************
CFLASHVN:

	ldi	LOW NOUN_VERB+1	; Get current VERB Nybbles
	plo	r5	
	ldi	HIGH NOUN_VERB+1	; Get current VERB Nybbles
	phi	r5
	
	ldn	r5	;Should be pointing to VERBs display 
	ani	$0F	;Stop FLASH MSB
	str	r5
	inc 	r5
	ldn	r5
	ani	$0F	;Stop FLASH LSB
	str	r5
	
	inc	r5	;now point to NOUNs display
	inc	r5

	ldn	r5
	ani	$0F	;Stop FLASH MSB
	str	r5
	inc 	r5
	ldn	r5
	ani	$0F	;Stop FLASH LSB
	str	r5

	ldi	LOW NOUN_VERB+2	; Get current VERB Nybbles
	plo	r5
	ldn	r5

	sep	rc

;	ldi	LOW REG1+4	;Hours
;	ldi	LOW REG3+2	;Sec
;SAVMN:
;	ldi	LOW REG2+4	;Mins
;	plo	r5
;	ldn	r5
;	phi	rf
;	inc	r5
;	ldn	r5
;	plo	rf

;	ldi	LOW MM
;	plo	r5
;	ghi	rf
;	str	r5
;	inc	r5
;	glo	rf
;	str	r5

;*********************************************************************
;                      SUBROUTINE: SAVTIME
;*********************************************************************
;USE: Sets the TIME, Moves HHMSS -> REG1, 2 or 3 based on the current
;Verb in use: 21, 22, or 23. 
;CALL: From KEY / CMD Processing [E] or [F] keys
;
;REGISTER USE:
;R(D) = PC
;R(C) = CALLING PC (Don't Use)
;R(4) = MEMORY HHMMSS SOURCE POINTER
;R(5) = MEMORY REGn POINTER
;R(F) = TEMP Storage - Holds the LSB for Jump table
;*********************************************************************

SAVTIME:
;	ldi	HIGH NOUN_VERB	;Get the pointer to Verb Reg
;	phi	r4			;to R(4.1)
	ldi	LOW NOUN_VERB+1
	plo	r4
	ldn	r4
	ani	$0F		;Clears the old control nibble
	xri	$02		;Check for a 20 VERB
	bnz	SAVEXIT		;Not a save -> EXIT

	inc	r4		;Move to VERB LSB
	ldn	r4
	ani	$0F		;Clears the old control nibble
	plo	rf		;Hold LSB as index

	glo	rf		;is it VERB 21?
	xri	$01
	bnz	MOV22		;No Check for next verb...

	ldi	LOW REG1+4	;Yes save R1 -> Hours
	plo	r4
	ldi	LOW HH
	plo	r5
	br	SAV01

MOV22:
	glo	rf	;is it VERB 22?
	xri	$02
	bnz	MOV23
	ldi	LOW REG2+4	;Yes it is Save R2 -> MIN
	plo	r4
	ldi	LOW MM
	plo	r5
	br	SAV01

MOV23:
	ldi	LOW REG3+4	;We'll Assume it is SEC
	plo	r4
	ldi	LOW SS
	plo	r5

;This moves the selected REGx -> HH , MM, or SS
;Sourece is R4, Destinatio is R5
SAV01:	
	ldn	r4	;pick up RTC
	str	r5	;save in REGn
	inc	r4	;Next Digit
	inc	r5
	ldn	r4	;Move it
	str	r5
;Return to calling key processor [E] or [C] key
SAVEXIT:
	sep	rc

;=========================================================================
;=============================PAGE 0500===================================
;=========================================================================

;*******************************************************
;
;  DSKY DISPLAY PAGE MAP (256 byte SCREEN)
;
;*******************************************************
;This needs to point to its own 256 byte page:
 
	org	$0500

;****************************** MAP *********************************
;
; A1 = 0502 (PROG ACTY)         P1 = 0505  P0 = 0506 (PROG)
; V1 = 054A  V0 =054B (VERB)    N1 = 054D  N0 = 054E (NOUN)

;
; ====================== 0548 (LINE) ================================ 
; 
; SR1 = 0579 R1.4 = 057A r1.3 = 057B r1.2 = 057C r1.1 = 057D r1.0 = 057E  (REG1) 
; SR2 = 05A9 R2.4 = 05AA r2.3 = 05AB r2.2 = 05AB r2.1 = 05AD r2.0 = 05AE  (REG2)
; SR3 = 05D9 R3.4 = 05DA r3.3 = 05DB r3.2 = 05DC r3.1 = 05DD r3.0 = 058E  (REG3)
;*******************************************************************

;initialize by loading the following patterns... not needed if page gets init in program
;Line1:    +0   +1   +2   +3   +4   +5   +6   +7
;Line2:    +8   +9   +a   +b   +c   +d   +e   +f

DSKY_L1:
  
	db	$00, $00, $ff, $00, $00, $f0, $f0, $00	;0 0500 (PROG ACTY TOP) --- (PROG TOP)
	db	$00, $00, $ff, $00, $00, $90, $90, $00	;1 0508
	db	$00, $00, $ff, $00, $00, $90, $90, $00	;2 0510
	db	$00, $00, $ff, $00, $00, $90, $90, $00	;3 0518
	db	$00, $00, $ff, $00, $00, $f0, $f0, $00	;4 0520
	db	$00, $00, $00, $00, $00, $00, $00, $00	;  0528 (VERB Line)   (NOUN L LINE)

DSKY_L2: 
	db	$00, $00, $60, $f0, $00, $f0, $f0, $00	;0 0538 (VV=16  NN=65)
	db	$00, $00, $20, $80, $00, $80, $80, $00	;1 0540
	db	$00, $00, $20, $f0, $00, $f0, $f0, $00	;2 0548
	db	$00, $00, $20, $90, $00, $90, $10, $00	;3 0550
	db	$00, $00, $70, $f0, $00, $f0, $f0, $00	;4 0558
	db	$00, $00, $00, $00, $00, $00, $00, $00	; 
DSKY_LINE:
	db	$00, $ff, $ff, $ff, $ff, $ff, $ff, $00	; 0569 (LINE)
	db	$00, $00, $00, $00, $00, $00, $00, $00	; 0570 (BLANK)
DSKY_R1:
	db	$00, $20, $F0, $f0, $f0, $f0, $f0, $00	;0 0578 (REG1 +/- 3 -- 4 TOP)
	db	$00, $20, $90, $90, $90, $90, $90, $00	;1 0580
	db	$00, $F8, $90, $90, $90, $90, $90, $00	;2 0588
	db	$00, $20, $90, $90, $90, $90, $90, $00	;3 0590
	db	$00, $20, $f0, $f0, $f0, $f0, $f0, $00	;4 0598
	db	$00, $00, $00, $00, $00, $00, $00, $00	; 05A0 (BLANK)
DSKY_R2:
	db	$00, $20, $f0, $f0, $f0, $f0, $f0, $00	;0 05A8 (REG2 +/- 3 -- 4 TOP)
	db	$00, $20, $90, $90, $90, $90, $90, $00	;1 05B0
	db	$00, $F8, $90, $90, $90, $90, $90, $00	;2 05B8
	db	$00, $20, $90, $90, $90, $90, $90, $00	;3 05C0
	db	$00, $20, $f0, $f0, $f0, $f0, $f0, $00	;4 05C8
	db	$00, $00, $00, $00, $00, $00, $00, $00	;05DO (BLANK)
DSKY_R3:
	db	$00, $20, $f0, $f0, $f0, $f0, $f0, $00	;0 05D8 (REG3 +/- 3 -- 4 TOP)
	db	$00, $20, $90, $90, $90, $90, $90, $00	;1 05EO
	db	$00, $F8, $90, $90, $90, $90, $90, $00	;2 05E8
	db	$00, $20, $90, $90, $90, $90, $90, $00	;3 05F0
	db	$00, $20, $f0, $f0, $f0, $f0, $f0, $00	;4 05F8
 	db	$00, $00, $00, $00, $00, $00, $00, $00	;  0530 (BLANK) (0xFF is the end of Buffer)




	END
