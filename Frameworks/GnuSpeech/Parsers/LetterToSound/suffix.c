//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "suffix.h"
#import "ends_with.h"
#import "vowel_before.h"



/******************************************************************************
 *
 *	function:	suffix
 *
 *	purpose:	Find suffix if vowel in word before the suffix.
 *                       Return 0 if failed, or pointer to character which
 *			preceeds the suffix.
 *
 *       arguments:      in, end, suflist
 *                       
 *	internal
 *	functions:	ends_with, vowel_before
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

char *suffix(char *in, char *end, char *suflist)
{
    register char      *temp;
	
    temp = (char *)ends_with(in, end, suflist);
    if (temp && vowel_before(in, temp + 1))
		return(temp);
    return(0);
}
