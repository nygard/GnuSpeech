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
//  MPostureEditor.h
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.4
//
////////////////////////////////////////////////////////////////////////////////

#import "MWindowController.h"
#import <AppKit/AppKit.h>

@class MMCategory, MModel, MMParameter, MMPosture, MMSymbol;
@class NSButton, NSButtonCell, NSFont, NSControl;

@interface MPostureEditor : MWindowController
{
    IBOutlet NSTableView *postureTableView;
    IBOutlet NSTextField *postureTotalTextField;
    IBOutlet NSButtonCell *removePostureButtonCell;
    IBOutlet NSTextView *postureCommentTextView;

    IBOutlet NSTableView *categoryTableView;

    IBOutlet NSTableView *parameterTableView;
    IBOutlet NSButton *useDefaultParameterButton;

    IBOutlet NSTableView *metaParameterTableView;
    IBOutlet NSButton *useDefaultMetaParameterButton;

    IBOutlet NSTableView *symbolTableView;
    IBOutlet NSButton *useDefaultSymbolButton;

    MModel *model;

    NSFont *regularControlFont;
    NSFont *boldControlFont;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)windowDidLoad;

- (void)updateViews;
- (void)_updatePostureDetails;
- (void)_updateUseDefaultButtons;

- (MMPosture *)selectedPosture;

- (IBAction)addPosture:(id)sender;
- (IBAction)removePosture:(id)sender;

- (IBAction)useDefaultValueForParameter:(id)sender;
- (IBAction)useDefaultValueForMetaParameter:(id)sender;
- (IBAction)useDefaultValueForSymbol:(id)sender;

// NSTableView data source
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row;

// NSTableView delegate
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row;

- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;

// NSTextView delegate
- (void)textDidEndEditing:(NSNotification *)aNotification;

@end
