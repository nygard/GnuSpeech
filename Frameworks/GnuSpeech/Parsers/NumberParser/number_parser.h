/*******************************************************************************
 *
 *  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock
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
 *  number_parser.h
 *  GnuSpeech
 *
 *  Version: 0.9.1
 *
 ******************************************************************************/


/*  FLAGS FOR ARGUMENT mode WHEN CALLING number_parser()  */
#define NP_NORMAL          0
#define NP_OVERRIDE_YEARS  1
#define NP_FORCE_SPELL     2


/*  DECLARATONS TO MAKE THESE FUNCTIONS USABLE BY CALLING ROUTINES  */
char *number_parser(const char *word_ptr, int mode);
char *degenerate_string(const char *word);



/********************************************************************
number_parser() RETURNS A POINTER TO A NULL TERMINATED CHARACTER
STRING, WHICH CONTAINS THE CORRESPONDING PRONUNCIATION FOR THE
NUMBER TO BE PARSED.  number_parser() TAKES TWO ARGUMENTS:
 1)  word:  a pointer to the NULL terminated string to be parsed.
 2)  mode:  one of the above flags.


TYPICAL USAGE:
  char word[124], *ptr;
  int mode;

  strcat(word,"45,023.34");
  mode = NP_NORMAL;

  if ((ptr = number_parser(word,mode)) == NULL)
      printf("The word contains no numbers.\n");
  else
      printf("%s\n",ptr);



degenerate_string() RETURNS A CHARACTER-BY-CHARACTER PRONUNCIATION
OF A NUMBER STRING.  degenerate_string() TAKES ONE ARGUMENT:
 1) word:  a pointer to the NULL terminated string to be parsed.


TYPICAL USAGE:
  char word[124], *ptr;

  strcat(word,"%^@3*5");

  ptr = degenerate_string(word)
  printf("%s\n",ptr);

********************************************************************/
