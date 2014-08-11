//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "letter_to_sound_private.h"

void medial_s(char *in, char **eow)
{
    register char      *end = *eow;
	
    while (in < end - 1) {
		if ((member(*in | 040, "aeiouy")) && (in[1] == 's')
			&& (member(in[2], "AEIOUYaeiouym")))
			in[1] &= 0xdf;
		in++;
    }
}
