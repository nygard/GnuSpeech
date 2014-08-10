//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MDataEntryController.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"

#import "MCommentCell.h"

// TODO (2004-03-20): Implement copy and pasting of categories, parameters, meta parameters, and symbols, although it looks like the original code did actually do the pasting part.

@implementation MDataEntryController
{
    IBOutlet NSTableView *_categoryTableView;
    IBOutlet NSTextField *_categoryTotalTextField;
    IBOutlet NSTextView *_categoryCommentTextView;
    IBOutlet NSButtonCell *_removeCategoryButtonCell;

    IBOutlet NSTableView *_parameterTableView;
    IBOutlet NSTextField *_parameterTotalTextField;
    IBOutlet NSTextView *_parameterCommentTextView;
    IBOutlet NSButtonCell *_removeParameterButtonCell;

    IBOutlet NSTableView *_metaParameterTableView;
    IBOutlet NSTextField *_metaParameterTotalTextField;
    IBOutlet NSTextView *_metaParameterCommentTextView;
    IBOutlet NSButtonCell *_removeMetaParameterButtonCell;

    IBOutlet NSTableView *_symbolTableView;
    IBOutlet NSTextField *_symbolTotalTextField;
    IBOutlet NSTextView *_symbolCommentTextView;
    IBOutlet NSButtonCell *_removeSymbolButtonCell;

    MModel *_model;
}

- (id)initWithModel:(MModel *)model;
{
    if ((self = [super initWithWindowNibName:@"DataEntry"])) {
        _model = model;

        [self setWindowFrameAutosaveName:@"Data Entry"];
    }

    return self;
}

#pragma mark -

- (MModel *)model;
{
    return _model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel == _model)
        return;

    _model = newModel;

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

    [[_categoryTableView tableColumnWithIdentifier:@"isUsed"] setDataCell:checkboxCell];

    commentImageCell = [[MCommentCell alloc] initImageCell:nil];
    [commentImageCell setImageAlignment:NSImageAlignCenter];
    [[_categoryTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[_parameterTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[_metaParameterTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[_symbolTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];

    [[[_parameterTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_parameterTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_parameterTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [[[_metaParameterTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_metaParameterTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_metaParameterTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [[[_symbolTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_symbolTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_symbolTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [_categoryCommentTextView setFieldEditor:YES];
    [_parameterCommentTextView setFieldEditor:YES];
    [_metaParameterCommentTextView setFieldEditor:YES];
    [_symbolCommentTextView setFieldEditor:YES];

    [self updateViews];
    [self _selectFirstRows];
}

- (void)updateViews;
{
    [_categoryTotalTextField setIntegerValue:[[[self model] categories] count]];
    [_parameterTotalTextField setIntegerValue:[[[self model] parameters] count]];
    [_metaParameterTotalTextField setIntegerValue:[[[self model] metaParameters] count]];
    [_symbolTotalTextField setIntegerValue:[[[self model] symbols] count]];

    [_categoryTableView reloadData];
    [_parameterTableView reloadData];
    [_metaParameterTableView reloadData];
    [_symbolTableView reloadData];

    [self _updateCategoryComment];
    [self _updateParameterComment];
    [self _updateMetaParameterComment];
    [self _updateSymbolComment];
}

- (void)_selectFirstRows;
{
    [_categoryTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    [_parameterTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    [_metaParameterTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    [_symbolTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

// TODO (2004-03-19): This should be _updateCategoryDetails now that it enables/disables the remove button
- (void)_updateCategoryComment;
{
    if ([_categoryTableView numberOfSelectedRows] == 1) {
        MMCategory *selectedCategory;
        NSString *comment;

        selectedCategory = [self selectedCategory];
        [_categoryCommentTextView setEditable:YES];
        comment = [selectedCategory comment];
        if (comment == nil)
            comment = @"";
        [_categoryCommentTextView setString:comment];
        [_removeCategoryButtonCell setEnabled:YES];
    } else {
        [_categoryCommentTextView setEditable:NO];
        [_categoryCommentTextView setString:@""];
        [_removeCategoryButtonCell setEnabled:NO];
    }
}

- (void)_updateParameterComment;
{
    if ([_parameterTableView numberOfSelectedRows] == 1) {
        MMParameter *selectedParameter;
        NSString *comment;

        selectedParameter = [self selectedParameter];
        [_parameterCommentTextView setEditable:YES];
        comment = [selectedParameter comment];
        if (comment == nil)
            comment = @"";
        [_parameterCommentTextView setString:comment];
        [_removeParameterButtonCell setEnabled:YES];
    } else {
        [_parameterCommentTextView setEditable:NO];
        [_parameterCommentTextView setString:@""];
        [_removeParameterButtonCell setEnabled:NO];
    }
}

- (void)_updateMetaParameterComment;
{
    if ([_metaParameterTableView numberOfSelectedRows] == 1) {
        MMParameter *selectedMetaParameter;
        NSString *comment;

        selectedMetaParameter = [self selectedMetaParameter];
        [_metaParameterCommentTextView setEditable:YES];
        comment = [selectedMetaParameter comment];
        if (comment == nil)
            comment = @"";
        [_metaParameterCommentTextView setString:comment];
        [_removeMetaParameterButtonCell setEnabled:YES];
    } else {
        [_metaParameterCommentTextView setEditable:NO];
        [_metaParameterCommentTextView setString:@""];
        [_removeMetaParameterButtonCell setEnabled:NO];
    }
}

- (void)_updateSymbolComment;
{
    if ([_symbolTableView numberOfSelectedRows] == 1) {
        MMSymbol *selectedSymbol;
        NSString *comment;

        selectedSymbol = [self selectedSymbol];
        [_symbolCommentTextView setEditable:YES];
        comment = [selectedSymbol comment];
        if (comment == nil)
            comment = @"";
        [_symbolCommentTextView setString:comment];
        [_removeSymbolButtonCell setEnabled:YES];
    } else {
        [_symbolCommentTextView setEditable:NO];
        [_symbolCommentTextView setString:@""];
        [_removeSymbolButtonCell setEnabled:NO];
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

    [_categoryTableView scrollRowToVisible:index];

    // The row needs to be selected before we start editing it.
    [_categoryTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [_categoryTableView editColumn:[_categoryTableView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
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

    [self updateViews];

    index = [[[self model] parameters] indexOfObject:newParameter];
    [_parameterTableView scrollRowToVisible:index];

    // The row needs to be selected before we start editing it.
    [_parameterTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [_parameterTableView editColumn:[_parameterTableView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
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

    [self updateViews];

    index = [[[self model] metaParameters] indexOfObject:newParameter];
    [_metaParameterTableView scrollRowToVisible:index];

    // The row needs to be selected before we start editing it.
    [_metaParameterTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [_metaParameterTableView editColumn:[_metaParameterTableView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
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

    [self updateViews];

    index = [[[self model] symbols] indexOfObject:newSymbol];
    [_symbolTableView scrollRowToVisible:index];

    // The row needs to be selected before we start editing it.
    [_symbolTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [_symbolTableView editColumn:[_symbolTableView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
}

- (IBAction)removeSymbol:(id)sender;
{
    MMSymbol *selectedSymbol;

    selectedSymbol = [self selectedSymbol];
    if (selectedSymbol != nil)
        [[self model] removeSymbol:selectedSymbol];

    [self updateViews];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == _categoryTableView)
        return [[[self model] categories] count];

    if (tableView == _parameterTableView)
        return [[[self model] parameters] count];

    if (tableView == _metaParameterTableView)
        return [[[self model] metaParameters] count];

    if (tableView == _symbolTableView)
        return [[[self model] symbols] count];

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier;

    identifier = [tableColumn identifier];

    if (tableView == _categoryTableView) {
        MMCategory *category = [[[self model] categories] objectAtIndex:row];

        if ([@"hasComment" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[category hasComment]];
        } else if ([@"isUsed" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[[self model] isCategoryUsed:category]];
        } else if ([@"name" isEqual:identifier] == YES) {
            return [category name];
        }
    } else if (tableView == _parameterTableView || tableView == _metaParameterTableView) {
        // TODO (2004-03-18): When MMSymbol == MMParameter, we can merge the last three cases.
        MMParameter *parameter;

        if (tableView == _parameterTableView)
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
    } else if (tableView == _symbolTableView) {
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

    if (tableView == _categoryTableView) {
        MMCategory *category = [[[self model] categories] objectAtIndex:row];

        if ([@"name" isEqual:identifier] == YES) {
            // TODO (2004-03-19): Ensure unique name
            [category setName:object];
        }
    } else if (tableView == _parameterTableView || tableView == _metaParameterTableView) {
        MMParameter *parameter;

        if (tableView == _parameterTableView)
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
    } else if (tableView == _symbolTableView) {
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

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification;
{
    NSTableView *tableView = [notification object];

    if (tableView == _categoryTableView) {
        [self _updateCategoryComment];
    } else if (tableView == _parameterTableView) {
        [self _updateParameterComment];
    } else if (tableView == _metaParameterTableView) {
        [self _updateMetaParameterComment];
    } else if (tableView == _symbolTableView) {
        [self _updateSymbolComment];
    }
}

#pragma mark - NSTextViewDelegate

- (void)textDidEndEditing:(NSNotification *)notification;
{
    NSTextView *textView = [notification object];
    // NSTextMovement is a key in the user info
    //NSLog(@"[aNotification userInfo]: %@", [aNotification userInfo]);

    NSString *newComment = [[textView string] copy];
    //NSLog(@"(1) newComment: %@", newComment);
    if ([newComment length] == 0) {
        newComment = nil;
    }
    //NSLog(@"(2) newComment: %@", newComment);

    if (textView == _categoryCommentTextView) {
        [[self selectedCategory] setComment:newComment];
        // TODO (2004-03-18): Bleck.  Need notification from model that things have changed.
        [_categoryTableView reloadData];
    } else if (textView == _parameterCommentTextView) {
        [[self selectedParameter] setComment:newComment];
        [_parameterTableView reloadData];
    } else if (textView == _metaParameterCommentTextView) {
        [[self selectedMetaParameter] setComment:newComment];
        [_metaParameterTableView reloadData];
    } else if (textView == _symbolCommentTextView) {
        [[self selectedSymbol] setComment:newComment];
        [_symbolTableView reloadData];
    }
}

#pragma mark -

- (MMCategory *)selectedCategory;
{
    NSInteger selectedRow;

    selectedRow = [_categoryTableView selectedRow];

    return [[[self model] categories] objectAtIndex:selectedRow];
}

- (MMParameter *)selectedParameter;
{
    NSInteger selectedRow;

    selectedRow = [_parameterTableView selectedRow];

    return [[[self model] parameters] objectAtIndex:selectedRow];
}

- (MMParameter *)selectedMetaParameter;
{
    NSInteger selectedRow;

    selectedRow = [_metaParameterTableView selectedRow];

    return [[[self model] metaParameters] objectAtIndex:selectedRow];
}

- (MMSymbol *)selectedSymbol;
{
    NSInteger selectedRow;

    selectedRow = [_symbolTableView selectedRow];

    return [[[self model] symbols] objectAtIndex:selectedRow];
}

@end
