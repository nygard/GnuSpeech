//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MRuleTester.h"

#import <AppKit/AppKit.h>
#import "MModel.h"

@implementation MRuleTester

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"RuleTester"] == nil)
        return nil;

    model = [aModel retain];

    [self setWindowFrameAutosaveName:@"Rule Tester"];

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

//
// Actions
//

- (IBAction)parseRule:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)shiftPhonesLeft:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

@end
