//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "letter_to_sound_private.h"

/******************************************************************************
 *
 *	function:	insert_mark
 *
 *	purpose:	
 *                       
 *			
 *       arguments:      end, at
 *                       
 *	internal
 *	functions:	none
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

void insert_mark(char **end, char *at)
{
    register char      *temp = *end;
	
    at++;
	
    if (*at == 'e')
		at++;
	
    if (*at == '|')
		return;
	
    while (temp >= at) {
		temp[1] = *temp;
        temp--;
    }
	
    *at = '|';
    (*end)++;
}
