//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

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
