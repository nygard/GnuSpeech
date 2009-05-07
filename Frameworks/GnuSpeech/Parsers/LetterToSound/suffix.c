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
 *  suffix.c
 *  GnuSpeech
 *
 *  Version: 0.9
 *
 ******************************************************************************/


/*  HEADER FILES  ************************************************************/
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
