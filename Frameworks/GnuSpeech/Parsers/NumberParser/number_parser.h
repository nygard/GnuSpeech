//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*  FLAGS FOR ARGUMENT mode WHEN CALLING number_parser()  */
enum : int {
    NP_MODE_NORMAL          = 0,
    NP_MODE_OVERRIDE_YEARS  = 1,
    NP_MODE_FORCE_SPELL     = 2,
};


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

  strcat(word, "45,023.34");
  mode = NP_NORMAL;

  if ((ptr = number_parser(word, mode)) == NULL)
      printf("The word contains no numbers.\n");
  else
      printf("%s\n",ptr);



degenerate_string() RETURNS A CHARACTER-BY-CHARACTER PRONUNCIATION
OF A NUMBER STRING.  degenerate_string() TAKES ONE ARGUMENT:
 1) word:  a pointer to the NULL terminated string to be parsed.


TYPICAL USAGE:
  char word[124], *ptr;

  strcat(word, "%^@3*5");

  ptr = degenerate_string(word)
  printf("%s\n",ptr);

********************************************************************/
