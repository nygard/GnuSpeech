//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MPostureEditor.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"

#import "MCommentCell.h"

// TODO (2004-03-20): Implement copy and pasting of postures.

@implementation MPostureEditor
{
    IBOutlet NSTableView *_postureTableView;
    IBOutlet NSTextField *_postureTotalTextField;
    IBOutlet NSButtonCell *_removePostureButtonCell;
    IBOutlet NSTextView *_postureCommentTextView;

    IBOutlet NSTableView *_categoryTableView;

    IBOutlet NSTableView *_parameterTableView;
    IBOutlet NSButton *_useDefaultParameterButton;

    IBOutlet NSTableView *_metaParameterTableView;
    IBOutlet NSButton *_useDefaultMetaParameterButton;

    IBOutlet NSTableView *_symbolTableView;
    IBOutlet NSButton *_useDefaultSymbolButton;

    MModel *_model;

    NSFont *_regularControlFont;
    NSFont *_boldControlFont;
}

- (id)initWithModel:(MModel *)model;
{
    if ((self = [super initWithWindowNibName:@"Postures"])) {
        _model = model;

        [self setWindowFrameAutosaveName:@"Postures"];
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
    [_postureTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
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

    _regularControlFont = [NSFont controlContentFontOfSize:[NSFont systemFontSize]];
    _boldControlFont = [[NSFontManager sharedFontManager] convertFont:_regularControlFont toHaveTrait:NSBoldFontMask];

    defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];

    checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
    [checkboxCell setControlSize:NSSmallControlSize];
    [checkboxCell setButtonType:NSSwitchButton];
    [checkboxCell setImagePosition:NSImageOnly];
    [checkboxCell setEditable:NO];

    [[_categoryTableView tableColumnWithIdentifier:@"isMember"] setDataCell:checkboxCell];

    commentImageCell = [[MCommentCell alloc] initImageCell:nil];
    [commentImageCell setImageAlignment:NSImageAlignCenter];
    [[_postureTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];

    [_postureCommentTextView setFieldEditor:YES];

    [[[_parameterTableView tableColumnWithIdentifier:@"value"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_parameterTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_parameterTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_parameterTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [[[_metaParameterTableView tableColumnWithIdentifier:@"value"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_metaParameterTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_metaParameterTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_metaParameterTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [[[_symbolTableView tableColumnWithIdentifier:@"value"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_symbolTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_symbolTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[_symbolTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [self updateViews];
    [_postureTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (void)updateViews;
{
    [_postureTableView reloadData];
    [_postureTotalTextField setIntegerValue:[[[self model] postures] count]];
    [self _updatePostureDetails];
    [self _updateUseDefaultButtons];
}

- (void)_updatePostureDetails;
{
    if ([_postureTableView numberOfSelectedRows] == 1) {
        MMPosture *selectedPosture;
        NSString *comment;

        selectedPosture = [self selectedPosture];
        [_postureCommentTextView setEditable:YES];
        comment = [selectedPosture comment];
        if (comment == nil)
            comment = @"";
        [_postureCommentTextView setString:comment];
        [_removePostureButtonCell setEnabled:YES];
    } else {
        [_postureCommentTextView setEditable:NO];
        [_postureCommentTextView setString:@""];
        [_removePostureButtonCell setEnabled:NO];
    }

    [_categoryTableView reloadData];
    [_parameterTableView reloadData];
    [_metaParameterTableView reloadData];
    [_symbolTableView reloadData];
}

- (void)_updateUseDefaultButtons;
{
    [_useDefaultParameterButton setEnabled:[_parameterTableView numberOfSelectedRows] == 1];
    [_useDefaultMetaParameterButton setEnabled:[_metaParameterTableView numberOfSelectedRows] == 1];
    [_useDefaultSymbolButton setEnabled:[_symbolTableView numberOfSelectedRows] == 1];
}

- (MMPosture *)selectedPosture;
{
    NSInteger selectedRow;

    selectedRow = [_postureTableView selectedRow];
    if (selectedRow == -1)
        return nil;

    return [[[self model] postures] objectAtIndex:selectedRow];
}

- (IBAction)addPosture:(id)sender;
{
    MMPosture *newPosture;
    NSUInteger index;

    newPosture = [[MMPosture alloc] initWithModel:[self model]];
    [[self model] addPosture:newPosture];

    [self updateViews];

    index = [[[self model] postures] indexOfObject:newPosture];

    [_postureTableView scrollRowToVisible:index];

    // The row needs to be selected before we start editing it.
    [_postureTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [_postureTableView editColumn:[_postureTableView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
}

- (IBAction)removePosture:(id)sender;
{
    MMPosture *selectedPosture;

    selectedPosture = [self selectedPosture];
    if (selectedPosture != nil)
        [[self model] removePosture:selectedPosture];

    [self updateViews];
}

- (IBAction)useDefaultValueForParameter:(id)sender;
{
    NSInteger selectedRow;
    MMParameter *selectedParameter;
    MMTarget *selectedTarget;

    selectedRow = [_parameterTableView selectedRow];
    selectedParameter = [[[self model] parameters] objectAtIndex:selectedRow];
    NSParameterAssert(selectedParameter != nil);

    selectedTarget = [[[self selectedPosture] parameterTargets] objectAtIndex:selectedRow];
    NSParameterAssert(selectedTarget != nil);

    [selectedTarget setValue:[selectedParameter defaultValue]];
    [self updateViews];
}

- (IBAction)useDefaultValueForMetaParameter:(id)sender;
{
    NSInteger selectedRow;
    MMParameter *selectedParameter;
    MMTarget *selectedTarget;

    selectedRow = [_metaParameterTableView selectedRow];
    selectedParameter = [[[self model] metaParameters] objectAtIndex:selectedRow];
    NSParameterAssert(selectedParameter != nil);

    selectedTarget = [[[self selectedPosture] metaParameterTargets] objectAtIndex:selectedRow];
    NSParameterAssert(selectedTarget != nil);

    [selectedTarget setValue:[selectedParameter defaultValue]];
    [self updateViews];
}

- (IBAction)useDefaultValueForSymbol:(id)sender;
{
    NSInteger selectedRow;
    MMSymbol *selectedSymbol;
    MMTarget *selectedTarget;

    selectedRow = [_symbolTableView selectedRow];
    selectedSymbol = [[[self model] symbols] objectAtIndex:selectedRow];
    NSParameterAssert(selectedSymbol != nil);

    selectedTarget = [[[self selectedPosture] symbolTargets] objectAtIndex:selectedRow];
    NSParameterAssert(selectedTarget != nil);

    [selectedTarget setValue:[selectedSymbol defaultValue]];
    [self updateViews];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == _postureTableView)
        return [[[self model] postures] count];

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
    id identifier = [tableColumn identifier];

    if (tableView == _postureTableView) {
        MMPosture *posture = [[[self model] postures] objectAtIndex:row];

        if ([@"hasComment" isEqual:identifier]) {
            return [NSNumber numberWithBool:[posture hasComment]];
        } else if ([@"name" isEqual:identifier]) {
            return [posture name];
        }
    } else if (tableView == _categoryTableView) {
        MMCategory *category = [[[self model] categories] objectAtIndex:row];

        if ([@"isMember" isEqual:identifier]) {
            return [NSNumber numberWithBool:[[self selectedPosture] isMemberOfCategory:category]];
        } else if ([@"name" isEqual:identifier]) {
            return [category name];
        }
    } else if (tableView == _parameterTableView || tableView == _metaParameterTableView) {
        // TODO (2004-03-18): When MMSymbol == MMParameter, we can merge the last three cases.
        MMParameter *parameter;

        if (tableView == _parameterTableView)
            parameter = [[[self model] parameters] objectAtIndex:row];
        else
            parameter = [[[self model] metaParameters] objectAtIndex:row];

        if ([@"name" isEqual:identifier]) {
            return [parameter name];
        } else if ([@"value" isEqual:identifier]) {
            MMTarget *aTarget;

            if (tableView == _parameterTableView)
                aTarget = [[[self selectedPosture] parameterTargets] objectAtIndex:row];
            else
                aTarget = [[[self selectedPosture] metaParameterTargets] objectAtIndex:row];
            if (aTarget == nil)
                return nil;

            return [NSNumber numberWithDouble:[aTarget value]];
        } else if ([@"minimum" isEqual:identifier]) {
            return [NSNumber numberWithDouble:[parameter minimumValue]];
        } else if ([@"maximum" isEqual:identifier]) {
            return [NSNumber numberWithDouble:[parameter maximumValue]];
        } else if ([@"default" isEqual:identifier]) {
            return [NSNumber numberWithDouble:[parameter defaultValue]];
        }
    } else if (tableView == _symbolTableView) {
        MMSymbol *symbol = [[[self model] symbols] objectAtIndex:row];

        if ([@"name" isEqual:identifier]) {
            return [symbol name];
        } else if ([@"value" isEqual:identifier]) {
            MMTarget *aTarget;

            aTarget = [[[self selectedPosture] symbolTargets] objectAtIndex:row];
            if (aTarget == nil)
                return nil;

            return [NSNumber numberWithDouble:[aTarget value]];
        } else if ([@"minimum" isEqual:identifier]) {
            return [NSNumber numberWithDouble:[symbol minimumValue]];
        } else if ([@"maximum" isEqual:identifier]) {
            return [NSNumber numberWithDouble:[symbol maximumValue]];
        } else if ([@"default" isEqual:identifier]) {
            return [NSNumber numberWithDouble:[symbol defaultValue]];
        }
    }

    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier = [tableColumn identifier];

    if (tableView == _postureTableView) {
        MMPosture *posture = [[[self model] postures] objectAtIndex:row];

        if ([@"name" isEqual:identifier]) {
            [posture setName:object];
        }
    } else if (tableView == _categoryTableView) {
        MMCategory *category = [[[self model] categories] objectAtIndex:row];

        if ([@"isMember" isEqual:identifier]) {
            if ([object boolValue])
                [[self selectedPosture] addCategory:category];
            else
                [[self selectedPosture] removeCategory:category];
        }
    } else if (tableView == _parameterTableView || tableView == _metaParameterTableView) {
        if ([@"value" isEqual:identifier]) {
            MMTarget *aTarget;

            if (tableView == _parameterTableView)
                aTarget = [[[self selectedPosture] parameterTargets] objectAtIndex:row];
            else
                aTarget = [[[self selectedPosture] metaParameterTargets] objectAtIndex:row];

            [aTarget setValue:[object doubleValue]];
        }
    } else if (tableView == _symbolTableView) {
        if ([@"value" isEqual:identifier]) {
            MMTarget *aTarget;

            aTarget = [[[self selectedPosture] symbolTargets] objectAtIndex:row];
            [aTarget setValue:[object doubleValue]];
        }
    }
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification;
{
    NSTableView *tableView = [notification object];

    if (tableView == _postureTableView) {
        [self _updatePostureDetails];
    } else if (tableView == _parameterTableView) {
        [self _updateUseDefaultButtons];
    } else if (tableView == _metaParameterTableView) {
        [self _updateUseDefaultButtons];
    } else if (tableView == _symbolTableView) {
        [self _updateUseDefaultButtons];
    }
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    // TODO (2004-03-19): Would really prefer to have "isDefaultValue" method in the model.  Plus it could cache the value.
    if (tableView == _parameterTableView || tableView == _metaParameterTableView) {
        MMParameter *parameter;
        MMTarget *target;

        if (tableView == _parameterTableView) {
            parameter = [[[self model] parameters] objectAtIndex:row];
            target = [[[self selectedPosture] parameterTargets] objectAtIndex:row];
        } else {
            parameter = [[[self model] metaParameters] objectAtIndex:row];
            target = [[[self selectedPosture] metaParameterTargets] objectAtIndex:row];
        }

        if ([target value] == [parameter defaultValue])
            [cell setFont:_boldControlFont];
        else
            [cell setFont:_regularControlFont];
    } else if (tableView == _symbolTableView) {
        MMSymbol *symbol = [[[self model] symbols] objectAtIndex:row];
        MMTarget *target = [[[self selectedPosture] symbolTargets] objectAtIndex:row];
        if ([target value] == [symbol defaultValue])
            [cell setFont:_boldControlFont];
        else
            [cell setFont:_regularControlFont];
    } else {
        [cell setFont:_regularControlFont];
    }
}

- (BOOL)control:(NSControl *)control shouldProcessCharacters:(NSString *)characters;
{
    NSArray *postures;
    NSUInteger count, index;
    MMPosture *posture;

    postures = [[self model] postures];
    count = [postures count];
    for (index = 0; index < count; index++) {
        posture = [postures objectAtIndex:index];
        if ([[posture name] hasPrefix:characters]) {
            [_postureTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
            [_postureTableView scrollRowToVisible:index];
            return NO;
        }
    }

    return YES;
}

#pragma mark - NSTextViewDelegate

- (void)textDidEndEditing:(NSNotification *)notification;
{
    NSTextView *textView = [notification object];
    // NSTextMovement is a key in the user info
    //NSLog(@"[notification userInfo]: %@", [notification userInfo]);

    NSString *newComment = [[textView string] copy];
    //NSLog(@"(1) newComment: %@", newComment);
    if ([newComment length] == 0) {
        newComment = nil;
    }
    //NSLog(@"(2) newComment: %@", newComment);

    if (textView == _postureCommentTextView) {
        [[self selectedPosture] setComment:newComment];
        // TODO (2004-03-18): Bleck.  Need notification from model that things have changed.
        [self updateViews];
    }
}

@end
