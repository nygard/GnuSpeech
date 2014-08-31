//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "letter_to_sound_private.h"

/// Strip trailing S'.  Check for a final s, strip it if found and return 's' or 'z' (depending on preceding character), or else return 0.
/// This appears to differ slightly from McIlroy's description.
/// @return 's', 'z', or 0.
char final_s(char *in, char **eow)
{
    char *end = *eow;
    char retval = 0;

    // Strip trailing letter S followed by apostrophe (S')
    if ((*(end - 1) == '\'') && (*(end - 2) == 's')) {
        *--end = '#';
        *eow = end;
    }

    /*  NOW LOOK FOR FINAL S  */
    if (*(end - 1) == 's') {
        *--end = '#';
        *eow = end;

        if (member(*(end - 1), "cfkpt"))
            retval = 's';
        else
            retval = 'z';

        /*  STRIP 'S  */
        if (*(end - 1) == '\'') {
            *--end = '#';
            *eow = end;
        }
    }

    return retval;
}
