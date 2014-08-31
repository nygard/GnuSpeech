//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "letter_to_sound_private.h"
#import "number_pronunciations.h"
#import <strings.h>


/*  GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ***********************************/
static int spell_it(char *word);
static int all_caps(char *in);


/*  GLOBAL VARIABLES (LOCAL TO THIS FILE)  ***********************************/
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

/// This takes a word that is surrounded by '#'.  It performs steps 1-4(e) of McIlroy's rules.
///
/// @return 1 if the word was in the exception list.
/// @return 2 if this spelled the word.
/// @return 0 otherwise.

int word_to_patphone(char *word)
{
    fprintf(stderr, "word_to_patphone(%s)\n", word);
    char replace_s = 0;


    /*  FIND END OF WORD  */
    char *end_of_word = word + 1;
    while (*end_of_word != '#' && *end_of_word != 0)
    {
        end_of_word++;
    }

    /*  IF NO LITTLE LETTERS SPELL THE WORD  */
    // This also lowercases the word buffer.
    if (all_caps(word))
    {
        fprintf(stderr, "all caps, spelling it.\n");
        return spell_it(word);
    }

    /*  IF SINGLE LETTER, SPELL IT  */
    // Step 4(a)
    if (end_of_word == (word + 2))
    {
        fprintf(stderr, "single letter, spelling it\n");
        return spell_it(word);
    }

    /*  IF NO VOWELS SPELL THE WORD  */
    if (!vowel_before(word, end_of_word))
    {
        fprintf(stderr, "no vowels, spelling it\n");
        return spell_it(word);
    }

    // Step 1: See if the whole word is in the exception list.
    if (check_word_list(word, &end_of_word))
    {
        fprintf(stderr, "word is in exception list\n");
        *++end_of_word = 0;
        fprintf(stderr, "word is now: '%s'\n", word);
        return 1;
    }

    // Step 2: Map cpitals into small letters, strip punctuation, and try step 1 again.
    // Omitted?  Handled earlier?

    // Step 3: Strip trailing s.  Change final ie to y (regardless of trailing s).  Repeat step 1 if any changes.
    replace_s = final_s(word, &end_of_word);
    fprintf(stderr, "replace_s? %d, word now: '%s'\n", replace_s, word);

    /*  FLIP IE TO Y, IF ANY CHANGES RECHECK WORD LIST  */
    if (ie_to_y(word, &end_of_word) || replace_s)
    {
        fprintf(stderr, "changed ie to y: '%s', or replaced s.\n", word);

        /*  IN WORD LIST NOW ALL DONE  */
        if (check_word_list(word, &end_of_word))
        {
            fprintf(stderr, "updated word is in exception list\n");
            /* Will eliminate this as well */
            if (replace_s)
            {
                *++end_of_word = replace_s;            /* & 0x5f [source of problems] */
                *++end_of_word = '/';
            }
            *++end_of_word = 0;
            fprintf(stderr, "word is now: '%s'\n", word);
            return 1;
        }
    }

    // Step 4(a): Reject a word consisting of 1 letter or a word without a vowel.
    // ???

    // Step 4(b)?
    mark_final_e(word, &end_of_word);
    fprintf(stderr, "called mark_final_e(), word is now: '%s'\n", word);

    // Step 4(c)
    long_medial_vowels(word, &end_of_word);
    fprintf(stderr, "called long_medial_vowels(), word is now: '%s'\n", word);

    // Step 4(d)
    medial_silent_e(word, &end_of_word);
    fprintf(stderr, "called medial_silent_e(), word is now: '%s'\n", word);

    // Step 4(e)
    medial_s(word, end_of_word);
    fprintf(stderr, "called medial_s(), word is now: '%s'\n", word);

    if (replace_s) {
        *end_of_word++ = replace_s;
        *end_of_word = '#';
    }
    *++end_of_word = 0;
    fprintf(stderr, "about to return, word is now: '%s'\n", word);

    return 0;
}

/// Replace word with the pronunciation of the spelling.  No bounds checking is performed.
static int spell_it(char *word)
{
    static char spell_string[8192];
    char *s = spell_string;
    char *t;
    char *hold = word;

    // Skip the leading #.
    word++;

    do {
        if (*word < ' ') {
            if (*word == '\t')
                t = "'t_aa_b ";
            else
                t = "'u_p_s ";   /* (OOPS!) */
        } else
            t = letters[*word - ' '];
        word++;
        while (*t)
            *s++ = *t++;
    } while (*word != '#' && *word != 0);

    *s = 0;

    strcpy(hold, spell_string);

    return 2;
}

/// Modify input buffer, changing all uppercase letters to lowercase.
/// @return 1 if there were no lowercase letters, or if the input string was empty, or if the input string contained a non-alpha character (other than a single quote).
/// @return 0 otherwise.
static int all_caps(char *in)
{
    int all_up   = 1;
    int force_up = 0;

    in++;
    if (*in == '#')
        force_up = 1;

    while (*in != '#' && *in != 0) {
        if      ((*in <= 'z') && (*in >= 'a')) all_up = 0;
        else if ((*in <= 'Z') && (*in >= 'A')) *in |= 0x20;
        else if (*in != '\'')                  force_up = 1;
        in++;
    }

    return all_up || force_up;
}
