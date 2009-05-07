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
 *  ends_with.c
 *  GnuSpeech
 *
 *  Version: 0.9
 *
 ******************************************************************************/


/*  HEADER FILES  ************************************************************/
#import "ends_with.h"



/******************************************************************************
 *
 *	function:	ends_with
 *
 *	purpose:	Return 0 if word doesn't end with set element, else
 *                       pointer to char before ending.
 *			
 *       arguments:      in, end, set
 *                       
 *	internal
 *	functions:	none
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

char *ends_with(char *in, char *end, char *set)
{
    register char      *temp;
	
    while (*set) {
		temp = end + 1;
		while (*--temp == *set)
			set++;
		if (*set == '/')
			return(temp);
		while (*set++ != '/');
    }
    return(0);
}
