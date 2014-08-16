//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSLetterToSound.h"

#import "letter_to_sound.h"

@implementation GSLetterToSound

- (NSString *)pronunciationForWord:(NSString *)word;
{
    const char *result = letter_to_sound((char *)[word cStringUsingEncoding:NSASCIIStringEncoding]);
    if (result != nil) {
        return [[NSString alloc] initWithUTF8String:result];
    }

    return nil;
}

@end
