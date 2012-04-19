//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"

@class WebView;

@interface MReleaseNotesController : MWindowController
{
#ifndef GNUSTEP
    IBOutlet WebView *webView;
#endif
}

- (id)init;

- (void)windowDidLoad;

@end
