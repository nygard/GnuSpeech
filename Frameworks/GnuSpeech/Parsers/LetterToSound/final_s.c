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
 *  final_s.c
 *  GnuSpeech
 *
 *  Version: 0.9.1
 *
 ******************************************************************************/


/*  HEADER FILES  ************************************************************/
#import "final_s.h"
#import "member.h"



/******************************************************************************
 *
 *	function:	final_s
 *
 *	purpose:	Check for a final s, strip it if found and return s or
 *                       z, or else return false.  Don't strip if it's the only
 *                       character.
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

char final_s(char *in, char **eow)
{
    register char      *end = *eow;
    char                retval = 0;
	
    /*  STRIP TRAILING S's  */
    if ((*(end - 1) == '\'') && (*(end - 2) == 's')) {
		*--end = '#';
		*eow = end;
    }
	
    /*  NOW LOOK FOR FINAL S  */
    if (*(end - 1) == 's') {
		*--end = '#';
		*eow = end;
		
		if (member(*(end - 1), "cfkpt"))
			retval = 's';
		else
			retval = 'z';
		
		/*  STRIP 'S  */
		if (*(end - 1) == '\'') {
			*--end = '#';
			*eow = end;
		}
    }
    return(retval);
}
