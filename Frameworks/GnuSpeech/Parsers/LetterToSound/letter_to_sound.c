/*******************************************************************************
 *
 *  Copyright (c) 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
 *  
 *  Contributors: Dalmazio Brisinda
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
 *  letter_to_sound.c
 *  GnuSpeech
 *
 *  Version: 0.8
 *
 *  Routines to return pronunciation of word based on letter-to-sound rules.
 *
 ******************************************************************************/


/*  HEADER FILES  ************************************************************/
#import "letter_to_sound.h"
#import "word_to_patphone.h"
#import "isp_trans.h"
#import "syllabify.h"
#import "apply_stress.h"
#import "tail.h"
#import <strings.h>
#import <stdio.h>


/*  LOCAL DEFINES  ***********************************************************/
#define WORD_TYPE_UNKNOWN          "j"
#define WORD_TYPE_DELIMITER        '%'
#define MAX_WORD_LENGTH            1024
#define MAX_PRONUNCIATION_LENGTH   8192
#define WORDEND(word,string)       (!strcmp(MAX(word+strlen(word)-strlen(string),word),string))


/*  GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ***********************************/
static char *word_type(char *word);




/******************************************************************************
 *
 *	function:	letter_to_sound
 *
 *	purpose:	Returns pronunciation of word based on letter-to-sound
 *                       rules.  Returns NULL if any error (rare).
 *			
 *       arguments:      word
 *                       
 *	internal
 *	functions:	word_to_patphone, isp_trans, syllabify, apply_stress,
 *                       word_type
 *
 *	library
 *	functions:	sprintf, strcat
 *
 ******************************************************************************/

char *letter_to_sound(char *word)
{
    char                buffer[MAX_WORD_LENGTH+3];
    static char         pronunciation[MAX_PRONUNCIATION_LENGTH+1];
    int                 number_of_syllables = 0;
	
	
    /*  FORMAT WORD  */
    sprintf(buffer, "#%s#", word);
	
    /*  CONVERT WORD TO PRONUNCIATION  */
    if (!word_to_patphone(buffer)) {
		isp_trans(buffer, pronunciation);
		/*  ATTEMPT TO MARK SYLL/STRESS  */
		number_of_syllables = syllabify(pronunciation);
		if (apply_stress(pronunciation, word))
			return NULL;
    } else
		strcpy(pronunciation, buffer);
	
    /*  APPEND WORD_TYPE_DELIMITER  */
    pronunciation[strlen(pronunciation) - 1] = WORD_TYPE_DELIMITER;
	
    /*  GUESS TYPE OF WORD  */
    if (number_of_syllables != 1)
		strcat(pronunciation, word_type(word));
    else
		strcat(pronunciation, WORD_TYPE_UNKNOWN);
	
    /*  RETURN RESULTING PRONUNCIATION  */
    return(pronunciation);
}



/******************************************************************************
 *
 *	function:	word_type
 *
 *	purpose:	Returns the word type based on the word spelling.
 *			
 *       arguments:      word
 *                       
 *	internal
 *	functions:	WORDEND
 *                       
 *	library
 *	functions:	(strlen, strcmp)
 *
 ******************************************************************************/

static char *word_type(char *word)
{
    tail_entry          *list_ptr;
	
    /*  IF WORD END MATCHES LIST, RETURN CORRESPONDING TYPE  */
    for (list_ptr = tail_list; list_ptr->tail; list_ptr++)
		if (WORDEND(word, list_ptr->tail))
			return(list_ptr->type);
	
    /*  ELSE RETURN UNKNOWN WORD TYPE  */
    return(WORD_TYPE_UNKNOWN);
}
