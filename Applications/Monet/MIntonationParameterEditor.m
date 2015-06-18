//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MIntonationParameterEditor.h"

@interface MIntonationParameterEditor ()

@end

@implementation MIntonationParameterEditor

- (id)init;
{
    if ((self = [super initWithWindowNibName:@"IntonationParameters"])) {
    }

    return self;
}

- (void)windowDidLoad;
{
    [super windowDidLoad];
}

@end
