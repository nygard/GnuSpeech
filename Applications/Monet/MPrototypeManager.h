//
// $Id: MPrototypeManager.h,v 1.1 2004/03/21 05:02:00 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <AppKit/NSWindowController.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MModel;

@interface MPrototypeManager : NSWindowController
{
    IBOutlet NSOutlineView *equationOutlineView;
    IBOutlet NSButtonCell *removeEquationButtonCell;
    IBOutlet NSTextView *equationTextView;
    IBOutlet NSTextView *equationParserMessagesTextView;
    IBOutlet NSTextView *equationCommentTextView;

    IBOutlet NSOutlineView *transitionOutlineView;
    IBOutlet NSButtonCell *removeTransitionButtonCell;
    IBOutlet NSMatrix *transitionTypeMatrix;
    IBOutlet NSView *miniTransitionView;
    IBOutlet NSTextView *transitionCommentTextView;

    IBOutlet NSOutlineView *specialTransitionOutlineView;
    IBOutlet NSButtonCell *removeSpecialTransitionButtonCell;
    IBOutlet NSMatrix *specialTransitionTypeMatrix;
    IBOutlet NSView *miniSpecialTransitionView;
    IBOutlet NSTextView *specialTransitionCommentTextView;

    MModel *model;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)windowDidLoad;

- (void)updateViews;
- (void)expandOutlines;
- (void)_updateEquationDetails;
- (void)_updateTransitionDetails;
- (void)_updateSpecialTransitionDetails;

// Equations
- (IBAction)addEquationGroup:(id)sender;
- (IBAction)addEquation:(id)sender;
- (IBAction)removeEquation:(id)sender;
- (IBAction)parseEquation:(id)sender; // We may not need this.
- (IBAction)setEquation:(id)sender;
- (IBAction)revertEquation:(id)sender;

// Transitions
- (IBAction)addTransitionGroup:(id)sender;
- (IBAction)addTransition:(id)sender;
- (IBAction)removeTransition:(id)sender;
- (IBAction)setTransitionType:(id)sender;
- (IBAction)editTransition:(id)sender;


// Special Transitions
- (IBAction)addSpecialTransitionGroup:(id)sender;
- (IBAction)addSpecialTransition:(id)sender;
- (IBAction)removeSpecialTransition:(id)sender;
- (IBAction)setSpecialTransitionType:(id)sender;
- (IBAction)editSpecialTransition:(id)sender;

// NSOutlineView data source
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item;

// NSOutlineView delegate
- (void)outlineViewSelectionDidChange:(NSNotification *)aNotification;

// NSTextView delegate
- (void)textDidEndEditing:(NSNotification *)aNotification;

@end
