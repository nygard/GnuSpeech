	NOLIST
;***************************************************************************************
;  FORMATTING FOR LISTING FILE
;***************************************************************************************

	page 144,70,0,0,0	; width, height, top margin, bottom margin, left margin
	opt cex,mex,mu,nocc	; dc expansions, macro expansions, (cross
				; reference,) memory usage, cycle usage reports
	lstcol 23,13,6,1,1	; label, opcode, operand, x, y field widths


	LIST	
;  REVISION INFORMATION ****************************************************************
;
;  _Author: rao $
;  _Date: 2002/03/21 16:49:47 $
;  _Revision: 1.1 $
;  _Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/loader.asm,v $
;  _State: Exp $
;
;
;  _Log: loader.asm,v $
;  Revision 1.1  2002/03/21 16:49:47  rao
;  Initial import.
;
;; Revision 1.1  1995/02/27  17:29:13  len
;; Added support for Intel MultiSound DSP.  Module now compiles FAT.
;;
;
;
;***************************************************************************************
;
;  Program:	loader.asm
;
;  Author:	Leonard Manzara
;
;  Date:	January 10th, 1995
;
;  Summary:	This is a code fragment that is used by bootstrap.asm
;		to load user code.  Note that this loader code is loaded
;		into high memory (in an out-of-the-way place) by bootstrap.asm,
;		allowing user code to be loaded in low memory.
;
;		Copyright (C) by Trillium Sound Research Inc. 1995
;		All Rights Reserved
;
;***************************************************************************************



	NOLIST
;***************************************************************************************
;  INCLUDE FILES
;***************************************************************************************

	include	'ioequlc.asm'


;***************************************************************************************
;  FORMATTING FOR LISTING FILE
;***************************************************************************************

	lstcol
	lstcol	,,,14,14	; change lising format slightly
	opt cc			; enable cycle usage reports
	LIST


;***************************************************************************************
;  HIGH P MEMORY ORIGIN
;***************************************************************************************

LOADER_ORIGIN	equ	$7F80


;***************************************************************************************
;  ROUTINE:	loader
;
;  Reads code and data segments from the host interface, and loads them into memory.
;  Each segment has a header, which indicates memory space type (1 = x, 2 = y, 3 = l,
;  and 4 = p), load address, and word count.  The loader reads this header, and then
;  puts the words into the appropriate memory space.  When the routine gets a 0 memory
;  space type, the loading is done, and the routine cleans up the chip, and then jumps
;  to vector 0, which executes the user's reset code.
;
;  Input: 	none
;  Output:	none
;***************************************************************************************

	org	p:LOADER_ORIGIN

; clear on-chip memory
	clr	a
	move	a,r0
	do #512,_clr
	 move	a,p:(r0)
	 move	a,x:(r0)
	 move	a,y:(r0)+
_clr



next_segment
	jsr 	get_input		; get memory space type
	tst	a			; memory space type 0 means we are done
	jeq	load_done		; so skip to load_done address
	move	a,b			; store the memory space type in b
	
	jsr	get_input		; get load address
	move	a1,r0			; and put it into r0

	jsr	get_input		; get word count
	move	a1,x0			; and put it into x0

	move	#1,a1
	cmp	a,b	#2,a1
	jeq	x_load			; 1 = load x memory

	cmp	a,b	#3,a1
	jeq	y_load			; 2 = load y memory

	cmp	a,b	#4,a1
	jeq	l_load			; 3 = load l memory

	cmp	a,b
	jeq	p_load			; 4 = load p memory

	jmp	load_done		; anything else means we are done



x_load	do x0,x_loop			; load x memory
	 jsr	get_input		; host data to A1
         move	a1,x:(r0)+		; store word where it goes
x_loop
	jmp next_segment


y_load	do x0,y_loop			; load y memory
	 jsr	get_input		; host data to A1
	 move	a1,y:(r0)+		; store word where it goes
y_loop
	jmp next_segment


l_load	move	x0,a			; the count given is for short (24 bit)
	asr	a			; words, not long (48 bit) words, so we must
	move	a,x0			; divide by 2, since we read in 2 short words
	do x0,l_loop			; (1 long word) at a time
	 jsr	get_input		; host data to A1
	 move	a1,x:(r0)		; store MS word where it goes
	 jsr	get_input		; host data to A1
	 move	a1,y:(r0)+		; store LS word where it goes
l_loop
	jmp next_segment


p_load	do x0,p_loop			; load p memory
	 jsr	get_input		; host data to A1
	 move	a1,p:(r0)+		; store word where it goes
p_loop
	jmp next_segment



load_done				; clean up the chip so it is ready
	clr	a			; to run user code
	clr	b
	move 	a,x0
	move 	a,r0
	move 	a,r1
	movec	a,sp			; clear the stack pointer register
	movec	a,la			; clear the loop address register
	movec	a,lc			; clear the loop counter register
	jmp 	$0000			; jump to the reset vector (i.e. execute
					; user code)


;***************************************************************************************
;  SUBROUTINE:	get_input
;
;  Gets one word of data from the host interface, and puts it into register a.
;
;  Input:	none
;  Output:	a
;***************************************************************************************

get_input
	jclr 	#m_hrdf,x:m_hsr,*	; wait for HRDF in HSR (hi data ready)
	move 	x:m_hrx,a		; put next word from host interface into a
	rts

	IF *>$7FFF
	fail 'loader.asm:  off-chip P memory overflow'
	ENDIF
