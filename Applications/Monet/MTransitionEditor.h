//
// $Id: MTransitionEditor.h,v 1.1 2004/03/22 19:09:52 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <AppKit/NSWindowController.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MModel, MMTransition;
@class TransitionView;

@interface MTransitionEditor : NSWindowController
{
    IBOutlet NSTextField *transitionNameTextField;
    IBOutlet TransitionView *transitionView;
    IBOutlet NSForm *controlParametersForm;

    MModel *model;

    MMTransition *transition;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)windowDidLoad;

- (void)updateViews;

- (MMTransition *)transition;
- (void)setTransition:(MMTransition *)newTransition;

@end
