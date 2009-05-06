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
 *  categories.c
 *  GnuSpeech
 *
 *  Version: 0.8
 *
 ******************************************************************************/

#import "categories.h"
#import "template.h"

/*  GLOBAL VARIABLES, LOCAL TO THIS FILE  */
static int number_of_categories;


void readFromFileCategories(FILE *fp1)
{
    int i;
    char temp[SYMBOL_LENGTH_MAX+1];

    /*  READ CATEGORY SYMBOLS FROM FILE, DUMP INTO BIT BUCKET  */
    fread((char *)&number_of_categories,sizeof(number_of_categories),1,fp1);
    for (i = 0; i < number_of_categories; i++) {
	    fread((char *)&temp,SYMBOL_LENGTH_MAX+1,1,fp1);
    }
}
