//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MSynthesisController.h"

#import <AppKit/AppKit.h>
#import "MModel.h"

@implementation MSynthesisController

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"Synthesis"] == nil)
        return nil;

    model = [aModel retain];

    [self setWindowFrameAutosaveName:@"Synthesis"];

    return self;
}

- (void)dealloc;
{
    [model release];

    [super dealloc];
}

- (MModel *)model;
{
    return model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel == model)
        return;

    [model release];
    model = [newModel retain];

    [self updateViews];
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
    [self updateViews];
}

- (void)updateViews;
{
}

- (IBAction)showIntonationWindow:(id)sender;
{
    [self window]; // Make sure the nib is loaded
    [intonationWindow makeKeyAndOrderFront:self];
}

- (IBAction)showIntonationParameterWindow:(id)sender;
{
    [self window]; // Make sure the nib is loaded
    [intonationParameterWindow makeKeyAndOrderFront:self];
}

@end
