//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MReleaseNotesController.h"

#import <WebKit/WebKit.h>

@implementation MReleaseNotesController
{
    IBOutlet WebView *_webView;
}

- (id)init;
{
    if ((self = [super initWithWindowNibName:@"ReleaseNotes"])) {
        [self setWindowFrameAutosaveName:@"ReleaseNotes"];
    }

    return self;
}

- (void)windowDidLoad;
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ReleaseNotes" ofType:@"html"];
    [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
}

@end
