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
 *  insert_mark.c
 *  GnuSpeech
 *
 *  Version: 0.9
 *
 ******************************************************************************/


/*  HEADER FILES  ************************************************************/
#import "insert_mark.h"



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
	
    while (temp >= at)
		temp[1] = *temp--;
	
    *at = '|';
    (*end)++;
}
