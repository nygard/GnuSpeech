//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "letter_to_sound_private.h"

/// Change each 's' that is preceded by a vowel, and followed by either a vowel or 'm', into 'S'.

void medial_s(char *in, char *end)
{
    while (in < end - 1)
    {
        if (   member(*in,   "AEIOUYaeiouy")
            && in[1] == 's'
            && member(in[2], "AEIOUYaeiouym"))
        {
            in[1] = 'S';
        }
        in++;
    }
}
