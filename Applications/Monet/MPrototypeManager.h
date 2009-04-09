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
//  MPrototypeManager.h
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.3
//
////////////////////////////////////////////////////////////////////////////////

#import "MWindowController.h"
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet
#import <AppKit/AppKit.h>

@class MMEquation, MMFormulaParser, MModel, MMTransition;
@class SpecialView, TransitionView;
@class NSOutlineView;

@interface MPrototypeManager : MWindowController
{
    IBOutlet NSOutlineView *equationOutlineView;
    IBOutlet NSButtonCell *addEquationButtonCell;
    IBOutlet NSButtonCell *removeEquationButtonCell;
    IBOutlet NSTextView *equationTextView;
    IBOutlet NSTextView *equationParserMessagesTextView;
    IBOutlet NSTextView *equationCommentTextView;

    IBOutlet NSOutlineView *transitionOutlineView;
    IBOutlet NSButtonCell *addTransitionButtonCell;
    IBOutlet NSButtonCell *removeTransitionButtonCell;
    IBOutlet TransitionView *miniTransitionView;
    IBOutlet NSTextView *transitionCommentTextView;

    IBOutlet NSOutlineView *specialTransitionOutlineView;
    IBOutlet NSButtonCell *addSpecialTransitionButtonCell;
    IBOutlet NSButtonCell *removeSpecialTransitionButtonCell;
    IBOutlet SpecialView *miniSpecialTransitionView;
    IBOutlet NSTextView *specialTransitionCommentTextView;

    MModel *model;

    MMFormulaParser *formulaParser;

    NSMutableDictionary *cachedEquationUsage;
    NSMutableDictionary *cachedTransitionUsage;
    //NSMutableDictionary *cachedSpecialTransitionUsage;
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

- (MMEquation *)selectedEquation;
- (MMTransition *)selectedTransition;
- (MMTransition *)selectedSpecialTransition;

// Equations
- (IBAction)addEquationGroup:(id)sender;
- (IBAction)addEquation:(id)sender;
- (IBAction)removeEquation:(id)sender;
- (IBAction)setEquation:(id)sender;
- (IBAction)revertEquation:(id)sender;

// Transitions
- (IBAction)addTransitionGroup:(id)sender;
- (IBAction)addTransition:(id)sender;
- (IBAction)removeTransition:(id)sender;
- (IBAction)editTransition:(id)sender;


// Special Transitions
- (IBAction)addSpecialTransitionGroup:(id)sender;
- (IBAction)addSpecialTransition:(id)sender;
- (IBAction)removeSpecialTransition:(id)sender;
- (IBAction)editSpecialTransition:(id)sender;

// NSOutlineView data source
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item;
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item;

// NSOutlineView delegate
- (void)outlineViewSelectionDidChange:(NSNotification *)aNotification;
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item;

// NSTextView delegate
- (void)textDidEndEditing:(NSNotification *)aNotification;

// Equation usage caching
- (void)clearEquationUsageCache;
- (NSArray *)usageOfEquation:(MMEquation *)anEquation;
- (NSArray *)usageOfEquation:(MMEquation *)anEquation recache:(BOOL)shouldRecache;
- (BOOL)isEquationUsed:(MMEquation *)anEquation;

// Transition usage caching
- (void)clearTransitionUsageCache;
- (NSArray *)usageOfTransition:(MMTransition *)aTransition;
- (NSArray *)usageOfTransition:(MMTransition *)aTransition recache:(BOOL)shouldRecache;
- (BOOL)isTransitionUsed:(MMTransition *)aTransition;

- (IBAction)doubleHit:(id)sender;

@end
