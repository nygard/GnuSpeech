/*******************************************************************************
 *
 *  Copyright (c) 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
 *  
 *  Contributors: 
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *******************************************************************************
 *
 *  medial_silent_e.c
 *  GnuSpeech
 *
 *  Version: 0.9.1
 *
 ******************************************************************************/


/*  HEADER FILES  ************************************************************/
#import "medial_silent_e.h"
#import "member.h"
#import "insert_mark.h"



/******************************************************************************
 *
 *	function:	medial_silent_e
 *
 *	purpose:	
 *                       
 *   arguments:  input, eow
 *                       
 *	internal
 *	functions:	member, insert_mark
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

void medial_silent_e(char *input, char **eow)
{
    char               *end = *eow;
    register char      *position;
    register int        index;
	
    for (position = input + 2; position < end - 5; position++) {
		if (!member(position[0], "bcdfgmnprst"))
			continue;		/* c */
		if (!member(position[1], "bdfgkpt"))
			continue;		/* k */
		if ((position[2] != 'l') || (position[3] != 'e'))
			continue;		/* le */
		if (member(position[4] | 040, "aeiouy"))
			continue;		/* s */
		if (position[4] == '|')
			continue;
		
		index = 5;
		while (!member(position[index] | 040, "aeiouy|")) {	/* he */
			index++;
			if (&position[index] >= end) {
				index = 0;
				break;
			}
		}
		
		if (!index)
			continue;
		if (position[index] == '|')
			continue;
		if ((position[index] == 'e') && (position[index + 1] == '|'))
			continue;
		insert_mark(&end, &position[3]);
		break;
    }
	
    for (position = input; position < end - 5; position++) {
		if ((member(position[0], "aeiou#")))
			continue;
		if (!member(position[1], "aiouy"))
			continue;
		if (member(position[2] | 040, "aehiouwxy"))
			continue;
		if (position[3] != 'e')
			continue;
		if (member(position[4] | 040, "aeiouynr"))
			continue;
		
		index = 5;
		if ((position[index] == '|') ||
			((position[index] == 'e') && (position[++index] == '|')))
			continue;
		index++;
		if (!member(position[index] | 040, "aeiouy"))
			continue;
		insert_mark(&end, &position[3]);
		position[1] &= 0xdf;
		break;
    }
	
    for (position = input + 1; position < end - 5; position++) {
		if (position[0] != 'o')
			continue;
		if (!member(position[1], "aiouyU"))
			continue;
		if (member(position[2] | 040, "aehiouwxy"))
			continue;
		if (position[3] != 'e')
			continue;
		if (member(position[4] | 040, "aeiouynr"))
			continue;
		index = 5;
		if ((position[index] == '|') ||
			((position[index] == 'e') && (position[++index] == '|')))
			continue;
		index++;
		if (!member(position[index] | 040, "aeiouy"))
			continue;
		insert_mark(&end, &position[3]);
		break;
    }
    *eow = end;
}
