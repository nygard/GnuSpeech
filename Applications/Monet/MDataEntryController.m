//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MDataEntryController.h"

#import <AppKit/AppKit.h>
#import "NSNumberFormatter-Extensions.h"

#import "CategoryList.h"
#import "MCommentCell.h"
#import "MMCategory.h"
#import "MModel.h"
#import "MMParameter.h"
#import "MMSymbol.h"
#import "ParameterList.h"
#import "SymbolList.h"

@implementation MDataEntryController

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"DataEntry"] == nil)
        return nil;

    model = [aModel retain];

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
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
    NSNumberFormatter *defaultNumberFormatter;
    NSButtonCell *checkboxCell;
    MCommentCell *commentImageCell;

    defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];

    checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
    [checkboxCell setControlSize:NSSmallControlSize];
    [checkboxCell setButtonType:NSSwitchButton];
    [checkboxCell setImagePosition:NSImageOnly];
    [checkboxCell setEditable:NO];

    [[categoryTableView tableColumnWithIdentifier:@"isUsed"] setDataCell:checkboxCell];

    [checkboxCell release];

    commentImageCell = [[MCommentCell alloc] initImageCell:nil];
    [commentImageCell setImageAlignment:NSImageAlignCenter];
    [[categoryTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[parameterTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[metaParameterTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[symbolTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [commentImageCell release];

#if 0
    [[[parameterTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[parameterTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[parameterTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [[[metaParameterTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[metaParameterTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[metaParameterTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [[[symbolTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[symbolTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[symbolTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];
#endif

    [categoryCommentTextView setFieldEditor:YES];
    [parameterCommentTextView setFieldEditor:YES];
    [metaParameterCommentTextView setFieldEditor:YES];
    [symbolCommentTextView setFieldEditor:YES];

    [self updateViews];
}

- (void)updateViews;
{
    [categoryTotalTextField setIntValue:[[[self model] categories] count]];
    [parameterTotalTextField setIntValue:[[[self model] parameters] count]];
    [metaParameterTotalTextField setIntValue:[[[self model] metaParameters] count]];
    [symbolTotalTextField setIntValue:[[[self model] symbols] count]];

    [categoryTableView reloadData];
    [parameterTableView reloadData];
    [metaParameterTableView reloadData];
    [symbolTableView reloadData];
}

//
// Actions
//

- (IBAction)addCategory:(id)sender;
{
    MMCategory *newCategory;

    NSLog(@" > %s", _cmd);

    newCategory = [[MMCategory alloc] initWithSymbol:nil];
    [[self model] addCategory:newCategory];
    [newCategory release];

    [self updateViews];

    // TODO (2004-03-18): Ideally we'd like to select the name of the category for editing.

    NSLog(@"<  %s", _cmd);
}

- (IBAction)removeCategory:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)addParameter:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)removeParameter:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)addMetaParameter:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)removeMetaParameter:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)addSymbol:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)removeSymbol:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

//
// NSTableView data source
//

- (int)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView ==  categoryTableView)
        return [[[self model] categories] count];

    if (tableView == parameterTableView)
        return [[[self model] parameters] count];

    if (tableView == metaParameterTableView)
        return [[[self model] metaParameters] count];

    if (tableView == symbolTableView)
        return [[[self model] symbols] count];

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
{
    id identifier;

    identifier = [tableColumn identifier];

    if (tableView == categoryTableView) {
        MMCategory *category = [[[self model] categories] objectAtIndex:row];

        if ([@"hasComment" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[category hasComment]];
        } else if ([@"isUsed" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[[self model] isCategoryUsed:category]];
        } else if ([@"name" isEqual:identifier] == YES) {
            return [category symbol];
        }
    } else if (tableView == parameterTableView || tableView == metaParameterTableView) {
        // TODO (2004-03-18): When MMSymbol == MMParameter, we can merge the last three cases.
        MMParameter *parameter;

        if (tableView == parameterTableView)
            parameter = [[[self model] parameters] objectAtIndex:row];
        else
            parameter = [[[self model] metaParameters] objectAtIndex:row];

        if ([@"hasComment" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[parameter hasComment]];
        } else if ([@"name" isEqual:identifier] == YES) {
            return [parameter symbol];
        } else if ([@"minimum" isEqual:identifier] == YES) {
            return [NSNumber numberWithDouble:[parameter minimumValue]];
        } else if ([@"maximum" isEqual:identifier] == YES) {
            return [NSNumber numberWithDouble:[parameter maximumValue]];
        } else if ([@"default" isEqual:identifier] == YES) {
            return [NSNumber numberWithDouble:[parameter defaultValue]];
        }
    } else if (tableView == symbolTableView) {
        MMSymbol *symbol = [[[self model] symbols] objectAtIndex:row];

        if ([@"hasComment" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[symbol hasComment]];
        } else if ([@"name" isEqual:identifier] == YES) {
            return [symbol symbol];
        } else if ([@"minimum" isEqual:identifier] == YES) {
            return [NSNumber numberWithDouble:[symbol minimumValue]];
        } else if ([@"maximum" isEqual:identifier] == YES) {
            return [NSNumber numberWithDouble:[symbol maximumValue]];
        } else if ([@"default" isEqual:identifier] == YES) {
            return [NSNumber numberWithDouble:[symbol defaultValue]];
        }
    }

    return nil;
}

//
// NSTableView delegate
//

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
{
    NSTableView *tableView;
    int selectedRowCount, selectedRow;
    NSString *comment;

    tableView = [aNotification object];
    selectedRowCount = [tableView numberOfSelectedRows];
    selectedRow = [tableView selectedRow];

    if (tableView == categoryTableView) {
        if (selectedRowCount == 1) {
            MMCategory *selectedCategory;

            selectedCategory = [[[self model] categories] objectAtIndex:selectedRow];
            [categoryCommentTextView setEditable:YES];
            comment = [selectedCategory comment];
            if (comment == nil)
                comment = @"";
            [categoryCommentTextView setString:comment];
        } else {
            [categoryCommentTextView setEditable:NO];
            [categoryCommentTextView setString:@""];
        }
    } else if (tableView == parameterTableView) {
        if (selectedRowCount == 1) {
            MMParameter *selectedParameter;

            selectedParameter = [[[self model] parameters] objectAtIndex:selectedRow];
            [parameterCommentTextView setEditable:YES];
            comment = [selectedParameter comment];
            if (comment == nil)
                comment = @"";
            [parameterCommentTextView setString:comment];
        } else {
            [parameterCommentTextView setEditable:NO];
            [parameterCommentTextView setString:@""];
        }
    } else if (tableView == metaParameterTableView) {
        if (selectedRowCount == 1) {
            MMParameter *selectedMetaParameter;

            selectedMetaParameter = [[[self model] metaParameters] objectAtIndex:selectedRow];
            [metaParameterCommentTextView setEditable:YES];
            comment = [selectedMetaParameter comment];
            if (comment == nil)
                comment = @"";
            [metaParameterCommentTextView setString:comment];
        } else {
            [metaParameterCommentTextView setEditable:NO];
            [metaParameterCommentTextView setString:@""];
        }
    } else if (tableView == symbolTableView) {
        if (selectedRowCount == 1) {
            MMSymbol *selectedSymbol;

            selectedSymbol = [[[self model] symbols] objectAtIndex:selectedRow];
            [symbolCommentTextView setEditable:YES];
            comment = [selectedSymbol comment];
            if (comment == nil)
                comment = @"";
            [symbolCommentTextView setString:comment];
        } else {
            [symbolCommentTextView setEditable:NO];
            [symbolCommentTextView setString:@""];
        }
    }
}

//
// NSTextView delegate
//

- (void)textDidEndEditing:(NSNotification *)aNotification;
{
    NSTextView *textView;
    int selectedRow;
    NSString *newComment;

    textView = [aNotification object];
    // NSTextMovement is a key in the user info
    //NSLog(@"[aNotification userInfo]: %@", [aNotification userInfo]);

    newComment = [[textView string] copy];
    //NSLog(@"(1) newComment: %@", newComment);
    if ([newComment length] == 0) {
        [newComment release];
        newComment = nil;
    }
    //NSLog(@"(2) newComment: %@", newComment);

    if (textView == categoryCommentTextView) {
        selectedRow = [categoryTableView selectedRow];
        //NSLog(@"selectedRow: %d", selectedRow);
        [[[[self model] categories] objectAtIndex:selectedRow] setComment:newComment];
        // TODO (2004-03-18): Bleck.  Need notification from model that things have changed.
        [categoryTableView reloadData];
    } else if (textView == parameterCommentTextView) {
        selectedRow = [parameterTableView selectedRow];
        //NSLog(@"selectedRow: %d", selectedRow);
        [[[[self model] parameters] objectAtIndex:selectedRow] setComment:newComment];
        [parameterTableView reloadData];
    } else if (textView == metaParameterCommentTextView) {
        selectedRow = [metaParameterTableView selectedRow];
        //NSLog(@"selectedRow: %d", selectedRow);
        [[[[self model] metaParameters] objectAtIndex:selectedRow] setComment:newComment];
        [metaParameterTableView reloadData];
    } else if (textView == symbolCommentTextView) {
        selectedRow = [symbolTableView selectedRow];
        //NSLog(@"selectedRow: %d", selectedRow);
        [[[[self model] symbols] objectAtIndex:selectedRow] setComment:newComment];
        [symbolTableView reloadData];
    }

    [newComment release];
}

@end
