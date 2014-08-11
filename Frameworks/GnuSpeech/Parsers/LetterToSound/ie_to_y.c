//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "letter_to_sound_private.h"


/// If final two characters are "ie" replace with "y" and return true.
int ie_to_y(char *in, char **end)
{
    register char      *t = *end;
	
    if ((*(t - 2) == 'i') && (*(t - 1) == 'e')) {
		*(t - 2) = 'y';
		*(t - 1) = '#';
		*end = --t;
		return(1);
    }
    return(0);
}
