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
;  _Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/bootstrap.asm,v $
;  _State: Exp $
;
;
;  _Log: bootstrap.asm,v $
;  Revision 1.1  2002/03/21 16:49:47  rao
;  Initial import.
;
;; Revision 1.1  1995/02/27  17:29:10  len
;; Added support for Intel MultiSound DSP.  Module now compiles FAT.
;;
;
;
;***************************************************************************************
;
;  Program:	bootstrap.asm
;
;  Author:	Leonard Manzara
;
;  Date:	January 13th, 1995
;
;  Summary:	This routine is invoked on hardware reset.  It does minimal chip and
;		msound hardware setup, loads the loader to an out-of-the-way memory
;		location (specified in the the loader code itself), and then jumps to
;		the loader routine.
;
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
;  ROUTINE:	bootstrap
;
;  This routine is invoked on hardware reset.  It does minimal chip and msound hardware
;  setup, loads the loader to an out-of-the-way memory location (specified in the the
;  loader code itself), and then jumps to the loader routine.
;
;  Input: 	none
;  Output:	none
;***************************************************************************************

	org	p:$0000		; interrupt vectors not used during bootstrap sequence

; chip setup
	bset #0,x:m_pbc	      	; Configure port B as Host Interface

; msound specific hardware setup
	movep 	#$3330,x:m_bcr	; set access to external RAM to 3 wait states
	bset    #0,y:$ffc4	; turn on external RAM 

; load the loader into high memory
	jsr	get_input	; get the load address
	move	a,r0		; store the load address in r0
	move	a,r1		; and r1

	jsr	get_input	; get the instruction count
	move	a,x0		; store the instruction count in x0

	do x0,_endloop		; instruction load loop
	 jsr	get_input	; get next instruction
	 move	a,p:(r0)+	; put the instruction into p memory
_endloop

; jump to the loader code in high memory
	jmp	(r1)



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

	IF *>512
	fail 'bootstrap.asm:  on-chip P memory overflow'
	ENDIF
