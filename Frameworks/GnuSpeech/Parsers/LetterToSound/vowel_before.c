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
 *  vowel_before.c
 *  GnuSpeech
 *
 *  Version: 0.9
 *
 ******************************************************************************/


/*  HEADER FILES  ************************************************************/
#import "vowel_before.h"
#import "member.h"


/******************************************************************************
 *
 *       function:     vowel_before
 *
 *       purpose:      Return the position of a vowel prior to 'position'.
 *                     If no vowel prior return 0.
 *
 *       arguments:    start, position
 *
 *       internal
 *       functions:    member
 *
 *       library
 *       functions:    none
 *
 ******************************************************************************/

char *vowel_before(char *start, char *position)
{
    position--;
    while (position >= start) {
		if (member(*position, "aeiouyAEIOUY"))
			return(position);
		position--;
    }
    return(0);
}
