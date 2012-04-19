//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MWindowController.h"
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet
#import <AppKit/NSForm.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSTextField.h>
#import <AppKit/NSTextView.h>
#import <AppKit/NSOutlineView.h>
#import <AppKit/NSPopUpButton.h>

@class MModel, MMPoint, MMTransition;
@class TransitionView;
@class NSPopUpButton;

@interface MTransitionEditor : MWindowController
{
    IBOutlet NSTextField *transitionNameTextField;
    IBOutlet NSPopUpButton *transitionTypePopUpButton;
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
- (IBAction)setPointValue:(id)sender;
- (IBAction)setPhantom:(id)sender;
- (IBAction)setTransitionType:(id)sender;

@end
