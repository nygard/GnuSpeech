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
 *  apply_stress.c
 *  GnuSpeech
 *
 *  Version: 0.9.1
 *
 ******************************************************************************/


/*  HEADER FILES  ************************************************************/
#import "apply_stress.h"
#import "stresstables.h"
#import <stdio.h>
#import <strings.h>


/*  GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ***********************************/
static int stress_suffix(char *orthography, int *type);
static int light(char *sb);
static int prefix(char *orthography);




/******************************************************************************
 *
 *	function:	apply_stres
 *
 *	purpose:	Find all syllables and make an array of pointers to
 *                       them.  Mark each as either weak or strong in a separate
 *                       array;  use the table of stress-affecting affices to
 *                       find any.  If none, look for stress-repellent prefices.
 *                       Decide which syllable gets the stress marker;  insert
 *                       it at the pointer to that syllable.  Returns nonzero
 *                       if an error occurred.
 *			
 *       arguments:      buffer, orthography
 *                       
 *	internal
 *	functions:	stress_suffix, light, prefix
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

int apply_stress(char *buffer, char *orthography)
{
    char               *syll_array[MAX_SYLLS];
    char               *spt, ich, temp = '\0';
    int                 index;
    int                 type, t, syll = (-1);
    int                 last_was_break = 1;
	
    for (index = 0, spt = buffer; *spt; spt++) {
		if (last_was_break) {
			last_was_break = 0;
			syll_array[index++] = spt;
		}
		if (*spt == '.')
			last_was_break = 1;
    }
	
    if (index > MAX_SYLLS) {
		return(1);
    }
	
    /*  RETURNS SYLLABLE NO. (FROM THE END) THAT IS THE START OF A STRESS-AFFECTING
	 SUFFIX, 0 IF NONE; AND TYPE  */
    t = stress_suffix(orthography, &type);
    if (t) {
		if (type == AUTOSTRESSED)
			syll = index - t;
		else if (type == PRESTRESS1)
			syll = index - t - 1;
		else if (type == PRESTRESS2)
			syll = index - t - 2;
		else if (type == PRESTRESS3) {
			syll = index - t - 1;
			if (syll >= 0 && light(syll_array[syll]))
				syll--;
		} else if (type == NEUTRAL)
			index -= t;
    }
	
    if ((syll < 0) && prefix(orthography) && (index >= 2))
		syll = 1;
	
    if (syll < 0) {		/* if as yet unsuccessful */
		syll = index - 2;
		if (syll < 0)
			syll = 0;
		if (light(syll_array[syll]))
			syll--;
    }
	
    if (syll < 0)
		syll = 0;
	
    spt = syll_array[syll];
	/*  strcpy(spt+1,spt); */
    ich = '\'';
    while (ich) {
		temp = *spt;
		*spt = ich;
		ich = temp;
		spt++;
    }
    *spt = '\0';
    return(0);
}



/******************************************************************************
 *
 *	function:	stress_suffix
 *
 *	purpose:	
 *                       
 *			
 *       arguments:      orthography, type
 *                       
 *	internal
 *	functions:	none
 *
 *	library
 *	functions:	strlen, strcmp
 *
 ******************************************************************************/

int stress_suffix(char *orthography, int *type)
{
    int                 t = 0, a, c;
    char               *b;
	
    c = strlen(orthography);
    while (suffix_list[t].suff) {
		b = suffix_list[t].suff;
		a = strlen(b);
		if ((a <= c) && !strcmp(b, orthography + c - a)) {
			*type = suffix_list[t].type;
			return(suffix_list[t].sylls);
		}
		t++;
    }
    return(0);
}



/******************************************************************************
 *
 *	function:	light
 *
 *	purpose:	Determine if a syllable is light.
 *                       
 *			
 *       arguments:      sb
 *                       
 *	internal
 *	functions:	isvowel
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

int light(char *sb)
{
    while (!isvowel(*sb))
		sb++;
	
    while (isvowel(*sb) || (*sb == '_') || (*sb == '.'))
		sb++;
	
    if (!*sb)
		return(1);
	
    while ((*sb != '_') && (*sb != '.') && *sb)
		sb++;
	
    if (!*sb)
		return(1);
	
    while (((*sb == '_') || (*sb == '.')) && *sb)
		sb++;
	
    if (!*sb)
		return(1);
	
    return isvowel(*sb);
}



/******************************************************************************
 *
 *	function:	prefix
 *
 *	purpose:	
 *                       
 *			
 *       arguments:      orthography
 *                       
 *	internal
 *	functions:	none
 *
 *	library
 *	functions:	strlen, strncmp
 *
 ******************************************************************************/

int prefix(char *orthography)
{
    int                 t = 0, l, m;
    char               *a;
	
    m = strlen(orthography);
    while ((a = prefices[t++]))
		if (((l = strlen(a)) <= m) && !strncmp(a, orthography, l))
			return(1);
	
    return(0);
}
