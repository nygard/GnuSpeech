//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MTransitionEditor.h"

#import <AppKit/AppKit.h>
#import "MModel.h"
#import "MMTransition.h"
#import "TransitionView.h"

@implementation MTransitionEditor

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"TransitionEditor"] == nil)
        return nil;

    model = [aModel retain];

    [self setWindowFrameAutosaveName:@"Transition Editor"];

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

    [transitionView setModel:model];

    [self updateViews];
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
    [transitionView setModel:model];
    [transitionView setTransition:transition];

    [self updateViews];
}

- (void)updateViews;
{
    NSString *name;

    name = [transition name];
    if (name == nil)
        name = @"--";
    [transitionNameTextField setStringValue:name];
}

- (MMTransition *)transition;
{
    return transition;
}

- (void)setTransition:(MMTransition *)newTransition;
{
    NSLog(@" > %s", _cmd);

    NSLog(@"transition: %p, newTransition: %p", transition, newTransition);

    if (newTransition == transition) {
        NSLog(@"<  %s", _cmd);
        return;
    }

    [transition release];
    transition = [newTransition retain];

    NSLog(@"transitionView: %p", transitionView);
    [transitionView setTransition:transition];

    [self updateViews];

    NSLog(@"<  %s", _cmd);
}

@end
