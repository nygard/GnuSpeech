//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSPronunciationDictionary.h"		/*  NEEDED FOR DECLARATIONS BELOW  */ 


#define TTS_PARSER_SUCCESS       (-1)

/// Or greater than 0 if position of error is known.
#define TTS_PARSER_FAILURE       (0)


void init_parser_module(void);
int set_escape_code(char new_escape_code);
int set_dict_data(const int16_t order[4], GSPronunciationDictionary *userDict, GSPronunciationDictionary *appDict, GSPronunciationDictionary *mainDict, NSDictionary *specialAcronymsDict);
int parser(const char *input, const char **output);
const char *lookup_word(const char *word, short *dict);

