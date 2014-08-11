//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*******************************************************************************
 *
 *       number_parser.c, in conjunction with number_parser.h, is used to create
 *       the function number_parser().  This function can be used to return to
 *       the caller the pronunciation of any string containing a numeral.  The
 *       calling routine must include number_parser.h to access number_parser()
 *       (and also degenerate_string(), another useful function).
 *       The include file number_pronunciations.h contains pronunciations for
 *       all numbers and symbols; it can be changed as needed to improve
 *       the pronunciations.  number_parser.c must be recompiled if any of the
 *       header files change.
 *
 *       number_parser() has two arguments:
 *       1) word_ptr - a pointer to a NULL terminated character string,
 *          containing the number or number string to be parsed.
 *       2) mode - an integer, specifying in what mode the number or
 *          number string is to be parsed.  Three constants are defined
 *          in number_parser.h:  NP_NORMAL, NP_OVERRIDE_YEARS, and
 *          NP_FORCE_SPELL.  Using NP_NORMAL, the function attempts
 *          to parse the number string according to the guidelines
 *          listed below.  NP_OVERRIDE_YEARS forces the function to
 *          interpret numbers from 1000 to 1999 NOT as years, but as
 *          ordinary integers.  NP_FORCE_SPELL forces the function to
 *          spell out each character of the number string.  This may
 *          be useful with very long numbers, or when the numbers are
 *          not to be interpreted in the usual way.
 *
 *       number_parser() returns a pointer to NULL if the word_ptr points
 *       to a string which contains NO numerals at all.  It returns a pointer
 *       to a NULL terminated character string containing the pronunciation
 *       for the number string in all other cases.
 *
 *       The parser can deal with the following cases:
 *       1) Cardinal numbers.
 *          a) Will name triads with numbers up to 10^63 (vigintillion);  with
 *             numbers longer than this the numerals are pronounced one at a
 *             time.  Eg: 1547630 is pronounced as one million, five hundred
 *             and forty-seven thousand, six hundred and thirty.
 *          b) Cardinal numbers can be with or without commas.  The function
 *             checks that the commas are properly placed.  Eg: 23,567 is
 *             pronounced as twenty-three thousand, five hundred and sixty-
 *             seven.
 *       2) Positive and negative numbers.  A + or - sign can be placed before
 *          most numbers, except before telephone numbers, clock times, or
 *          years.  Eg:  -34.5 is pronounced as negative thirty-four point five.
 *       3) Decimal numbers.  All numbers with a decimal point can be
 *          pronounced.  Eg:  +34.234 is pronounced as positive thirty-four
 *          point two three four.
 *       4) Simple fractions.  Number strings with the form  integer/integer
 *          are pronounced correctly.  Each integer must NOT contain commas
 *          or decimals.  Any + or - sign must precede the first integer,
 *          and any % sign must follow the last integer.  Eg:  -3/4% is
 *          pronounced as negative three quarters percent.
 *       5) Ordinal numbers.  Ordinal numbers up to 10^63 are pronounced
 *          correctly, provided the proper suffix (-st, -nd, or -th) is
 *          provided.  Eg:  101ST is pronounced as one hundred and first.
 *       6) Dollars and cents.  Dollars and cents are pronounced correctly
 *          if the $ sign is placed before the number.  An optional + or -
 *          sign can be placed before the dollar sign.  Eg:  -$2.01 is
 *          pronounced as negative two dollars and one cent.
 *       7) Percent.  If a % sign is placed after the number, the word
 *          "percent" is also pronounced.  Eg:  2.45% is pronounced as
 *          two point four five percent.
 *       8) Telephone numbers.  The parser recognizes the following types of
 *          telephone numbers:
 *          a) 7 digit code.  Eg:  555-2345.
 *          b) 10 digit code.  Eg:  203-555-2345
 *          c) 11 digit code.  Eg:  1-800-555-2345
 *          d) area codes.  Eg:  (203) 555-2345  or  (203)555-2345
 *               (Note the optional space above.)
 *       9) Clock times.  The function recognizes both normal and military
 *          (24 hour) time.  Eg:  9:31 is pronounced nine thirty-one.
 *          08:00 is pronounced oh eight hundred.  Seconds are also recognized.
 *          Eg. 10:23:14 is pronounced ten twenty-three and 14 seconds.  Non-
 *          military times on the hour have o'clock appended.  Eg. 9:00 is
 *          pronounced nine o'clock.
 *       10) Years.  Integers from 1000 to 1999 are pronounced as two pairs.
 *           Eg:  1906 is pronounced as nineteen oh six, NOT one thousand,
 *           nine hundred and six.  This default can be changed by setting
 *           the mode to NP_OVERRIDE_YEARS.
 *
 *       If the function cannot put the number string it receives into
 *       any of the above cases, it will pronounce the string one character
 *       at a time.  If the calling routine wishes to have character-by-
 *       character pronunciation as the default, the mode should be set to
 *       NP_FORCE_SPELL.  Using the function degenerate_string() will also
 *       achieve the same thing.
 *
 *******************************************************************************/


/*  INCLUDE FILES  ***********************************************************/

#import "number_parser.h"
#import "number_pronunciations.h"
/*  #incude "number_pronunciations_english.h"  (use this for plain english)  */
#import <string.h>



/*  SYMBOLIC CONSTANTS  ******************************************************/

#define OUTPUT_MAX             8192    /*  OUTPUT BUFFER SIZE IN CHARS     */
#define INTEGER_DIGITS_MAX     100     /*  MAX # OF INTEGER DIGITS         */
#define FRACTIONAL_DIGITS_MAX  100     /*  MAX # OF FRACTIONAL DIGITS      */
#define COMMAS_MAX             33      /*  MAX # OF COMMAS                 */
#define NEGATIVE_MAX           3       /*  MAX # OF NEGATIVE SIGNS (-)     */
#define CLOCK_MAX              2       /*  MAX # OF COLONS IN CLOCK TIMES  */

#define NP_NO                  0       /*  GENERAL PURPOSE FLAGS  */
#define NP_YES                 1
#define NONZERO                1

#define NO_NUMERALS            0       /*  FLAGS RETURNED BY error_check()  */
#define DEGENERATE             1
#define OK                     3

#define SECONDTH_FLAG          1       /*  FLAGS FOR special_flag  */
#define HALF_FLAG              2
#define QUARTER_FLAG           3

#define SEVEN_DIGIT_CODE       1       /*  TELEPHONE FLAGS  */
#define TEN_DIGIT_CODE         2
#define ELEVEN_DIGIT_CODE      3
#define AREA_CODE              4



/*  EXTERNAL VARIABLES  (LOCAL TO THIS FILE)  *******************************/

/*  INPUT AND OUTPUT VARIABLES  */
static char *word;
static char output[OUTPUT_MAX];        /*  STORAGE FOR OUTPUT  */

/*  PARSING STATISTIC VARIABLES  */
static long word_length;
static long degenerate;
static long integer_digits;
static long fractional_digits;
static long commas;
static long mydecimal;
static long dollar;
static long percent;
static long negative;
static long positive;
static long ordinal;
static long myclock;
static long slash;
static long left_paren;
static long right_paren;
static long blank;
static long dollar_plural;
static long dollar_nonzero;
static long cents_plural;
static long cents_nonzero;
static long telephone;
static long left_zero_pad;
static long right_zero_pad;
static long ordinal_plural;
static long frac_left_zero_pad;
static long frac_right_zero_pad;
static long frac_ordinal_triad;

static long commas_pos[COMMAS_MAX];
static long mydecimal_pos;
static long dollar_pos;
static long percent_pos;
static long negative_pos[NEGATIVE_MAX];
static long positive_pos;
static long integer_digits_pos[INTEGER_DIGITS_MAX];
static long fractional_digits_pos[FRACTIONAL_DIGITS_MAX];
static long ordinal_pos[2];
static long myclock_pos[CLOCK_MAX];
static long slash_pos;
static long left_paren_pos;
static long right_paren_pos;
static long blank_pos;

/*  VARIABLES PERTAINING TO TRIADS AND TRIAD NAMES  */
static char triad[3];
static char *triad_name[3][TRIADS_MAX] = {
    {
        NULL_STRING,
        THOUSAND,
        MILLION,
        BILLION,
        TRILLION,
        QUADRILLION,
        QUINTILLION,
        SEXTILLION,
        SEPTILLION,
        OCTILLION,
        NONILLION,
        DECILLION,
        UNDECILLION,
        DUODECILLION,
        TREDECILLION,
        QUATTUORDECILLION,
        QUINDECILLION,
        SEXDECILLION,
        SEPTENDECILLION,
        OCTODECILLION,
        NOVEMDECILLION,
        VIGINTILLION
    },
    {
        NULL_STRING,
        THOUSANDTH,
        MILLIONTH,
        BILLIONTH,
        TRILLIONTH,
        QUADRILLIONTH,
        QUINTILLIONTH,
        SEXTILLIONTH,
        SEPTILLIONTH,
        OCTILLIONTH,
        NONILLIONTH,
        DECILLIONTH,
        UNDECILLIONTH,
        DUODECILLIONTH,
        TREDECILLIONTH,
        QUATTUORDECILLIONTH,
        QUINDECILLIONTH,
        SEXDECILLIONTH,
        SEPTENDECILLIONTH,
        OCTODECILLIONTH,
        NOVEMDECILLIONTH,
        VIGINTILLIONTH
    },
    {
        NULL_STRING,
        THOUSANDTHS,
        MILLIONTHS,
        BILLIONTHS,
        TRILLIONTHS,
        QUADRILLIONTHS,
        QUINTILLIONTHS,
        SEXTILLIONTHS,
        SEPTILLIONTHS,
        OCTILLIONTHS,
        NONILLIONTHS,
        DECILLIONTHS,
        UNDECILLIONTHS,
        DUODECILLIONTHS,
        TREDECILLIONTHS,
        QUATTUORDECILLIONTHS,
        QUINDECILLIONTHS,
        SEXDECILLIONTHS,
        SEPTENDECILLIONTHS,
        OCTODECILLIONTHS,
        NOVEMDECILLIONTHS,
        VIGINTILLIONTHS
    }
};

/*  ORDINAL VARIABLES  */
static char     ordinal_buffer[3];
static int      ordinal_triad;

/*  CLOCK VARIABLES  */
static char     hour[4], minute[4], second[4];
static int      military, seconds;



char *number_parser(const char *word_ptr, int mode);
void initial_parse(void);
int error_check(int mode);
char *process_word(int mode);
char *degenerate_string(const char *word);
int process_triad(char *triad, char *output, int pause, int ordinal, int right_zero_pad, int ordinal_plural, int special_flag);
void process_digit(char digit, char *output, int ordinal, int ordinal_plural, int special_flag);

/******************************************************************************
 *
 *      purpose:        Returns a pointer to a NULL terminated character string
 *                       which contains the pronunciation for the string pointed
 *                       at by the argument word_ptr.
 *
 *       arguments:      word_ptr:  a pointer to the NULL terminated number
 *                         string which is to be parsed.
 *                       mode:  determines how the number string is to be
 *                         parsed.  Should be set to NP_NORMAL,
 *                         NP_OVERRIDE_YEARS, or NP_FORCE_SPELL.
 *
 ******************************************************************************/

char *number_parser(const char *word_ptr, int mode)
{
    int status;

    /*  MAKE POINTER TO WORD TO BE PARSED GLOBAL TO THIS FILE  */
    word = (char *)word_ptr;

    /*  DO INITIAL PARSE OF WORD  */
    initial_parse();

    /*  DO ERROR CHECKING OF INPUT  */
    status = error_check(mode);

    /*  IF NO NUMBERS, RETURN NULL;  IF CONTAINS ERRORS,
     DO CHAR-BY-CHAR SPELLING;  ELSE, PROCESS NORMALLY  */
    if (status == NO_NUMERALS)
        return (NULL);
    else if (status == DEGENERATE)
        return (degenerate_string(word));
    else if (status == OK)
        return (process_word(mode));

    return(NULL);
}



/******************************************************************************
 *
 *      purpose:        Finds positions of numbers, commas, and other symbols
 *                       within the word.
 *
 ******************************************************************************/

void initial_parse(void)
{
    long i;

    /*  PUT NULL BYTE INTO output;  FIND LENGTH OF INPUT WORD  */
    output[0] = '\0';
    word_length = strlen(word);

    /*  INITIALIZE PARSING VARIABLES  */
    degenerate = integer_digits = fractional_digits = commas = mydecimal = 0;
    dollar = percent = negative = positive = ordinal = myclock = slash = 0;
    telephone = left_paren = right_paren = blank = 0;
    ordinal_plural = NP_YES;

    /*  FIND THE POSITION OF THE FOLLOWING CHARACTERS  */
    for (i = 0; i < word_length; i++) {
        switch (*(word+i)) {
            case ',':
                if (++commas > COMMAS_MAX)
                    degenerate++;
                else
                    *(commas_pos + (commas - 1)) = i;
                break;
            case '.':
                mydecimal++;
                mydecimal_pos = i;
                break;
            case '$':
                dollar++;
                dollar_pos = i;
                break;
            case '%':
                percent++;
                percent_pos = i;
                break;
            case '-':
                if (++negative > NEGATIVE_MAX)
                    degenerate++;
                else
                    *(negative_pos + (negative - 1)) = i;
                break;
            case '+':
                positive++;
                positive_pos = i;
                break;
            case ':':
                if (++myclock > CLOCK_MAX)
                    degenerate++;
                else
                    *(myclock_pos + (myclock - 1)) = i;
                break;
            case '/':
                slash++;
                slash_pos = i;
                break;
            case '(':
                left_paren++;
                left_paren_pos = i;
                break;
            case ')':
                right_paren++;
                right_paren_pos = i;
                break;
            case ' ':
                blank++;
                blank_pos = i;
                break;
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
                if (mydecimal || slash) {
                    if (++fractional_digits > FRACTIONAL_DIGITS_MAX)
                        degenerate++;
                    else
                        *(fractional_digits_pos + (fractional_digits - 1)) = i;
                } else {
                    if (++integer_digits > INTEGER_DIGITS_MAX)
                        degenerate++;
                    else
                        *(integer_digits_pos + (integer_digits - 1)) = i;
                }
                break;
            case 's':
            case 'S':
            case 't':
            case 'T':
            case 'n':
            case 'N':
            case 'd':
            case 'D':
            case 'r':
            case 'R':
            case 'h':
            case 'H':
                if (++ordinal > 2)
                    degenerate++;
                else {
                    char c = *(word + i);
                    ordinal_pos[ordinal - 1] = i;
                    /*  CONVERT TO UPPER CASE IF NECESSARY  */
                    *(ordinal_buffer + (ordinal - 1)) = ((c >= 'a') && (c <= 'z')) ? c + ('A' - 'a') : c ;
                    *(ordinal_buffer + 2) = '\0';
                }
                break;
            default:
                degenerate++;
                break;
        }
    }

    /*  FIND LEFT ZERO PAD FOR INTEGER PART OF WORD  */
    for (i = 0, left_zero_pad = 0; i < integer_digits; i++) {
        if (*(word + (*(integer_digits_pos + i))) == '0')
            left_zero_pad++;
        else
            break;
    }
    /*  FIND RIGHT ZERO PAD FOR INTEGER PART OF WORD  */
    for (i = (integer_digits - 1), right_zero_pad = 0; i >= 0; i--) {
        if (*(word + (*(integer_digits_pos + i))) == '0')
            right_zero_pad++;
        else
            break;
    }
    /*  DETERMINE RIGHT MOST TRIAD TO RECEIVE ORDINAL NAME  */
    ordinal_triad = (int)(right_zero_pad / 3.0);


    /*  FIND LEFT ZERO PAD FOR FRACTIONS  */
    for (i = 0, frac_left_zero_pad = 0; i < fractional_digits; i++) {
        if (*(word + (*(fractional_digits_pos + i))) == '0')
            frac_left_zero_pad++;
        else
            break;
    }
    /*  FIND RIGHT ZERO PAD FOR FRACTIONS  */
    for (i = (fractional_digits - 1), frac_right_zero_pad = 0; i >= 0; i--) {
        if (*(word + (*(fractional_digits_pos + i))) == '0')
            frac_right_zero_pad++;
        else
            break;
    }
    /*  DETERMINE RIGHT MOST TRIAD TO RECEIVE ORDINAL NAME FOR FRACTIONS  */
    frac_ordinal_triad = (int)(frac_right_zero_pad / 3.0);
}



/******************************************************************************
 *
 *      purpose:        Checks the initiallly parsed word for format errors.
 *                      Returns NO_NUMERALS if the word contains no digits,
 *                       DEGENERATE if the word contains errors, OK otherwise.
 *
 ******************************************************************************/

int error_check(int mode)
{
    long i;

    /*  IF THERE ARE NO DIGITS THEN RETURN  */
    if ((integer_digits + fractional_digits) == 0)
        return (NO_NUMERALS);

    /* IF MODE SET TO FORCE_SPELL, USE degenerate_string()  */
    if (mode == NP_FORCE_SPELL)
        return (DEGENERATE);

    /*  CANNOT HAVE UNSPECIFIED SYMBOLS, OR ANY MORE THAN ONE OF EACH OF THE
     FOLLOWING:  . $ % + / ( ) blank  */
    if (degenerate || mydecimal > 1 || dollar > 1 || percent > 1 ||
        positive > 1 || slash > 1 || left_paren > 1 ||
        right_paren > 1 || blank > 1)
        return (DEGENERATE);


    /*  CHECK FOR TOO MANY DIGITS WHEN COMMAS OR ORDINAL USED  */
    if ((integer_digits > (TRIADS_MAX * 3)) && (commas || ordinal))
        return (DEGENERATE);

    /*  MAKE SURE % SIGN AT FAR RIGHT AND THAT THERE IS NO $ SIGN  */
    if (percent && ((percent_pos != (word_length - 1)) || dollar))
        return (DEGENERATE);

    /*  THE + SIGN MUST BE AT THE FAR LEFT OF THE STRING  */
    if (positive && (positive_pos != 0))
        return (DEGENERATE);

    /*  IF 1 OR MORE (-) SIGNS USED,  MAKE SURE IT IS AT FAR LEFT,
     OR THAT THE NUMBER CORRESPONDS TO STANDARD TELEPHONE FORMATS  */
    if ((negative == 1) && (negative_pos[0] != 0)) {
        if ((integer_digits == 7) && (negative_pos[0] == 3) &&
            (word_length == 8))
            telephone = SEVEN_DIGIT_CODE;
        else if ((negative_pos[0] == 9) && (left_paren_pos == 0) &&
                 (right_paren_pos == 4) && (blank_pos == 5) &&
                 (word_length == 14) && (integer_digits == 10))
            telephone = AREA_CODE;
        else if ((negative_pos[0] == 8) && (left_paren_pos == 0) &&
                 (right_paren_pos == 4) && (word_length == 13) &&
                 (integer_digits == 10))
            telephone = AREA_CODE;
        else
            return (DEGENERATE);
    } else if (negative == 2) {
        if ((integer_digits == 10) && (negative_pos[0] == 3) &&
            (negative_pos[1] == 7) && (word_length == 12))
            telephone = TEN_DIGIT_CODE;
        else
            return (DEGENERATE);
    } else if (negative == 3) {
        if ((integer_digits == 11) && (negative_pos[0] == 1) &&
            (negative_pos[1] == 5) && (negative_pos[2] == 9) &&
            (word_length == 14))
            telephone = ELEVEN_DIGIT_CODE;
        else
            return (DEGENERATE);
    }

    /*  THE ")", "(", AND blank CHARACTERS LEGAL ONLY WHEN AREA CODE  */
    if ((left_paren || right_paren || blank) && (telephone != AREA_CODE))
        return (DEGENERATE);

    /*  LEFT ZERO PADS ARE LEGAL ONLY WHEN ONE INTEGER DIGIT, OR IN
     CLOCK TIMES AND TELEPHONE NUMBERS  */
    if (left_zero_pad && (integer_digits > 1) && (!myclock) && (!telephone))
        return (DEGENERATE);

    if (slash) {
        /*  IF FRACTION, CHECK FOR TOO MANY DIGITS IN NUMERATOR OR DENOMINATOR  */
        if ((integer_digits > (TRIADS_MAX * 3)) || (fractional_digits > (TRIADS_MAX * 3)))
            return (DEGENERATE);

        /*  IN FRACTIONS, LEFT ZERO PADS ARE LEGAL ONLY WHEN ONE DIGIT  */
        if (frac_left_zero_pad && (fractional_digits > 1))
            return (DEGENERATE);

        /*  FRACTIONS MUST HAVE DIGITS IN BOTH NUMERATOR AND DENOMINATOR,
         AND CANNOT CONTAIN THE . $ , : SIGNS, OR ORDINAL SUFFIXES  */
        if ((!integer_digits) || (!fractional_digits) ||
            mydecimal || dollar || commas || myclock || ordinal)
            return (DEGENERATE);
    }

    /*  CHECK FOR LEGAL CLOCK TIME FORMATS;  FILL hour AND minute AND second BUFFERS  */
    if (myclock) {
        hour[0] = minute[0] = second[0] = '0';
        hour[3] = minute[3] = second[3] = '\0';
        if (integer_digits == 3) {
            if ((word_length != 4) || (myclock_pos[0] != 1))
                return (DEGENERATE);
            hour[1] = '0';
            hour[2] = word[integer_digits_pos[0]];
            minute[1] = word[integer_digits_pos[1]];
            minute[2] = word[integer_digits_pos[2]];
            seconds = NP_NO;
        } else if (integer_digits == 4) {
            if ((word_length != 5) || (myclock_pos[0] != 2))
                return (DEGENERATE);
            hour[1] = word[integer_digits_pos[0]];
            hour[2] = word[integer_digits_pos[1]];
            minute[1] = word[integer_digits_pos[2]];
            minute[2] = word[integer_digits_pos[3]];
            seconds = NP_NO;
        } else if (integer_digits == 5) {
            if ((word_length != 7) || (myclock_pos[0] != 1) || (myclock_pos[1] != 4))
                return (DEGENERATE);
            hour[1] = '0';
            hour[2] = word[integer_digits_pos[0]];
            minute[1] = word[integer_digits_pos[1]];
            minute[2] = word[integer_digits_pos[2]];
            second[1] = word[integer_digits_pos[3]];
            second[2] = word[integer_digits_pos[4]];
            seconds = NP_YES;
        } else if (integer_digits == 6) {
            if ((word_length != 8) || (myclock_pos[0] != 2) || (myclock_pos[1] != 5))
                return (DEGENERATE);
            hour[1] = word[integer_digits_pos[0]];
            hour[2] = word[integer_digits_pos[1]];
            minute[1] = word[integer_digits_pos[2]];
            minute[2] = word[integer_digits_pos[3]];
            second[1] = word[integer_digits_pos[4]];
            second[2] = word[integer_digits_pos[5]];
            seconds = NP_YES;
        } else
            return (DEGENERATE);
        {
            int minutes = 0, hours = 0, secs = 0;
            minutes = atoi(minute);
            hours = atoi(hour);
            if (seconds)
                secs = atoi(second);
            if (hours > 24 || minutes > 59 || secs > 59)
                return (DEGENERATE);
            military = (hours >= 1 && hours <= 12 && (!left_zero_pad)) ? NP_NO : NP_YES;
        }
    }

    /*  CHECK THAT COMMAS ARE PROPERLY SPACED  */
    if (commas) {
        if (commas_pos[0] < integer_digits_pos[0])
            return (DEGENERATE);
        for (i = 0; i < (commas - 1); i++) {
            if (commas_pos[i + 1] != (commas_pos[i] + 4))
                return (DEGENERATE);
        }
        if (mydecimal && (mydecimal_pos != (commas_pos[commas - 1] + 4)))
            return (DEGENERATE);
        if (integer_digits_pos[integer_digits - 1] != (commas_pos[commas - 1] + 3))
            return (DEGENERATE);
        if ((integer_digits_pos[0] + 3) < commas_pos[0])
            return (DEGENERATE);
    }

    /*  CHECK FOR LEGAL USE OF $ SIGN
     DETERMINE IF DOLLARS AND CENTS ARE PLURAL AND NONZERO  */
    if (dollar) {
        if ((negative || positive) && (dollar_pos != 1))
            return (DEGENERATE);
        if ((!negative) && (!positive) && (dollar_pos != 0))
            return (DEGENERATE);
        for (i = integer_digits - 1, dollar_plural = dollar_nonzero = NP_NO;
             i >= 0; i--) {
            if (word[integer_digits_pos[i]] >= '1') {
                dollar_nonzero = NP_YES;
                if (i == (integer_digits - 1) &&
                    (word[integer_digits_pos[i]] >= '2')) {
                    dollar_plural = NP_YES;
                    break;
                } else if (i < (integer_digits - 1)) {
                    dollar_plural = NP_YES;
                    break;
                }
            }
        }
        for (i = 0, cents_plural = NP_YES, cents_nonzero = NP_NO;
             i < fractional_digits; i++) {
            if (word[fractional_digits_pos[i]] >= '1') {
                cents_nonzero = NP_YES;
                break;
            }
        }
        if ((fractional_digits == 2) && (word[fractional_digits_pos[0]] == '0')
            && (word[fractional_digits_pos[1]] == '1'))
            cents_plural = NP_NO;
        if ((!dollar_nonzero) && (!cents_nonzero) && (positive || negative))
            return (DEGENERATE);
    }

    /*  CHECK FOR LEGAL USE OF ORDINAL SUFFIXES  */
    if (ordinal) {
        char ones_digit = '\0', tens_digit = '\0';

        ones_digit = word[integer_digits_pos[integer_digits - 1]];
        if (integer_digits >= 2)
            tens_digit = word[integer_digits_pos[integer_digits - 2]];

        if ((ordinal != 2) || (!integer_digits) ||
            mydecimal || dollar || percent)
            return (DEGENERATE);

        if ((ordinal_pos[0] != (word_length - 2)) ||
            (ordinal_pos[1] != (word_length - 1)))
            return (DEGENERATE);

        if (!strcmp(ordinal_buffer, "ST")) {
            if ((ones_digit != '1') || (tens_digit == '1'))
                return (DEGENERATE);
        } else if (!strcmp(ordinal_buffer, "ND")) {
            if ((ones_digit != '2') || (tens_digit == '1'))
                return (DEGENERATE);
        } else if (!strcmp(ordinal_buffer, "RD")) {
            if ((ones_digit != '3') || (tens_digit == '1'))
                return (DEGENERATE);
        } else if (!strcmp(ordinal_buffer, "TH")) {
            if (((ones_digit == '1') || (ones_digit == '2') ||
                 (ones_digit == '3')) && (tens_digit != '1'))
                return (DEGENERATE);
        } else
            return (DEGENERATE);
    }

    /*  IF WE GET THIS FAR, THEN THE NUMBER CAN BE PROCESSED NORMALLY  */
    return (OK);
}



/******************************************************************************
 *
 *      purpose:        Processes the the input string pointed at by word
 *                       and returns a pointer to a NULL terminated string
 *                       which contains the corresponding pronunciation.
 *
 ******************************************************************************/

char *process_word(int mode)
{
    long i;

    /*  SPECIAL PROCESSING OF WORD;  EACH RETURNS IMMEDIATELY  */
    /*  PROCESS CLOCK TIMES  */
    if (myclock) {
        /*  HOUR  */
        if (left_zero_pad)
            strcat(output, OH);
        process_triad(hour, output, NP_NO, NP_NO, NP_NO, NP_NO, NP_NO);
        /*  MINUTE  */
        if ((minute[1] == '0') && (minute[2] == '0')) {
            if (military)
                strcat(output, HUNDRED);
            else if (!seconds)
                strcat(output, OCLOCK);
        } else {
            if ((minute[1] == '0') && (minute[2] != '0'))
                strcat(output, OH);
            process_triad(minute, output, NP_NO, NP_NO, NP_NO, NP_NO, NP_NO);
        }
        /*  SECOND  */
        if (seconds) {
            strcat(output, AND);
            if ((second[1] == '0') && (second[2] == '0'))
                strcat(output, ZERO);
            else
                process_triad(second, output, NP_NO, NP_NO, NP_NO, NP_NO, NP_NO);

            if ((second[1] == '0') && (second[2] == '1'))
                strcat(output, SECOND);
            else
                strcat(output, SECONDS);
        }
        return (output);
    }
    /*  PROCESS TELEPHONE NUMBERS  */
    if (telephone == SEVEN_DIGIT_CODE) {
        for (i = 0; i < 3; i++)
            process_digit(*(word + (*(integer_digits_pos + i))), output, NP_NO, NP_NO, NP_NO);
        strcat(output, PAUSE);
        for (i = 3; i < 7; i++)
            process_digit(*(word + (*(integer_digits_pos + i))), output, NP_NO, NP_NO, NP_NO);
        return (output);
    } else if (telephone == TEN_DIGIT_CODE) {
        for (i = 0; i < 3; i++)
            process_digit(*(word + (*(integer_digits_pos + i))), output, NP_NO, NP_NO, NP_NO);
        strcat(output, PAUSE);
        for (i = 3; i < 6; i++)
            process_digit(*(word + (*(integer_digits_pos + i))), output, NP_NO, NP_NO, NP_NO);
        strcat(output, PAUSE);
        for (i = 6; i < 10; i++)
            process_digit(*(word + (*(integer_digits_pos + i))), output, NP_NO, NP_NO, NP_NO);
        return (output);
    } else if (telephone == ELEVEN_DIGIT_CODE) {
        process_digit(word[integer_digits_pos[0]], output, NP_NO, NP_NO, NP_NO);
        if ((word[integer_digits_pos[1]] != '0') &&
            (word[integer_digits_pos[2]] == '0') &&
            (word[integer_digits_pos[3]] == '0')) {
            process_digit(word[integer_digits_pos[1]], output, NP_NO, NP_NO, NP_NO);
            strcat(output, HUNDRED);
        } else {
            strcat(output, PAUSE);
            for (i = 1; i < 4; i++)
                process_digit(*(word + (*(integer_digits_pos + i))), output, NP_NO, NP_NO, NP_NO);
        }
        strcat(output, PAUSE);
        for (i = 4; i < 7; i++)
            process_digit(*(word + (*(integer_digits_pos + i))), output, NP_NO, NP_NO, NP_NO);
        strcat(output, PAUSE);
        for (i = 7; i < 11; i++)
            process_digit(*(word + (*(integer_digits_pos + i))), output, NP_NO, NP_NO, NP_NO);
        return (output);
    } else if (telephone == AREA_CODE) {
        strcat(output, AREA);
        strcat(output, CODE);
        for (i = 0; i < 3; i++)
            process_digit(*(word + (*(integer_digits_pos + i))), output, NP_NO, NP_NO, NP_NO);
        strcat(output, PAUSE);
        for (i = 3; i < 6; i++)
            process_digit(*(word + (*(integer_digits_pos + i))), output, NP_NO, NP_NO, NP_NO);
        strcat(output, PAUSE);
        for (i = 6; i < 10; i++)
            process_digit(*(word + (*(integer_digits_pos + i))), output, NP_NO, NP_NO, NP_NO);
        return (output);
    }
    /*  PROCESS ZERO DOLLARS AND ZERO CENTS  */
    if (dollar && (!dollar_nonzero) && (!cents_nonzero)) {
        strcat(output, ZERO);
        strcat(output, DOLLARS);
        return (output);
    }
    /*  PROCESS FOR YEAR IF INTEGER IN RANGE 1000 TO 1999  */
    if ((integer_digits == 4) && (word_length == 4) &&
        (word[integer_digits_pos[0]] == '1') && (mode != NP_OVERRIDE_YEARS)) {
        triad[0] = '0';
        triad[1] = word[integer_digits_pos[0]];
        triad[2] = word[integer_digits_pos[1]];
        process_triad(triad, output, NP_NO, NP_NO, NP_NO, NP_NO, NP_NO);
        if ((word[integer_digits_pos[2]] == '0') &&
            (word[integer_digits_pos[3]] == '0'))
            strcat(output, HUNDRED);
        else if (word[integer_digits_pos[2]] == '0') {
            strcat(output, OH);
            process_digit(word[integer_digits_pos[3]], output, NP_NO, NP_NO, NP_NO);
        } else {
            triad[0] = '0';
            triad[1] = word[integer_digits_pos[2]];
            triad[2] = word[integer_digits_pos[3]];
            process_triad(triad, output, NP_NO, NP_NO, NP_NO, NP_NO, NP_NO);
        }
        return (output);
    }


    /*  ORDINARY SEQUENTIAL PROCESSING  */
    /*  APPEND POSITIVE OR NEGATIVE IF INDICATED  */
    if (positive)
        strcat(output, POSITIVE);
    else if (negative)
        strcat(output, NEGATIVE);

    /*  PROCESS SINGLE INTEGER DIGIT  */
    if (integer_digits == 1) {
        if ((word[integer_digits_pos[0]] == '0') && dollar)
            ;
        else
            process_digit(word[integer_digits_pos[0]], output, ordinal, NP_NO, NP_NO);
        ordinal_plural = (word[integer_digits_pos[0]] == '1') ? NP_NO : NP_YES;
    }
    /*  PROCESS INTEGERS AS TRIADS, UP TO MAX LENGTH  */
    else if ((integer_digits >= 2) && (integer_digits <= (TRIADS_MAX * 3))) {
        long digit_index = 0, num_digits, triad_index, index, pause_flag = NP_NO;
        for (i = 0; i < 3; i++)
            triad[i] = '0';
        index = (int)((integer_digits - 1) / 3.0);
        num_digits = integer_digits - (index * 3);
        triad_index = 3 - num_digits;

        for (i = index; i >= 0; i--) {
            while (num_digits--)
                triad[triad_index++] = word[integer_digits_pos[digit_index++]];

            if (process_triad(triad, output, pause_flag,
                              (ordinal && (ordinal_triad == i)),
                              right_zero_pad, NP_NO, NP_NO) == NONZERO) {
                if (ordinal && (ordinal_triad == i))
                    strcat(output, triad_name[1][i]);
                else
                    strcat(output, triad_name[0][i]);
                pause_flag = NP_YES;
            }
            if ((i == 1) && (word[integer_digits_pos[digit_index]] == '0') &&
                ((word[integer_digits_pos[digit_index + 1]] != '0') ||
                 (word[integer_digits_pos[digit_index + 2]] != '0'))) {
                    strcat(output, AND);
                    pause_flag = NP_NO;
                }
            triad_index = 0;
            num_digits = 3;
        }
    }
    /*  PROCESS EXTREMELY LARGE NUMBERS AS STREAM OF SINGLE DIGITS  */
    else if ((integer_digits > (TRIADS_MAX * 3)) && (!commas) && (!ordinal)) {
        for (i = 0; i < integer_digits; i++)
            process_digit(*(word + (*(integer_digits_pos + i))), output, NP_NO, NP_NO, NP_NO);
    }

    /*  APPEND DOLLAR OR DOLLARS IF NEEDED  */
    if (dollar && dollar_nonzero) {
        if (fractional_digits && (fractional_digits != 2))
            ;
        else if (dollar_plural)
            strcat(output, DOLLARS);
        else if (!dollar_plural)
            strcat(output, DOLLAR);
        if (cents_nonzero && (fractional_digits == 2))
            strcat(output, AND);
    }

    /*  APPEND POINT IF FRACTIONAL DIGITS, NO SLASH,
     AND IF NOT .00 DOLLAR FORMAT  */
    if (fractional_digits && (!slash) &&
        ((!dollar) || (dollar && (fractional_digits != 2)))) {
        strcat(output, POINT);
        for (i = 0; i < fractional_digits; i++)
            process_digit(word[fractional_digits_pos[i]], output, NP_NO, NP_NO, NP_NO);
    }
    /*  PROCESS DENOMINATOR OF FRACTIONS  */
    else if (slash) {
        char ones_digit = '\0', tens_digit = '\0';
        long  special_flag;

        if (((integer_digits >= 3) && (fractional_digits >= 3)) ||
            (word[integer_digits_pos[integer_digits - 1]] == '0'))
            strcat(output, PAUSE);

        ones_digit = word[fractional_digits_pos[fractional_digits - 1]];
        if (fractional_digits >= 2)
            tens_digit = word[fractional_digits_pos[fractional_digits - 2]];

        ordinal = NP_YES;
        special_flag = NP_NO;
        if ((ones_digit == '0' && tens_digit == '\0') ||
            (ones_digit == '1' && tens_digit != '1')) {
            strcat(output, OVER);
            ordinal = ordinal_plural = NP_NO;
        } else if (ones_digit == '2') {
            if (tens_digit == '\0')
                special_flag = HALF_FLAG;
            else if (tens_digit != '1')
                special_flag = SECONDTH_FLAG;
        } else if (ones_digit == '4' && tens_digit == '\0')
            special_flag = QUARTER_FLAG;

        if (fractional_digits == 1)
            process_digit(ones_digit, output, ordinal,
                          ordinal_plural, special_flag);
        else if (fractional_digits >= 2 &&
                 (fractional_digits <= (TRIADS_MAX * 3))) {
            long digit_index = 0, num_digits, triad_index,
            index, pause_flag = NP_NO;
            for (i = 0; i < 3; i++)
                triad[i] = '0';
            index = (int)((fractional_digits - 1) / 3.0);
            num_digits = fractional_digits - (index * 3);
            triad_index = 3 - num_digits;

            for (i = index; i >= 0; i--) {
                while (num_digits--)
                    triad[triad_index++] =
                    word[fractional_digits_pos[digit_index++]];

                if (process_triad(triad, output, pause_flag,
                                  (ordinal && (frac_ordinal_triad == i)),
                                  frac_right_zero_pad,
                                  (ordinal_plural && (frac_ordinal_triad == i)),
                                  (special_flag && (frac_ordinal_triad == i))) == NONZERO) {
                    if (ordinal_plural && (frac_ordinal_triad == i))
                        strcat(output, triad_name[2][i]);
                    else if (ordinal && (frac_ordinal_triad == i))
                        strcat(output, triad_name[1][i]);
                    else
                        strcat(output, triad_name[0][i]);
                    pause_flag = NP_YES;
                }
                if ((i == 1) &&
                    (word[fractional_digits_pos[digit_index]] == '0') &&
                    ((word[fractional_digits_pos[digit_index + 1]] != '0') ||
                     (word[fractional_digits_pos[digit_index + 2]] != '0'))) {
                        strcat(output, AND);
                        pause_flag = NP_NO;
                    }
                triad_index = 0;
                num_digits = 3;
            }
        }
    }
    /*  APPEND CENTS  */
    else if (dollar && cents_nonzero && (fractional_digits == 2)) {
        triad[0] = '0';
        triad[1] = word[fractional_digits_pos[0]];
        triad[2] = word[fractional_digits_pos[1]];
        if (process_triad(triad, output, NP_NO, NP_NO, NP_NO, NP_NO, NP_NO) == NONZERO) {
            if (cents_plural)
                strcat(output, CENTS);
            else
                strcat(output, CENT);
        }
    }

    /*  APPEND DOLLARS IF NOT $.00 FORMAT  */
    if (dollar && fractional_digits && (fractional_digits != 2))
        strcat(output, DOLLARS);

    /*  APPEND PERCENT IF NECESSARY  */
    if (percent)
        strcat(output, PERCENT);

    /*  RETURN OUTPUT TO CALLER  */
    return (output);
}



/******************************************************************************
 *
 *      purpose:        Returns a pointer to a NULL terminated string which
 *                       contains a character-by-character pronunciation for
 *                       the NULL terminated character string pointed at by
 *                       the argument word.
 *
 ******************************************************************************/

char *degenerate_string(const char *word)
{
    long word_length, i;

    /*  APPEND NULL BYTE TO OUTPUT;  DETERMINE WORD LENGTH  */
    output[0] = '\0';
    word_length = strlen(word);

    /*  APPEND PROPER PRONUNCIATION FOR EACH CHARACTER  */
    for (i = 0; i < word_length; i++) {
        switch (*(word+i)) {
            case ' ': strcat(output, BLANK);           break;
            case '!': strcat(output, EXCLAMATION_POINT);   break;
            case '"': strcat(output, DOUBLE_QUOTE);        break;
            case '#': strcat(output, NUMBER_SIGN);         break;
            case '$': strcat(output, DOLLAR_SIGN);             break;
            case '%': strcat(output, PERCENT_SIGN);            break;
            case '&': strcat(output, AMPERSAND);               break;
            case '\'':strcat(output, SINGLE_QUOTE);        break;
            case '(': strcat(output, OPEN_PARENTHESIS);    break;
            case ')': strcat(output, CLOSE_PARENTHESIS);   break;
            case '*': strcat(output, ASTERISK);        break;
            case '+': strcat(output, PLUS_SIGN);               break;
            case ',': strcat(output, COMMA);           break;
            case '-': strcat(output, HYPHEN);          break;
            case '.': strcat(output, PERIOD);          break;
            case '/': strcat(output, SLASH);           break;
            case '0': strcat(output, ZERO);                    break;
            case '1': strcat(output, ONE);                     break;
            case '2': strcat(output, TWO);             break;
            case '3': strcat(output, THREE);           break;
            case '4': strcat(output, FOUR);                    break;
            case '5': strcat(output, FIVE);                break;
            case '6': strcat(output, SIX);                     break;
            case '7': strcat(output, SEVEN);           break;
            case '8': strcat(output, EIGHT);           break;
            case '9': strcat(output, NINE);                    break;
            case ':': strcat(output, COLON);           break;
            case ';': strcat(output, SEMICOLON);               break;
            case '<': strcat(output, OPEN_ANGLE_BRACKET);  break;
            case '=': strcat(output, EQUAL_SIGN);              break;
            case '>': strcat(output, CLOSE_ANGLE_BRACKET); break;
            case '?': strcat(output, QUESTION_MARK);       break;
            case '@': strcat(output, AT_SIGN);         break;
            case 'A':
            case 'a': strcat(output, A);                       break;
            case 'B':
            case 'b': strcat(output, B);                       break;
            case 'C':
            case 'c': strcat(output, C);                       break;
            case 'D':
            case 'd': strcat(output, D);                       break;
            case 'E':
            case 'e': strcat(output, E);                       break;
            case 'F':
            case 'f': strcat(output, F);                       break;
            case 'G':
            case 'g': strcat(output, G);                       break;
            case 'H':
            case 'h': strcat(output, H);                       break;
            case 'I':
            case 'i': strcat(output, I);                       break;
            case 'J':
            case 'j': strcat(output, J);                       break;
            case 'K':
            case 'k': strcat(output, K);                       break;
            case 'L':
            case 'l': strcat(output, L);                       break;
            case 'M':
            case 'm': strcat(output, M);                       break;
            case 'N':
            case 'n': strcat(output, N);                       break;
            case 'O':
            case 'o': strcat(output, O);                       break;
            case 'P':
            case 'p': strcat(output, P);                       break;
            case 'Q':
            case 'q': strcat(output, Q);                       break;
            case 'R':
            case 'r': strcat(output, R);                       break;
            case 'S':
            case 's': strcat(output, S);                       break;
            case 'T':
            case 't': strcat(output, T);                       break;
            case 'U':
            case 'u': strcat(output, U);                       break;
            case 'V':
            case 'v': strcat(output, V);                       break;
            case 'W':
            case 'w': strcat(output, W);                       break;
            case 'X':
            case 'x': strcat(output, X);                       break;
            case 'Y':
            case 'y': strcat(output, Y);                       break;
            case 'Z':
            case 'z': strcat(output, Z);                       break;
            case '[': strcat(output, OPEN_SQUARE_BRACKET); break;
            case '\\':strcat(output, BACKSLASH);               break;
            case ']': strcat(output, CLOSE_SQUARE_BRACKET);break;
            case '^': strcat(output, CARET);           break;
            case '_': strcat(output, UNDERSCORE);              break;
            case '`': strcat(output, GRAVE_ACCENT);            break;
            case '{': strcat(output, OPEN_BRACE);          break;
            case '|': strcat(output, VERTICAL_BAR);            break;
            case '}': strcat(output, CLOSE_BRACE);         break;
            case '~': strcat(output, TILDE);           break;
            default:  strcat(output, UNKNOWN);         break;
        }
    }
    return (output);
}



/******************************************************************************
 *
 *      purpose:        Appends to output the appropriate pronunciation for the
 *                       input triad (i.e. hundreds, tens, and ones).  If the
 *                       pause flag is set, then a pause is inserted before the
 *                       triad proper.  If the ordinal flag is set, ordinal
 *                       pronunciations are used.  If the ordinal_plural flag is
 *                       set, then plural ordinal pronunciations are used.  The
 *                       special flag is not used in this function, but is
 *                       passed on to the process_digit() function.  The
 *                       right_zero_pad is the pad for the whole word being
 *                       parsed, NOT the pad for the input triad.
 *
 ******************************************************************************/

int process_triad(char *triad, char *output, int pause, int ordinal, int right_zero_pad, int ordinal_plural, int special_flag)
{
    /*  IF TRIAD IS 000, RETURN ZERO  */
    if ((*(triad) == '0') && (*(triad+1) == '0') && (*(triad+2) == '0'))
        return (0);

    /*  APPEND PAUSE IF FLAG SET  */
    if (pause)
        strcat(output, PAUSE);

    /*  PROCESS HUNDREDS  */
        if (*(triad) >= '1') {
            process_digit(*(triad), output, NP_NO, NP_NO, NP_NO);
            if (ordinal_plural && (right_zero_pad == 2))
                strcat(output, HUNDREDTHS);
            else if (ordinal && (right_zero_pad == 2))
                strcat(output, HUNDREDTH);
            else
                strcat(output, HUNDRED);
            if ((*(triad+1) != '0') || (*(triad+2) != '0'))
                strcat(output, AND);
        }

    /*  PROCESS TENS  */
    if (*(triad+1) == '1') {
        if (ordinal_plural && (right_zero_pad == 1) && (*(triad + 2) == '0'))
            strcat(output, TENTHS);
        else if (ordinal && (right_zero_pad == 1) && (*(triad + 2) == '0'))
            strcat(output, TENTH);
        else if (ordinal_plural && (right_zero_pad == 0)) {
            switch (*(triad + 2)) {
                case '1':       strcat(output, ELEVENTHS);      break;
                case '2':       strcat(output, TWELFTHS);       break;
                case '3':       strcat(output, THIRTEENTHS);    break;
                case '4':       strcat(output, FOURTEENTHS);    break;
                case '5':       strcat(output, FIFTEENTHS);     break;
                case '6':       strcat(output, SIXTEENTHS);     break;
                case '7':       strcat(output, SEVENTEENTHS);   break;
                case '8':       strcat(output, EIGHTEENTHS);    break;
                case '9':       strcat(output, NINETEENTHS);    break;
            }
        } else if (ordinal && (right_zero_pad == 0)) {
            switch (*(triad+2)) {
                case '1':       strcat(output, ELEVENTH);       break;
                case '2':       strcat(output, TWELFTH);        break;
                case '3':       strcat(output, THIRTEENTH);     break;
                case '4':       strcat(output, FOURTEENTH);     break;
                case '5':       strcat(output, FIFTEENTH);      break;
                case '6':       strcat(output, SIXTEENTH);      break;
                case '7':       strcat(output, SEVENTEENTH);    break;
                case '8':       strcat(output, EIGHTEENTH);     break;
                case '9':       strcat(output, NINETEENTH);     break;
            }
        } else {
            switch (*(triad+2)) {
                case '0':       strcat(output, TEN);            break;
                case '1':       strcat(output, ELEVEN);         break;
                case '2':       strcat(output, TWELVE);         break;
                case '3':       strcat(output, THIRTEEN);       break;
                case '4':       strcat(output, FOURTEEN);       break;
                case '5':       strcat(output, FIFTEEN);        break;
                case '6':       strcat(output, SIXTEEN);        break;
                case '7':       strcat(output, SEVENTEEN);      break;
                case '8':       strcat(output, EIGHTEEN);       break;
                case '9':       strcat(output, NINETEEN);       break;
            }
        }
    } else if (*(triad+1) >= '2') {
        if (ordinal_plural && (right_zero_pad == 1)) {
            switch (*(triad+1)) {
                case '2':       strcat(output, TWENTIETHS);     break;
                case '3':       strcat(output, THIRTIETHS);     break;
                case '4':       strcat(output, FORTIETHS);      break;
                case '5':       strcat(output, FIFTIETHS);      break;
                case '6':       strcat(output, SIXTIETHS);      break;
                case '7':       strcat(output, SEVENTIETHS);    break;
                case '8':       strcat(output, EIGHTIETHS);     break;
                case '9':       strcat(output, NINETIETHS);     break;
            }
        } else if (ordinal && (right_zero_pad == 1)) {
            switch (*(triad+1)) {
                case '2':       strcat(output, TWENTIETH);      break;
                case '3':       strcat(output, THIRTIETH);      break;
                case '4':       strcat(output, FORTIETH);       break;
                case '5':       strcat(output, FIFTIETH);       break;
                case '6':       strcat(output, SIXTIETH);       break;
                case '7':       strcat(output, SEVENTIETH);     break;
                case '8':       strcat(output, EIGHTIETH);      break;
                case '9':       strcat(output, NINETIETH);      break;
            }
        } else {
            switch (*(triad+1)) {
                case '2':       strcat(output, TWENTY);         break;
                case '3':       strcat(output, THIRTY);         break;
                case '4':       strcat(output, FORTY);          break;
                case '5':       strcat(output, FIFTY);          break;
                case '6':       strcat(output, SIXTY);          break;
                case '7':       strcat(output, SEVENTY);        break;
                case '8':       strcat(output, EIGHTY);         break;
                case '9':       strcat(output, NINETY);         break;
            }
        }
    }
    /*  PROCESS ONES  */
    if (*(triad + 1) != '1' && *(triad + 2) >= '1') {
        process_digit(*(triad + 2), output, (ordinal && (right_zero_pad == 0)),
                      (ordinal_plural && (right_zero_pad == 0)), special_flag);
    }
    
    /*  RETURN WITH NONZERO VALUE  */
    return (NONZERO);
}



/******************************************************************************
 *
 *      purpose:        Appends to output the pronunciation for the input
 *                       digit.  If the special_flag is set, the appropriate
 *                       special pronunciation is used.  If the ordinal_plural
 *                       flag is set, the plural ordinal pronunciations are
 *                       used.  If the ordinal flag is set, ordinal 
 *                       pronunciations are used.  Otherwise standard digit
 *                       pronunciations are used.
 *
 ******************************************************************************/

void process_digit(char digit, char *output, int ordinal, int ordinal_plural, int special_flag)
{
    /*  DO SPECIAL PROCESSING IF FLAG SET  */
    if (special_flag == HALF_FLAG) {
        if (ordinal_plural)
            strcat(output, HALVES);
        else
            strcat(output, HALF);
    } else if (special_flag == SECONDTH_FLAG) {
        if (ordinal_plural)
            strcat(output, SECONDTHS);
        else
            strcat(output, SECONDTH);
    } else if (special_flag == QUARTER_FLAG) {
        if (ordinal_plural)
            strcat(output, QUARTERS);
        else
            strcat(output, QUARTER);
    }
    /*  DO PLURAL ORDINALS  */
    else if (ordinal_plural) {
        switch (digit) {
            case '3':    strcat(output, THIRDS);            break;
            case '4':    strcat(output, FOURTHS);           break;
            case '5':    strcat(output, FIFTHS);            break;
            case '6':    strcat(output, SIXTHS);            break;
            case '7':    strcat(output, SEVENTHS);          break;
            case '8':    strcat(output, EIGHTHS);           break;
            case '9':    strcat(output, NINTHS);            break;
        }
    }
    /*  DO SINGULAR ORDINALS  */
    else if (ordinal) {
        switch (digit) {
            case '0':    strcat(output, ZEROETH);           break;
            case '1':    strcat(output, FIRST);     break;
            case '2':    strcat(output, SECOND);            break;
            case '3':    strcat(output, THIRD);     break;
            case '4':    strcat(output, FOURTH);            break;
            case '5':    strcat(output, FIFTH);     break;
            case '6':    strcat(output, SIXTH);     break;
            case '7':    strcat(output, SEVENTH);           break;
            case '8':    strcat(output, EIGHTH);            break;
            case '9':    strcat(output, NINTH);     break;
        }
    }
    /*  DO ORDINARY DIGITS  */
    else {
        switch (digit) {
            case '0':    strcat(output, ZERO);      break;
            case '1':    strcat(output, ONE);       break;
            case '2':    strcat(output, TWO);       break;
            case '3':    strcat(output, THREE);     break;
            case '4':    strcat(output, FOUR);      break;
            case '5':    strcat(output, FIVE);      break;
            case '6':    strcat(output, SIX);       break;
            case '7':    strcat(output, SEVEN);     break;
            case '8':    strcat(output, EIGHT);     break;
            case '9':    strcat(output, NINE);      break;
        }
    }
}
