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
 *  ie_to_y.c
 *  GnuSpeech
 *
 *  Version: 0.9.1
 *
 ******************************************************************************/


/*  HEADER FILES  ************************************************************/
#import "ie_to_y.h"



/******************************************************************************
 *
 *	function:	ie_to_y
 *
 *	purpose:	If final two characters are "ie" replace with "y" and
 *                       return true.
 *			
 *       arguments:      in, end
 *                       
 *	internal
 *	functions:	none
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

int ie_to_y(char *in, char **end)
{
    register char      *t = *end;
	
    if ((*(t - 2) == 'i') && (*(t - 1) == 'e')) {
		*(t - 2) = 'y';
		*(t - 1) = '#';
		*end = --t;
		return(1);
    }
    return(0);
}
