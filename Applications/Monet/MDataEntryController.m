//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MDataEntryController.h"

#import <AppKit/AppKit.h>
#import "NSNumberFormatter-Extensions.h"

#import "CategoryList.h"
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

    defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];

    checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
    [checkboxCell setControlSize:NSSmallControlSize];
    [checkboxCell setButtonType:NSSwitchButton];
    [checkboxCell setImagePosition:NSImageOnly];
    [checkboxCell setEditable:NO];

    [[categoryTableView tableColumnWithIdentifier:@"isUsed"] setDataCell:checkboxCell];

    [checkboxCell release];
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
    NSLog(@" > %s", _cmd);
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

        if ([@"isUsed" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:YES];
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

        if ([@"name" isEqual:identifier] == YES) {
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

        if ([@"name" isEqual:identifier] == YES) {
            return [symbol symbol];
        } else if ([@"minimum" isEqual:identifier] == YES) {
            return [NSNumber numberWithDouble:[symbol minimumValue]];
        } else if ([@"maximum" isEqual:identifier] == YES) {
            return [NSNumber numberWithDouble:[symbol maximumValue]];
        } else if ([@"default" isEqual:identifier] == YES) {
            return [NSNumber numberWithDouble:[symbol defaultValue]];
        }
    }

    return @"Test";
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
{
    NSTableView *tableView;
    int selectedRowCount, selectedRow;
    NSString *comment;

    NSLog(@" > %s", _cmd);

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

    NSLog(@"<  %s", _cmd);
}

@end
