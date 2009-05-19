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
 *  medial_s.c
 *  GnuSpeech
 *
 *  Version: 0.9.1
 *
 ******************************************************************************/


/*  HEADER FILES  ************************************************************/
#import "medial_s.h"
#import "member.h"



/******************************************************************************
 *
 *	function:	medial_s
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

void medial_s(char *in, char **eow)
{
    register char      *end = *eow;
	
    while (in < end - 1) {
		if ((member(*in | 040, "aeiouy")) && (in[1] == 's')
			&& (member(in[2], "AEIOUYaeiouym")))
			in[1] &= 0xdf;
		in++;
    }
}
