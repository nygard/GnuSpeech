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
//  MDataEntryController.h
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.4
//
////////////////////////////////////////////////////////////////////////////////

#import "MWindowController.h"
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet
#import <Foundation/NSUndoManager.h>
#import <Foundation/NSNotification.h>

@class MMCategory, MModel, MMParameter, MMSymbol;
@class NSTableView, NSTableColumn, NSTextField, NSTextView;
@class NSButtonCell;

@interface MDataEntryController : MWindowController
{
    IBOutlet NSTableView *categoryTableView;
    IBOutlet NSTextField *categoryTotalTextField;
    IBOutlet NSTextView *categoryCommentTextView;
    IBOutlet NSButtonCell *removeCategoryButtonCell;

    IBOutlet NSTableView *parameterTableView;
    IBOutlet NSTextField *parameterTotalTextField;
    IBOutlet NSTextView *parameterCommentTextView;
    IBOutlet NSButtonCell *removeParameterButtonCell;

    IBOutlet NSTableView *metaParameterTableView;
    IBOutlet NSTextField *metaParameterTotalTextField;
    IBOutlet NSTextView *metaParameterCommentTextView;
    IBOutlet NSButtonCell *removeMetaParameterButtonCell;

    IBOutlet NSTableView *symbolTableView;
    IBOutlet NSTextField *symbolTotalTextField;
    IBOutlet NSTextView *symbolCommentTextView;
    IBOutlet NSButtonCell *removeSymbolButtonCell;

    MModel *model;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)windowDidLoad;

- (void)updateViews;
- (void)_selectFirstRows;
- (void)_updateCategoryComment;
- (void)_updateParameterComment;
- (void)_updateMetaParameterComment;
- (void)_updateSymbolComment;

// Actions
- (IBAction)addCategory:(id)sender;
- (IBAction)removeCategory:(id)sender;

- (IBAction)addParameter:(id)sender;
- (IBAction)removeParameter:(id)sender;

- (IBAction)addMetaParameter:(id)sender;
- (IBAction)removeMetaParameter:(id)sender;

- (IBAction)addSymbol:(id)sender;
- (IBAction)removeSymbol:(id)sender;

// NSTableView data source
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row;

// NSTableView delegate
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;

// NSTextView delegate
- (void)textDidEndEditing:(NSNotification *)aNotification;

- (MMCategory *)selectedCategory;
- (MMParameter *)selectedParameter;
- (MMParameter *)selectedMetaParameter;
- (MMSymbol *)selectedSymbol;

@end
