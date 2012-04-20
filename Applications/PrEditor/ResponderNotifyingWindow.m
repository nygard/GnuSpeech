//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "ResponderNotifyingWindow.h"

@implementation ResponderNotifyingWindow
{
}

- (BOOL)makeFirstResponder:(NSResponder *)aResponder
{
    BOOL response = [super makeFirstResponder:aResponder];
    if (response) {
        // Commented out on October 13, 2008 -- dalmazio.
        //[[self delegate] window:self madeFirstResponder:aResponder];    
    }
    return response;
}

@end
