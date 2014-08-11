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
#import "streams.h"
#import "TTS_types.h"
#import "diphone_module.h"

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

#define TTS_FALSE             0
#define TTS_TRUE              1
#define TTS_NO                0
#define TTS_YES               1

#define SYMBOL_LENGTH_MAX     12

#define WORD_LENGTH_MAX       1024
#define SILENCE_MAX           5.0
#define SILENCE_PHONE_LENGTH  0.1     /*  SILENCE PHONE IS 100ms  */

#define DEFAULT_END_PUNC      "."
#define MODE_NEST_MAX         100

#define NON_PHONEME           0
#define PHONEME               1
#define MAX_PHONES_PER_CHUNK  1500
#define MAX_FEET_PER_CHUNK    100



/*  GLOBAL VARIABLES, LOCAL TO THIS FILE  ************************************/
static char escape_character;
static short dictionaryOrder[4];
static GSPronunciationDictionary *userDictionary, *appDictionary, *mainDictionary;
static NSDictionary *specialAcronymsDictionary;
static NXStream *stream2;






/// Sets up parser module for subsequent use.  This must be called before parser() is ever used.

void init_parser_module(void)
{
	stream2 = NULL;
	
	userDictionary = nil;
	appDictionary = nil;
	mainDictionary = nil;
	specialAcronymsDictionary = nil;
	
	escape_character = '%';  // default escape character
}



/// Sets escape code for parsing.  Assumes Objective C client library checks validity of argument.

int set_escape_code(char new_escape_code)
{
	escape_character = new_escape_code;
	
	return(TTS_PARSER_SUCCESS);
}



/// Sets the dictionary order, and sets the user and application dictionaries (all globals).  Assumes Objective C client library checks validity of arguments.

int set_dict_data(const int16_t order[4], 
				  GSPronunciationDictionary *userDict, 
				  GSPronunciationDictionary *appDict, 
				  GSPronunciationDictionary *mainDict,
				  NSDictionary *specialAcronymsDict)
{
	/*  INITIALIZE GLOBAL ORDER VARIABLE  */
	dictionaryOrder[0] = TTS_EMPTY;
	dictionaryOrder[1] = TTS_EMPTY;
	dictionaryOrder[2] = TTS_EMPTY;
	dictionaryOrder[3] = TTS_EMPTY;
	
	/*  COPY POINTER TO DICTIONARIES INTO GLOBAL VARIABLES  */
	userDictionary = userDict;
	appDictionary = appDict;
	mainDictionary = mainDict;
	specialAcronymsDictionary = specialAcronymsDict;
	
	/*  COPY ORDER TO GLOBAL VARIABLE, ACCOUNT FOR UNOPENABLE PREDITOR-NOT DICTIONARIES  */
	NSUInteger j = 0;
	for (NSUInteger index = 0; index < 4; index++) {
		if (order[index] == TTS_USER_DICTIONARY) {
			if (userDictionary != nil)
				dictionaryOrder[j++] = order[index];
		}
		else if (order[index] == TTS_APPLICATION_DICTIONARY) {
			if (appDictionary != nil)
				dictionaryOrder[j++] = order[index];
		}
        else {
			dictionaryOrder[j++] = order[index];
        }
	}
	
	return(TTS_PARSER_SUCCESS);
}



/// Takes plain english input, and produces phonetic output suitable for further processing in the TTS system.
/// If a parse error occurs, a value of 0 or above is returned.  Usually this will point to the position of the
/// error in the input buffer, but in later stages of the parse only a 0 is returned since positional information
/// is lost.  If no parser error, then TTS_PARSER_SUCCESS is returned.

int parser(const char *input, const char **output)
{
	/*  FIND LENGTH OF INPUT  */
	long input_length = strlen(input);
	
	/*  ALLOCATE BUFFER1, BUFFER2  */
    char *buffer1 = (char *)malloc(input_length+1);
    char *buffer2 = (char *)malloc(input_length+1);
	
	/*  CONDITION INPUT:  CONVERT NON-PRINTABLE CHARS TO SPACES
	 (EXCEPT ESC CHAR), CONNECT WORDS HYPHENATED OVER A NEWLINE  */
    long buffer1_length;
	gs_pm_condition_input(input, buffer1, input_length, &buffer1_length);
		
    int error;
    long buffer2_length;
	/*  RATIONALIZE MODE MARKINGS, CHECKING FOR ERRORS  */
	if ((error = gs_pm_mark_modes(buffer1, buffer2, buffer1_length, &buffer2_length)) != TTS_PARSER_SUCCESS) {
		free(buffer1);
		free(buffer2);
		return(error);
	}
		
	/*  FREE BUFFER 1  */
	free(buffer1);
	
	/*  OPEN MEMORY STREAM 1  */
    NXStream *stream1;
	if ((stream1 = NXOpenMemory(NULL,0,NX_READWRITE)) == NULL) {
		NXLogError("TTS Server:  Cannot open memory stream (parser).");
		return(TTS_PARSER_FAILURE);
	}
	
	/*  STRIP OUT OR CONVERT UNESSENTIAL PUNCTUATION  */
    long stream1_length;
    gs_pm_strip_punctuation(buffer2, buffer2_length, stream1, &stream1_length);
	
	/*  FREE BUFFER 2  */
	free(buffer2);
	
#if 0
	/*  PRINT STREAM 1  */
	printf("\nSTREAM 1\n");
	print_stream(stream1, stream1_length);
#endif
	
	/*  CLOSE STREAM 2 IF IT IS NOT NULL.  THIS STREAM PERSISTS BETWEEN CALLS  */
	if (stream2 != NULL) {
		NXCloseMemory(stream2, NX_FREEBUFFER);
		stream2 = NULL;
	}
	
	/*  OPEN MEMORY STREAM 2  */
	if ((stream2 = NXOpenMemory(NULL,0,NX_READWRITE)) == NULL) {
		NXLogError("TTS Server:  Cannot open memory stream (parser).");
		return(TTS_PARSER_FAILURE);
	}
	
	/*  DO FINAL CONVERSION  */
    long stream2_length;
	if ((error = gs_pm_final_conversion(stream1, stream1_length, stream2, &stream2_length)) != TTS_PARSER_SUCCESS) {
		NXCloseMemory(stream1, NX_FREEBUFFER);
		NXCloseMemory(stream2, NX_FREEBUFFER);
		stream2 = NULL;
		return(error);
	}
	
	/*  CLOSE STREAM 1  */
	NXCloseMemory(stream1, NX_FREEBUFFER);
	
	/*  DO SAFETY CHECK;  MAKE SURE NOT TOO MANY FEET OR PHONES PER CHUNK  */
	gs_pm_safety_check(stream2, &stream2_length);
	
#if 0
	/*  PRINT OUT STREAM 2  */
	printf("STREAM 2\n");
	print_stream(stream2, stream2_length);
#endif
	
	/*  SET OUTPUT POINTER TO MEMORY STREAM BUFFER
	 THIS STREAM PERSISTS BETWEEN CALLS  */
    int len, maxlen;
	NXGetMemoryBuffer(stream2, output, &len, &maxlen);
	
	/*  RETURN SUCCESS  */
	return(TTS_PARSER_SUCCESS);
}



/// Returns the pronunciation of word, and sets dict to the dictionary in which it was found.  Relies on the global dictionaryOrder.

const char *lookup_word(const char *word, short *dict)
{
	NSString *pr;
	NSString *w;
	
	const char *pronunciation;

	
	/*  SEARCH DICTIONARIES IN USER ORDER TILL PRONUNCIATION FOUND  */
	for (NSUInteger index = 0; index < 4; index++) {
		switch(dictionaryOrder[index]) {
			case TTS_EMPTY:
				break;
			case TTS_NUMBER_PARSER:
				if ((pronunciation = number_parser(word, NP_MODE_NORMAL)) != NULL) {
					*dict = TTS_NUMBER_PARSER;
					return((const char *)pronunciation);
				}
				break;
			case TTS_USER_DICTIONARY:
				w = [NSString stringWithCString:word encoding:NSASCIIStringEncoding];
				if ((pr = [userDictionary pronunciationForWord:w]) != nil) {
					pronunciation = [pr cStringUsingEncoding:NSASCIIStringEncoding];
					*dict = TTS_USER_DICTIONARY;
					return((const char *)pronunciation);
				}
				break;
			case TTS_APPLICATION_DICTIONARY:
				w = [NSString stringWithCString:word encoding:NSASCIIStringEncoding];
				if ((pr = [appDictionary pronunciationForWord:w]) != nil) {
					pronunciation = [pr cStringUsingEncoding:NSASCIIStringEncoding];				
					*dict = TTS_APPLICATION_DICTIONARY;
					return((const char *)pronunciation);
				}
				break;
			case TTS_MAIN_DICTIONARY:
				w = [NSString stringWithCString:word encoding:NSASCIIStringEncoding];
				if ((pr = [mainDictionary pronunciationForWord:w]) != nil) {
					pronunciation = [pr cStringUsingEncoding:NSASCIIStringEncoding];				
					*dict = TTS_MAIN_DICTIONARY;
					return((const char *)pronunciation);
				}
				break;
			case TTS_LETTER_TO_SOUND:
				if ((pronunciation = letter_to_sound((char *)word)) != NULL) {
					*dict = TTS_LETTER_TO_SOUND;
					return((const char *)pronunciation);
				}
				else {
					*dict = TTS_LETTER_TO_SOUND;
					return((const char *)degenerate_string(word));
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
	    return((const char *)pronunciation);
	}

    *dict = TTS_LETTER_TO_SOUND;
    return((const char *)degenerate_string(word));
}



/// Converts all non-printable characters (except escape character to blanks.  Also connects words hyphenated over a newline.

void gs_pm_condition_input(const char *input, char *output, long input_length, long *output_length_ptr)
{
	int i, j = 0;
	
	for (i = 0; i < input_length; i++) {
		if ((input[i] == '-') && ((i-1) >= 0) && isalpha(input[i-1])) {
			/*  CONNECT HYPHENATED WORD OVER NEWLINE  */
			int ii = i;
			/*  IGNORE ANY WHITE SPACE UP TO NEWLINE  */
			while (((ii+1) < input_length) && (input[ii+1] != '\n') &&
				   (input[ii+1] != escape_character) && isspace(input[ii+1]))
				ii++;
			/*  IF NEWLINE, THEN CONCATENATE WORD  */
			if (((ii+1) < input_length) && input[ii+1] == '\n') {
				i = ++ii;
				/*  IGNORE ANY WHITE SPACE  */
				while (((i+1) < input_length) && (input[i+1] != escape_character) && isspace(input[i+1]))
					i++;
			}
			/*  ELSE, OUTPUT HYPHEN  */
			else
				output[j++] = input[i];
		}
		else if ((!isascii(input[i])) || ((!isprint(input[i])) && (input[i] != escape_character)))
		/*  CONVERT NONPRINTABLE CHARACTERS TO SPACE  */
			output[j++] = ' ';
		else
		/*  PASS EVERYTHING ELSE THROUGH  */
			output[j++] = input[i];
	}
	
	/*  BE SURE TO APPEND NULL TO STRING  */
	output[j] = '\0';
	*output_length_ptr = j;
}



/// Parses input for modes, checking for errors, and marks output with mode start and end points.  Tagging and silence mode arguments are checked.

int gs_pm_mark_modes(char *input, char *output, long length, long *output_length)
{
	int i, j = 0, pos, minus, period;
	int mode_stack[MODE_NEST_MAX], stack_ptr = 0, mode;
	int mode_marker[5][2] = {
        {RAW_MODE_BEGIN,      RAW_MODE_END},
        {LETTER_MODE_BEGIN,   LETTER_MODE_END},
		{EMPHASIS_MODE_BEGIN, EMPHASIS_MODE_END},
		{TAGGING_MODE_BEGIN,  TAGGING_MODE_END},
		{SILENCE_MODE_BEGIN,  SILENCE_MODE_END},
    };
	
	
	
	/*  INITIALIZE MODE STACK TO NORMAL MODE */
	mode_stack[stack_ptr] = NORMAL_MODE;
	
	/*  MARK THE MODES OF INPUT, CHECKING FOR ERRORS  */
	for (i = 0; i < length; i++) {
		/*  IF ESCAPE CODE, DO MODE PROCESSING  */
		if (input[i] == escape_character) {
			/*  IF IN RAW MODE  */
			if (mode_stack[stack_ptr] == RAW_MODE) {
				/*  CHECK FOR RAW MODE END  */
				if ( ((i+2) < length) &&
					((input[i+1] == 'r') || (input[i+1] == 'R')) &&
					((input[i+2] == 'e') || (input[i+2] == 'E')) ) {
					/*  DECREMENT STACK POINTER, CHECKING FOR STACK UNDERFLOW  */
					if ((--stack_ptr) < 0)
						return(i);
					/*  MARK END OF RAW MODE  */
					output[j++] = mode_marker[RAW_MODE][END];
					/*  INCREMENT INPUT INDEX  */
					i+=2;
					/*  MARK BEGINNING OF STACKED MODE, IF NOT NORMAL MODE  */
					if (mode_stack[stack_ptr] != NORMAL_MODE)
						output[j++] = mode_marker[mode_stack[stack_ptr]][BEGIN];
				}
				/*  IF NOT END OF RAW MODE, THEN PASS THROUGH ESC CHAR IF PRINTABLE  */
				else {
					if (isprint(escape_character))
						output[j++] = escape_character;
				}
			}
			/*  ELSE, IF IN ANY OTHER MODE  */
			else {
				/*  CHECK FOR DOUBLE ESCAPE CHARACTER  */
				if ( ((i+1) < length) && (input[i+1] == escape_character) ) {
					/*  OUTPUT SINGLE ESCAPE CHARACTER IF PRINTABLE  */
					if (isprint(escape_character))
						output[j++] = escape_character;
					/*  INCREMENT INPUT INDEX  */
					i++;
				}
				/*  CHECK FOR BEGINNING OF MODE  */
				else if ( ((i+2) < length) && ((input[i+2] == 'b') || (input[i+2] == 'B')) ) {
					/*  CHECK FOR WHICH MODE  */
					switch(input[i+1]) {
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
						/*  IF CURRENT MODE NOT NORMAL, WRITE END OF CURRENT MODE  */
						if (mode_stack[stack_ptr] != NORMAL_MODE)
							output[j++] = mode_marker[mode_stack[stack_ptr]][END];
						/*  INCREMENT STACK POINTER, CHECKING FOR STACK OVERFLOW  */
						if ((++stack_ptr) >= MODE_NEST_MAX)
							return(i);
						/*  STORE NEW MODE ON STACK  */
						mode_stack[stack_ptr] = mode;
						/*  MARK BEGINNING OF MODE  */
						output[j++] = mode_marker[mode][BEGIN];
						/*  INCREMENT INPUT INDEX  */
						i+=2;
						/*  ADD TAGGING MODE END, IF NOT GIVEN, GETTING RID OF BLANKS  */
						if (mode == TAGGING_MODE) {
							/*  IGNORE ANY WHITE SPACE  */
							while (((i+1) < length) && (input[i+1] == ' '))
								i++;
							/*  COPY NUMBER, CHECKING VALIDITY  */
							pos = minus = 0;
							while (((i+1) < length) && (input[i+1] != ' ') && (input[i+1] != escape_character)) {
								i++;
								/*  ALLOW ONLY MINUS OR PLUS SIGN AND DIGITS  */
								if (!isdigit(input[i]) && !((input[i] == '-') || (input[i] == '+')))
									return(i);
								/*  MINUS OR PLUS SIGN AT BEGINNING ONLY  */
								if ((pos > 0) && ((input[i] == '-') || (input[i] == '+')))
									return(i);
								/*  OUTPUT CHARACTER, KEEPING TRACK OF POSITION AND MINUS SIGN  */
								output[j++] = input[i];
								if ((input[i] == '-') || (input[i] == '+'))
									minus++;
								pos++;
							}
							/*  MAKE SURE MINUS OR PLUS SIGN HAS NUMBER FOLLOWING IT  */
							if (minus >= pos)
								return(i);
							/*  IGNORE ANY WHITE SPACE  */
							while (((i+1) < length) && (input[i+1] == ' '))
								i++;
							/*  IF NOT EXPLICIT TAG END, THEN INSERT ONE, POP STACK  */
							if (!(((i+3) < length) && (input[i+1] == escape_character) &&
								  ((input[i+2] == 't') || (input[i+2] == 'T')) &&
								  ((input[i+3] == 'e') || (input[i+3] == 'E'))) ) {
								/*  MARK END OF MODE  */
								output[j++] = mode_marker[mode][END];
								/*  DECREMENT STACK POINTER, CHECKING FOR STACK UNDERFLOW  */
								if ((--stack_ptr) < 0)
									return(i);
								/*  MARK BEGINNING OF STACKED MODE, IF NOT NORMAL MODE  */
								if (mode_stack[stack_ptr] != NORMAL_MODE)
									output[j++] = mode_marker[mode_stack[stack_ptr]][BEGIN];
							}
						}
						else if (mode == SILENCE_MODE) {
							/*  IGNORE ANY WHITE SPACE  */
							while (((i+1) < length) && (input[i+1] == ' '))
								i++;
							/*  COPY NUMBER, CHECKING VALIDITY  */
							period = 0;
							while (((i+1) < length) && (input[i+1] != ' ') && (input[i+1] != escape_character)) {
								i++;
								/*  ALLOW ONLY DIGITS AND PERIOD  */
								if (!isdigit(input[i]) && (input[i] != '.'))
									return(i);
								/*  ALLOW ONLY ONE PERIOD  */
								if (period && (input[i] == '.'))
									return(i);
								/*  OUTPUT CHARACTER, KEEPING TRACK OF # OF PERIODS  */
								output[j++] = input[i];
								if (input[i] == '.')
									period++;
							}
							/*  IGNORE ANY WHITE SPACE  */
							while (((i+1) < length) && (input[i+1] == ' '))
								i++;
							/*  IF NOT EXPLICIT SILENCE END, THEN INSERT ONE, POP STACK  */
							if (!(((i+3) < length) && (input[i+1] == escape_character) &&
								  ((input[i+2] == 's') || (input[i+2] == 'S')) &&
								  ((input[i+3] == 'e') || (input[i+3] == 'E'))) ) {
								/*  MARK END OF MODE  */
								output[j++] = mode_marker[mode][END];
								/*  DECREMENT STACK POINTER, CHECKING FOR STACK UNDERFLOW  */
								if ((--stack_ptr) < 0)
									return(i);
								/*  MARK BEGINNING OF STACKED MODE, IF NOT NORMAL MODE  */
								if (mode_stack[stack_ptr] != NORMAL_MODE)
									output[j++] = mode_marker[mode_stack[stack_ptr]][BEGIN];
							}
						}
					}
					else {
						/*  ELSE, PASS ESC CHAR THROUGH IF PRINTABLE  */
						if (isprint(escape_character))
							output[j++] = escape_character;
					}
				}
				/*  CHECK FOR END OF MODE  */
				else if ( ((i+2) < length) && ((input[i+2] == 'e') || (input[i+2] == 'E')) ) {
					/*  CHECK FOR WHICH MODE  */
					switch(input[i+1]) {
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
						/*  CHECK IF MATCHING MODE BEGIN  */
						if (mode_stack[stack_ptr] != mode)
							return(i);
						/*  MATCHES WITH MODE BEGIN  */
						else {
							/*  DECREMENT STACK POINTER, CHECKING FOR STACK UNDERFLOW  */
							if ((--stack_ptr) < 0)
								return(i);
							/*  MARK END OF MODE  */
							output[j++] = mode_marker[mode][END];
							/*  INCREMENT INPUT INDEX  */
							i+=2;
							/*  MARK BEGINNING OF STACKED MODE, IF NOT NORMAL MODE  */
							if (mode_stack[stack_ptr] != NORMAL_MODE)
								output[j++] = mode_marker[mode_stack[stack_ptr]][BEGIN];
						}
					}
					else {
						/*  ELSE, PASS ESC CHAR THROUGH IF PRINTABLE  */
						if (isprint(escape_character))
							output[j++] = escape_character;
					}
				}
				/*  ELSE, PASS ESC CHAR THROUGH IF PRINTABLE  */
				else {
					if (isprint(escape_character))
						output[j++] = escape_character;
				}
			}
		}
		/*  ELSE, SIMPLY COPY INPUT TO OUTPUT  */
		else {
			output[j++] = input[i];
		}
	}
	
	/*  BE SURE TO ADD A NULL TO END OF STRING  */
	output[j] = '\0';
	
	/*  SET LENGTH OF OUTPUT STRING  */
	*output_length = j;
	
	return(TTS_PARSER_SUCCESS);
}



/// Deletes unnecessary punctuation, and converts some punctuation to another form.

void gs_pm_strip_punctuation(char *buffer, long length, NXStream *stream, long *stream_length)
{
	long i, mode = NORMAL_MODE, status;
	
	/*  DELETE OR CONVERT PUNCTUATION  */
	for (i = 0; i < length; i++) {
		switch(buffer[i]) {
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
					switch(buffer[i]) {
						case '[':
							buffer[i] = '(';
							break;
						case ']':
							buffer[i] = ')';
							break;
						case '-':
							if (!gs_pm_convert_dash(buffer, &i, length) && 
								!gs_pm_number_follows(buffer, i, length) &&
								!gs_pm_is_isolated(buffer, i, length))
								buffer[i] = DELETED;
							break;
						case '+':
							if (!gs_pm_part_of_number(buffer, i, length) && !gs_pm_is_isolated(buffer, i, length))
								buffer[i] = DELETED;
							break;
						case '\'':
							if (!(((i-1) >= 0) && isalpha(buffer[i-1]) && ((i+1) < length) && isalpha(buffer[i+1])))
								buffer[i] = DELETED;
							break;
						case '.':
							gs_pm_delete_ellipsis(buffer, &i, length);
							break;
						case '/':
						case '$':
						case '%':
							if (!gs_pm_part_of_number(buffer, i, length))
								buffer[i] = DELETED;
							break;
						case '<':
						case '>':
						case '&':
						case '=':
						case '@':
							if (!gs_pm_is_isolated(buffer, i, length))
								buffer[i] = DELETED;
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
							buffer[i] = DELETED;
							break;
						default:
							break;
					}
				}
				break;
		}
	}
	
	/*  SECOND PASS  */
	NXSeek(stream, 0, NX_FROMSTART);
	mode = NORMAL_MODE;  status = PUNCTUATION;
	for (i = 0; i < length; i++) {
		switch(buffer[i]) {
			case RAW_MODE_BEGIN:      mode = RAW_MODE;      NXPutc(stream,buffer[i]); break;
			case EMPHASIS_MODE_BEGIN: mode = EMPHASIS_MODE; NXPutc(stream,buffer[i]); break;
			case TAGGING_MODE_BEGIN:  mode = TAGGING_MODE;  NXPutc(stream,buffer[i]); break;
			case SILENCE_MODE_BEGIN:  mode = SILENCE_MODE;  NXPutc(stream,buffer[i]); break;
			case LETTER_MODE_BEGIN:   mode = LETTER_MODE;   /*  expand below  */    ; break;
				
			case RAW_MODE_END:
			case EMPHASIS_MODE_END:
			case TAGGING_MODE_END:
			case SILENCE_MODE_END:    mode = NORMAL_MODE;   NXPutc(stream,buffer[i]); break;
			case LETTER_MODE_END:     mode = NORMAL_MODE;   /*  expand below  */    ; break;
				
			case DELETED:
				/*  CONVERT ALL DELETED CHARACTERS TO BLANKS  */
				buffer[i] = ' ';
				NXPutc(stream,' ');
				break;
				
			default:
				if ((mode == NORMAL_MODE) || (mode == EMPHASIS_MODE)) {
					switch(buffer[i]) {
						case '(':
							/*  CONVERT (?) AND (!) TO BLANKS  */
							if ( ((i+2) < length) && (buffer[i+2] == ')') &&
								((buffer[i+1] == '!') || (buffer[i+1] == '?')) ) {
								buffer[i] = buffer[i+1] = buffer[i+2] = ' ';
								NXPrintf(stream,"   ");
								i += 2;
								continue;
							}
							/*  ALLOW TELEPHONE NUMBER WITH AREA CODE:  (403)274-3877  */
							if (gs_pm_is_telephone_number(buffer, i, length)) {
								int j;
								for (j = 0; j < 12; j++)
									NXPutc(stream,buffer[i++]); 
								status = WORD;
								continue;
							}
							/*  CONVERT TO COMMA IF PRECEDED BY WORD, FOLLOWED BY WORD  */
							if ((status == WORD) && gs_pm_word_follows(buffer, i, length)) {
								buffer[i] = ' ';
								NXPrintf(stream,", ");
								status = PUNCTUATION;
							}
							else {
								buffer[i] = ' ';
								NXPutc(stream,' ');
							}
							break;
						case ')':
							/*  CONVERT TO COMMA IF PRECEDED BY WORD, FOLLOWED BY WORD  */
							if ((status == WORD) && gs_pm_word_follows(buffer, i, length)) {
								buffer[i] = ',';
								NXPrintf(stream,", ");
								status = PUNCTUATION;
							}
							else {
								buffer[i] = ' ';
								NXPutc(stream,' ');
							}
							break;
						case '&':
							NXPrintf(stream,"%s",AND);
							status = WORD;
							break;
						case '+':
							if (gs_pm_is_isolated(buffer, i, length))
								NXPrintf(stream,"%s",PLUS);
							else
								NXPutc(stream,'+');
							status = WORD;
							break;
						case '<':
							NXPrintf(stream,"%s",IS_LESS_THAN);
							status = WORD;
							break;
						case '>':
							NXPrintf(stream,"%s",IS_GREATER_THAN);
							status = WORD;
							break;
						case '=':
							NXPrintf(stream,"%s",EQUALS);
							status = WORD;
							break;
						case '-':
							if (gs_pm_is_isolated(buffer, i, length))
								NXPrintf(stream,"%s",MINUS);
							else
								NXPutc(stream,'-');
							status = WORD;
							break;
						case '@':
							NXPrintf(stream,"%s",AT);
							status = WORD;
							break;
						case '.':
							if (!gs_pm_expand_abbreviation(buffer, i, length, stream)) {
								NXPutc(stream,buffer[i]);
								status = PUNCTUATION;
							}
							break;
						default:
							NXPutc(stream,buffer[i]); 
							if (gs_pm_is_punctuation(buffer[i]))
								status = PUNCTUATION;
							else if (isalnum(buffer[i]))
								status = WORD;
							break;
					}
				}
				/*  EXPAND LETTER MODE CONTENTS TO PLAIN WORDS OR SINGLE LETTERS  */
				else if (mode == LETTER_MODE) {
					gs_pm_expand_letter_mode(buffer, &i, length, stream, &status);
					continue;
				}
				/*  ELSE PASS CHARACTERS STRAIGHT THROUGH  */
				else
					NXPutc(stream,buffer[i]);
				break;
		}
	}
	
	/*  SET STREAM LENGTH  */
	*stream_length = NXTell(stream);
}



/// Converts contents of stream1 to stream2.  Adds chunk, tone group, and associated markers;  expands words to pronunciations, and also expands other modes.

int gs_pm_final_conversion(NXStream *stream1, long stream1_length,
                           NXStream *stream2, long *stream2_length)
{
	long i, last_word_end = UNDEFINED_POSITION, tg_marker_pos = UNDEFINED_POSITION;
	long mode = NORMAL_MODE, next_mode, prior_tonic = TTS_FALSE, raw_mode_flag = TTS_FALSE;
	long last_written_state = STATE_BEGIN, current_state, next_state;
	const char *input;
	char word[WORD_LENGTH_MAX+1];
	long length, max_length;
	
	
	/*  REWIND STREAM2 BACK TO BEGINNING  */
	NXSeek(stream2, 0, NX_FROMSTART);
	
	/*  GET MEMORY BUFFER ASSOCIATED WITH STREAM1  */
	NXGetMemoryBuffer(stream1, &input, (int *)&length, (int *)&max_length);
	
	/*  MAIN LOOP  */
	for (i = 0; i < stream1_length; i++) {
		switch(input[i]) {
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
				if (gs_pm_get_state(input, &i, stream1_length, &mode, &next_mode, &current_state,
							  &next_state, &raw_mode_flag, word, stream2) != TTS_PARSER_SUCCESS)
					return(TTS_PARSER_FAILURE);
				
#if 0
				printf("last_written_state = %-d current_state = %-d next_state = %-d ",
					   last_written_state,current_state,next_state);
				printf("mode = %-d next_mode = %-d word = %s\n",
					   mode,next_mode,word);
#endif
				
				/*  ACTION ACCORDING TO CURRENT STATE  */
				switch(current_state) {
						
					case STATE_WORD:
						/*  ADD BEGINNING MARKERS IF NECESSARY (SWITCH FALL-THRU DESIRED)  */
						switch(last_written_state) {
							case STATE_BEGIN:
								NXPrintf(stream2,"%s ",CHUNK_BOUNDARY);
							case STATE_FINAL_PUNC:
								NXPrintf(stream2,"%s ",TONE_GROUP_BOUNDARY);
								prior_tonic = TTS_FALSE;
							case STATE_MEDIAL_PUNC:
								NXPrintf(stream2,"%s ",TG_UNDEFINED);
								tg_marker_pos = NXTell(stream2) - 3;
							case STATE_SILENCE:
								NXPrintf(stream2,"%s ",UTTERANCE_BOUNDARY);
						}
						
						if (mode == NORMAL_MODE) {
							/*  PUT IN WORD MARKER  */
							NXPrintf(stream2,"%s ",WORD_BEGIN);
							/*  ADD LAST WORD MARKER AND TONICIZATION IF NECESSARY  */
							switch(next_state) {
								case STATE_MEDIAL_PUNC:
								case STATE_FINAL_PUNC:
								case STATE_END:
									/*  PUT IN LAST WORD MARKER  */
									NXPrintf(stream2,"%s ",LAST_WORD);
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
									return(TTS_PARSER_FAILURE);
								NXPrintf(stream2,"%s %s ",TONE_GROUP_BOUNDARY,TG_UNDEFINED);
								tg_marker_pos = NXTell(stream2) - 3;
							}
							/*  PUT IN WORD MARKER  */
							NXPrintf(stream2,"%s ",WORD_BEGIN);
							/*  MARK LAST WORD OF TONE GROUP, IF NECESSARY  */
							if ((next_state == STATE_MEDIAL_PUNC) ||
								(next_state == STATE_FINAL_PUNC) ||
								(next_state == STATE_END) ||
								((next_state == STATE_WORD) && (next_mode == EMPHASIS_MODE)) )
								NXPrintf(stream2,"%s ",LAST_WORD);
							/*  TONICIZE WORD  */
							gs_pm_expand_word(word, TTS_YES, stream2);
							prior_tonic = TTS_TRUE;
						}
						
						/*  SET LAST WRITTEN STATE, AND END POSITION AFTER THE WORD  */
						last_written_state = STATE_WORD;
						last_word_end = NXTell(stream2);
						break;
						
						
					case STATE_MEDIAL_PUNC:
						/*  APPEND LAST WORD MARK, PAUSE, TONE GROUP MARK (FALL-THRU DESIRED)  */
						switch(last_written_state) {
							case STATE_WORD:
								if (gs_pm_shift_silence(input, i, stream1_length, mode, stream2))
									last_word_end = NXTell(stream2);
								else if ((next_state != STATE_END) && 
										 gs_pm_another_word_follows(input, i, stream1_length, mode)) {
									if (!strcmp(word,","))
										NXPrintf(stream2,"%s %s ", UTTERANCE_BOUNDARY, MEDIAL_PAUSE);
									else
										NXPrintf(stream2,"%s %s ", UTTERANCE_BOUNDARY, LONG_MEDIAL_PAUSE);
								}
								else if (next_state == STATE_END)
									NXPrintf(stream2,"%s ", UTTERANCE_BOUNDARY);
							case STATE_SILENCE:
								NXPrintf(stream2,"%s ",TONE_GROUP_BOUNDARY);
								prior_tonic = TTS_FALSE;
								if (gs_pm_set_tone_group(stream2, tg_marker_pos, word) == TTS_PARSER_FAILURE)
									return(TTS_PARSER_FAILURE);
								tg_marker_pos = UNDEFINED_POSITION;
								last_written_state = STATE_MEDIAL_PUNC;
						}
						break;
						
						
					case STATE_FINAL_PUNC:
						if (last_written_state == STATE_WORD) {
							if (gs_pm_shift_silence(input, i, stream1_length, mode, stream2)) {
								last_word_end = NXTell(stream2);
								NXPrintf(stream2,"%s ",TONE_GROUP_BOUNDARY);
								prior_tonic = TTS_FALSE;
								if (gs_pm_set_tone_group(stream2, tg_marker_pos, word) == TTS_PARSER_FAILURE)
									return(TTS_PARSER_FAILURE);
								tg_marker_pos = UNDEFINED_POSITION;
								/*  IF SILENCE INSERTED, THEN CONVERT FINAL PUNCTUATION TO MEDIAL  */
								last_written_state = STATE_MEDIAL_PUNC;
							}
							else {
								NXPrintf(stream2,"%s %s %s ",UTTERANCE_BOUNDARY,
										 TONE_GROUP_BOUNDARY,CHUNK_BOUNDARY);
								prior_tonic = TTS_FALSE;
								if (gs_pm_set_tone_group(stream2, tg_marker_pos, word) == TTS_PARSER_FAILURE)
									return(TTS_PARSER_FAILURE);
								tg_marker_pos = UNDEFINED_POSITION;
								last_written_state = STATE_FINAL_PUNC;
							}
						}
						else if (last_written_state == STATE_SILENCE) {
							NXPrintf(stream2,"%s ",TONE_GROUP_BOUNDARY);
							prior_tonic = TTS_FALSE;
							if (gs_pm_set_tone_group(stream2, tg_marker_pos, word) == TTS_PARSER_FAILURE)
								return(TTS_PARSER_FAILURE);
							tg_marker_pos = UNDEFINED_POSITION;
							/*  IF SILENCE INSERTED, THEN CONVERT FINAL PUNCTUATION TO MEDIAL  */
							last_written_state = STATE_MEDIAL_PUNC;
						}
						break;
						
						
					case STATE_SILENCE:
						if (last_written_state == STATE_BEGIN) {
							NXPrintf(stream2,"%s %s %s ",CHUNK_BOUNDARY,TONE_GROUP_BOUNDARY,TG_UNDEFINED);
							prior_tonic = TTS_FALSE;
							tg_marker_pos = NXTell(stream2) - 3;
							if ((gs_pm_convert_silence(word, stream2) <= 0.0) && (next_state == STATE_END))
								return(TTS_PARSER_FAILURE);
							last_written_state = STATE_SILENCE;
							last_word_end = NXTell(stream2);
						}
						else if (last_written_state == STATE_WORD) {
							gs_pm_convert_silence(word, stream2);
							last_written_state = STATE_SILENCE;
							last_word_end = NXTell(stream2);
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
	switch(last_written_state) {
			
		case STATE_MEDIAL_PUNC:
			NXPrintf(stream2,"%s",CHUNK_BOUNDARY);
			break;
			
		case STATE_WORD:  /*  FALL THROUGH DESIRED  */
			NXPrintf(stream2,"%s ",UTTERANCE_BOUNDARY);
		case STATE_SILENCE:
			NXPrintf(stream2,"%s %s",TONE_GROUP_BOUNDARY,CHUNK_BOUNDARY);
			prior_tonic = TTS_FALSE;
			if (gs_pm_set_tone_group(stream2, tg_marker_pos, DEFAULT_END_PUNC) == TTS_PARSER_FAILURE)
				return(TTS_PARSER_FAILURE);
			tg_marker_pos = UNDEFINED_POSITION;
			break;
			
		case STATE_BEGIN:
			if (!raw_mode_flag)
				return(TTS_PARSER_FAILURE);
			break;
	}
	
	/*  BE SURE TO ADD NULL TO END OF STREAM  */
	NXPutc(stream2, '\0');
	
	/*  SET STREAM2 LENGTH  */
	*stream2_length = NXTell(stream2);
	
	/*  RETURN SUCCESS  */
	return(TTS_PARSER_SUCCESS);
}



/// Determines the current state and next state in buffer.  A word or punctuation is put into word.  Raw mode contents are expanded and written to stream.

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
		switch(buffer[j]) {
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
							switch(buffer[j]) {
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
						return(TTS_PARSER_FAILURE);
					
					/*  SET RAW_MODE FLAG  */
					*raw_mode_flag = TTS_TRUE;
					
					/*  SET OUTSIDE COUNTER  */
					*i = j;
				}
				break;
		}
		
		/*  ONLY NEED TWO STATES  */
		if (state >= 2)
			return(TTS_PARSER_SUCCESS);
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
	
	/*  RETURN SUCCESS  */
	return(TTS_PARSER_SUCCESS);
}



/// Set the tone group marker according to the punctuation passed in as "word".  The marker is inserted in the stream at position "tg_pos".

int gs_pm_set_tone_group(NXStream *stream, long tg_pos, char *word)
{
	long current_pos;
	
	/*  RETURN IMMEDIATELY IF tg_pos NOT LEGAL  */
	if (tg_pos == UNDEFINED_POSITION)
		return(TTS_PARSER_FAILURE);
	
	/*  GET CURRENT POSITION IN STREAM  */
	current_pos = NXTell(stream);
	
	/*  SEEK TO TONE GROUP MARKER POSITION  */
	NXSeek(stream, tg_pos, NX_FROMSTART);
	
	/*  WRITE APPROPRIATE TONE GROUP TYPE  */
	switch(word[0]) {
		case '.':
			NXPrintf(stream,"%s",TG_STATEMENT);
			break;
		case '!':
			NXPrintf(stream,"%s",TG_EXCLAMATION);
			break;
		case '?':
			NXPrintf(stream,"%s",TG_QUESTION);
			break;
		case ',':
			NXPrintf(stream,"%s",TG_CONTINUATION);
			break;
		case ';':
			NXPrintf(stream,"%s",TG_HALF_PERIOD);
			break;
		case ':':
			NXPrintf(stream,"%s",TG_CONTINUATION);
			break;
		default:
			return(TTS_PARSER_FAILURE);
			break;
	}
	
	/*  SEEK TO ORIGINAL POSITION ON STREAM  */
	NXSeek(stream, current_pos, NX_FROMSTART);
	
	/*  RETURN SUCCESS */
	return(TTS_PARSER_SUCCESS);
}



/// Converts numeric quantity in "buffer" to appropriate number of silence phones, which are written onto the
/// end of stream.  Rounding is performed.  Returns actual length of silence.

float gs_pm_convert_silence(char *buffer, NXStream *stream)
{
	int j, number_silence_phones;
	double silence_length;
	
	/*  CONVERT BUFFER TO DOUBLE  */
	silence_length = strtod(buffer,NULL);
	
	/*  LIMIT SILENCE LENGTH TO MAXIMUM  */
	silence_length = (silence_length > SILENCE_MAX) ? SILENCE_MAX : silence_length;
	
	/*  FIND EQUIVALENT NUMBER OF SILENCE PHONES, PERFORMING ROUNDING  */
	number_silence_phones = (int)rint(silence_length/SILENCE_PHONE_LENGTH);
	
	/*  PUT IN UTTERANCE BOUNDARY MARKER  */
	NXPrintf(stream,"%s ",UTTERANCE_BOUNDARY);
	
	/*  WRITE OUT SILENCE PHONES TO STREAMS  */
	for (j = 0; j < number_silence_phones; j++)
		NXPrintf(stream,"%s ",SILENCE_PHONE);
	
	/*  RETURN ACTUAL LENGTH OF SILENCE  */
	return((float)(number_silence_phones * SILENCE_PHONE_LENGTH));
}



/// Returns 1 if another word follows in buffer, after position i.  Else, 0 is returned.

int gs_pm_another_word_follows(const char *buffer, long i, long length, long mode)
{
	long j;
	
	for (j = i+1; j < length; j++) {
		/*  FILTER THROUGH EACH CHARACTER  */
		switch(buffer[j]) {
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
						return(1);
				}
				break;
		}
	}
	
	/*  IF HERE, THEN NO WORD FOLLOWS  */
	return(0);
}



/// Looks past punctuation to see if some silence occurs before the next word (or raw mode contents), and shifts
/// the silence to the current point on the stream.  The the numeric quantity is converted to equivalent silence
/// phones, and a 1 is returned.  0 is returned otherwise.

int gs_pm_shift_silence(const char *buffer, long i, long length, long mode, NXStream *stream)
{
	long j;
	char word[WORD_LENGTH_MAX+1];
	
	for (j = i+1; j < length; j++) {
		/*  FILTER THROUGH EACH CHARACTER  */
		switch(buffer[j]) {
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
					/*  SKIP WHITE SPACE  */
					if (buffer[j] == ' ')
						continue;
					/*  WORD HERE, SO RETURN WITHOUT SHIFTING  */
					if (!gs_pm_is_punctuation(buffer[j]))
						return(0);
				}
				else if (mode == RAW_MODE)
				/*  ASSUME RAW MODE CONTAINS WORD OF SOME SORT  */
					return(0);
				else if (mode == SILENCE_MODE) {
					/*  COLLECT SILENCE DIGITS INTO WORD BUFFER  */
					int k = 0;
					do {
						word[k++] = buffer[j++];
					} while ((j < length) && !gs_pm_is_mode(buffer[j]) && (k < WORD_LENGTH_MAX));
					word[k] = '\0';
					/*  CONVERT WORD TO SILENCE PHONES, APPENDING TO STREAM  */
					gs_pm_convert_silence(word, stream);
					/*  RETURN, INDICATING SILENCE SHIFTED BACKWARDS  */
					return(1);
				}
				break;
		}
	}
	
	/*  IF HERE, THEN SILENCE NOT SHIFTED  */
	return(0);
}



/// Inserts the tag contained in word onto the stream at the insert_point.

void gs_pm_insert_tag(NXStream *stream, long insert_point, char *word)
{
	long j, end_point, length;
	char *temp;
	
	/*  RETURN IMMEDIATELY IF NO INSERT POINT  */
	if (insert_point == UNDEFINED_POSITION)
		return;
	
	/*  FIND POSITION OF END OF STREAM  */
	end_point = NXTell(stream);
	
	/*  CALCULATE HOW MANY CHARACTERS TO SHIFT  */
	length = end_point - insert_point;
	
	/*  IF LENGTH IS 0, THEN SIMPLY APPEND TAG TO STREAM  */
	if (length == 0)
		NXPrintf(stream,"%s %s ", TAG_BEGIN, word);
	else {
		/*  ELSE, SAVE STREAM AFTER INSERT POINT  */
		temp = (char *)malloc(length+1);
		NXSeek(stream, insert_point, NX_FROMSTART);
		for (j = 0; j < length; j++)
			temp[j] = NXGetc(stream);
		temp[j] = '\0';
		
		/*  INSERT TAG; ADD TEMPORARY MATERIAL  */
		NXSeek(stream, insert_point, NX_FROMSTART);
		NXPrintf(stream,"%s %s %s", TAG_BEGIN, word, temp);
		
		/*  FREE TEMPORARY STORAGE  */
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
	int possessive = TTS_NO;
	char last_phoneme[SYMBOL_LENGTH_MAX+1], *last_phoneme_ptr;
	
	
	/*  STRIP OF POSSESSIVE ENDING IF WORD ENDS WITH 's, SET FLAG  */
	possessive = gs_pm_is_possessive(word);
	
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
			NXPrintf(stream, FOOT_BEGIN);
			last_foot_begin = NXTell(stream) - 2;
		}
	}
	
	/*  PRINT PRONUNCIATION TO STREAM, UP TO WORD TYPE MARKER (%)  */
	/*  KEEP TRACK OF LAST PHONEME  */
	ptr = pronunciation;
	last_phoneme[0] = '\0';
	last_phoneme_ptr = last_phoneme;
	while (*ptr && (*ptr != '%')) {
		switch(*ptr) {
			case '\'':
			case '`':
				NXPrintf(stream, FOOT_BEGIN);
				last_foot_begin = NXTell(stream) - 2;
				last_phoneme[0] = '\0';
				last_phoneme_ptr = last_phoneme;
				break;
			case '"':
				NXPrintf(stream, SECONDARY_STRESS);
				last_phoneme[0] = '\0';
				last_phoneme_ptr = last_phoneme;
				break;
			case '_':
			case '.':
				NXPrintf(stream, "%c", *ptr);
				last_phoneme[0] = '\0';
				last_phoneme_ptr = last_phoneme;
				break;
			case ' ':
				/*  SUPPRESS UNNECESSARY BLANKS  */
				if (*(ptr+1) && (*(ptr+1) != ' ')) {
					NXPrintf(stream, "%c", *ptr);
					last_phoneme[0] = '\0';
					last_phoneme_ptr = last_phoneme;
				}
				break;
			default:
				NXPrintf(stream, "%c", *ptr);
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
			NXPrintf(stream, "_s");
		else if (!strcmp(last_phoneme,"s") || !strcmp(last_phoneme,"sh") ||
				 !strcmp(last_phoneme,"z") || !strcmp(last_phoneme,"zh") ||
				 !strcmp(last_phoneme,"j") || !strcmp(last_phoneme,"ch"))
			NXPrintf(stream, ".uh_z");
		else
			NXPrintf(stream, "_z");
	}
	
	/*  ADD SPACE AFTER WORD  */
	NXPrintf(stream, " ");
	
	/*  IF TONIC, CONVERT LAST FOOT MARKER TO TONIC MARKER  */
	if (is_tonic && (last_foot_begin != UNDEFINED_POSITION)) {
		temporary_position = NXTell(stream);
		NXSeek(stream, last_foot_begin, NX_FROMSTART);
		NXPrintf(stream, TONIC_BEGIN);
		NXSeek(stream, temporary_position, NX_FROMSTART);
	}
}



/// Writes raw mode contents to stream, checking phones and markers.

int gs_pm_expand_raw_mode(const char *buffer, long *j, long length, NXStream *stream)
{
	int k, super_raw_mode = TTS_FALSE, delimiter = TTS_FALSE, blank = TTS_TRUE;
	char token[SYMBOL_LENGTH_MAX+1];
	
	/*  EXPAND AND CHECK RAW MODE CONTENTS TILL END OF RAW MODE  */
	token[k=0] = '\0';
	for ( ; (*j < length) && (buffer[*j] != RAW_MODE_END); (*j)++) {
		NXPrintf(stream, "%c", buffer[*j]);
		/*  CHECK IF ENTERING OR EXITING SUPER RAW MODE  */
		if (buffer[*j] == '%') {
			if (!super_raw_mode) {
				if (gs_pm_illegal_token(token))
					return(TTS_PARSER_FAILURE);
				super_raw_mode = TTS_TRUE;
				token[k=0] = '\0';
				continue;
			}
			else {
				super_raw_mode = TTS_FALSE;
				token[k=0] = '\0';
				delimiter = blank = TTS_FALSE;
				continue;
			}
		}
		/*  EXAMINE SLASH CODES, DELIMITERS, AND PHONES IN REGULAR RAW MODE  */
		if (!super_raw_mode) {
			switch(buffer[*j]) {
				case '/':
					/*  SLASH CODE  */
					/*  EVALUATE PENDING TOKEN  */
					if (gs_pm_illegal_token(token))
						return(TTS_PARSER_FAILURE);
					/*  PUT SLASH CODE INTO TOKEN BUFFER  */
					token[0] = '/';
					if ((++(*j) < length) && (buffer[*j] != RAW_MODE_END)) {
						NXPrintf(stream, "%c", buffer[*j]);
						token[1] = buffer[*j];
						token[2] = '\0';
						/*  CHECK LEGALITY OF SLASH CODE  */
						if (gs_pm_illegal_slash_code(token))
							return(TTS_PARSER_FAILURE);
						/*  CHECK ANY TAG AND TAG NUMBER  */
						if (!strcmp(token,TAG_BEGIN)) {
							if (gs_pm_expand_tag_number(buffer, j, length, stream) == TTS_PARSER_FAILURE)
								return(TTS_PARSER_FAILURE);
						}
						/*  RESET FLAGS  */
						token[k=0] = '\0';
						delimiter = blank = TTS_FALSE;
					}
					else
						return(TTS_PARSER_FAILURE);
					break;
				case '_':
				case '.':
					/*  SYLLABLE DELIMITERS  */
					/*  DON'T ALLOW REPEATED DELIMITERS, OR DELIMITERS AFTER BLANK  */
					if (delimiter || blank)
						return(TTS_PARSER_FAILURE);
					delimiter++;
					blank = TTS_FALSE;
					/*  EVALUATE PENDING TOKEN  */
					if (gs_pm_illegal_token(token))
						return(TTS_PARSER_FAILURE);
					/*  RESET FLAGS  */
					token[k=0] = '\0';
					break;
				case ' ':
					/*  WORD DELIMITER  */
					/*  DON'T ALLOW SYLLABLE DELIMITER BEFORE BLANK  */
					if (delimiter)
						return(TTS_PARSER_FAILURE);
					/*  SET FLAGS  */
					blank++;
					delimiter = TTS_FALSE;
					/*  EVALUATE PENDING TOKEN  */
					if (gs_pm_illegal_token(token))
						return(TTS_PARSER_FAILURE);
					/*  RESET FLAGS  */
					token[k=0] = '\0';
					break;
				default:
					/*  PHONE SYMBOL  */
					/*  RESET FLAGS  */
					delimiter = blank = TTS_FALSE;
					/*  ACCUMULATE PHONE SYMBOL IN TOKEN BUFFER  */
					token[k++] = buffer[*j];
					if (k <= SYMBOL_LENGTH_MAX)
						token[k] = '\0';
					else
						return(TTS_PARSER_FAILURE);
					break;
			}
		}
	}
	
	/*  CHECK ANY REMAINING TOKENS  */
	if (gs_pm_illegal_token(token))
		return(TTS_PARSER_FAILURE);
	
	/*  CANNOT END WITH A DELIMITER  */
	if (delimiter)
		return(TTS_PARSER_FAILURE);
	
	/*  PAD WITH SPACE, RESET EXTERNAL COUNTER  */
	NXPrintf(stream," ");
	(*j)--;
	
	/*  RETURN SUCCESS  */
	return(TTS_PARSER_SUCCESS);
}



/// Returns 1 if token is not a valid DEGAS phone.  Otherwise, 0 is returned.

int gs_pm_illegal_token(char *token)
{
	/*  RETURN IMMEDIATELY IF ZERO LENGTH STRING  */
	if (strlen(token) == 0)
		return(0);
	
	/*  IF PHONE A VALID DEGAS PHONE, RETURN 0;  1 OTHERWISE  */
	if (validPhone(token))
	    return(0);
	else
		return(1);
}



/// Returns 1 if code is illegal, 0 otherwise.

int gs_pm_illegal_slash_code(char *code)
{
	int i = 0;
	static char *legal_code[] = {CHUNK_BOUNDARY,TONE_GROUP_BOUNDARY,FOOT_BEGIN,
		TONIC_BEGIN,SECONDARY_STRESS,LAST_WORD,TAG_BEGIN,
		WORD_BEGIN,TG_STATEMENT,TG_EXCLAMATION,TG_QUESTION,
	TG_CONTINUATION,TG_HALF_PERIOD,NULL};
	
	/*  COMPARE CODE WITH LEGAL CODES, RETURN 0 IMMEDIATELY IF A MATCH  */
	while (legal_code[i] != NULL)
		if (!strcmp(legal_code[i++],code))
			return(0);
	
	/*  IF HERE, THEN NO MATCH;  RETURN 1, INDICATING ILLEGAL CODE  */
	return(1);
}



/// Expand tag number in buffer at position j and write to stream.  Perform error checking, returning error code
/// if format of tag number is illegal.

int gs_pm_expand_tag_number(const char *buffer, long *j, long length, NXStream *stream)
{
	int sign = 0;
	
	/*  SKIP WHITE  */
	while ((((*j)+1) < length) && (buffer[(*j)+1] == ' ')) {
		(*j)++;
		NXPrintf(stream,"%c",buffer[*j]);
	}
	
	/*  CHECK FORMAT OF TAG NUMBER  */
	while ((((*j)+1) < length) && (buffer[(*j)+1] != ' ') &&
		   (buffer[(*j)+1] != RAW_MODE_END) && (buffer[(*j)+1] != '%')) {
		NXPrintf(stream,"%c",buffer[++(*j)]);
		if ((buffer[*j] == '-') || (buffer[*j] == '+')) {
			if (sign)
				return(TTS_PARSER_FAILURE);
			sign++;
		}
		else if (!isdigit(buffer[*j]))
			return(TTS_PARSER_FAILURE);
	}
	
	/*  RETURN SUCCESS  */
	return(TTS_PARSER_SUCCESS);
}



/// Returns 1 if character is a mode marker, 0 otherwise.

int gs_pm_is_mode(char c)
{
	if ((c >= SILENCE_MODE_END) && (c <= RAW_MODE_BEGIN))
		return(1);
	else
		return(0);
}



/// Returns 1 if character at position i is isolated, i.e. is surrounded by space or mode marker.  Returns
/// 0 otherwise.

int gs_pm_is_isolated(char *buffer, long i, long len)
{
	if ( ((i == 0) || (((i-1) >= 0) && (gs_pm_is_mode(buffer[i-1]) || (buffer[i-1] == ' ')))) && 
		((i == (len-1)) || (((i+1) < len) && (gs_pm_is_mode(buffer[i+1]) || (buffer[i+1] == ' ')))))
		return(1);
	else
		return(0);
}



/// Returns 1 if character at position i is part of a number (including mixtures with non-numeric
/// characters).  Returns 0 otherwise.

int gs_pm_part_of_number(char *buffer, long i, long len)
{
	while( (--i >= 0) && (buffer[i] != ' ') && (buffer[i] != DELETED) && (!gs_pm_is_mode(buffer[i])) )
		if (isdigit(buffer[i]))
			return(1);
	
	while( (++i < len) && (buffer[i] != ' ') && (buffer[i] != DELETED) && (!gs_pm_is_mode(buffer[i])) )
		if (isdigit(buffer[i]))
			return(1);
	
	return(0);
}



/// Returns a 1 if at least one digit follows the character at position i, up to white space or mode marker.
/// Returns 0 otherwise.

int gs_pm_number_follows(char *buffer, long i, long len)
{
	while( (++i < len) && (buffer[i] != ' ') && 
		  (buffer[i] != DELETED) && (!gs_pm_is_mode(buffer[i])) )
		if (isdigit(buffer[i]))
			return(1);
	
	return(0);
}



/// Deletes three dots in a row (disregarding white space).  If four dots, then the last three are deleted.

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



/// Converts "--" to ", ", and "---" to ",  "
/// Returns 1 if this is done, 0 otherwise.

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
		return(1);
	}
	
	/*  RETURN ZERO IF NOT CONVERTED  */
	return(0);
}



/// Returns 1 if string at position i in buffer is of the form:  (ddd)ddd-dddd
/// where each d is a digit.

int gs_pm_is_telephone_number(char *buffer, long i, long length)
{
	/*  CHECK FORMAT: (ddd)ddd-dddd  */
	if ( ((i+12) < length) && 
        isdigit(buffer[i+1]) && isdigit(buffer[i+2]) && isdigit(buffer[i+3]) && 
        (buffer[i+4] == ')') && 
        isdigit(buffer[i+5]) && isdigit(buffer[i+6]) && isdigit(buffer[i+7]) && 
        (buffer[i+8] == '-') &&
        isdigit(buffer[i+9]) && isdigit(buffer[i+10]) &&
        isdigit(buffer[i+11]) && isdigit(buffer[i+12]) ) {
		/*  MAKE SURE STRING ENDS WITH WHITE SPACE, MODE, OR PUNCTUATION  */
		if ( ((i+13) == length) ||
			( ((i+13) < length) &&
			 (
			  gs_pm_is_punctuation(buffer[i+13]) || gs_pm_is_mode(buffer[i+13]) ||
			  (buffer[i+13] == ' ') || (buffer[i+13] == DELETED)
			  )
			 )
			)
		/*  RETURN 1 IF ALL ABOVE CONDITIONS ARE MET  */
			return(1);
	}
	/*  IF HERE, THEN STRING IS NOT IN SPECIFIED FORMAT  */
	return(0);
}



/// Returns 1 if character is a .,;:?!
/// Returns 0 otherwise.

int gs_pm_is_punctuation(char c)
{
	switch(c) {
		case '.':
		case ',':
		case ';':
		case ':':
		case '?':
		case '!':
			return(1);
		default:
			return(0);
	}
}



/// Returns a 1 if a word or speakable symbol (letter mode) follows the position i in buffer.  Raw, tagging, and
/// silence mode contents are ignored.  Returns a 0 if any punctuation (except . as part of number) follows.

int gs_pm_word_follows(char *buffer, long i, long length)
{
	long j, mode = NORMAL_MODE;
	
	for (j = (i+1); j < length; j++) {
		switch(buffer[j]) {
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
				switch(mode) {
					case NORMAL_MODE:
					case EMPHASIS_MODE:
						/*  IGNORE WHITE SPACE  */
						if ((buffer[j] == ' ') || (buffer[j] == DELETED))
							continue;
						/*  PUNCTUATION MEANS NO WORD FOLLOWS (UNLESS PERIOD PART OF NUMBER)  */
						else if (gs_pm_is_punctuation(buffer[j])) {
							if ((buffer[j] == '.') && ((j+1) < length) && isdigit(buffer[j+1]))
								return(1);
							else
								return(0);
						}
						/*  ELSE, SOME WORD FOLLOWS  */
						else
							return(1);
					case LETTER_MODE:
						/*  IF LETTER MODE CONTAINS ANY SYMBOLS, THEN RETURN 1  */
						return(1);
					case RAW_MODE:
					case SILENCE_MODE:
					case TAGGING_MODE:
						/*  IGNORE CONTENTS OF RAW, SILENCE, AND TAGGING MODE  */
						continue;
				}
		}
	}
	
	/*  IF HERE, THEN A FOLLOWING WORD NOT FOUND  */
	return(0);
}



/// Expands listed abbreviations.  Two lists are used (see abbreviations.h):  one list expands unconditionally,
/// the other only if the abbreviation is followed by a number.  The abbreviation p. is expanded to page.
/// Single alphabetic characters have periods deleted, but no expansion is made.  They are also capitalized.
/// Returns 1 if expansion made (i.e. period is deleted), 0 otherwise.

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
				NXSeek(stream, -1, NX_FROMCURRENT);
				NXPrintf(stream, "page ");
			}
			else {
				/*  ELSE, CAPITALIZE CHARACTER IF NECESSARY, BLANK OUT PERIOD  */
				NXSeek(stream, -1, NX_FROMCURRENT);
				if (islower(buffer[i-1]))
					buffer[i-1] = toupper(buffer[i-1]);
				NXPrintf(stream,"%c ",buffer[i-1]);
			}
			/*  INDICATE ABBREVIATION EXPANDED  */
			return(1);
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
					NXSeek(stream, -word_length, NX_FROMCURRENT);
					NXPrintf(stream,"%s ",abbr_with_number[j][EXPANSION]);
					return(1);
				}
			}
		}
		
		/*  EXPAND THESE ABBREVIATIONS UNCONDITIONALLY  */
		for (j = 0; abbreviation[j][ABBREVIATION] != NULL; j++) {
			if (!strcmp(abbreviation[j][ABBREVIATION],word)) {
				NXSeek(stream, -word_length, NX_FROMCURRENT);
				NXPrintf(stream,"%s ",abbreviation[j][EXPANSION]);
				return(1);
			}
		}
	}
	
	/*  IF HERE, THEN NO EXPANSION MADE  */
	return(0);
}



/// Expands contents of letter mode string to word or words.  A comma is added after each expansion, except
/// the last letter when it is followed by punctuation.

void gs_pm_expand_letter_mode(char *buffer, long *i, long length, NXStream *stream, long *status)
{
	for ( ; ((*i) < length) && (buffer[*i] != LETTER_MODE_END); (*i)++) {
		/*  CONVERT LETTER TO WORD OR WORDS  */
		switch (buffer[*i]) {
			case ' ': NXPrintf(stream, "blank");                break;
			case '!': NXPrintf(stream, "exclamation point");    break;
			case '"': NXPrintf(stream, "double quote");         break;
			case '#': NXPrintf(stream, "number sign");          break;
			case '$': NXPrintf(stream, "dollar");               break;
			case '%': NXPrintf(stream, "percent");              break;
			case '&': NXPrintf(stream, "ampersand");            break;
			case '\'':NXPrintf(stream, "single quote");         break;
			case '(': NXPrintf(stream, "open parenthesis");     break;
			case ')': NXPrintf(stream, "close parenthesis");    break;
			case '*': NXPrintf(stream, "asterisk");             break;
			case '+': NXPrintf(stream, "plus sign");            break;
			case ',': NXPrintf(stream, "comma");                break;
			case '-': NXPrintf(stream, "hyphen");               break;
			case '.': NXPrintf(stream, "period");               break;
			case '/': NXPrintf(stream, "slash");                break;
			case '0': NXPrintf(stream, "zero");                 break;
			case '1': NXPrintf(stream, "one");                  break;
			case '2': NXPrintf(stream, "two");                  break;
			case '3': NXPrintf(stream, "three");                break;
			case '4': NXPrintf(stream, "four");                 break;
			case '5': NXPrintf(stream, "five");                 break;
			case '6': NXPrintf(stream, "six");                  break;
			case '7': NXPrintf(stream, "seven");                break;
			case '8': NXPrintf(stream, "eight");                break;
			case '9': NXPrintf(stream, "nine");                 break;
			case ':': NXPrintf(stream, "colon");                break;
			case ';': NXPrintf(stream, "semicolon");            break;
			case '<': NXPrintf(stream, "open angle bracket");   break;
			case '=': NXPrintf(stream, "equal sign");           break;
			case '>': NXPrintf(stream, "close angle bracket");  break;
			case '?': NXPrintf(stream, "question mark");        break;
			case '@': NXPrintf(stream, "at sign");              break;
			case 'A':
			case 'a': NXPrintf(stream, "A");                    break;
			case 'B':
			case 'b': NXPrintf(stream, "B");                    break;
			case 'C':
			case 'c': NXPrintf(stream, "C");                    break;
			case 'D':
			case 'd': NXPrintf(stream, "D");                    break;
			case 'E':
			case 'e': NXPrintf(stream, "E");                    break;
			case 'F':
			case 'f': NXPrintf(stream, "F");                    break;
			case 'G':
			case 'g': NXPrintf(stream, "G");                    break;
			case 'H':
			case 'h': NXPrintf(stream, "H");                    break;
			case 'I':
			case 'i': NXPrintf(stream, "I");                    break;
			case 'J':
			case 'j': NXPrintf(stream, "J");                    break;
			case 'K':
			case 'k': NXPrintf(stream, "K");                    break;
			case 'L':
			case 'l': NXPrintf(stream, "L");                    break;
			case 'M':
			case 'm': NXPrintf(stream, "M");                    break;
			case 'N':
			case 'n': NXPrintf(stream, "N");                    break;
			case 'O':
			case 'o': NXPrintf(stream, "O");                    break;
			case 'P':
			case 'p': NXPrintf(stream, "P");                    break;
			case 'Q':
			case 'q': NXPrintf(stream, "Q");                    break;
			case 'R':
			case 'r': NXPrintf(stream, "R");                    break;
			case 'S':
			case 's': NXPrintf(stream, "S");                    break;
			case 'T':
			case 't': NXPrintf(stream, "T");                    break;
			case 'U':
			case 'u': NXPrintf(stream, "U");                    break;
			case 'V':
			case 'v': NXPrintf(stream, "V");                    break;
			case 'W':
			case 'w': NXPrintf(stream, "W");                    break;
			case 'X':
			case 'x': NXPrintf(stream, "X");                    break;
			case 'Y':
			case 'y': NXPrintf(stream, "Y");                    break;
			case 'Z':
			case 'z': NXPrintf(stream, "Z");                    break;
			case '[': NXPrintf(stream, "open square bracket");  break;
			case '\\':NXPrintf(stream, "back slash");           break;
			case ']': NXPrintf(stream, "close square bracket"); break;
			case '^': NXPrintf(stream, "caret");                break;
			case '_': NXPrintf(stream, "under score");          break;
			case '`': NXPrintf(stream, "grave accent");         break;
			case '{': NXPrintf(stream, "open brace");           break;
			case '|': NXPrintf(stream, "vertical bar");         break;
			case '}': NXPrintf(stream, "close brace");          break;
			case '~': NXPrintf(stream, "tilde");                break;
			default:  NXPrintf(stream, "unknown");              break;
		}
		/*  APPEND COMMA, UNLESS PUNCTUATION FOLLOWS LAST LETTER  */
		if ( (((*i)+1) < length) &&
			(buffer[(*i)+1] == LETTER_MODE_END) &&
			!gs_pm_word_follows(buffer, (*i), length)) {
			NXPrintf(stream," ");
			*status = WORD;
		}
		else {
			NXPrintf(stream,", ");
			*status = PUNCTUATION;
		}
	}
	/*  BE SURE TO SET INDEX BACK ONE, SO CALLING ROUTINE NOT FOULED UP  */
	(*i)--;
}



/// Returns 1 if all letters of the word are upper case, 0 otherwise.

int gs_pm_is_all_upper_case(char *word)
{
	while (*word) {
		if (!isupper(*word))
			return(0);
		word++;
	}
	
	return(1);
}



/// Converts any upper case letter in word to lower case.

char *gs_pm_to_lower_case(char *word)
{
	char *ptr = word;
	
	while (*ptr) {
		if (isupper(*ptr))
			*ptr = tolower(*ptr);
		ptr++;
	}
	
	return(word);
}



/// Returns a pointer to the pronunciation of a special acronym if it is defined in the list.  Otherwise, NULL is returned.

const char *gs_pm_is_special_acronym(char *word)
{	
	NSString * w = [NSString stringWithCString:word encoding:NSASCIIStringEncoding];
	NSString * pr;
	
	/*  CHECK IF MATCH FOUND, RETURN PRONUNCIATION  */	
	if ((pr = [specialAcronymsDictionary objectForKey:w]) != nil)
		return [pr cStringUsingEncoding:NSASCIIStringEncoding];
	
	/*  IF HERE, NO SPECIAL ACRONYM FOUND, RETURN NULL  */
	return(NULL);
}



/// Returns 1 if the pronunciation contains ' (and ` for backwards compatibility).  Otherwise 0 is returned.

int gs_pm_contains_primary_stress(const char *pronunciation)
{
	for ( ; *pronunciation && (*pronunciation != '%'); pronunciation++)
		if ((*pronunciation == '\'') || (*pronunciation == '`'))
			return(TTS_YES);
	
	return(TTS_NO);
}



/// Returns 1 if the first " is converted to a ', otherwise 0 is returned.

int gs_pm_converted_stress(char *pronunciation)
{
	/*  LOOP THRU PRONUNCIATION UNTIL " FOUND, REPLACE WITH '  */
	for ( ; *pronunciation && (*pronunciation != '%'); pronunciation++)
		if (*pronunciation == '"') {
			*pronunciation = '\'';
			return(TTS_YES);
		}
	
	/*  IF HERE, NO " FOUND  */
	return(TTS_NO);
}



/// Returns 1 if 's is found at end of word, and removes the 's ending from the word.  Otherwise, 0 is returned.

int gs_pm_is_possessive(char *word)
{
	/*  LOOP UNTIL 's FOUND, REPLACE ' WITH NULL  */
	for ( ; *word; word++)
		if ((*word == '\'') && *(word+1) && (*(word+1) == 's') && (*(word+2) == '\0')) {
			*word = '\0';
			return(TTS_YES);
		}
	
	/*  IF HERE, NO 's FOUND, RETURN FAILURE  */
	return(TTS_NO);
}



/// Checks to make sure that there are not too many feet phones per chunk.  If there are, the input is split
/// into two or mor chunks.

void gs_pm_safety_check(NXStream *stream, long *stream_length)
{
	int  c, number_of_feet = 0, number_of_phones = 0, state = NON_PHONEME;
	long last_word_pos = UNDEFINED_POSITION, last_tg_pos = UNDEFINED_POSITION;
	char last_tg_type = '0';
	
	/*  REWIND STREAM TO BEGINNING  */
	NXSeek(stream, 0, NX_FROMSTART);
	
	/*  LOOP THROUGH STREAM, INSERTING NEW CHUNK MARKERS IF NECESSARY  */
	while ((c = NXGetc(stream)) != '\0' && c != EOF) {
		switch(c) {
			case '%':
				/*  IGNORE SUPER RAW MODE CONTENTS  */
				while ((c = NXGetc(stream)) != '%') {
					if (c == '\0' || c == EOF) {
						NXUngetc(stream);
						break;
					}
				}
				state = NON_PHONEME;
				break;
			case '/':
				/*  SLASH CODES  */
				switch(c = NXGetc(stream)) {
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
						while ((c = NXGetc(stream)) == ' ')
							;
						NXUngetc(stream);
						/*  SKIP OVER TAG NUMBER  */
						while ((c = NXGetc(stream)) != ' ') {
							if (c == '\0' || c == EOF) {
								NXUngetc(stream);
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
						last_tg_type = c;
						last_tg_pos = NXTell(stream) - 2;
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
					if (c == ' ')
						last_word_pos = NXTell(stream);
				}
				state = NON_PHONEME;
				break;
			default:
				state = PHONEME;
				break;
		}
	}
	
	/*  BE SURE TO RESET LENGTH OF STREAM  */
	*stream_length = NXTell(stream);
}



/// Insert chunk markers and associated markers in the stream at the insert point.  Use the tone group type
/// passed in as an argument.

void gs_pm_insert_chunk_marker(NXStream *stream, long insert_point, char tg_type)
{
	NXStream *temp_stream;
	long new_position;
	char c;
	
	
	/*  OPEN TEMPORARY STREAM  */
	temp_stream = NXOpenMemory(NULL, 0, NX_READWRITE);
	
	/*  COPY STREAM FROM INSERT POINT TO END TO BUFFER TO ANOTHER STREAM  */
	NXSeek(stream, insert_point, NX_FROMSTART);
	while ((c = NXGetc(stream)) != '\0')
		NXPutc(temp_stream, c);
	NXPutc(temp_stream, '\0');
	
	/*  PUT IN MARKERS AT INSERT POINT  */
	NXSeek(stream, insert_point, NX_FROMSTART);
	NXPrintf(stream, "%s %s %s /%c ", TONE_GROUP_BOUNDARY, CHUNK_BOUNDARY,
			 TONE_GROUP_BOUNDARY, tg_type);
	new_position = NXTell(stream) - 9;
	
	/*  APPEND CONTENTS OF TEMPORARY STREAM  */
	NXSeek(temp_stream, 0, NX_FROMSTART);
	while ((c = NXGetc(temp_stream)) != '\0')
		NXPutc(stream, c);
	NXPutc(stream, '\0');
	
	/*  POSITION THE STREAM AT THE NEW /c MARKER  */
	NXSeek(stream, new_position, NX_FROMSTART);
	
	/*  FREE TEMPORARY STREAM  */
	NXCloseMemory(temp_stream, NX_FREEBUFFER);
}



/// Checks to see if a tonic marker is present in the stream between the start and end positions.  If no
/// tonic is present, then put one in at the last foot marker if it exists.

void gs_pm_check_tonic(NXStream *stream, long start_pos, long end_pos)
{
	long temp_pos, i, extent, last_foot_pos = UNDEFINED_POSITION;
	
	
	/*  REMEMBER CURRENT POSITION IN STREAM  */
	temp_pos = NXTell(stream);
	
	/*  CALCULATE EXTENT OF STREAM TO LOOP THROUGH  */
	extent = end_pos - start_pos;
	
	/*  REWIND STREAM TO START POSITION  */
	NXSeek(stream, start_pos, NX_FROMSTART);
	
	/*  LOOP THROUGH STREAM, DETERMINING LAST FOOT POSITION, AND PRESENCE OF TONIC  */
	for (i = 0; i < extent; i++) {
		if ((NXGetc(stream) == '/') && (++i < extent)) {
			switch(NXGetc(stream)) {
				case '_':
					last_foot_pos = NXTell(stream) - 1;
					break;
				case '*':
					/*  GO TO ORIGINAL POSITION ON STREAM, AND RETURN IMMEDIATELY  */
					NXSeek(stream, temp_pos, NX_FROMSTART);
					return;
			}
		}
	}
	
	/*  IF HERE, NO TONIC, SO INSERT TONIC MARKER  */
	if (last_foot_pos != UNDEFINED_POSITION) {
		NXSeek(stream, last_foot_pos, NX_FROMSTART);
		NXPutc(stream, '*');
	}
	
	/*  GO TO ORIGINAL POSITION ON STREAM  */
	NXSeek(stream, temp_pos, NX_FROMSTART);
}



/// Prints out the contents of a parser stream, inserting visible mode markers.
#if 0
static void print_stream(NXStream *stream, long stream_length)
{
	/*  REWIND STREAM TO BEGINNING  */
	NXSeek(stream, 0, NX_FROMSTART);
	
	/*  PRINT LOOP  */
	printf("stream_length = %-ld\n<begin>", stream_length);
	for (NSUInteger i = 0; i < stream_length; i++) {
		char c = NXGetc(stream);
		switch(c) {
			case RAW_MODE_BEGIN:
				printf("<raw mode begin>");
				break;
			case RAW_MODE_END:
				printf("<raw mode end>");
				break;
			case LETTER_MODE_BEGIN:
				printf("<letter mode begin>");
				break;
			case LETTER_MODE_END:
				printf("<letter mode end>");
				break;
			case EMPHASIS_MODE_BEGIN:
				printf("<emphasis mode begin>");
				break;
			case EMPHASIS_MODE_END:
				printf("<emphasis mode end>");
				break;
			case TAGGING_MODE_BEGIN:
				printf("<tagging mode begin>");
				break;
			case TAGGING_MODE_END:
				printf("<tagging mode end>");
				break;
			case SILENCE_MODE_BEGIN:
				printf("<silence mode begin>");
				break;
			case SILENCE_MODE_END:
				printf("<silence mode end>");
				break;
			default:
				printf("%c",c);
				break;
		}
	}
	printf("<end>\n");
}
#endif