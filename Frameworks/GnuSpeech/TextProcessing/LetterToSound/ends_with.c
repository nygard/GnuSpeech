//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "letter_to_sound_private.h"

/// Return NULL if word doesn't end with set element, else pointer to char before ending.
char *ends_with(char *in, char *end, char *set)
{
    while (*set) {
        char *temp = end + 1;
        while (*--temp == *set)
            set++;
        if (*set == '/')
            return temp;
        while (*set++ != '/')
            /* pass */;
    }

    return NULL;
}
