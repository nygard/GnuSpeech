////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  MTransitionEditor.h
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//	Version: 0.9.3
//
////////////////////////////////////////////////////////////////////////////////

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
