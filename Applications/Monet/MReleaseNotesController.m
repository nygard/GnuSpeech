//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MReleaseNotesController.h"

#import <WebKit/WebKit.h>

@implementation MReleaseNotesController
{
    IBOutlet WebView *webView;
}

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
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
}

@end
