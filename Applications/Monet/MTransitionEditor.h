//
// $Id: MTransitionEditor.h,v 1.4 2004/03/24 00:41:18 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <AppKit/NSWindowController.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

@class MModel, MMPoint, MMTransition;
@class TransitionView;

@interface MTransitionEditor : NSWindowController
{
    IBOutlet NSTextField *transitionNameTextField;
    IBOutlet TransitionView *transitionView;
    IBOutlet NSForm *controlParametersForm;

    IBOutlet NSOutlineView *equationOutlineView;
    IBOutlet NSTextField *valueTextField;
    IBOutlet NSButton *isPhantomSwitch;

    IBOutlet NSButton *type1Button;
    IBOutlet NSButton *type2Button;
    IBOutlet NSButton *type3Button;

    IBOutlet NSTextView *equationTextView;

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
- (void)expandEquations;

- (MMTransition *)transition;
- (void)setTransition:(MMTransition *)newTransition;

// NSOutlineView data source
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;

// NSOutlineView delegate
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item;
- (void)outlineViewSelectionDidChange:(NSNotification *)aNotification;

// TransitionView delegate
- (void)transitionViewSelectionDidChange:(NSNotification *)aNotification;
- (BOOL)transitionView:(TransitionView *)aTransitionView shouldAddPoint:(MMPoint *)aPoint;

- (void)_updateSelectedPointDetails;
- (IBAction)setType:(id)sender;
- (IBAction)setValue:(id)sender;
- (IBAction)setPhantom:(id)sender;

@end
