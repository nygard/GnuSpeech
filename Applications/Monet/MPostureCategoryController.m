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
//  MPostureCategoryController.m
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//	Version: 0.9.3
//
////////////////////////////////////////////////////////////////////////////////

#import "MPostureCategoryController.h"

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <GnuSpeech/GnuSpeech.h>

@implementation MPostureCategoryController

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"PostureCategory"] == nil)
        return nil;

    model = [aModel retain];

    [self setWindowFrameAutosaveName:@"Posture Categories"];

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
    [self _selectFirstRow];
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
#if 0
    NSNumberFormatter *defaultNumberFormatter;
    NSButtonCell *checkboxCell;
    MCommentCell *commentImageCell;

    defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];

    checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
    [checkboxCell setControlSize:NSSmallControlSize];
    [checkboxCell setButtonType:NSSwitchButton];
    [checkboxCell setImagePosition:NSImageOnly];
    [checkboxCell setEditable:NO];

    [[categoryOutlineView tableColumnWithIdentifier:@"isUsed"] setDataCell:checkboxCell];

    [checkboxCell release];

    commentImageCell = [[MCommentCell alloc] initImageCell:nil];
    [commentImageCell setImageAlignment:NSImageAlignCenter];
    [[categoryOutlineView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[parameterTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[metaParameterTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[symbolTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [commentImageCell release];

    // InterfaceBuilder uses the first column in the nib as the outline column, so we need to rearrange them.
    [categoryOutlineView moveColumn:[categoryOutlineView columnWithIdentifier:@"hasComment"] toColumn:0];
    //[categoryOutlineView moveColumn:[categoryOutlineView columnWithIdentifier:@"isUsed"] toColumn:1];

    [[[parameterTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[parameterTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[parameterTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [[[metaParameterTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[metaParameterTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[metaParameterTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [[[symbolTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[symbolTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[symbolTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [categoryCommentTextView setFieldEditor:YES];
    [parameterCommentTextView setFieldEditor:YES];
    [metaParameterCommentTextView setFieldEditor:YES];
    [symbolCommentTextView setFieldEditor:YES];
#endif
    [self updateViews];
    [self _selectFirstRow];
}

- (void)updateViews;
{
    [self createCategoryColumns];
    [postureCategoryTableView reloadData];
#if 0
    [categoryTotalTextField setIntValue:[[[self model] categories] count]];
    [parameterTotalTextField setIntValue:[[[self model] parameters] count]];
    [metaParameterTotalTextField setIntValue:[[[self model] metaParameters] count]];
    [symbolTotalTextField setIntValue:[[[self model] symbols] count]];

    [categoryOutlineView reloadData];
    [parameterTableView reloadData];
    [metaParameterTableView reloadData];
    [symbolTableView reloadData];

    [self _updateCategoryComment];
    [self _updateParameterComment];
    [self _updateMetaParameterComment];
    [self _updateSymbolComment];
#endif
}

- (void)createCategoryColumns;
{
    NSTableColumn *postureNameTableColumn;
    NSArray *tableColumns;
    unsigned int count, index;
    CategoryList *categories;

    // Retain this column because we'll be removing it but want to add it back.
    postureNameTableColumn = [[postureCategoryTableView tableColumnWithIdentifier:@"name"] retain];

    // Remove all the table columns
    tableColumns = [[NSArray alloc] initWithArray:[postureCategoryTableView tableColumns]];
    count = [tableColumns count];
    for (index = 0; index < count; index++)
        [postureCategoryTableView removeTableColumn:[tableColumns objectAtIndex:index]];
    [tableColumns release];

    // Add the posture name column back
    [postureCategoryTableView addTableColumn:postureNameTableColumn];
    [postureNameTableColumn release];

    // Now we can add the category columns
    categories = [[self model] categories];
    count = [categories count];
    for (index = 0; index < count; index++) {
        NSTableColumn *newTableColumn;
        MMCategory *category;
        NSButtonCell *checkboxCell;

        category = [categories objectAtIndex:index];

        newTableColumn = [[NSTableColumn alloc] init];
        //[newTableColumn setIdentifier:[category symbol]];
        [newTableColumn setIdentifier:category];
        [[newTableColumn headerCell] setTitle:[category name]];

        checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
        [checkboxCell setControlSize:NSSmallControlSize];
        [checkboxCell setButtonType:NSSwitchButton];
        [checkboxCell setImagePosition:NSImageOnly];
        [checkboxCell setEditable:NO];
        [newTableColumn setDataCell:checkboxCell];
        [checkboxCell release];

        [newTableColumn sizeToFit];
        [postureCategoryTableView addTableColumn:newTableColumn];

        [newTableColumn release];
    }
}

- (void)_selectFirstRow;
{
    [postureCategoryTableView selectRow:0 byExtendingSelection:NO];
}

//
// NSTableView data source
//

- (int)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == postureCategoryTableView)
        return [[[self model] postures] count];

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
{
    id identifier;

    identifier = [tableColumn identifier];

    if (tableView == postureCategoryTableView) {
        MMPosture *posture;

        posture = [[[self model] postures] objectAtIndex:row];
        if ([@"name" isEqual:identifier] == YES) {
            return [posture name];
        } else if ([identifier isKindOfClass:[MMCategory class]]) {
            return [NSNumber numberWithBool:[posture isMemberOfCategory:identifier]];
        }
    }

    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row;
{
}

//
// NSTableView delegate
//

- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;
{
    NSArray *postures;
    unsigned int count, index;
    MMPosture *posture;

    postures = [[self model] postures];
    count = [postures count];
    for (index = 0; index < count; index++) {
        posture = [postures objectAtIndex:index];
        if ([[posture name] hasPrefix:characters] == YES) {
            [postureCategoryTableView selectRow:index byExtendingSelection:NO];
            [postureCategoryTableView scrollRowToVisible:index];
            return NO;
        }
    }

    return YES;
}

@end
