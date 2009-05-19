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
 *  stresstables.h
 *  GnuSpeech
 *
 *  Version: 0.9.1
 *
 ******************************************************************************/


/*  LOCAL DEFINES  ***********************************************************/
#define MAX_SYLLS      100
#define isvowel(c)     (((c)=='a') || ((c)=='e') || ((c)=='i') || ((c)=='o') || ((c)=='u') )

/*  SUFFIX TYPES  */
#define AUTOSTRESSED   0
#define PRESTRESS1     1
#define PRESTRESS2     2
#define PRESTRESS3     3	/* actually prestressed 1/2, but can't use '/' in identifier */
#define NEUTRAL        4


/*  DATA TYPES  **************************************************************/
struct suff_data {
    char               *suff;
    int                 type;
    int                 sylls;
};


/*  GLOBAL VARIABLES (LOCAL TO THIS FILE)  ***********************************/
static struct suff_data suffix_list[] = {
/*  AUTOSTRESSED: (2nd entry 0)  */
					 {"ade", 0, 1},
					 {"aire", 0, 1},
					 {"aise", 0, 1},
					 {"arian", 0, 1},
					 {"arium", 0, 1},
					 {"cidal", 0, 2},
					 {"cratic", 0, 2},
					 {"ee", 0, 1},
					 {"een", 0, 1},
					 {"eer", 0, 1},
					 {"elle", 0, 1},
					 {"enne", 0, 1},
					 {"ential", 0, 2},
					 {"esce", 0, 1},
					 {"escence", 0, 2},
					 {"escent", 0, 2},
					 {"ese", 0, 1},
					 {"esque", 0, 1},
					 {"esse", 0, 1},
					 {"et", 0, 1},
					 {"ette", 0, 1},
					 {"eur", 0, 1},
					 {"faction", 0, 2},
					 {"ician", 0, 2},
					 {"icious", 0, 2},
					 {"icity", 0, 3},
					 {"ation", 0, 2},
					 {"self", 0, 1},
/* PRESTRESS1: (2nd entry 1) */
					 {"cracy", 1, 2},
					 {"erie", 1, 2},
					 {"ety", 1, 2},
					 {"ic", 1, 1},
					 {"ical", 1, 2},
					 {"ssion", 1, 1},
					 {"ia", 1, 1},
					 {"metry", 1, 2},
/* PRESTRESS2: (2nd entry 2) */
					 {"able", 2, 1},   /*  NOTE: McIl GIVES WRONG SYLL. CT. */
					 {"ast", 2, 1},
					 {"ate", 2, 1},
					 {"atory", 2, 3},
					 {"cide", 2, 1},
					 {"ene", 2, 1},
					 {"fy", 2, 1},
					 {"gon", 2, 1},
					 {"tude", 2, 1},
					 {"gram", 2, 1},
/* PRESTRESS 1/2: (2nd entry 3) */
					 {"ad", 3, 1},
					 {"al", 3, 1},
					 {"an", 3, 1},	   /*  OMIT?  */
					 {"ancy", 3, 2},
					 {"ant", 3, 1},
					 {"ar", 3, 1},
					 {"ary", 3, 2},
					 {"ative", 3, 2},
					 {"ator", 3, 2},
					 {"ature", 3, 2},
					 {"ence", 3, 1},
					 {"ency", 3, 2},
					 {"ent", 3, 1},
					 {"ery", 3, 2},
					 {"ible", 3, 1},   /*  BUG  */
					 {"is", 3, 1},
/* STRESS NEUTRAL: (2nd entry 4) */
					 {"acy", 4, 2},
					 {"age", 4, 1},
					 {"ance", 4, 1},
					 {"edly", 4, 2},
					 {"edness", 4, 2},
					 {"en", 4, 1},
					 {"er", 4, 1},
					 {"ess", 4, 1},
					 {"ful", 4, 1},
					 {"hood", 4, 1},
					 {"less", 4, 1},
					 {"ness", 4, 1},
					 {"ish", 4, 1},
					 {"dom", 4, 1},
					 {0, 0, 0}	   /*  END MARKER  */
};


/*  STRESS REPELLENT PREFICES  */
static char        *prefices[] = {
				  "ex",
				  "ac",
				  "af",
				  "de",
				  "in",
				  "non",
				  0
};
