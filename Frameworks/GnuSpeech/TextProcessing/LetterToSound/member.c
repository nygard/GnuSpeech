//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "letter_to_sound_private.h"

/// Return true if element in set, false otherwise.
int member(char element, char *set)
{
    while (*set)
        if (element == *set++)
            return 1;

    return 0;
}