//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

// A window that notifies its delegate when the firstResponder changes

@interface ResponderNotifyingWindow : NSWindow {

}

- (BOOL)makeFirstResponder:(NSResponder *)aResponder;

@end
