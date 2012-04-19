//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import "MReleaseNotesController.h"
#import <Foundation/NSBundle.h>

#ifndef GNUSTEP
#import <WebKit/WebKit.h>
#endif

@implementation MReleaseNotesController

- (id)init;
{
    if ([super initWithWindowNibName:@"ReleaseNotes"] == nil)
        return nil;

    [self setWindowFrameAutosaveName:@"ReleaseNotes"];

    return self;
}

- (void)windowDidLoad;
{
    NSString *path;

    path = [[NSBundle mainBundle] pathForResource:@"ReleaseNotes" ofType:@"html"];
#ifndef GNUSTEP
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
#endif
}

@end
