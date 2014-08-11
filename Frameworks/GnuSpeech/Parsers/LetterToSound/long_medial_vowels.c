//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*  HEADER FILES  ************************************************************/
#import "long_medial_vowels.h"
#import "member.h"



/******************************************************************************
 *
 *	function:	long_medial_vowels
 *
 *	purpose:	
 *                       
 *			
 *       arguments:      in, eow
 *                       
 *	internal
 *	functions:	member
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

int long_medial_vowels(char *in, char **eow)
{
    register char      *end = *eow;
    register char      *position;
	
    /*  McIlroy 4.4 - a  */
    for (position = in; position < end - 3; position++) {
		if (member(position[0], "aeiou"))
			continue;
		if (position[1] != 'u')
			continue;
		if (member(position[2], "aeiouwxy|"))
			continue;
		if (member(position[3] | 040, "aeiouy")) {
			position[1] &= 0xdf;
			continue;
		}
		if ((!(member(position[2], "bcdfgkpt")) || (position[3] != 'r')))
			continue;
		if (member(position[4] | 040, "aeiouy"))
			position[1] &= 0xdf;
		/*  TO FIX cupric WE HAVE TO CHECK FOR |vowel HERE  */
    }
	
    /*  McIlroy 4.4 b, b  */
    for (position = in; position < end - 3; position++) {
		if (!member(*position, "aeo"))
			continue;
		
		if (member(position[1], "aehiouwxy"))
			continue;
		
		if ((position[2] == 'h') && (position[1] == 't')) {
			if (((member(position[3], "ie")) && (member(position[4] | 040, "aou")))
				|| ((position[3] == 'i') && (position[4] == 'e') && (position[5] == 'n')))
				*position &= 0xdf;
			continue;
		}
		
		if (member(position[1], "bcdfgkpt")) {
			if ((position[2] == 'r') && (position[3] == 'i'))
				if (member(position[4] | 040, "aou")) {
					*position &= 0xdf;
					continue;
				}
		}
		
		if (((member(position[2], "ie")) && (member(position[3] | 040, "aou")))
			|| ((position[2] == 'i') && (position[3] == 'e') && (position[4] == 'n')))
			*position &= 0xdf;
	}
	
    /*  McIlroy 4.4 - c  */
    position = in;
    while (!member(*position | 040, "aeiouy") && (position < end))
		position++;
    if (position == end)
		return(0);
    if ((member(position[1] | 040, "aou"))
		&& ((*position == 'i') || ((*position == 'y') && (position + 1 > in))))
		*position &= 0xdf;
	
    return(0);
}
