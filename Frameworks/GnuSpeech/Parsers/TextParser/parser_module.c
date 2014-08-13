//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*
 *     July 7th, 1992          Completed.
 *
 *     December 12th, 1994     Added word begin /w and utterance
 *                             boundary # markers.
 *
 *     January 5th, 1995       Fixed illegal_slash_code() so that it will
 *                             recognize the new /w code when doing raw mode
 *                             checking.  The # marker is a phone, so the new
 *                             validPhone() function should return this as
 *                             valid.  Also changed all closing of streams to
 *                             use NX_FREEBUFFER instead of NX_TRUNCATEBUFFER,
 *                             eliminating a potential memory leak.  The NeXT
 *                             documentation is wrong, since it recommends
 *                             using NX_TRUNCATEBUFFER, plus NXGetMemoryBuffer()
 *                             and vm_deallocate() calls to free the internal
 *                             stream buffer.
 *
 *     March 7th, 1995         Fixed bug when using medial punctuation (,;:)
 *                             at the end of an utterance.
 *
 *     April 5, 2009           Ported to OS X 10.5.6 using custom string-based
 *                             NXStream implementation. (dalmazio)
 *
 ******************************************************************************/


/*  HEADER FILES  ************************************************************/
#import "parser_module.h"
#import "number_parser.h"
#import "letter_to_sound.h"
#import "abbreviations.h"
#import "NXStream.h"
#import "TTS_types.h"

#import <ctype.h>
#import <stdio.h>
#import <stdlib.h>
#import <strings.h>


/*  LOCAL DEFINES  ***********************************************************/
#define UNDEFINED_MODE        (-2)
#define NORMAL_MODE           (-1)
#define RAW_MODE              0
#define LETTER_MODE           1
#define EMPHASIS_MODE         2
#define TAGGING_MODE          3
#define SILENCE_MODE          4

#define RAW_MODE_BEGIN        (-1)
#define RAW_MODE_END          (-2)
#define LETTER_MODE_BEGIN     (-3)
#define LETTER_MODE_END       (-4)
#define EMPHASIS_MODE_BEGIN   (-5)
#define EMPHASIS_MODE_END     (-6)
#define TAGGING_MODE_BEGIN    (-7)
#define TAGGING_MODE_END      (-8)
#define SILENCE_MODE_BEGIN    (-9)
#define SILENCE_MODE_END      (-10)
#define DELETED               (-11)

#define BEGIN                 0
#define END                   1

#define WORD                  0
#define PUNCTUATION           1
#define PRONUNCIATION         1

#define AND                   "and"
#define PLUS                  "plus"
#define IS_LESS_THAN          "is less than"
#define IS_GREATER_THAN       "is greater than"
#define EQUALS                "equals"
#define MINUS                 "minus"
#define AT                    "at"

#define ABBREVIATION          0
#define EXPANSION             1

#define STATE_UNDEFINED       (-1)
#define STATE_BEGIN           0
#define STATE_WORD            1
#define STATE_MEDIAL_PUNC     2
#define STATE_FINAL_PUNC      3
#define STATE_END             4
#define STATE_SILENCE         5
#define STATE_TAGGING         6


#define CHUNK_BOUNDARY        "/c"
#define TONE_GROUP_BOUNDARY   "//"
#define FOOT_BEGIN            "/_"
#define TONIC_BEGIN           "/*"
#define SECONDARY_STRESS      "/\""
#define LAST_WORD             "/l"
#define TAG_BEGIN             "/t"
#define WORD_BEGIN            "/w"
#define UTTERANCE_BOUNDARY    "#"
#define MEDIAL_PAUSE          "^"
#define LONG_MEDIAL_PAUSE     "^ ^ ^"
#define SILENCE_PHONE         "^"

#define TG_UNDEFINED          "/x"
#define TG_STATEMENT          "/0"
#define TG_EXCLAMATION        "/1"
#define TG_QUESTION           "/2"
#define TG_CONTINUATION       "/3"
#define TG_HALF_PERIOD        "/4"

#define UNDEFINED_POSITION    (-1)

#define TTS_NO                0
#define TTS_YES               1

#define SYMBOL_LENGTH_MAX     12

#define WORD_LENGTH_MAX       1024

static double kSilenceMax         = 5.0;
static double kSilencePhoneLength = 0.1; // Silence phone is 100 ms.

#define DEFAULT_END_PUNC      "."
#define MODE_NEST_MAX         100

#define NON_PHONEME           0
#define PHONEME               1
#define MAX_PHONES_PER_CHUNK  1500
#define MAX_FEET_PER_CHUNK    100



/*  GLOBAL VARIABLES, LOCAL TO THIS FILE  ************************************/
static char _escape_character;
static short _dictionaryOrder[4];
static GSPronunciationDictionary *_userDictionary;
static GSPronunciationDictionary *_appDictionary;
static GSPronunciationDictionary *_mainDictionary;
static NSDictionary *_specialAcronymsDictionary;
static NXStream *_persistentStream;


/// Check whether a phone is valid (exists in the currently initialized database).
///
/// @param phone Null terminated string.
///
/// @returns Returns a 1 if the phone is valid, 0 otherwise.

static int validPhone(char *phone)
{
    // This is used in raw mode, turned on with %rb.
    // TODO: (2014-08-11) This needs to look up the phone in the Monet data.  Previously it was using the unitialized Degas function, but the app crashed before it even got that far.
    return 1;
}





/// Set up parser module for subsequent use.  This must be called before parser() is ever used.

void init_parser_module(void)
{
    _persistentStream = NULL;

    _userDictionary = nil;
    _appDictionary = nil;
    _mainDictionary = nil;
    _specialAcronymsDictionary = nil;

    _escape_character = '%';  // default escape character
}


/// Set escape code for parsing.  Assumes Objective C client library checks validity of argument.
///
/// @param new_escape_code New escape character.

void set_escape_code(char new_escape_code)
{
    _escape_character = new_escape_code;
}


/// Set the dictionary order and the user and application dictionaries (all globals).  Assumes Objective C client library checks validity of arguments.

void set_dict_data(const int16_t order[4],
                   GSPronunciationDictionary *userDict,
                   GSPronunciationDictionary *appDict,
                   GSPronunciationDictionary *mainDict,
                   NSDictionary *specialAcronymsDict)
{
    /*  INITIALIZE GLOBAL ORDER VARIABLE  */
    _dictionaryOrder[0] = TTS_EMPTY;
    _dictionaryOrder[1] = TTS_EMPTY;
    _dictionaryOrder[2] = TTS_EMPTY;
    _dictionaryOrder[3] = TTS_EMPTY;

    /*  COPY POINTER TO DICTIONARIES INTO GLOBAL VARIABLES  */
    _userDictionary = userDict;
    _appDictionary = appDict;
    _mainDictionary = mainDict;
    _specialAcronymsDictionary = specialAcronymsDict;

    /*  COPY ORDER TO GLOBAL VARIABLE, ACCOUNT FOR UNOPENABLE PREDITOR-NOT DICTIONARIES  */
    NSUInteger dictionaryOrderIndex = 0;
    for (NSUInteger index = 0; index < 4; index++) {
        if (order[index] == TTS_USER_DICTIONARY) {
            if (_userDictionary != nil)
                _dictionaryOrder[dictionaryOrderIndex++] = order[index];
        }
        else if (order[index] == TTS_APPLICATION_DICTIONARY) {
            if (_appDictionary != nil)
                _dictionaryOrder[dictionaryOrderIndex++] = order[index];
        }
        else {
            _dictionaryOrder[dictionaryOrderIndex++] = order[index];
        }
    }
}



/// Take plain english input, and produce phonetic output suitable for further processing in the TTS system.
///
/// If a parse error occurs, a value of 0 or above is returned.  Usually this will point to the position of the
/// error in the input buffer, but in later stages of the parse only a 0 is returned since positional information
/// is lost.
///
/// @return If no parser error, then TTS_PARSER_SUCCESS is returned.
/// @return If a parse error occurs, return >= 0.

int parser(const char *input, const char **output)
{
    long input_length = strlen(input);

    char *buffer1 = (char *)malloc(input_length + 1);
    char *buffer2 = (char *)malloc(input_length + 1);

    /*  CONDITION INPUT:  CONVERT NON-PRINTABLE CHARS TO SPACES
     (EXCEPT ESC CHAR), CONNECT WORDS HYPHENATED OVER A NEWLINE  */
    long buffer1_length;
    gs_pm_condition_input(input, buffer1, input_length, &buffer1_length);
    NSLog(@"conditioned input: '%s'", buffer1);

    int error;
    long buffer2_length = input_length + 1;
    /*  RATIONALIZE MODE MARKINGS, CHECKING FOR ERRORS  */
    error = gs_pm_mark_modes(buffer1, buffer2, buffer1_length, &buffer2_length);
    if (error != TTS_PARSER_SUCCESS) {
        free(buffer1);
        free(buffer2);
        return error;
    }

    free(buffer1);

    NXStream *stream1 = [[NXStream alloc] init];
    if (stream1 == nil) {
        NSLog(@"TTS Server:  Cannot open memory stream (parser).");
        free(buffer2);
        return TTS_PARSER_FAILURE;
    }

    /*  STRIP OUT OR CONVERT UNESSENTIAL PUNCTUATION  */
    gs_pm_strip_punctuation_pass1(buffer2, buffer2_length, stream1);
    gs_pm_strip_punctuation_pass2(buffer2, buffer2_length, stream1);

    free(buffer2);

    /*  THIS STREAM PERSISTS BETWEEN CALLS  */
    _persistentStream = nil;

    _persistentStream = [[NXStream alloc] init];
    if (_persistentStream == nil) {
        NSLog(@"TTS Server:  Cannot open memory stream (parser).");
        return TTS_PARSER_FAILURE;
    }

    /*  DO FINAL CONVERSION  */
    error = gs_pm_final_conversion(stream1, _persistentStream);
    if (error != TTS_PARSER_SUCCESS) {
        _persistentStream = nil;
        return error;
    }

    /*  DO SAFETY CHECK;  MAKE SURE NOT TOO MANY FEET OR PHONES PER CHUNK  */
    gs_pm_safety_check(_persistentStream);

    /*  SET OUTPUT POINTER TO MEMORY STREAM BUFFER
     THIS STREAM PERSISTS BETWEEN CALLS  */
    *output = [_persistentStream mutableBytes];

    return TTS_PARSER_SUCCESS;
}



/// Return the pronunciation of word, and set dict to the dictionary in which it was found.  Relies on the global dictionaryOrder.

const char *lookup_word(const char *word, short *dict)
{
    NSString *pr;
    NSString *w;

    const char *pronunciation;


    /*  SEARCH DICTIONARIES IN USER ORDER TILL PRONUNCIATION FOUND  */
    for (NSUInteger index = 0; index < 4; index++) {
        switch (_dictionaryOrder[index]) {
            case TTS_EMPTY:
                break;
            case TTS_NUMBER_PARSER:
                if ((pronunciation = number_parser(word, NP_MODE_NORMAL)) != NULL) {
                    *dict = TTS_NUMBER_PARSER;
                    return (const char *)pronunciation;
                }
                break;
            case TTS_USER_DICTIONARY:
                w = [NSString stringWithCString:word encoding:NSASCIIStringEncoding];
                if ((pr = [_userDictionary pronunciationForWord:w]) != nil) {
                    pronunciation = [pr cStringUsingEncoding:NSASCIIStringEncoding];
                    *dict = TTS_USER_DICTIONARY;
                    return (const char *)pronunciation;
                }
                break;
            case TTS_APPLICATION_DICTIONARY:
                w = [NSString stringWithCString:word encoding:NSASCIIStringEncoding];
                if ((pr = [_appDictionary pronunciationForWord:w]) != nil) {
                    pronunciation = [pr cStringUsingEncoding:NSASCIIStringEncoding];
                    *dict = TTS_APPLICATION_DICTIONARY;
                    return (const char *)pronunciation;
                }
                break;
            case TTS_MAIN_DICTIONARY:
                w = [NSString stringWithCString:word encoding:NSASCIIStringEncoding];
                if ((pr = [_mainDictionary pronunciationForWord:w]) != nil) {
                    pronunciation = [pr cStringUsingEncoding:NSASCIIStringEncoding];
                    *dict = TTS_MAIN_DICTIONARY;
                    return (const char *)pronunciation;
                }
                break;
            case TTS_LETTER_TO_SOUND:
                if ((pronunciation = letter_to_sound((char *)word)) != NULL) {
                    *dict = TTS_LETTER_TO_SOUND;
                    return (const char *)pronunciation;
                }
                else {
                    *dict = TTS_LETTER_TO_SOUND;
                    return (const char *)degenerate_string(word);
                }
                break;
            default:
                break;
        }
    }

    /*  IF HERE, THEN FIND WORD IN LETTER-TO-SOUND RULEBASE  */
    /*  THIS IS GUARANTEED TO FIND A PRONUNCIATION OF SOME SORT  */
    if ((pronunciation = letter_to_sound((char *)word)) != NULL) {
        *dict = TTS_LETTER_TO_SOUND;
        return (const char *)pronunciation;
    }

    *dict = TTS_LETTER_TO_SOUND;
    return (const char *)degenerate_string(word);
}



/// Convert all non-printable characters (except escape character to blanks.  Also connect words hyphenated over a newline.

void gs_pm_condition_input(const char *input, char *output, long input_length, long *output_length_ptr)
{
    NSInteger outputIndex = 0;

    for (NSInteger inputIndex = 0; inputIndex < input_length; inputIndex++) {
        if ((input[inputIndex] == '-') && ((inputIndex - 1) >= 0) && isalpha(input[inputIndex - 1])) {
            /*  CONNECT HYPHENATED WORD OVER NEWLINE  */
            NSInteger ii = inputIndex;
            /*  IGNORE ANY WHITE SPACE UP TO NEWLINE  */
            while (((ii + 1) < input_length) && (input[ii + 1] != '\n') &&
                   (input[ii + 1] != _escape_character) && isspace(input[ii + 1]))
            {
                ii++;
            }
            /*  IF NEWLINE, THEN CONCATENATE WORD  */
            if (((ii + 1) < input_length) && input[ii + 1] == '\n') {
                inputIndex = ++ii;
                /*  IGNORE ANY WHITE SPACE  */
                while (((inputIndex + 1) < input_length) && (input[inputIndex + 1] != _escape_character) && isspace(input[inputIndex + 1])) {
                    inputIndex++;
                }
            }
            else {
                /*  ELSE, OUTPUT HYPHEN  */
                output[outputIndex++] = input[inputIndex];
            }
        }
        else if ((!isascii(input[inputIndex])) || ((!isprint(input[inputIndex])) && (input[inputIndex] != _escape_character))) {
            /*  CONVERT NONPRINTABLE CHARACTERS TO SPACE  */
            output[outputIndex++] = ' ';
        } else {
            output[outputIndex++] = input[inputIndex];
        }
    }

    output[outputIndex] = '\0';
    *output_length_ptr = outputIndex;
}




// Mark beginning of stacked mode, if not normal mode.
#define MARK_BEGINNING_OF_STACKED_MODE() { if (mode_stack[stack_ptr] != NORMAL_MODE) { output[outputIndex++] = mode_marker[mode_stack[stack_ptr]][BEGIN]; } }

// Mark end of stacked mode, if not normal mode.
#define MARK_END_OF_STACKED_MODE()       { if (mode_stack[stack_ptr] != NORMAL_MODE) { output[outputIndex++] = mode_marker[mode_stack[stack_ptr]][END]; } }

#define MARK_BEGINNING_OF_MODE(mode)     { output[outputIndex++] = mode_marker[mode][BEGIN]; }
#define MARK_END_OF_MODE(mode)           { output[outputIndex++] = mode_marker[mode][END]; }


// Decrement stack pointer, checkfor for stack underflow.
#define DECREMENT_STACK_POINTER()        { if ((--stack_ptr) < 0) return inputIndex; }

#define OUTPUT_ESCAPE_IF_PRINTABLE()     { if (isprint(_escape_character)) { output[outputIndex++] = _escape_character; } }

#define PUSH_MODE(mode)                  { if ((++stack_ptr) >= MODE_NEST_MAX) { return inputIndex; } mode_stack[stack_ptr] = mode; }

/// Parse input for modes, check for errors, and mark output with mode start and end points.  Also check tagging and silence mode arguments.
/// @returns Return TTS_PARSER_SUCCESS (-1) on success, or index of error.
//   - errors can be:
//     - Trying to end raw mode with empty mode stack.
// %[rR][bB] - begin raw mode
// %[rR][eE] - end raw mode
// - in raw mode, only the "end raw mode" escape is recognized.  % or %r or %rb will just be passed through.  Escape character must be printable to be passed through.
// - when raw mode ends, it marks the end of raw mode, and begins the mode at the top of the stack (if that isn't normal mode).
// - this means that effectively they aren't nested.  Could be represented as an array of (mode, string) instead of embedding begin/end.
// - double escape produces escape, as long as it is printable.  %%
// %[lL][bB] - begin letter mode
// %[eE][bB] - begin emphasis mode
// %[tT][bB] - begin tagging mode
// %[sS][bB] - beging silence mode
// %[?][bB] - anything else is undefined.
// - in anything other than raw mode... beginning a mode emits that mode begin, puts mode on stack.
// - begin tagging mode:
//   - skip whitespace.  [+-]?[0-9]+[\w]*           (\w whitespace?)
//   - will consume trailing %[tT][eE] immediately, if present.  Otherwise will add the end mode anyway.
//   - so both "%tb 12345   %te foo" and just "%tb 12345 foo" are valid.

int gs_pm_mark_modes(char *input, char *output, long length, long *output_length)
{
    int mode_marker[5][2] = {
        { RAW_MODE_BEGIN,      RAW_MODE_END      },
        { LETTER_MODE_BEGIN,   LETTER_MODE_END   },
        { EMPHASIS_MODE_BEGIN, EMPHASIS_MODE_END },
        { TAGGING_MODE_BEGIN,  TAGGING_MODE_END  },
        { SILENCE_MODE_BEGIN,  SILENCE_MODE_END  },
    };



    /*  INITIALIZE MODE STACK TO NORMAL MODE */
    int mode_stack[MODE_NEST_MAX], stack_ptr = 0;

    memset(output, 0, *output_length); // Zero it out, to make debugging easier.
    for (NSUInteger index = 0; index < MODE_NEST_MAX; index++) mode_stack[index] = 1000; // Just for debugging.

    mode_stack[stack_ptr] = NORMAL_MODE;
    int mode;
    int outputIndex = 0;

    /*  MARK THE MODES OF INPUT, CHECKING FOR ERRORS  */
    for (int inputIndex = 0; inputIndex < length; inputIndex++) {
        if (input[inputIndex] == _escape_character) {
            if (mode_stack[stack_ptr] == RAW_MODE)
            {
                /*  CHECK FOR RAW MODE END  */
                if ( ((inputIndex + 2) < length)
                    && ((input[inputIndex + 1] == 'r') || (input[inputIndex + 1] == 'R'))
                    && ((input[inputIndex + 2] == 'e') || (input[inputIndex + 2] == 'E')) )
                {
                    DECREMENT_STACK_POINTER();
                    MARK_END_OF_MODE(RAW_MODE);
                    inputIndex += 2;
                    MARK_BEGINNING_OF_STACKED_MODE();
                }
                /*  IF NOT END OF RAW MODE, THEN PASS THROUGH ESC CHAR IF PRINTABLE  */
                else {
                    OUTPUT_ESCAPE_IF_PRINTABLE();
                }
            }
            /*  ELSE, IF IN ANY OTHER MODE  */
            else
            {
                /*  CHECK FOR DOUBLE ESCAPE CHARACTER  */
                if ( ((inputIndex + 1) < length) && (input[inputIndex + 1] == _escape_character) ) {
                    OUTPUT_ESCAPE_IF_PRINTABLE();
                    inputIndex++;
                }
                /*  CHECK FOR BEGINNING OF MODE  */
                else if ( ((inputIndex + 2) < length) && ((input[inputIndex + 2] == 'b') || (input[inputIndex + 2] == 'B')) ) {
                    /*  CHECK FOR WHICH MODE  */
                    switch (input[inputIndex + 1]) {
                        case 'r':
                        case 'R': mode = RAW_MODE;       break;
                        case 'l':
                        case 'L': mode = LETTER_MODE;    break;
                        case 'e':
                        case 'E': mode = EMPHASIS_MODE;  break;
                        case 't':
                        case 'T': mode = TAGGING_MODE;   break;
                        case 's':
                        case 'S': mode = SILENCE_MODE;   break;
                        default:  mode = UNDEFINED_MODE; break;
                    }
                    if (mode != UNDEFINED_MODE) {
                        MARK_END_OF_STACKED_MODE();
                        PUSH_MODE(mode);
                        MARK_BEGINNING_OF_MODE(mode);
                        inputIndex += 2;
                        /*  ADD TAGGING MODE END, IF NOT GIVEN, GETTING RID OF BLANKS  */
                        if (mode == TAGGING_MODE)
                        {
                            /*  IGNORE ANY WHITE SPACE  */
                            while (((inputIndex + 1) < length) && (input[inputIndex + 1] == ' ')) {
                                inputIndex++;
                            }
                            /*  COPY NUMBER, CHECKING VALIDITY  */
                            int has_minus_or_plus = 0;
                            int pos = 0;
                            while (((inputIndex + 1) < length) && (input[inputIndex + 1] != ' ') && (input[inputIndex + 1] != _escape_character))
                            {
                                inputIndex++;
                                /*  ALLOW ONLY MINUS OR PLUS SIGN AND DIGITS  */
                                if (!isdigit(input[inputIndex]) && (input[inputIndex] != '-') && (input[inputIndex] != '+')) {
                                    //fprintf(stderr, "[1] failed at index: %d, input: '%s', output: '%s'\n", inputIndex, input+inputIndex, output);
                                    return inputIndex;
                                }
                                /*  MINUS OR PLUS SIGN AT BEGINNING ONLY  */
                                if ((pos > 0) && ((input[inputIndex] == '-') || (input[inputIndex] == '+'))) {
                                    //fprintf(stderr, "[2] failed at index: %d, input: '%s', output: '%s'\n", inputIndex, input+inputIndex, output);
                                    return inputIndex;
                                }
                                /*  OUTPUT CHARACTER, KEEPING TRACK OF POSITION AND MINUS SIGN  */
                                output[outputIndex++] = input[inputIndex];
                                if ((input[inputIndex] == '-') || (input[inputIndex] == '+')) {
                                    has_minus_or_plus++;
                                }
                                pos++;
                            }
                            //fprintf(stderr, "Done loop\n");
                            /*  MAKE SURE MINUS OR PLUS SIGN HAS NUMBER FOLLOWING IT  */
                            if (has_minus_or_plus >= pos) {
                                //fprintf(stderr, "[3] failed at index: %d, input: '%s', output: '%s'\n", inputIndex, input+inputIndex, output);
                                return inputIndex;
                            }
                            /*  IGNORE ANY WHITE SPACE  */
                            while (((inputIndex + 1) < length) && (input[inputIndex + 1] == ' ')) {
                                inputIndex++;
                            }
                            /*  IF NOT EXPLICIT TAG END, THEN INSERT ONE, POP STACK  */
                            if (!(((inputIndex + 3) < length) && (input[inputIndex + 1] == _escape_character) &&
                                  ((input[inputIndex + 2] == 't') || (input[inputIndex + 2] == 'T')) &&
                                  ((input[inputIndex + 3] == 'e') || (input[inputIndex + 3] == 'E'))) )
                            {
                                MARK_END_OF_MODE(mode);
                                DECREMENT_STACK_POINTER();
                                MARK_BEGINNING_OF_STACKED_MODE();
                            }
                        }
                        else if (mode == SILENCE_MODE)
                        {
                            /*  IGNORE ANY WHITE SPACE  */
                            while (((inputIndex + 1) < length) && (input[inputIndex + 1] == ' ')) {
                                inputIndex++;
                            }
                            /*  COPY NUMBER, CHECKING VALIDITY  */
                            int period = 0;
                            while (((inputIndex + 1) < length) && (input[inputIndex + 1] != ' ') && (input[inputIndex + 1] != _escape_character))
                            {
                                inputIndex++;
                                /*  ALLOW ONLY DIGITS AND PERIOD  */
                                if (!isdigit(input[inputIndex]) && (input[inputIndex] != '.')) {
                                    return inputIndex;
                                }
                                /*  ALLOW ONLY ONE PERIOD  */
                                if (period && (input[inputIndex] == '.')) {
                                    return inputIndex;
                                }
                                /*  OUTPUT CHARACTER, KEEPING TRACK OF # OF PERIODS  */
                                output[outputIndex++] = input[inputIndex];
                                if (input[inputIndex] == '.') {
                                    period++;
                                }
                            }
                            /*  IGNORE ANY WHITE SPACE  */
                            while (((inputIndex + 1) < length) && (input[inputIndex + 1] == ' ')) {
                                inputIndex++;
                            }
                            /*  IF NOT EXPLICIT SILENCE END, THEN INSERT ONE, POP STACK  */
                            if (!(((inputIndex + 3) < length) && (input[inputIndex + 1] == _escape_character) &&
                                  ((input[inputIndex + 2] == 's') || (input[inputIndex + 2] == 'S')) &&
                                  ((input[inputIndex + 3] == 'e') || (input[inputIndex + 3] == 'E'))) )
                            {
                                MARK_END_OF_MODE(mode);
                                DECREMENT_STACK_POINTER();
                                MARK_BEGINNING_OF_STACKED_MODE();
                            }
                        }
                    }
                    else {
                        OUTPUT_ESCAPE_IF_PRINTABLE();
                    }
                }
                /*  CHECK FOR END OF MODE  */
                else if ( ((inputIndex + 2) < length) && ((input[inputIndex + 2] == 'e') || (input[inputIndex + 2] == 'E')) )
                {
                    /*  CHECK FOR WHICH MODE  */
                    switch (input[inputIndex + 1]) {
                        case 'r':
                        case 'R': mode = RAW_MODE;       break;
                        case 'l':
                        case 'L': mode = LETTER_MODE;    break;
                        case 'e':
                        case 'E': mode = EMPHASIS_MODE;  break;
                        case 't':
                        case 'T': mode = TAGGING_MODE;   break;
                        case 's':
                        case 'S': mode = SILENCE_MODE;   break;
                        default:  mode = UNDEFINED_MODE; break;
                    }
                    if (mode != UNDEFINED_MODE) {
                        // Check if this matches the mode begin.
                        if (mode_stack[stack_ptr] != mode) {
                            return inputIndex;
                        } else {
                            DECREMENT_STACK_POINTER();
                            MARK_END_OF_MODE(mode);
                            inputIndex += 2;
                            MARK_BEGINNING_OF_STACKED_MODE();
                        }
                    }
                    else {
                        OUTPUT_ESCAPE_IF_PRINTABLE();
                    }
                }
                else {
                    OUTPUT_ESCAPE_IF_PRINTABLE();
                }
            }
        }
        else {
            output[outputIndex++] = input[inputIndex];
        }
    }

    output[outputIndex] = '\0';
    *output_length = outputIndex;

    return TTS_PARSER_SUCCESS;
}



/// Delete unnecessary punctuation, and convert some punctuation to another form.

// NORMAL and EMPHASIS modes:
// CHANGE: [ -> (
// CHANGE: ] -> )
// DELETE: "`#*\^_|~{}

void gs_pm_strip_punctuation_pass1(char *buffer, long length, NXStream *stream)
{
    long mode = NORMAL_MODE;

    /*  DELETE OR CONVERT PUNCTUATION  */
    for (long index = 0; index < length; index++) {
        switch (buffer[index]) {
            case RAW_MODE_BEGIN:      mode = RAW_MODE;      break;
            case LETTER_MODE_BEGIN:   mode = LETTER_MODE;   break;
            case EMPHASIS_MODE_BEGIN: mode = EMPHASIS_MODE; break;
            case TAGGING_MODE_BEGIN:  mode = TAGGING_MODE;  break;
            case SILENCE_MODE_BEGIN:  mode = SILENCE_MODE;  break;
            case RAW_MODE_END:
            case LETTER_MODE_END:
            case EMPHASIS_MODE_END:
            case TAGGING_MODE_END:
            case SILENCE_MODE_END:    mode = NORMAL_MODE;   break;

            default:
                if ((mode == NORMAL_MODE) || (mode == EMPHASIS_MODE))
                {
                    switch (buffer[index]) {
                        case '[':
                            buffer[index] = '(';
                            break;
                        case ']':
                            buffer[index] = ')';
                            break;
                        case '-':
                            if (   !gs_pm_convert_dash  (buffer, &index, length)
                                && !gs_pm_number_follows(buffer, index, length)
                                && !gs_pm_is_isolated   (buffer, index, length))
                            {
                                buffer[index] = DELETED;
                            }
                            break;
                        case '+':
                            if (   !gs_pm_part_of_number(buffer, index, length)
                                && !gs_pm_is_isolated   (buffer, index, length))
                            {
                                buffer[index] = DELETED;
                            }
                            break;
                        case '\'':
                            // Keep <alpha><single quote><alpha>.  Discard rest: single quote at beginning or end, or preceded or followed by non-alpha.
#if 1
                            if (!(   (index - 1 >= 0)
                                  && isalpha(buffer[index - 1])
                                  && (index + 1 < length)
                                  && isalpha(buffer[index + 1])))
                            {
                                buffer[index] = DELETED;
                            }
#else
                            if (   (index - 1 < 0)
                                || !isalpha(buffer[index - 1])
                                || (index + 1 >= length)
                                || !isalpha(buffer[index + 1]) )
                            {
                                buffer[index] = DELETED;
                            }
#endif
                            break;
                        case '.':
                            gs_pm_delete_ellipsis(buffer, &index, length);
                            break;
                        case '/':
                        case '$':
                        case '%':
                            if (!gs_pm_part_of_number(buffer, index, length)) {
                                buffer[index] = DELETED;
                            }
                            break;
                        case '<':
                        case '>':
                        case '&':
                        case '=':
                        case '@':
                            if (!gs_pm_is_isolated(buffer, index, length)) {
                                buffer[index] = DELETED;
                            }
                            break;
                        case '"':
                        case '`':
                        case '#':
                        case '*':
                        case '\\':
                        case '^':
                        case '_':
                        case '|':
                        case '~':
                        case '{':
                        case '}':
                            buffer[index] = DELETED;
                            break;
                        default:
                            break;
                    }
                }
                break;
        }
    }
}

/// Delete unnecessary punctuation, and convert some punctuation to another form.

void gs_pm_strip_punctuation_pass2(char *buffer, long length, NXStream *stream)
{
    [stream seekWithOffset:0 fromPosition:NXStreamLocation_Start];

    long mode = NORMAL_MODE;
    long status = PUNCTUATION;
    for (long index = 0; index < length; index++) {
        switch (buffer[index]) {
            case RAW_MODE_BEGIN:      mode = RAW_MODE;      [stream putChar:buffer[index]]; break;
            case EMPHASIS_MODE_BEGIN: mode = EMPHASIS_MODE; [stream putChar:buffer[index]]; break;
            case TAGGING_MODE_BEGIN:  mode = TAGGING_MODE;  [stream putChar:buffer[index]]; break;
            case SILENCE_MODE_BEGIN:  mode = SILENCE_MODE;  [stream putChar:buffer[index]]; break;
            case LETTER_MODE_BEGIN:   mode = LETTER_MODE;   /*  expand below  */      ; break;

            case RAW_MODE_END:
            case EMPHASIS_MODE_END:
            case TAGGING_MODE_END:
            case SILENCE_MODE_END:    mode = NORMAL_MODE;   [stream putChar:buffer[index]]; break;
            case LETTER_MODE_END:     mode = NORMAL_MODE;   /*  expand below  */      ; break;

            case DELETED:
                /*  CONVERT ALL DELETED CHARACTERS TO BLANKS  */
                buffer[index] = ' ';
                [stream putChar:' '];
                break;

            default:
                if ((mode == NORMAL_MODE) || (mode == EMPHASIS_MODE)) {
                    switch (buffer[index]) {
                        case '(':
                            /*  CONVERT (?) AND (!) TO BLANKS  */
                            if (   (index + 2 < length)
                                && (buffer[index + 2] == ')')
                                && (buffer[index + 1] == '!' || buffer[index + 1] == '?') )
                            {
                                buffer[index] = buffer[index + 1] = buffer[index + 2] = ' ';
                                [stream printf:"   "];
                                index += 2;
                                continue;
                            }
                            /*  ALLOW TELEPHONE NUMBER WITH AREA CODE:  (403)274-3877  */
                            if (gs_pm_is_telephone_number(buffer, index, length))
                            {
                                for (int j = 0; j < 12; j++)
                                    [stream putChar:buffer[index++]];
                                status = WORD;
                                continue;
                            }
                            /*  CONVERT TO COMMA IF PRECEDED BY WORD, FOLLOWED BY WORD  */
                            if ((status == WORD) && gs_pm_word_follows(buffer, index, length))
                            {
                                buffer[index] = ' ';
                                [stream printf:", "];
                                status = PUNCTUATION;
                            }
                            else
                            {
                                buffer[index] = ' ';
                                [stream putChar:' '];
                            }
                            break;
                        case ')':
                            /*  CONVERT TO COMMA IF PRECEDED BY WORD, FOLLOWED BY WORD  */
                            if ((status == WORD) && gs_pm_word_follows(buffer, index, length))
                            {
                                buffer[index] = ',';
                                [stream printf:", "];
                                status = PUNCTUATION;
                            }
                            else
                            {
                                buffer[index] = ' ';
                                [stream putChar:' '];
                            }
                            break;
                        case '&':
                            [stream printf:"%s", AND];
                            status = WORD;
                            break;
                        case '+':
                            if (gs_pm_is_isolated(buffer, index, length))
                                [stream printf:"%s", PLUS];
                            else
                                [stream putChar:'+'];
                            status = WORD;
                            break;
                        case '<':
                            [stream printf:"%s", IS_LESS_THAN];
                            status = WORD;
                            break;
                        case '>':
                            [stream printf:"%s", IS_GREATER_THAN];
                            status = WORD;
                            break;
                        case '=':
                            [stream printf:"%s", EQUALS];
                            status = WORD;
                            break;
                        case '-':
                            if (gs_pm_is_isolated(buffer, index, length))
                                [stream printf:"%s", MINUS];
                            else
                                [stream putChar:'-'];
                            status = WORD;
                            break;
                        case '@':
                            [stream printf:"%s", AT];
                            status = WORD;
                            break;
                        case '.':
                            if (!gs_pm_expand_abbreviation(buffer, index, length, stream)) {
                                [stream putChar:buffer[index]];
                                status = PUNCTUATION;
                            }
                            break;
                        default:
                            [stream putChar:buffer[index]];
                            if (gs_pm_is_punctuation(buffer[index]))
                                status = PUNCTUATION;
                            else if (isalnum(buffer[index]))
                                status = WORD;
                            break;
                    }
                }
                /*  EXPAND LETTER MODE CONTENTS TO PLAIN WORDS OR SINGLE LETTERS  */
                else if (mode == LETTER_MODE) {
                    gs_pm_expand_letter_mode(buffer, &index, length, stream, &status);
                    continue;
                }
                /*  ELSE PASS CHARACTERS STRAIGHT THROUGH  */
                else
                    [stream putChar:buffer[index]];
                break;
        }
    }

    [stream truncate];
    assert([stream length] == [stream position]);
}



/// Convert contents of stream1 to stream2.  Add chunk, tone group, and associated markers;  expand words to pronunciations, and also expand other modes.

int gs_pm_final_conversion(NXStream *stream1, NXStream *stream2)
{
    long i, last_word_end = UNDEFINED_POSITION, tg_marker_pos = UNDEFINED_POSITION;
    long mode = NORMAL_MODE, next_mode, prior_tonic = TTS_NO, raw_mode_flag = TTS_NO;
    long last_written_state = STATE_BEGIN, current_state, next_state;
    const char *input;
    char word[WORD_LENGTH_MAX + 1];


    [stream2 seekWithOffset:0 fromPosition:NXStreamLocation_Start];

    /*  GET MEMORY BUFFER ASSOCIATED WITH STREAM1  */
    input = [stream1 mutableBytes];
    long stream1Length = [stream1 length];

    /*  MAIN LOOP  */
    for (i = 0; i < stream1Length; i++) {
        switch (input[i]) {
            case RAW_MODE_BEGIN:      mode = RAW_MODE;      break;
            case LETTER_MODE_BEGIN:   mode = LETTER_MODE;   break;
            case EMPHASIS_MODE_BEGIN: mode = EMPHASIS_MODE; break;
            case TAGGING_MODE_BEGIN:  mode = TAGGING_MODE;  break;
            case SILENCE_MODE_BEGIN:  mode = SILENCE_MODE;  break;

            case RAW_MODE_END:
            case LETTER_MODE_END:
            case EMPHASIS_MODE_END:
            case TAGGING_MODE_END:
            case SILENCE_MODE_END:    mode = NORMAL_MODE;   break;

            default:
                /*  GET STATE INFORMATION  */
                if (gs_pm_get_state(input, &i, stream1Length, &mode, &next_mode, &current_state,
                                    &next_state, &raw_mode_flag, word, stream2) != TTS_PARSER_SUCCESS)
                    return TTS_PARSER_FAILURE;

#if 0
                printf("last_written_state = %-d current_state = %-d next_state = %-d ",
                       last_written_state,current_state,next_state);
                printf("mode = %-d next_mode = %-d word = %s\n",
                       mode,next_mode,word);
#endif

                /*  ACTION ACCORDING TO CURRENT STATE  */
                switch (current_state) {

                    case STATE_WORD:
                        /*  ADD BEGINNING MARKERS IF NECESSARY (SWITCH FALL-THRU DESIRED)  */
                        switch (last_written_state) {
                            case STATE_BEGIN:
                                [stream2 printf:"%s ", CHUNK_BOUNDARY];
                            case STATE_FINAL_PUNC:
                                [stream2 printf:"%s ", TONE_GROUP_BOUNDARY];
                                prior_tonic = TTS_NO;
                            case STATE_MEDIAL_PUNC:
                                [stream2 printf:"%s ", TG_UNDEFINED];
                                tg_marker_pos = [stream2 position] - 3;
                            case STATE_SILENCE:
                                [stream2 printf:"%s ", UTTERANCE_BOUNDARY];
                        }

                        if (mode == NORMAL_MODE) {
                            /*  PUT IN WORD MARKER  */
                            [stream2 printf:"%s ", WORD_BEGIN];
                            /*  ADD LAST WORD MARKER AND TONICIZATION IF NECESSARY  */
                            switch (next_state) {
                                case STATE_MEDIAL_PUNC:
                                case STATE_FINAL_PUNC:
                                case STATE_END:
                                    /*  PUT IN LAST WORD MARKER  */
                                    [stream2 printf:"%s ", LAST_WORD];
                                    /*  WRITE WORD TO STREAM WITH TONIC IF NO PRIOR TONICIZATION  */
                                    gs_pm_expand_word(word, (!prior_tonic), stream2);
                                    break;
                                default:
                                    /*  WRITE WORD TO STREAM WITHOUT TONIC  */
                                    gs_pm_expand_word(word, TTS_NO, stream2);
                                    break;
                            }
                        }
                        else if (mode == EMPHASIS_MODE) {
                            /*  START NEW TONE GROUP IF PRIOR TONIC ALREADY SET  */
                            if (prior_tonic) {
                                if (gs_pm_set_tone_group(stream2, tg_marker_pos, ",") == TTS_PARSER_FAILURE)
                                    return TTS_PARSER_FAILURE;
                                [stream2 printf:"%s %s ", TONE_GROUP_BOUNDARY, TG_UNDEFINED];
                                tg_marker_pos = [stream2 position] - 3;
                            }
                            /*  PUT IN WORD MARKER  */
                            [stream2 printf:"%s ", WORD_BEGIN];
                            /*  MARK LAST WORD OF TONE GROUP, IF NECESSARY  */
                            if ((next_state == STATE_MEDIAL_PUNC) ||
                                (next_state == STATE_FINAL_PUNC) ||
                                (next_state == STATE_END) ||
                                ((next_state == STATE_WORD) && (next_mode == EMPHASIS_MODE)) )
                                [stream2 printf:"%s ", LAST_WORD];
                            /*  TONICIZE WORD  */
                            gs_pm_expand_word(word, TTS_YES, stream2);
                            prior_tonic = TTS_YES;
                        }

                        /*  SET LAST WRITTEN STATE, AND END POSITION AFTER THE WORD  */
                        last_written_state = STATE_WORD;
                        last_word_end = [stream2 position];
                        break;


                    case STATE_MEDIAL_PUNC:
                        /*  APPEND LAST WORD MARK, PAUSE, TONE GROUP MARK (FALL-THRU DESIRED)  */
                        switch (last_written_state) {
                            case STATE_WORD:
                                if (gs_pm_shift_silence(input, i, stream1Length, mode, stream2))
                                    last_word_end = [stream2 position];
                                else if ((next_state != STATE_END) &&
                                         gs_pm_another_word_follows(input, i, stream1Length, mode)) {
                                    if (!strcmp(word,","))
                                        [stream2 printf:"%s %s ", UTTERANCE_BOUNDARY, MEDIAL_PAUSE];
                                    else
                                        [stream2 printf:"%s %s ", UTTERANCE_BOUNDARY, LONG_MEDIAL_PAUSE];
                                }
                                else if (next_state == STATE_END)
                                    [stream2 printf:"%s ", UTTERANCE_BOUNDARY];
                            case STATE_SILENCE:
                                [stream2 printf:"%s ", TONE_GROUP_BOUNDARY];
                                prior_tonic = TTS_NO;
                                if (gs_pm_set_tone_group(stream2, tg_marker_pos, word) == TTS_PARSER_FAILURE)
                                    return TTS_PARSER_FAILURE;
                                tg_marker_pos = UNDEFINED_POSITION;
                                last_written_state = STATE_MEDIAL_PUNC;
                        }
                        break;


                    case STATE_FINAL_PUNC:
                        if (last_written_state == STATE_WORD) {
                            if (gs_pm_shift_silence(input, i, stream1Length, mode, stream2)) {
                                last_word_end = [stream2 position];
                                [stream2 printf:"%s ", TONE_GROUP_BOUNDARY];
                                prior_tonic = TTS_NO;
                                if (gs_pm_set_tone_group(stream2, tg_marker_pos, word) == TTS_PARSER_FAILURE)
                                    return TTS_PARSER_FAILURE;
                                tg_marker_pos = UNDEFINED_POSITION;
                                /*  IF SILENCE INSERTED, THEN CONVERT FINAL PUNCTUATION TO MEDIAL  */
                                last_written_state = STATE_MEDIAL_PUNC;
                            }
                            else {
                                [stream2 printf:"%s %s %s ", UTTERANCE_BOUNDARY,
                                         TONE_GROUP_BOUNDARY,CHUNK_BOUNDARY];
                                prior_tonic = TTS_NO;
                                if (gs_pm_set_tone_group(stream2, tg_marker_pos, word) == TTS_PARSER_FAILURE)
                                    return TTS_PARSER_FAILURE;
                                tg_marker_pos = UNDEFINED_POSITION;
                                last_written_state = STATE_FINAL_PUNC;
                            }
                        }
                        else if (last_written_state == STATE_SILENCE) {
                            [stream2 printf:"%s ", TONE_GROUP_BOUNDARY];
                            prior_tonic = TTS_NO;
                            if (gs_pm_set_tone_group(stream2, tg_marker_pos, word) == TTS_PARSER_FAILURE)
                                return TTS_PARSER_FAILURE;
                            tg_marker_pos = UNDEFINED_POSITION;
                            /*  IF SILENCE INSERTED, THEN CONVERT FINAL PUNCTUATION TO MEDIAL  */
                            last_written_state = STATE_MEDIAL_PUNC;
                        }
                        break;


                    case STATE_SILENCE:
                        if (last_written_state == STATE_BEGIN) {
                            [stream2 printf:"%s %s %s ", CHUNK_BOUNDARY, TONE_GROUP_BOUNDARY, TG_UNDEFINED];
                            prior_tonic = TTS_NO;
                            tg_marker_pos = [stream2 position] - 3;
                            if ((gs_pm_convert_silence(word, stream2) <= 0.0) && (next_state == STATE_END))
                                return TTS_PARSER_FAILURE;
                            last_written_state = STATE_SILENCE;
                            last_word_end = [stream2 position];
                        }
                        else if (last_written_state == STATE_WORD) {
                            gs_pm_convert_silence(word, stream2);
                            last_written_state = STATE_SILENCE;
                            last_word_end = [stream2 position];
                        }
                        break;


                    case STATE_TAGGING:
                        gs_pm_insert_tag(stream2, last_word_end, word);
                        last_word_end = UNDEFINED_POSITION;
                        break;


                    case STATE_END:
                        break;
                }
                break;
        }
    }

    /*  FINAL STATE  */
    switch (last_written_state) {

        case STATE_MEDIAL_PUNC:
            [stream2 printf:"%s", CHUNK_BOUNDARY];
            break;

        case STATE_WORD:  /*  FALL THROUGH DESIRED  */
            [stream2 printf:"%s ", UTTERANCE_BOUNDARY];
        case STATE_SILENCE:
            [stream2 printf:"%s %s", TONE_GROUP_BOUNDARY, CHUNK_BOUNDARY];
            //prior_tonic = TTS_NO;
            if (gs_pm_set_tone_group(stream2, tg_marker_pos, DEFAULT_END_PUNC) == TTS_PARSER_FAILURE)
                return TTS_PARSER_FAILURE;
            //tg_marker_pos = UNDEFINED_POSITION;
            break;

        case STATE_BEGIN:
            if (!raw_mode_flag)
                return TTS_PARSER_FAILURE;
            break;
    }

    [stream2 putChar:'\0'];
    [stream2 truncate];

    return TTS_PARSER_SUCCESS;
}



/// Determine the current state and next state in buffer.  A word or punctuation is put into word.  Expand raw mode contents into stream.

int gs_pm_get_state(const char *buffer, long *i, long length, long *mode, long *next_mode,
                    long *current_state, long *next_state, long *raw_mode_flag,
                    char *word, NXStream *stream)
{
    long j;
    long k, state = 0, current_mode;
    long *state_buffer[2];


    /*  PUT STATE POINTERS INTO ARRAY  */
    state_buffer[0] = current_state;
    state_buffer[1] = next_state;

    /*  GET 2 STATES  */
    for (j = *i, current_mode = *mode; j < length; j++) {
        /*  FILTER THROUGH EACH CHARACTER  */
        switch (buffer[j]) {
            case RAW_MODE_BEGIN:      current_mode = RAW_MODE;      break;
            case LETTER_MODE_BEGIN:   current_mode = LETTER_MODE;   break;
            case EMPHASIS_MODE_BEGIN: current_mode = EMPHASIS_MODE; break;
            case TAGGING_MODE_BEGIN:  current_mode = TAGGING_MODE;  break;
            case SILENCE_MODE_BEGIN:  current_mode = SILENCE_MODE;  break;

            case RAW_MODE_END:
            case LETTER_MODE_END:
            case EMPHASIS_MODE_END:
            case TAGGING_MODE_END:
            case SILENCE_MODE_END:    current_mode = NORMAL_MODE;   break;

            default:
                if ((current_mode == NORMAL_MODE) || (current_mode == EMPHASIS_MODE)) {
                    /*  SKIP WHITE  */
                    if (buffer[j] == ' ')
                        break;

                    /*  PUNCTUATION  */
                    if (gs_pm_is_punctuation(buffer[j])) {
                        if ((buffer[j] == '.') && ((j+1) < length) && isdigit(buffer[j+1])) {
                            ;  /*  DO NOTHING, HANDLE AS WORD BELOW  */
                        }
                        else {
                            /*  SET STATE ACCORDING TO PUNCUATION TYPE  */
                            switch (buffer[j]) {
                                case '.':
                                case '!':
                                case '?':  *(state_buffer[state]) = STATE_FINAL_PUNC;  break;
                                case ';':
                                case ':':
                                case ',':  *(state_buffer[state]) = STATE_MEDIAL_PUNC;  break;
                            }

                            /*  PUT PUNCTUATION INTO WORD BUFFER, SET OUTSIDE COUNTER, IN CURRENT STATE  */
                            if (state == 0) {
                                word[0] = buffer[j];
                                word[1] = '\0';
                                *i = j;
                                /*  SET OUTSIDE MODE  */
                                *mode = current_mode;
                            }
                            /*  SET NEXT MODE IF SECOND STATE  */
                            else
                                *next_mode = current_mode;

                            /*  INCREMENT STATE  */
                            state++;
                            break;
                        }
                    }

                    /*  WORD  */
                    if (state == 0) {
                        /*  PUT WORD INTO BUFFER  */
                        k = 0;
                        do {
                            word[k++] = buffer[j++];
                        } while ((j < length) && (buffer[j] != ' ') &&
                                 !gs_pm_is_mode(buffer[j]) && (k < WORD_LENGTH_MAX));
                        word[k] = '\0'; j--;

                        /*  BACK UP IF WORD ENDS WITH PUNCTUATION  */
                        while (k >= 1) {
                            if (gs_pm_is_punctuation(word[k-1])) {
                                word[--k] = '\0';
                                j--;
                            }
                            else
                                break;
                        }

                        /*  SET OUTSIDE COUNTER  */
                        *i = j;

                        /*  SET OUTSIDE MODE  */
                        *mode = current_mode;
                    }
                    else {
                        /*  SET NEXT MODE IF SECOND STATE  */
                        *next_mode = current_mode;
                    }

                    /*  SET STATE TO WORD, INCREMENT STATE  */
                    *(state_buffer[state++]) = STATE_WORD;
                    break;
                }
                else if ((current_mode == SILENCE_MODE) && (state == 0)) {
                    /*  PUT SILENCE LENGTH INTO WORD BUFFER IN CURRENT STATE ONLY  */
                    k = 0;
                    do {
                        word[k++] = buffer[j++];
                    } while ((j < length) && !gs_pm_is_mode(buffer[j]) && (k < WORD_LENGTH_MAX));
                    word[k] = '\0';  j--;

                    /*  SET OUTSIDE COUNTER  */
                    *i = j;

                    /*  SET OUTSIDE MODE  */
                    *mode = current_mode;

                    /*  SET STATE TO SILENCE, INCREMENT STATE  */
                    *(state_buffer[state++]) = STATE_SILENCE;
                }
                else if ((current_mode == TAGGING_MODE) && (state == 0)) {
                    /*  PUT TAG INTO WORD BUFFER IN CURRENT STATE ONLY  */
                    k = 0;
                    do {
                        word[k++] = buffer[j++];
                    } while ((j < length) && !gs_pm_is_mode(buffer[j]) && (k < WORD_LENGTH_MAX));
                    word[k] = '\0';  j--;

                    /*  SET OUTSIDE COUNTER  */
                    *i = j;

                    /*  SET OUTSIDE MODE  */
                    *mode = current_mode;

                    /*  SET STATE TO TAGGING, INCREMENT STATE  */
                    *(state_buffer[state++]) = STATE_TAGGING;
                }
                else if ((current_mode == RAW_MODE) && (state == 0)) {
                    /*  EXPAND RAW MODE IN CURRENT STATE ONLY  */
                    if (gs_pm_expand_raw_mode(buffer, &j, length, stream) != TTS_PARSER_SUCCESS)
                        return TTS_PARSER_FAILURE;

                    /*  SET RAW_MODE FLAG  */
                    *raw_mode_flag = TTS_YES;

                    /*  SET OUTSIDE COUNTER  */
                    *i = j;
                }
                break;
        }

        /*  ONLY NEED TWO STATES  */
        if (state >= 2)
            return TTS_PARSER_SUCCESS;
    }


    /*  IF HERE, THEN END OF INPUT BUFFER, INDICATE END STATE  */
    if (state == 0) {
        /*  SET STATES  */
        *current_state = STATE_END;
        *next_state = STATE_UNDEFINED;
        /*  BLANK OUT WORD BUFFER  */
        word[0] = '\0';
        /*  SET OUTSIDE COUNTER  */
        *i = j;
        /*  SET OUTSIDE MODE  */
        *mode = current_mode;
    }
    else
        *next_state = STATE_END;

    return TTS_PARSER_SUCCESS;
}



/// Set the tone group marker according to the punctuation passed in as "word".  The marker is inserted in the stream at position "tg_pos".

int gs_pm_set_tone_group(NXStream *stream, long tg_pos, char *word)
{
    if (tg_pos == UNDEFINED_POSITION)
        return TTS_PARSER_FAILURE;

    long current_pos = [stream position];

    /*  SEEK TO TONE GROUP MARKER POSITION  */
    [stream seekWithOffset:tg_pos fromPosition:NXStreamLocation_Start];

    /*  WRITE APPROPRIATE TONE GROUP TYPE  */
    switch (word[0]) {
        case '.': [stream printf:"%s", TG_STATEMENT];    break;
        case '!': [stream printf:"%s", TG_EXCLAMATION];  break;
        case '?': [stream printf:"%s", TG_QUESTION];     break;
        case ',': [stream printf:"%s", TG_CONTINUATION]; break;
        case ';': [stream printf:"%s", TG_HALF_PERIOD];  break;
        case ':': [stream printf:"%s", TG_CONTINUATION]; break;
        default:  return TTS_PARSER_FAILURE;
    }

    /*  SEEK TO ORIGINAL POSITION ON STREAM  */
    [stream seekWithOffset:current_pos fromPosition:NXStreamLocation_Start];

    return TTS_PARSER_SUCCESS;
}



/// Convert numeric quantity in "buffer" to appropriate number of silence phones, and write these onto the
/// end of stream.  Perform rounding.
///
/// @returns Return actual length of silence.

double gs_pm_convert_silence(char *buffer, NXStream *stream)
{
    double silence_length = strtod(buffer, NULL);
    silence_length = MIN(silence_length, kSilenceMax);                        // Limit silence length to maximum.
    long number_silence_phones = rintl(silence_length / kSilencePhoneLength); // Find equivalent number of silence phones, performing rounding.

    [stream printf:"%s ", UTTERANCE_BOUNDARY];
    for (NSUInteger index = 0; index < number_silence_phones; index++)
        [stream printf:"%s ", SILENCE_PHONE];

    return number_silence_phones * kSilencePhoneLength;                       // Return actual length of silence.
}



/// @returns Return 1 if another word follows in buffer, after position i.
/// @returns Otherwise, return 0.

int gs_pm_another_word_follows(const char *buffer, long i, long length, long mode)
{
    for (long j = i + 1; j < length; j++) {
        /*  FILTER THROUGH EACH CHARACTER  */
        switch (buffer[j]) {
            case RAW_MODE_BEGIN:      mode = RAW_MODE;      break;
            case LETTER_MODE_BEGIN:   mode = LETTER_MODE;   break;
            case EMPHASIS_MODE_BEGIN: mode = EMPHASIS_MODE; break;
            case TAGGING_MODE_BEGIN:  mode = TAGGING_MODE;  break;
            case SILENCE_MODE_BEGIN:  mode = SILENCE_MODE;  break;

            case RAW_MODE_END:
            case LETTER_MODE_END:
            case EMPHASIS_MODE_END:
            case TAGGING_MODE_END:
            case SILENCE_MODE_END:    mode = NORMAL_MODE;   break;

            default:
                if ((mode == NORMAL_MODE) || (mode == EMPHASIS_MODE)) {
                    /*  WORD HAS BEEN FOUND  */
                    if (!gs_pm_is_punctuation(buffer[j]))
                        return 1;
                }
                break;
        }
    }

    /*  IF HERE, THEN NO WORD FOLLOWS  */
    return 0;
}



/// Look past punctuation to see if some silence occurs before the next word (or raw mode contents).
/// If so, convert the numeric quantity into the equivalent silence phones on the outputStream.
///
/// @param buffer       The input buffer.
/// @param offset       The offset into the input buffer.
/// @param bufferLength The length of the input buffer.
/// @param currentMode  The current mode at the offset of the buffer.
/// @param outputStream The output stream.
///
/// @return 1 if silence was shifted.
/// @return 0 otherwise.

int gs_pm_shift_silence(const char *buffer, long offset, long bufferLength, long currentMode, NXStream *outputStream)
{
    for (long index = offset + 1; index < bufferLength; index++) {
        /*  FILTER THROUGH EACH CHARACTER  */
        switch (buffer[index]) {
            case RAW_MODE_BEGIN:      currentMode = RAW_MODE;      break;
            case LETTER_MODE_BEGIN:   currentMode = LETTER_MODE;   break;
            case EMPHASIS_MODE_BEGIN: currentMode = EMPHASIS_MODE; break;
            case TAGGING_MODE_BEGIN:  currentMode = TAGGING_MODE;  break;
            case SILENCE_MODE_BEGIN:  currentMode = SILENCE_MODE;  break;

            case RAW_MODE_END:
            case LETTER_MODE_END:
            case EMPHASIS_MODE_END:
            case TAGGING_MODE_END:
            case SILENCE_MODE_END:    currentMode = NORMAL_MODE;   break;

            default:
                if ((currentMode == NORMAL_MODE) || (currentMode == EMPHASIS_MODE)) {
                    /*  SKIP WHITE SPACE  */
                    if (buffer[index] == ' ')
                        continue;
                    /*  WORD HERE, SO RETURN WITHOUT SHIFTING  */
                    if (!gs_pm_is_punctuation(buffer[index]))
                        return 0;
                }
                else if (currentMode == RAW_MODE) {
                /*  ASSUME RAW MODE CONTAINS WORD OF SOME SORT  */
                    return 0;
                } else if (currentMode == SILENCE_MODE) {
                    /*  COLLECT SILENCE DIGITS INTO WORD BUFFER  */
                    char word[WORD_LENGTH_MAX + 1];
                    
                    int wordIndex = 0;
                    do {
                        word[wordIndex++] = buffer[index++];
                    } while ((index < bufferLength) && !gs_pm_is_mode(buffer[index]) && (wordIndex < WORD_LENGTH_MAX));
                    word[wordIndex] = '\0';

                    /*  CONVERT WORD TO SILENCE PHONES, APPENDING TO STREAM  */
                    gs_pm_convert_silence(word, outputStream);

                    /*  RETURN, INDICATING SILENCE SHIFTED BACKWARDS  */
                    return 1;
                }
                break;
        }
    }

    /*  IF HERE, THEN SILENCE NOT SHIFTED  */
    return 0;
}



/// Insert the tag contained in word onto the stream at the insert_point.

void gs_pm_insert_tag(NXStream *stream, long insert_point, char *word)
{
    /*  RETURN IMMEDIATELY IF NO INSERT POINT  */
    if (insert_point == UNDEFINED_POSITION)
        return;

    long end_point = [stream position];

    /*  CALCULATE HOW MANY CHARACTERS TO SHIFT  */
    long length = end_point - insert_point;

    /*  IF LENGTH IS 0, THEN SIMPLY APPEND TAG TO STREAM  */
    if (length == 0) {
        [stream printf:"%s %s ", TAG_BEGIN, word];
    } else {
        /*  ELSE, SAVE STREAM AFTER INSERT POINT  */
        char *temp = (char *)malloc(length+1);
        assert(temp != NULL);
        [stream seekWithOffset:insert_point fromPosition:NXStreamLocation_Start];
        long j;
        for (j = 0; j < length; j++)
            temp[j] = [stream getChar];
        temp[j] = '\0';

        /*  INSERT TAG; ADD TEMPORARY MATERIAL  */
        [stream seekWithOffset:insert_point fromPosition:NXStreamLocation_Start];
        [stream printf:"%s %s %s", TAG_BEGIN, word, temp];

        free(temp);
    }
}



/// Write pronunciation of word to stream.  Deal with possessives if necessary.  Also, deal with single
/// characters, and upper case words (including special acronyms) if necessary.  Add special marks if word
/// is tonic.

void gs_pm_expand_word(char *word, long is_tonic, NXStream *stream)
{
    short dictionary;
    const char *pronunciation, *ptr;
    long last_foot_begin, temporary_position;
    char last_phoneme[SYMBOL_LENGTH_MAX+1], *last_phoneme_ptr;


    /*  STRIP OF POSSESSIVE ENDING IF WORD ENDS WITH 's, SET FLAG  */
    int possessive = gs_pm_is_possessive(word);

    /*  USE degenerate_string IF WORD IS A SINGLE CHARACTER
     (EXCEPT SMALL, NON-POSSESSIVE A)  */
    if ((strlen(word) == 1) && isalpha(word[0])) {
        if (!strcmp(word,"a") && !possessive)
            pronunciation = "uh";
        else
            pronunciation = degenerate_string((const char *)word);
        dictionary = TTS_LETTER_TO_SOUND;
    }
    /*  ALL UPPER CASE WORDS PRONOUNCED ONE LETTER AT A TIME,
     EXCEPT SPECIAL ACRONYMS  */
    else if (gs_pm_is_all_upper_case(word)) {
        if (!(pronunciation = gs_pm_is_special_acronym(word)))
            pronunciation = degenerate_string((const char *)word);

        dictionary = TTS_LETTER_TO_SOUND;
    }
    /*  ALL OTHER WORDS ARE LOOKED UP IN DICTIONARIES, AFTER CONVERTING TO LOWER CASE  */
    else
        pronunciation = lookup_word((const char *)gs_pm_to_lower_case(word), &dictionary);


    /*  ADD FOOT BEGIN MARKER TO FRONT OF WORD IF IT HAS NO PRIMARY STRESS AND IT IS
     TO RECEIVE A TONIC;  IF ONLY A SECONDARY STRESS MARKER, CONVERT TO PRIMARY  */
    last_foot_begin = UNDEFINED_POSITION;
    if (is_tonic && !gs_pm_contains_primary_stress(pronunciation)) {
        if (!gs_pm_converted_stress((char *)pronunciation)) {
            [stream printf:FOOT_BEGIN];
            last_foot_begin = [stream position] - 2;
        }
    }

    /*  PRINT PRONUNCIATION TO STREAM, UP TO WORD TYPE MARKER (%)  */
    /*  KEEP TRACK OF LAST PHONEME  */
    ptr = pronunciation;
    last_phoneme[0] = '\0';
    last_phoneme_ptr = last_phoneme;
    while (*ptr && (*ptr != '%')) {
        switch (*ptr) {
            case '\'':
            case '`':
                [stream printf:FOOT_BEGIN];
                last_foot_begin = [stream position] - 2;
                last_phoneme[0] = '\0';
                last_phoneme_ptr = last_phoneme;
                break;
            case '"':
                [stream printf:SECONDARY_STRESS];
                last_phoneme[0] = '\0';
                last_phoneme_ptr = last_phoneme;
                break;
            case '_':
            case '.':
                [stream printf:"%c", *ptr];
                last_phoneme[0] = '\0';
                last_phoneme_ptr = last_phoneme;
                break;
            case ' ':
                /*  SUPPRESS UNNECESSARY BLANKS  */
                if (*(ptr+1) && (*(ptr+1) != ' ')) {
                    [stream printf:"%c", *ptr];
                    last_phoneme[0] = '\0';
                    last_phoneme_ptr = last_phoneme;
                }
                break;
            default:
                [stream printf:"%c", *ptr];
                *last_phoneme_ptr++ = *ptr;
                *last_phoneme_ptr = '\0';
                break;
        }
        ptr++;
    }

    /*  ADD APPROPRIATE ENDING TO PRONUNCIATION IF POSSESSIVE  */
    if (possessive) {
        if (!strcmp(last_phoneme,"p") || !strcmp(last_phoneme,"t") ||
            !strcmp(last_phoneme,"k") || !strcmp(last_phoneme,"f") ||
            !strcmp(last_phoneme,"th"))
            [stream printf:"_s"];
        else if (!strcmp(last_phoneme,"s") || !strcmp(last_phoneme,"sh") ||
                 !strcmp(last_phoneme,"z") || !strcmp(last_phoneme,"zh") ||
                 !strcmp(last_phoneme,"j") || !strcmp(last_phoneme,"ch"))
            [stream printf:".uh_z"];
        else
            [stream printf:"_z"];
    }

    /*  ADD SPACE AFTER WORD  */
    [stream printf:" "];

    /*  IF TONIC, CONVERT LAST FOOT MARKER TO TONIC MARKER  */
    if (is_tonic && (last_foot_begin != UNDEFINED_POSITION)) {
        temporary_position = [stream position];
        [stream seekWithOffset:last_foot_begin fromPosition:NXStreamLocation_Start];
        [stream printf:TONIC_BEGIN];
        [stream seekWithOffset:temporary_position fromPosition:NXStreamLocation_Start];
    }
}



/// Write raw mode contents to stream, and check phones and markers.

int gs_pm_expand_raw_mode(const char *buffer, long *j, long length, NXStream *stream)
{
    int k, super_raw_mode = TTS_NO, delimiter = TTS_NO, blank = TTS_YES;
    char token[SYMBOL_LENGTH_MAX+1];

    /*  EXPAND AND CHECK RAW MODE CONTENTS TILL END OF RAW MODE  */
    token[k=0] = '\0';
    for ( ; (*j < length) && (buffer[*j] != RAW_MODE_END); (*j)++) {
        [stream printf:"%c", buffer[*j]];
        /*  CHECK IF ENTERING OR EXITING SUPER RAW MODE  */
        if (buffer[*j] == '%') {
            if (!super_raw_mode) {
                if (gs_pm_illegal_token(token))
                    return TTS_PARSER_FAILURE;
                super_raw_mode = TTS_YES;
                token[k=0] = '\0';
                continue;
            }
            else {
                super_raw_mode = TTS_NO;
                token[k=0] = '\0';
                delimiter = blank = TTS_NO;
                continue;
            }
        }
        /*  EXAMINE SLASH CODES, DELIMITERS, AND PHONES IN REGULAR RAW MODE  */
        if (!super_raw_mode) {
            switch (buffer[*j]) {
                case '/':
                    /*  SLASH CODE  */
                    /*  EVALUATE PENDING TOKEN  */
                    if (gs_pm_illegal_token(token))
                        return TTS_PARSER_FAILURE;
                    /*  PUT SLASH CODE INTO TOKEN BUFFER  */
                    token[0] = '/';
                    if ((++(*j) < length) && (buffer[*j] != RAW_MODE_END)) {
                        [stream printf:"%c", buffer[*j]];
                        token[1] = buffer[*j];
                        token[2] = '\0';
                        /*  CHECK LEGALITY OF SLASH CODE  */
                        if (gs_pm_illegal_slash_code(token))
                            return TTS_PARSER_FAILURE;
                        /*  CHECK ANY TAG AND TAG NUMBER  */
                        if (!strcmp(token,TAG_BEGIN)) {
                            if (gs_pm_expand_tag_number(buffer, j, length, stream) == TTS_PARSER_FAILURE)
                                return TTS_PARSER_FAILURE;
                        }
                        /*  RESET FLAGS  */
                        token[k=0] = '\0';
                        delimiter = blank = TTS_NO;
                    }
                    else
                        return TTS_PARSER_FAILURE;
                    break;
                case '_':
                case '.':
                    /*  SYLLABLE DELIMITERS  */
                    /*  DON'T ALLOW REPEATED DELIMITERS, OR DELIMITERS AFTER BLANK  */
                    if (delimiter || blank)
                        return TTS_PARSER_FAILURE;
                    delimiter++;
                    blank = TTS_NO;
                    /*  EVALUATE PENDING TOKEN  */
                    if (gs_pm_illegal_token(token))
                        return TTS_PARSER_FAILURE;
                    /*  RESET FLAGS  */
                    token[k=0] = '\0';
                    break;
                case ' ':
                    /*  WORD DELIMITER  */
                    /*  DON'T ALLOW SYLLABLE DELIMITER BEFORE BLANK  */
                    if (delimiter)
                        return TTS_PARSER_FAILURE;
                    /*  SET FLAGS  */
                    blank++;
                    delimiter = TTS_NO;
                    /*  EVALUATE PENDING TOKEN  */
                    if (gs_pm_illegal_token(token))
                        return TTS_PARSER_FAILURE;
                    /*  RESET FLAGS  */
                    token[k=0] = '\0';
                    break;
                default:
                    /*  PHONE SYMBOL  */
                    /*  RESET FLAGS  */
                    delimiter = blank = TTS_NO;
                    /*  ACCUMULATE PHONE SYMBOL IN TOKEN BUFFER  */
                    token[k++] = buffer[*j];
                    if (k <= SYMBOL_LENGTH_MAX)
                        token[k] = '\0';
                    else
                        return TTS_PARSER_FAILURE;
                    break;
            }
        }
    }

    /*  CHECK ANY REMAINING TOKENS  */
    if (gs_pm_illegal_token(token))
        return TTS_PARSER_FAILURE;

    /*  CANNOT END WITH A DELIMITER  */
    if (delimiter)
        return TTS_PARSER_FAILURE;

    /*  PAD WITH SPACE, RESET EXTERNAL COUNTER  */
    [stream printf:" "];
    (*j)--;

    return TTS_PARSER_SUCCESS;
}



/// @return Return 1 if token is not a valid Monet phone.
/// @return Return 0 otherwise.

int gs_pm_illegal_token(char *token)
{
    if (strlen(token) == 0)
        return 0;

    /*  IF PHONE A VALID DEGAS PHONE, RETURN 0;  1 OTHERWISE  */
    if (validPhone(token))
        return 0;

    return 1;
}



/// @return Return 1 if code is illegal, 0 otherwise.

int gs_pm_illegal_slash_code(char *code)
{
    static char *legal_code[] = {
        CHUNK_BOUNDARY,
        TONE_GROUP_BOUNDARY,
        FOOT_BEGIN,
        TONIC_BEGIN,
        SECONDARY_STRESS,
        LAST_WORD,
        TAG_BEGIN,
        WORD_BEGIN,
        TG_STATEMENT,
        TG_EXCLAMATION,
        TG_QUESTION,
        TG_CONTINUATION,
        TG_HALF_PERIOD,
        NULL
    };

    /*  COMPARE CODE WITH LEGAL CODES, RETURN 0 IMMEDIATELY IF A MATCH  */
    int index = 0;
    while (legal_code[index] != NULL)
        if (!strcmp(legal_code[index++], code))
            return 0;

    /*  IF HERE, THEN NO MATCH;  RETURN 1, INDICATING ILLEGAL CODE  */
    return 1;
}



/// Expand tag number in buffer at position j and write to stream.  Perform error checking.
/// @return Error code if format of tag number is illegal.

int gs_pm_expand_tag_number(const char *buffer, long *j, long length, NXStream *stream)
{
    int sign = 0;

    /*  SKIP WHITE  */
    while ((((*j)+1) < length) && (buffer[(*j)+1] == ' ')) {
        (*j)++;
        [stream printf:"%c", buffer[*j]];
    }

    /*  CHECK FORMAT OF TAG NUMBER  */
    while ((((*j)+1) < length) && (buffer[(*j)+1] != ' ') &&
           (buffer[(*j)+1] != RAW_MODE_END) && (buffer[(*j)+1] != '%')) {
        [stream printf:"%c", buffer[++(*j)]];
        if ((buffer[*j] == '-') || (buffer[*j] == '+')) {
            if (sign)
                return TTS_PARSER_FAILURE;
            sign++;
        }
        else if (!isdigit(buffer[*j]))
            return TTS_PARSER_FAILURE;
    }

    return TTS_PARSER_SUCCESS;
}



/// @return Return 1 if character is a mode marker, 0 otherwise.

int gs_pm_is_mode(char ch)
{
    if ((ch >= SILENCE_MODE_END) && (ch <= RAW_MODE_BEGIN))
        return 1;

    return 0;
}



/// @return Return 1 if character at position i is isolated, i.e. is surrounded by space or mode marker.
/// @return Return 0 otherwise.

int gs_pm_is_isolated(char *buffer, long i, long len)
{
    if (   ((i == 0)       || (((i-1) >= 0)  && (gs_pm_is_mode(buffer[i-1]) || (buffer[i-1] == ' '))))
        && ((i == (len-1)) || (((i+1) < len) && (gs_pm_is_mode(buffer[i+1]) || (buffer[i+1] == ' ')))))
    {
        return 1;
    }

    return 0;
}



/// @return Return 1 if character at position i is part of a number (including mixtures with non-numeric characters).
/// @return Return 0 otherwise.

int gs_pm_part_of_number(char *buffer, long i, long len)
{
    while (   (--i >= 0)
           && (buffer[i] != ' ')
           && (buffer[i] != DELETED)
           && (!gs_pm_is_mode(buffer[i])) )
    {
        if (isdigit(buffer[i]))
            return 1;
    }

    while (   (++i < len)
           && (buffer[i] != ' ')
           && (buffer[i] != DELETED)
           && (!gs_pm_is_mode(buffer[i])) )
    {
        if (isdigit(buffer[i]))
            return 1;
    }

    return 0;
}



/// @return Return a 1 if at least one digit follows the character at position i, up to white space or mode marker.
/// @return Return 0 otherwise.

int gs_pm_number_follows(char *buffer, long i, long len)
{
    while (   (++i < len)
           && (buffer[i] != ' ')
           && (buffer[i] != DELETED)
           && (!gs_pm_is_mode(buffer[i])) )
    {
        if (isdigit(buffer[i]))
            return 1;
    }

    return 0;
}



/// Delete three dots in a row (disregarding white space).  If four dots, then the last three are deleted.

void gs_pm_delete_ellipsis(char *buffer, long *i, long length)
{
    /*  SET POSITION OF FIRST DOT  */
    long pos1 = *i, pos2, pos3;

    /*  IGNORE ANY WHITE SPACE  */
    while (((*i+1) < length) && (buffer[*i+1] == ' '))
        (*i)++;
    /*  CHECK FOR 2ND DOT  */
    if (((*i+1) < length) && (buffer[*i+1] == '.')) {
        pos2 = ++(*i);
        /*  IGNORE ANY WHITE SPACE  */
        while (((*i+1) < length) && (buffer[*i+1] == ' '))
            (*i)++;
        /*  CHECK FOR 3RD DOT  */
        if (((*i+1) < length) && (buffer[*i+1] == '.')) {
            pos3 = ++(*i);
            /*  IGNORE ANY WHITE SPACE  */
            while (((*i+1) < length) && (buffer[*i+1] == ' '))
                (*i)++;
            /*  CHECK FOR 4TH DOT  */
            if (((*i+1) < length) && (buffer[*i+1] == '.'))
                buffer[pos2] = buffer[pos3] = buffer[++(*i)] = DELETED;
            else
                buffer[pos1] = buffer[pos2] = buffer[pos3] = DELETED;
        }
    }
}



/// Convert "--" to ", ", and "---" to ",  "
/// @return Return 1 if this is done, 0 otherwise.

int gs_pm_convert_dash(char *buffer, long *i, long length)
{
    /*  SET POSITION OF INITIAL DASH  */
    long pos1 = *i;

    /*  CHECK FOR 2ND DASH  */
    if (((*i+1) < length) && (buffer[*i+1] == '-')) {
        buffer[pos1] = ',';
        buffer[++(*i)] = DELETED;
        /*  CHECK FOR 3RD DASH  */
        if (((*i+1) < length) && (buffer[*i+1] == '-'))
            buffer[++(*i)] = DELETED;
        return 1;
    }

    /*  RETURN ZERO IF NOT CONVERTED  */
    return 0;
}



/// @return Return 1 if string at position i in buffer is of the form:  (ddd)ddd-dddd
///         where each d is a digit.

int gs_pm_is_telephone_number(char *buffer, long i, long length)
{
    /*  CHECK FORMAT: (ddd)ddd-dddd  */
    if ( ((i+12) < length)
        && isdigit(buffer[i+1]) && isdigit(buffer[i+2]) && isdigit(buffer[i+3])
        && (buffer[i+4] == ')')
        && isdigit(buffer[i+5]) && isdigit(buffer[i+6]) && isdigit(buffer[i+7])
        && (buffer[i+8] == '-')
        && isdigit(buffer[i+9]) && isdigit(buffer[i+10]) && isdigit(buffer[i+11]) && isdigit(buffer[i+12]) )
    {
        /*  MAKE SURE STRING ENDS WITH WHITE SPACE, MODE, OR PUNCTUATION  */
        if ( ((i+13) == length)
            || ( ((i+13) < length)
                && ( gs_pm_is_punctuation(buffer[i+13])
                    || gs_pm_is_mode(buffer[i+13])
                    || (buffer[i+13] == ' ')
                    || (buffer[i+13] == DELETED)
                    )
                )
            )
        {
            return 1;
        }
    }

    /*  STRING IS NOT IN SPECIFIED FORMAT  */
    return 0;
}



/// @return Return 1 if character is a .,;:?!
/// @return Return 0 otherwise.

int gs_pm_is_punctuation(char ch)
{
    switch (ch) {
        case '.':
        case ',':
        case ';':
        case ':':
        case '?':
        case '!':
            return 1;
        default:
            return 0;
    }
}



/// @return Return a 1 if a word or speakable symbol (letter mode) follows the position i in buffer.  Raw, tagging, and
///         silence mode contents are ignored.
/// @return Return a 0 if any punctuation (except . as part of number) follows.

int gs_pm_word_follows(char *buffer, long i, long length)
{
    long mode = NORMAL_MODE;

    for (long j = (i+1); j < length; j++) {
        switch (buffer[j]) {
            case RAW_MODE_BEGIN:      mode = RAW_MODE;      break;
            case LETTER_MODE_BEGIN:   mode = LETTER_MODE;   break;
            case EMPHASIS_MODE_BEGIN: mode = EMPHASIS_MODE; break;
            case TAGGING_MODE_BEGIN:  mode = TAGGING_MODE;  break;
            case SILENCE_MODE_BEGIN:  mode = SILENCE_MODE;  break;
            case RAW_MODE_END:
            case LETTER_MODE_END:
            case EMPHASIS_MODE_END:
            case TAGGING_MODE_END:
            case SILENCE_MODE_END:    mode = NORMAL_MODE;   break;
            default:
                switch (mode) {
                    case NORMAL_MODE:
                    case EMPHASIS_MODE:
                        /*  IGNORE WHITE SPACE  */
                        if ((buffer[j] == ' ') || (buffer[j] == DELETED))
                            continue;
                        /*  PUNCTUATION MEANS NO WORD FOLLOWS (UNLESS PERIOD PART OF NUMBER)  */
                        else if (gs_pm_is_punctuation(buffer[j])) {
                            if ((buffer[j] == '.') && ((j+1) < length) && isdigit(buffer[j+1]))
                                return 1;
                            else
                                return 0;
                        }
                        /*  ELSE, SOME WORD FOLLOWS  */
                        else
                            return 1;
                    case LETTER_MODE:
                        /*  IF LETTER MODE CONTAINS ANY SYMBOLS, THEN RETURN 1  */
                        return 1;
                    case RAW_MODE:
                    case SILENCE_MODE:
                    case TAGGING_MODE:
                        /*  IGNORE CONTENTS OF RAW, SILENCE, AND TAGGING MODE  */
                        continue;
                }
        }
    }

    /*  IF HERE, THEN A FOLLOWING WORD NOT FOUND  */
    return 0;
}



/// Expand listed abbreviations.  Two lists are used (see abbreviations.h):  one list expands unconditionally,
/// the other only if the abbreviation is followed by a number.  The abbreviation p. is expanded to page.
/// Single alphabetic characters have periods deleted, but no expansion is made.  They are also capitalized.
///
/// @return Returns 1 if expansion made (i.e. period is deleted), 0 otherwise.

int gs_pm_expand_abbreviation(char *buffer, long i, long length, NXStream *stream)
{
    long j, k, word_length = 0;
    char word[5];

    /*  DELETE PERIOD AFTER SINGLE CHARACTER (EXCEPT p.)  */
    if ( ((i-1) == 0) ||  ( ((i-2) >= 0) &&
                           ( (buffer[i-2] == ' ') || (buffer[i-2] == '.') || (gs_pm_is_mode(buffer[i-2])) )
                           ) ) {
        if (isalpha(buffer[i-1])) {
            if ((buffer[i-1] == 'p') && (((i-1) == 0) || (((i-2) >= 0) && (buffer[i-2] != '.')) ) ) {
                /*  EXPAND p. TO page  */
                [stream seekWithOffset:-1 fromPosition:NXStreamLocation_Current];
                [stream printf:"page "];
            }
            else {
                /*  ELSE, CAPITALIZE CHARACTER IF NECESSARY, BLANK OUT PERIOD  */
                [stream seekWithOffset:-1 fromPosition:NXStreamLocation_Current];
                if (islower(buffer[i-1]))
                    buffer[i-1] = toupper(buffer[i-1]);
                [stream printf:"%c ", buffer[i-1]];
            }
            /*  INDICATE ABBREVIATION EXPANDED  */
            return 1;
        }
    }

    /*  GET LENGTH OF PRECEDING ISOLATED STRING, UP TO 4 CHARACTERS  */
    for (j = 2; j <= 4; j++) {
        if (((i-j) == 0) ||
            (((i-(j+1)) >= 0) && ((buffer[i-(j+1)] == ' ') || (gs_pm_is_mode(buffer[i-(j+1)]))) ) ) {
            if (isalpha(buffer[i-j]) && isalpha(buffer[i-j+1])) {
                word_length = j;
                break;
            }
        }
    }

    /*  IS ABBREVIATION ONLY IF WORD LENGTH IS 2, 3, OR 4 CHARACTERS  */
    if ((word_length >= 2) && (word_length <= 4)) {
        /*  GET ABBREVIATION  */
        for (k = 0, j = i - word_length; k < word_length; k++)
            word[k] = buffer[j++];
        word[k] = '\0';

        /*  EXPAND THESE ABBREVIATIONS ONLY IF FOLLOWED BY NUMBER  */
        for (j = 0; abbr_with_number[j][ABBREVIATION] != NULL; j++) {
            if (!strcmp(abbr_with_number[j][ABBREVIATION],word)) {
                /*  IGNORE WHITE SPACE  */
                while (((i+1) < length) && ((buffer[i+1] == ' ') || (buffer[i+1] == DELETED)))
                    i++;
                /*  EXPAND ONLY IF NUMBER FOLLOWS  */
                if (gs_pm_number_follows(buffer, i, length)) {
                    [stream seekWithOffset:-word_length fromPosition:NXStreamLocation_Current];
                    [stream printf:"%s ", abbr_with_number[j][EXPANSION]];
                    return 1;
                }
            }
        }

        /*  EXPAND THESE ABBREVIATIONS UNCONDITIONALLY  */
        for (j = 0; abbreviation[j][ABBREVIATION] != NULL; j++) {
            if (!strcmp(abbreviation[j][ABBREVIATION],word)) {
                [stream seekWithOffset:-word_length fromPosition:NXStreamLocation_Current];
                [stream printf:"%s ", abbreviation[j][EXPANSION]];
                return 1;
            }
        }
    }

    /*  IF HERE, THEN NO EXPANSION MADE  */
    return 0;
}



/// Expand contents of letter mode string to word or words.  Add a comma after each expansion, except
/// the last letter when it is followed by punctuation.

void gs_pm_expand_letter_mode(char *buffer, long *i, long length, NXStream *stream, long *status)
{
    for ( ; ((*i) < length) && (buffer[*i] != LETTER_MODE_END); (*i)++) {
        /*  CONVERT LETTER TO WORD OR WORDS  */
        switch (buffer[*i]) {
            case ' ': [stream printf:"blank"];                break;
            case '!': [stream printf:"exclamation point"];    break;
            case '"': [stream printf:"double quote"];         break;
            case '#': [stream printf:"number sign"];          break;
            case '$': [stream printf:"dollar"];               break;
            case '%': [stream printf:"percent"];              break;
            case '&': [stream printf:"ampersand"];            break;
            case '\'':[stream printf:"single quote"];         break;
            case '(': [stream printf:"open parenthesis"];     break;
            case ')': [stream printf:"close parenthesis"];    break;
            case '*': [stream printf:"asterisk"];             break;
            case '+': [stream printf:"plus sign"];            break;
            case ',': [stream printf:"comma"];                break;
            case '-': [stream printf:"hyphen"];               break;
            case '.': [stream printf:"period"];               break;
            case '/': [stream printf:"slash"];                break;
            case '0': [stream printf:"zero"];                 break;
            case '1': [stream printf:"one"];                  break;
            case '2': [stream printf:"two"];                  break;
            case '3': [stream printf:"three"];                break;
            case '4': [stream printf:"four"];                 break;
            case '5': [stream printf:"five"];                 break;
            case '6': [stream printf:"six"];                  break;
            case '7': [stream printf:"seven"];                break;
            case '8': [stream printf:"eight"];                break;
            case '9': [stream printf:"nine"];                 break;
            case ':': [stream printf:"colon"];                break;
            case ';': [stream printf:"semicolon"];            break;
            case '<': [stream printf:"open angle bracket"];   break;
            case '=': [stream printf:"equal sign"];           break;
            case '>': [stream printf:"close angle bracket"];  break;
            case '?': [stream printf:"question mark"];        break;
            case '@': [stream printf:"at sign"];              break;
            case 'A':
            case 'a': [stream printf:"A"];                    break;
            case 'B':
            case 'b': [stream printf:"B"];                    break;
            case 'C':
            case 'c': [stream printf:"C"];                    break;
            case 'D':
            case 'd': [stream printf:"D"];                    break;
            case 'E':
            case 'e': [stream printf:"E"];                    break;
            case 'F':
            case 'f': [stream printf:"F"];                    break;
            case 'G':
            case 'g': [stream printf:"G"];                    break;
            case 'H':
            case 'h': [stream printf:"H"];                    break;
            case 'I':
            case 'i': [stream printf:"I"];                    break;
            case 'J':
            case 'j': [stream printf:"J"];                    break;
            case 'K':
            case 'k': [stream printf:"K"];                    break;
            case 'L':
            case 'l': [stream printf:"L"];                    break;
            case 'M':
            case 'm': [stream printf:"M"];                    break;
            case 'N':
            case 'n': [stream printf:"N"];                    break;
            case 'O':
            case 'o': [stream printf:"O"];                    break;
            case 'P':
            case 'p': [stream printf:"P"];                    break;
            case 'Q':
            case 'q': [stream printf:"Q"];                    break;
            case 'R':
            case 'r': [stream printf:"R"];                    break;
            case 'S':
            case 's': [stream printf:"S"];                    break;
            case 'T':
            case 't': [stream printf:"T"];                    break;
            case 'U':
            case 'u': [stream printf:"U"];                    break;
            case 'V':
            case 'v': [stream printf:"V"];                    break;
            case 'W':
            case 'w': [stream printf:"W"];                    break;
            case 'X':
            case 'x': [stream printf:"X"];                    break;
            case 'Y':
            case 'y': [stream printf:"Y"];                    break;
            case 'Z':
            case 'z': [stream printf:"Z"];                    break;
            case '[': [stream printf:"open square bracket"];  break;
            case '\\':[stream printf:"back slash"];           break;
            case ']': [stream printf:"close square bracket"]; break;
            case '^': [stream printf:"caret"];                break;
            case '_': [stream printf:"under score"];          break;
            case '`': [stream printf:"grave accent"];         break;
            case '{': [stream printf:"open brace"];           break;
            case '|': [stream printf:"vertical bar"];         break;
            case '}': [stream printf:"close brace"];          break;
            case '~': [stream printf:"tilde"];                break;
            default:  [stream printf:"unknown"];              break;
        }
        /*  APPEND COMMA, UNLESS PUNCTUATION FOLLOWS LAST LETTER  */
        if ( (((*i)+1) < length) &&
            (buffer[(*i)+1] == LETTER_MODE_END) &&
            !gs_pm_word_follows(buffer, (*i), length)) {
            [stream printf:" "];
            *status = WORD;
        }
        else {
            [stream printf:", "];
            *status = PUNCTUATION;
        }
    }
    /*  BE SURE TO SET INDEX BACK ONE, SO CALLING ROUTINE NOT FOULED UP  */
    (*i)--;
}



/// @return Return 1 if all letters of the word are upper case, 0 otherwise.

int gs_pm_is_all_upper_case(char *word)
{
    while (*word) {
        if (!isupper(*word))
            return 0;
        word++;
    }

    return 1;
}



/// Convert any upper case letter in word to lower case.

char *gs_pm_to_lower_case(char *word)
{
    char *ptr = word;

    while (*ptr) {
        if (isupper(*ptr))
            *ptr = tolower(*ptr);
        ptr++;
    }

    return word;
}



/// @return Return a pointer to the pronunciation of a special acronym if it is defined in the list.
/// @return Otherwise, return NULL.

const char *gs_pm_is_special_acronym(char *word)
{
    /*  CHECK IF MATCH FOUND, RETURN PRONUNCIATION  */
    NSString *pronunciation = [_specialAcronymsDictionary objectForKey:[NSString stringWithCString:word encoding:NSASCIIStringEncoding]];
    if (pronunciation != nil)
        return [pronunciation cStringUsingEncoding:NSASCIIStringEncoding];

    /*  NO SPECIAL ACRONYM FOUND  */
    return NULL;
}



/// @return Return 1 if the pronunciation contains ' (and ` for backwards compatibility).
/// @return Otherwise, return 0;

int gs_pm_contains_primary_stress(const char *pronunciation)
{
    for ( ; *pronunciation && (*pronunciation != '%'); pronunciation++)
        if ((*pronunciation == '\'') || (*pronunciation == '`'))
            return TTS_YES;

    return TTS_NO;
}



/// @return Return 1 if the first " is converted to a '.
/// @return Otherwise, return 0.

int gs_pm_converted_stress(char *pronunciation)
{
    /*  LOOP THRU PRONUNCIATION UNTIL " FOUND, REPLACE WITH '  */
    for ( ; *pronunciation && (*pronunciation != '%'); pronunciation++)
        if (*pronunciation == '"') {
            *pronunciation = '\'';
            return TTS_YES;
        }

    /*  IF HERE, NO " FOUND  */
    return TTS_NO;
}



/// @return Return 1 if 's is found at end of word, and removes the 's ending from the word.
/// @return Otherwise, return 0.

int gs_pm_is_possessive(char *word)
{
    /*  LOOP UNTIL 's FOUND, REPLACE ' WITH NULL  */
    for ( ; *word; word++)
        if ((*word == '\'') && *(word+1) && (*(word+1) == 's') && (*(word+2) == '\0')) {
            *word = '\0';
            return TTS_YES;
        }

    /*  IF HERE, NO 's FOUND  */
    return TTS_NO;
}



/// Check to make sure that there are not too many feet phones per chunk.  If there are, the input is split
/// into two or mor chunks.

void gs_pm_safety_check(NXStream *stream)
{
    int  ch, number_of_feet = 0, number_of_phones = 0, state = NON_PHONEME;
    long last_word_pos = UNDEFINED_POSITION, last_tg_pos = UNDEFINED_POSITION;
    char last_tg_type = '0';

    [stream seekWithOffset:0 fromPosition:NXStreamLocation_Start];

    /*  LOOP THROUGH STREAM, INSERTING NEW CHUNK MARKERS IF NECESSARY  */
    while ((ch = [stream getChar]) != '\0' && ch != EOF) {
        switch (ch) {
            case '%':
                /*  IGNORE SUPER RAW MODE CONTENTS  */
                while ((ch = [stream getChar]) != '%') {
                    if (ch == '\0' || ch == EOF) {
                        [stream ungetChar];
                        break;
                    }
                }
                state = NON_PHONEME;
                break;
            case '/':
                /*  SLASH CODES  */
                switch (ch = [stream getChar]) {
                    case 'c':
                        /*  CHUNK MARKER (/c)  */
                        number_of_feet = number_of_phones = 0;
                        break;
                    case '_':
                    case '*':
                        /*  FOOT AND TONIC FOOT MARKERS  */
                        if (++number_of_feet > MAX_FEET_PER_CHUNK) {
                            /*  SPLIT STREAM INTO TWO CHUNKS  */
                            gs_pm_insert_chunk_marker(stream, last_word_pos, last_tg_type);
                            gs_pm_set_tone_group(stream, last_tg_pos, ",");
                            gs_pm_check_tonic(stream, last_tg_pos, last_word_pos);
                        }
                        break;
                    case 't':
                        /*  IGNORE TAGGING MODE CONTENTS  */
                        /*  SKIP WHITE  */
                        while ((ch = [stream getChar]) == ' ')
                            ;
                        [stream ungetChar];
                        /*  SKIP OVER TAG NUMBER  */
                        while ((ch = [stream getChar]) != ' ') {
                            if (ch == '\0' || ch == EOF) {
                                [stream ungetChar];
                                break;
                            }
                        }
                        break;
                    case '0':
                    case '1':
                    case '2':
                    case '3':
                    case '4':
                        /*  REMEMBER TONE GROUP TYPE AND POSITION  */
                        last_tg_type = ch;
                        last_tg_pos = [stream position] - 2;
                        break;
                    default:
                        /*  IGNORE ALL OTHER SLASH CODES  */
                        break;
                }
                state = NON_PHONEME;
                break;
            case '.':
            case '_':
            case ' ':
                /*  END OF PHONE (AND WORD) DELIMITERS  */
                if (state == PHONEME) {
                    if (++number_of_phones > MAX_PHONES_PER_CHUNK) {
                        /*  SPLIT STREAM INTO TWO CHUNKS  */
                        gs_pm_insert_chunk_marker(stream, last_word_pos, last_tg_type);
                        gs_pm_set_tone_group(stream, last_tg_pos, ",");
                        gs_pm_check_tonic(stream, last_tg_pos, last_word_pos);
                        state = NON_PHONEME;
                        break;
                    }
                    if (ch == ' ')
                        last_word_pos = [stream position];
                }
                state = NON_PHONEME;
                break;
            default:
                state = PHONEME;
                break;
        }
    }

    [stream truncate];
}



/// Insert chunk markers and associated markers in the stream at the insert point.  Use the tone group type
/// passed in as an argument.

void gs_pm_insert_chunk_marker(NXStream *stream, long insert_point, char tg_type)
{
    char ch;


    NXStream *temp_stream = [[NXStream alloc] init];

    /*  COPY STREAM FROM INSERT POINT TO END TO BUFFER TO ANOTHER STREAM  */
    [stream seekWithOffset:insert_point fromPosition:NXStreamLocation_Start];
    while ((ch = [stream getChar]) != '\0')
        [temp_stream putChar:ch];
    [temp_stream putChar:'\0'];

    /*  PUT IN MARKERS AT INSERT POINT  */
    [stream seekWithOffset:insert_point fromPosition:NXStreamLocation_Start];
    [stream printf:"%s %s %s /%c ", TONE_GROUP_BOUNDARY, CHUNK_BOUNDARY, TONE_GROUP_BOUNDARY, tg_type];
    long new_position = [stream position] - 9;

    /*  APPEND CONTENTS OF TEMPORARY STREAM  */
    [temp_stream seekWithOffset:0 fromPosition:NXStreamLocation_Start];
    while ((ch = [temp_stream getChar]) != '\0')
        [stream putChar:ch];
    [stream putChar:'\0'];

    /*  POSITION THE STREAM AT THE NEW /c MARKER  */
    [stream seekWithOffset:new_position fromPosition:NXStreamLocation_Start];
}



/// Check to see if a tonic marker is present in the stream between the start and end positions.  If no
/// tonic is present, then put one in at the last foot marker if it exists.

void gs_pm_check_tonic(NXStream *stream, long startPosition, long endPosition)
{
    long originalPosition = [stream position];
    long length = endPosition - startPosition;

    [stream seekWithOffset:startPosition fromPosition:NXStreamLocation_Start];

    // Dertermine last foot position, and presence of tonic.
    long lastFootPosition = UNDEFINED_POSITION;
    for (long index = 0; index < length; index++) {
        if (([stream getChar] == '/') && (++index < length)) {
            switch ([stream getChar]) {
                case '_':
                    lastFootPosition = [stream position] - 1;
                    break;
                case '*':
                    [stream seekWithOffset:originalPosition fromPosition:NXStreamLocation_Start];
                    return;
            }
        }
    }

    /*  IF HERE, NO TONIC, SO INSERT TONIC MARKER  */
    if (lastFootPosition != UNDEFINED_POSITION) {
        [stream seekWithOffset:lastFootPosition fromPosition:NXStreamLocation_Start];
        [stream putChar:'*'];
    }

    [stream seekWithOffset:originalPosition fromPosition:NXStreamLocation_Start];
}



#if 0
/// Print out the contents of a parser stream, inserting visible mode markers.
static void print_stream(NXStream *stream, long stream_length)
{
    [stream seekWithOffset:0 fromPosition:NX_FROMSTART];

    printf("stream_length = %-ld\n<begin>", stream_length);
    for (NSUInteger i = 0; i < stream_length; i++) {
        char c = [stream getChar];
        switch (c) {
            case RAW_MODE_BEGIN:      printf("<raw mode begin>");      break;
            case RAW_MODE_END:        printf("<raw mode end>");        break;
            case LETTER_MODE_BEGIN:   printf("<letter mode begin>");   break;
            case LETTER_MODE_END:     printf("<letter mode end>");     break;
            case EMPHASIS_MODE_BEGIN: printf("<emphasis mode begin>"); break;
            case EMPHASIS_MODE_END:   printf("<emphasis mode end>");   break;
            case TAGGING_MODE_BEGIN:  printf("<tagging mode begin>");  break;
            case TAGGING_MODE_END:    printf("<tagging mode end>");    break;
            case SILENCE_MODE_BEGIN:  printf("<silence mode begin>");  break;
            case SILENCE_MODE_END:    printf("<silence mode end>");    break;
            default:                  printf("%c", c);                 break;
        }
    }
    printf("<end>\n");
}
#endif
