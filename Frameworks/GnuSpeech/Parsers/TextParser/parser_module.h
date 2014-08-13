//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSPronunciationDictionary.h"           /*  NEEDED FOR DECLARATIONS BELOW  */


#define TTS_PARSER_SUCCESS       (-1)

/// Or greater than 0 if position of error is known.
#define TTS_PARSER_FAILURE       (0)


void init_parser_module(void);
void set_escape_code(char new_escape_code);
void set_dict_data(const int16_t order[4], GSPronunciationDictionary *userDict, GSPronunciationDictionary *appDict, GSPronunciationDictionary *mainDict, NSDictionary *specialAcronymsDict);
int parser(const char *input, const char **output);
const char *lookup_word(const char *word, short *dict);

@class NXStream;

// Internal functions, exposed just for testing.

typedef enum : NSUInteger {
    GSTextParserPunctuationState_Word        = 0,
    GSTextParserPunctuationState_Punctuation = 1,
} GSTextParserPunctuationState;

// gs_pm = GnuSpeech Parser Module
void   gs_pm_condition_input(const char *input, char *output, long input_length, long *output_length_ptr);
int    gs_pm_mark_modes(char *input, char *output, long length, long *output_length);
void   gs_pm_strip_punctuation_pass1(char *buffer, long length);
void   gs_pm_strip_punctuation_pass2(char *buffer, long length, NXStream *stream);
int    gs_pm_final_conversion(NXStream *stream1, NXStream *stream2);
int    gs_pm_get_state(const char *buffer, long *i, long length, long *mode, long *next_mode,
                       long *current_state, long *next_state, long *raw_mode_flag,
                       char *word, NXStream *stream);
int    gs_pm_set_tone_group(NXStream *stream, long tg_pos, char *word);
double gs_pm_convert_silence(char *buffer, NXStream *stream);
int    gs_pm_another_word_follows(const char *buffer, long i, long length, long mode);
int    gs_pm_shift_silence(const char *buffer, long i, long length, long mode, NXStream *stream);
void   gs_pm_insert_tag(NXStream *stream, long insert_point, char *word);
void   gs_pm_expand_word(char *word, long is_tonic, NXStream *stream);
int    gs_pm_expand_raw_mode(const char *buffer, long *j, long length, NXStream *stream);
int    gs_pm_illegal_token(char *token);
int    gs_pm_illegal_slash_code(char *code);
int    gs_pm_expand_tag_number(const char *buffer, long *j, long length, NXStream *stream);
int    gs_pm_is_mode(char ch);
int    gs_pm_is_isolated(char *buffer, long i, long len);
int    gs_pm_part_of_number(char *buffer, long i, long len);
int    gs_pm_number_follows(char *buffer, long i, long len);
void   gs_pm_delete_ellipsis(char *buffer, long *i, long length);
int    gs_pm_convert_dash(char *buffer, long *i, long length);
int    gs_pm_is_telephone_number(char *buffer, long i, long length);
int    gs_pm_is_punctuation(char ch);
int    gs_pm_word_follows(char *buffer, long i, long length);
int    gs_pm_expand_abbreviation(char *buffer, long i, long length, NXStream *stream);
void   gs_pm_expand_letter_mode(char *buffer, long *i, long length, NXStream *stream, GSTextParserPunctuationState *status);
int    gs_pm_is_all_upper_case(char *word);
char * gs_pm_to_lower_case(char *word);

const char *gs_pm_is_special_acronym(char *word);

int   gs_pm_contains_primary_stress(const char *pronunciation);
int   gs_pm_converted_stress(char *pronunciation);
int   gs_pm_is_possessive(char *word);
void  gs_pm_safety_check(NXStream *stream);
void  gs_pm_insert_chunk_marker(NXStream *stream, long insert_point, char tg_type);
void  gs_pm_check_tonic(NXStream *stream, long startPosition, long endPosition);
