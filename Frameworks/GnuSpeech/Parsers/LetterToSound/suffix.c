//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "letter_to_sound_private.h"

/// Find suffix if vowel in word before the suffix.
/// Return 0 if failed, or pointer to character which preceeds the suffix.

char *suffix(char *in, char *end, char *suflist)
{
    register char      *temp;

    temp = (char *)ends_with(in, end, suflist);
    if (temp && vowel_before(in, temp + 1))
        return(temp);
    return(0);
}
