//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "letter_to_sound_private.h"
#import "number_pronunciations.h"
#import <strings.h>


/*  LOCAL DEFINES  ***********************************************************/
#define SPELL_STRING_LEN   8192


/*  GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ***********************************/
static int spell_it(char *word);
static int all_caps(char *in);


/*  GLOBAL VARIABLES (LOCAL TO THIS FILE)  ***********************************/
static char spell_string[SPELL_STRING_LEN];
static char *letters[] = {
    BLANK, EXCLAMATION_POINT, DOUBLE_QUOTE, NUMBER_SIGN, DOLLAR_SIGN,
    PERCENT_SIGN, AMPERSAND, SINGLE_QUOTE, OPEN_PARENTHESIS, CLOSE_PARENTHESIS,
    ASTERISK, PLUS_SIGN, COMMA, HYPHEN, PERIOD, SLASH,
    ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE,
    COLON, SEMICOLON, OPEN_ANGLE_BRACKET, EQUAL_SIGN, CLOSE_ANGLE_BRACKET,
    QUESTION_MARK, AT_SIGN,
    A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
    OPEN_SQUARE_BRACKET, BACKSLASH, CLOSE_SQUARE_BRACKET, CARET, UNDERSCORE,
    GRAVE_ACCENT,
    A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
    OPEN_BRACE, VERTICAL_BAR, CLOSE_BRACE, TILDE, UNKNOWN
};

int word_to_patphone(char *word)
{
    char                *end_of_word;
    register char       replace_s = 0;


    /*  FIND END OF WORD  */
    end_of_word = word + 1;
    while (*end_of_word != '#')
        end_of_word++;

    /*  IF NO LITTLE LETTERS SPELL THE WORD  */
    if (all_caps(word))
        return(spell_it(word));

    /*  IF SINGLE LETTER, SPELL IT  */
    if (end_of_word == (word + 2))
        return(spell_it(word));

    /*  IF NO VOWELS SPELL THE WORD  */
    if (!vowel_before(word, end_of_word))
        return(spell_it(word));

    /*  SEE IF IT IS IN THE EXCEPTION LIST  */
    if (check_word_list(word, &end_of_word)) {
        *++end_of_word = 0;
        return(1);
    }

    /*  KILL ANY TRAILING S  */
    replace_s = final_s(word, &end_of_word);

    /*  FLIP IE TO Y, IF ANY CHANGES RECHECK WORD LIST  */
    if (ie_to_y(word, &end_of_word) || replace_s)
    /*  IN WORD LIST NOW ALL DONE  */
        if (check_word_list(word, &end_of_word)) {   /* Will eliminate this as well */
            if (replace_s) {
                *++end_of_word = replace_s;            /* & 0x5f [source of problems] */
                *++end_of_word = '/';
            }
            *++end_of_word = 0;
            return(1);
        }

    mark_final_e(word, &end_of_word);
    long_medial_vowels(word, &end_of_word);
    medial_silent_e(word, &end_of_word);
    medial_s(word, &end_of_word);

    if (replace_s) {
        *end_of_word++ = replace_s;
        *end_of_word = '#';
    }
    *++end_of_word = 0;
    return(0);
}


static int spell_it(char *word)
{
    register char      *s = spell_string;
    register char      *t;
    char               *hold = word;

    /*  EAT THE '#'  */
    word++;

    do {
        if (*word < ' ') {
            if (*word == '\t')
                t = "'t_aa_b";
            else
                t = "'u_p_s";   /* (OOPS!) */
        } else
            t = letters[*word - ' '];
        word++;
        while (*t)
            *s++ = *t++;
    } while (*word != '#');

    *s = 0;

    strcpy(hold, spell_string);
    return(2);
}

static int all_caps(char *in)
{
    int                 all_up = 1;
    int                 force_up = 0;

    in++;
    if (*in == '#')
        force_up = 1;

    while (*in != '#') {
        if ((*in <= 'z') && (*in >= 'a'))
            all_up = 0;
        else if ((*in <= 'Z') && (*in >= 'A'))
            *in |= 0x20;
        else if (*in != '\'')
            force_up = 1;
        in++;
    }
    return (all_up || force_up);
}
