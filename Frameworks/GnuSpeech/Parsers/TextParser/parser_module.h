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
 *  parser_module.h
 *  GnuSpeech
 *
 *  Created by Leonard Manzara.
 *
 *  Version: 0.9
 *
 ******************************************************************************/


/*  HEADER FILES  ************************************************************/
#import "GSPronunciationDictionary.h"		/*  NEEDED FOR DECLARATIONS BELOW  */ 


/*  LOCAL DEFINES  ***********************************************************/
#define TTS_PARSER_SUCCESS       (-1)
#define TTS_PARSER_FAILURE       0              /*  OR GREATER THAN 0 IF     */
                                                /*  POSITION OF ERROR KNOWN  */


/*  GLOBAL FUNCTIONS *********************************************************/
extern void init_parser_module(void);
extern int set_escape_code(char new_escape_code);
extern int set_dict_data(const short order[4], GSPronunciationDictionary *userDict, GSPronunciationDictionary *appDict, GSPronunciationDictionary *mainDict, NSDictionary *specialAcronymsDict);
extern int parser(const char *input, const char **output);
extern const char *lookup_word(const char *word, short *dict);

