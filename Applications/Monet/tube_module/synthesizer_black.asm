	NOLIST
;  REVISION INFORMATION ****************************************************************
;
;  _Author: rao $
;  _Date: 2002/03/21 16:49:47 $
;  _Revision: 1.1 $
;  _Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/synthesizer_black.asm,v $
;  _State: Exp $
;
;
;  _Log: synthesizer_black.asm,v $
;  Revision 1.1  2002/03/21 16:49:47  rao
;  Initial import.
;
;; Revision 1.1  1995/02/27  17:29:22  len
;; Added support for Intel MultiSound DSP.  Module now compiles FAT.
;;
;
;
;***************************************************************************************
;
;  Program:	synthesizer_black.asm
;
;  Author:	Leonard Manzara
;
;  Date:	January, 1995
;
;  Summary:	Master include file for the synthesizer on black
;               (NeXT Motorola) hardware.
;               
;
;		Copyright (C) by Trillium Sound Research Inc. 1994
;		All Rights Reserved
;
;***************************************************************************************


;***************************************************************************************
;  COMPILATION FLAGS
;***************************************************************************************

BLACK		set	1
MSOUND		set	0
SSI_OUTPUT	set	0

;***************************************************************************************
;  INCLUDE FILES
;***************************************************************************************
	LIST
	include	'synthesizer.asm'