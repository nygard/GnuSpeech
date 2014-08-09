//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MDataEntryController.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"

#import "MCommentCell.h"

// TODO (2004-03-20): Implement copy and pasting of categories, parameters, meta parameters, and symbols, although it looks like the original code did actually do the pasting part.

@implementation MDataEntryController
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
{
    if ((self = [super initWithWindowNibName:@"DataEntry"])) {
        model = [aModel retain];

        [self setWindowFrameAutosaveName:@"Data Entry"];
    }

    return self;
}

- (void)dealloc;
{
    [model release];

    [super dealloc];
}

#pragma mark -

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
    [self _selectFirstRows];
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

    [self updateViews];
    [self _selectFirstRows];
}

- (void)updateViews;
{
    [categoryTotalTextField setIntegerValue:[[[self model] categories] count]];
    [parameterTotalTextField setIntegerValue:[[[self model] parameters] count]];
    [metaParameterTotalTextField setIntegerValue:[[[self model] metaParameters] count]];
    [symbolTotalTextField setIntegerValue:[[[self model] symbols] count]];

    [categoryTableView reloadData];
    [parameterTableView reloadData];
    [metaParameterTableView reloadData];
    [symbolTableView reloadData];

    [self _updateCategoryComment];
    [self _updateParameterComment];
    [self _updateMetaParameterComment];
    [self _updateSymbolComment];
}

- (void)_selectFirstRows;
{
    [categoryTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    [parameterTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    [metaParameterTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    [symbolTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

// TODO (2004-03-19): This should be _updateCategoryDetails now that it enables/disables the remove button
- (void)_updateCategoryComment;
{
    if ([categoryTableView numberOfSelectedRows] == 1) {
        MMCategory *selectedCategory;
        NSString *comment;

        selectedCategory = [self selectedCategory];
        [categoryCommentTextView setEditable:YES];
        comment = [selectedCategory comment];
        if (comment == nil)
            comment = @"";
        [categoryCommentTextView setString:comment];
        [removeCategoryButtonCell setEnabled:YES];
    } else {
        [categoryCommentTextView setEditable:NO];
        [categoryCommentTextView setString:@""];
        [removeCategoryButtonCell setEnabled:NO];
    }
}

- (void)_updateParameterComment;
{
    if ([parameterTableView numberOfSelectedRows] == 1) {
        MMParameter *selectedParameter;
        NSString *comment;

        selectedParameter = [self selectedParameter];
        [parameterCommentTextView setEditable:YES];
        comment = [selectedParameter comment];
        if (comment == nil)
            comment = @"";
        [parameterCommentTextView setString:comment];
        [removeParameterButtonCell setEnabled:YES];
    } else {
        [parameterCommentTextView setEditable:NO];
        [parameterCommentTextView setString:@""];
        [removeParameterButtonCell setEnabled:NO];
    }
}

- (void)_updateMetaParameterComment;
{
    if ([metaParameterTableView numberOfSelectedRows] == 1) {
        MMParameter *selectedMetaParameter;
        NSString *comment;

        selectedMetaParameter = [self selectedMetaParameter];
        [metaParameterCommentTextView setEditable:YES];
        comment = [selectedMetaParameter comment];
        if (comment == nil)
            comment = @"";
        [metaParameterCommentTextView setString:comment];
        [removeMetaParameterButtonCell setEnabled:YES];
    } else {
        [metaParameterCommentTextView setEditable:NO];
        [metaParameterCommentTextView setString:@""];
        [removeMetaParameterButtonCell setEnabled:NO];
    }
}

- (void)_updateSymbolComment;
{
    if ([symbolTableView numberOfSelectedRows] == 1) {
        MMSymbol *selectedSymbol;
        NSString *comment;

        selectedSymbol = [self selectedSymbol];
        [symbolCommentTextView setEditable:YES];
        comment = [selectedSymbol comment];
        if (comment == nil)
            comment = @"";
        [symbolCommentTextView setString:comment];
        [removeSymbolButtonCell setEnabled:YES];
    } else {
        [symbolCommentTextView setEditable:NO];
        [symbolCommentTextView setString:@""];
        [removeSymbolButtonCell setEnabled:NO];
    }
}

#pragma mark - Actions

- (IBAction)addCategory:(id)sender;
{
    MMCategory *newCategory;
    NSUInteger index;

    newCategory = [[MMCategory alloc] init];
    [[self model] addCategory:newCategory];

    [self updateViews];

    index = [[[self model] categories] indexOfObject:newCategory];
    [newCategory release];

    [categoryTableView scrollRowToVisible:index];

    // The row needs to be selected before we start editing it.
    [categoryTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [categoryTableView editColumn:[categoryTableView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
}

- (IBAction)removeCategory:(id)sender;
{
    MMCategory *selectedCategory;

    selectedCategory = [self selectedCategory];
    if (selectedCategory != nil)
        [[self model] removeCategory:selectedCategory];

    [self updateViews];
}

- (IBAction)addParameter:(id)sender;
{
    MMParameter *newParameter;
    NSUInteger index;

    newParameter = [[MMParameter alloc] init];
    [[self model] addParameter:newParameter];
    [newParameter release];

    [self updateViews];

    index = [[[self model] parameters] indexOfObject:newParameter];
    [parameterTableView scrollRowToVisible:index];

    // The row needs to be selected before we start editing it.
    [parameterTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [parameterTableView editColumn:[parameterTableView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
}

- (IBAction)removeParameter:(id)sender;
{
    MMParameter *selectedParameter;

    selectedParameter = [self selectedParameter];
    if (selectedParameter != nil)
        [[self model] removeParameter:selectedParameter];

    [self updateViews];
}

- (IBAction)addMetaParameter:(id)sender;
{
    MMParameter *newParameter;
    NSUInteger index;

    newParameter = [[MMParameter alloc] init];
    [[self model] addMetaParameter:newParameter];
    [newParameter release];

    [self updateViews];

    index = [[[self model] metaParameters] indexOfObject:newParameter];
    [metaParameterTableView scrollRowToVisible:index];

    // The row needs to be selected before we start editing it.
    [metaParameterTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [metaParameterTableView editColumn:[metaParameterTableView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
}

- (IBAction)removeMetaParameter:(id)sender;
{
    MMParameter *selectedParameter;

    selectedParameter = [self selectedMetaParameter];
    if (selectedParameter != nil)
        [[self model] removeMetaParameter:selectedParameter];

    [self updateViews];
}

- (IBAction)addSymbol:(id)sender;
{
    MMSymbol *newSymbol;
    NSUInteger index;

    newSymbol = [[MMSymbol alloc] init];
    [[self model] addSymbol:newSymbol];
    [newSymbol release];

    [self updateViews];

    index = [[[self model] symbols] indexOfObject:newSymbol];
    [symbolTableView scrollRowToVisible:index];

    // The row needs to be selected before we start editing it.
    [symbolTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [symbolTableView editColumn:[symbolTableView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
}

- (IBAction)removeSymbol:(id)sender;
{
    MMSymbol *selectedSymbol;

    selectedSymbol = [self selectedSymbol];
    if (selectedSymbol != nil)
        [[self model] removeSymbol:selectedSymbol];

    [self updateViews];
}

#pragma mark - NSTableView data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == categoryTableView)
        return [[[self model] categories] count];

    if (tableView == parameterTableView)
        return [[[self model] parameters] count];

    if (tableView == metaParameterTableView)
        return [[[self model] metaParameters] count];

    if (tableView == symbolTableView)
        return [[[self model] symbols] count];

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
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
            return [category name];
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
            return [parameter name];
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
            return [symbol name];
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

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier;

    identifier = [tableColumn identifier];

    if (tableView == categoryTableView) {
        MMCategory *category = [[[self model] categories] objectAtIndex:row];

        if ([@"name" isEqual:identifier] == YES) {
            // TODO (2004-03-19): Ensure unique name
            [category setName:object];
        }
    } else if (tableView == parameterTableView || tableView == metaParameterTableView) {
        MMParameter *parameter;

        if (tableView == parameterTableView)
            parameter = [[[self model] parameters] objectAtIndex:row];
        else
            parameter = [[[self model] metaParameters] objectAtIndex:row];

        if ([@"name" isEqual:identifier] == YES) {
            // TODO (2004-03-19): Ensure unique name
            [parameter setName:object];
        } else if ([@"minimum" isEqual:identifier] == YES) {
            // TODO (2004-03-19): Make sure current values are still in range
            [parameter setMinimumValue:[object doubleValue]];
        } else if ([@"maximum" isEqual:identifier] == YES) {
            [parameter setMaximumValue:[object doubleValue]];
        } else if ([@"default" isEqual:identifier] == YES) {
            // TODO (2004-03-19): Propagate changes to default
            [parameter setDefaultValue:[object doubleValue]];
        }
    } else if (tableView == symbolTableView) {
        MMSymbol *symbol = [[[self model] symbols] objectAtIndex:row];

        if ([@"name" isEqual:identifier] == YES) {
            // TODO (2004-03-19): Ensure unique name
            [symbol setName:object];
        } else if ([@"minimum" isEqual:identifier] == YES) {
            // TODO (2004-03-19): Make sure current values are still in range
            [symbol setMinimumValue:[object doubleValue]];
        } else if ([@"maximum" isEqual:identifier] == YES) {
            [symbol setMaximumValue:[object doubleValue]];
        } else if ([@"default" isEqual:identifier] == YES) {
            // TODO (2004-03-19): Propagate changes to default
            [symbol setDefaultValue:[object doubleValue]];
        }
    }
}

#pragma mark - NSTableView delegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
{
    NSTableView *tableView;

    tableView = [aNotification object];

    if (tableView == categoryTableView) {
        [self _updateCategoryComment];
    } else if (tableView == parameterTableView) {
        [self _updateParameterComment];
    } else if (tableView == metaParameterTableView) {
        [self _updateMetaParameterComment];
    } else if (tableView == symbolTableView) {
        [self _updateSymbolComment];
    }
}

#pragma mark - NSTextView delegate

- (void)textDidEndEditing:(NSNotification *)aNotification;
{
    NSTextView *textView;
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
        [[self selectedCategory] setComment:newComment];
        // TODO (2004-03-18): Bleck.  Need notification from model that things have changed.
        [categoryTableView reloadData];
    } else if (textView == parameterCommentTextView) {
        [[self selectedParameter] setComment:newComment];
        [parameterTableView reloadData];
    } else if (textView == metaParameterCommentTextView) {
        [[self selectedMetaParameter] setComment:newComment];
        [metaParameterTableView reloadData];
    } else if (textView == symbolCommentTextView) {
        [[self selectedSymbol] setComment:newComment];
        [symbolTableView reloadData];
    }

    [newComment release];
}

- (MMCategory *)selectedCategory;
{
    NSInteger selectedRow;

    selectedRow = [categoryTableView selectedRow];

    return [[[self model] categories] objectAtIndex:selectedRow];
}

- (MMParameter *)selectedParameter;
{
    NSInteger selectedRow;

    selectedRow = [parameterTableView selectedRow];

    return [[[self model] parameters] objectAtIndex:selectedRow];
}

- (MMParameter *)selectedMetaParameter;
{
    NSInteger selectedRow;

    selectedRow = [metaParameterTableView selectedRow];

    return [[[self model] metaParameters] objectAtIndex:selectedRow];
}

- (MMSymbol *)selectedSymbol;
{
    NSInteger selectedRow;

    selectedRow = [symbolTableView selectedRow];

    return [[[self model] symbols] objectAtIndex:selectedRow];
}

@end
