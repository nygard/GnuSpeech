//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Cocoa/Cocoa.h>

@interface ApplicationController : NSObject
{
	IBOutlet NSTextView *textView;
	id ttsServerProxy;
}

- (id)init;
- (IBAction)speak:(id)sender;
- (void)dealloc;

@end
