//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "member.h"



/******************************************************************************
 *
 *	function:	member
 *
 *	purpose:	Return true if element in set, false otherwise.
 *			
 *       arguments:      element, set
 *                       
 *	internal
 *	functions:	none
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

int member(char element, char *set)
{
    while (*set)
		if (element == *set++)
			return(1);
	
    return(0);
}
