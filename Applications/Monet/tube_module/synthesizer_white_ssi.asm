	NOLIST
;  REVISION INFORMATION ****************************************************************
;
;  _Author: rao $
;  _Date: 2002/03/21 16:49:47 $
;  _Revision: 1.1 $
;  _Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/synthesizer_white_ssi.asm,v $
;  _State: Exp $
;
;
;  _Log: synthesizer_white_ssi.asm,v $
;  Revision 1.1  2002/03/21 16:49:47  rao
;  Initial import.
;
;; Revision 1.1  1995/02/27  17:29:29  len
;; Added support for Intel MultiSound DSP.  Module now compiles FAT.
;;
;
;
;***************************************************************************************
;
;  Program:	synthesizer_white_ssi.asm
;
;  Author:	Leonard Manzara
;
;  Date:	February, 1995
;
;  Summary:	Master include file for the synthesizer on white
;               (Intel) hardware, using the Turtle Beach Multisound
;               DSP card.  This version sends sound data out the ssi.
;
;
;		Copyright (C) by Trillium Sound Research Inc. 1994
;		All Rights Reserved
;
;***************************************************************************************


;***************************************************************************************
;  COMPILATION FLAGS
;***************************************************************************************

BLACK		set	0
MSOUND		set	1
SSI_OUTPUT	set	1

;***************************************************************************************
;  INCLUDE FILES
;***************************************************************************************
	LIST
	include	'synthesizer.asm'

