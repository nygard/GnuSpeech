//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MSpecialTransitionEditor.h"

#import <GnuSpeech/GnuSpeech.h>

@implementation MSpecialTransitionEditor

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"SpecialTransitionEditor"] == nil)
        return nil;

    model = [aModel retain];

    [self setWindowFrameAutosaveName:@"Special Transition Editor"];

    return self;
}

@end
