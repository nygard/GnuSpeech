//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MPostureEditor.h"

#import <AppKit/AppKit.h>
#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"

#import "MCommentCell.h"

// TODO (2004-03-20): Implement copy and pasting of postures.

@implementation MPostureEditor

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"Postures"] == nil)
        return nil;

    model = [aModel retain];

    [self setWindowFrameAutosaveName:@"Postures"];

    return self;
}

- (void)dealloc;
{
    [model release];
    [regularControlFont release];
    [boldControlFont release];

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
    [postureTableView selectRow:0 byExtendingSelection:NO];
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

    regularControlFont = [[NSFont controlContentFontOfSize:[NSFont systemFontSize]] retain];
    boldControlFont = [[[NSFontManager sharedFontManager] convertFont:regularControlFont toHaveTrait:NSBoldFontMask] retain];

    defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];

    checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
    [checkboxCell setControlSize:NSSmallControlSize];
    [checkboxCell setButtonType:NSSwitchButton];
    [checkboxCell setImagePosition:NSImageOnly];
    [checkboxCell setEditable:NO];

    [[categoryTableView tableColumnWithIdentifier:@"isMember"] setDataCell:checkboxCell];

    [checkboxCell release];

    commentImageCell = [[MCommentCell alloc] initImageCell:nil];
    [commentImageCell setImageAlignment:NSImageAlignCenter];
    [[postureTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [commentImageCell release];

    [postureCommentTextView setFieldEditor:YES];

    [[[parameterTableView tableColumnWithIdentifier:@"value"] dataCell] setFormatter:defaultNumberFormatter];
    [[[parameterTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[parameterTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[parameterTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [[[metaParameterTableView tableColumnWithIdentifier:@"value"] dataCell] setFormatter:defaultNumberFormatter];
    [[[metaParameterTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[metaParameterTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[metaParameterTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [[[symbolTableView tableColumnWithIdentifier:@"value"] dataCell] setFormatter:defaultNumberFormatter];
    [[[symbolTableView tableColumnWithIdentifier:@"minimum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[symbolTableView tableColumnWithIdentifier:@"maximum"] dataCell] setFormatter:defaultNumberFormatter];
    [[[symbolTableView tableColumnWithIdentifier:@"default"] dataCell] setFormatter:defaultNumberFormatter];

    [self updateViews];
    [postureTableView selectRow:0 byExtendingSelection:NO];
}

- (void)updateViews;
{
    [postureTableView reloadData];
    [postureTotalTextField setIntValue:[[[self model] postures] count]];
    [self _updatePostureDetails];
    [self _updateUseDefaultButtons];
}

- (void)_updatePostureDetails;
{
    if ([postureTableView numberOfSelectedRows] == 1) {
        MMPosture *selectedPosture;
        NSString *comment;

        selectedPosture = [self selectedPosture];
        [postureCommentTextView setEditable:YES];
        comment = [selectedPosture comment];
        if (comment == nil)
            comment = @"";
        [postureCommentTextView setString:comment];
        [removePostureButtonCell setEnabled:YES];
    } else {
        [postureCommentTextView setEditable:NO];
        [postureCommentTextView setString:@""];
        [removePostureButtonCell setEnabled:NO];
    }

    [categoryTableView reloadData];
    [parameterTableView reloadData];
    [metaParameterTableView reloadData];
    [symbolTableView reloadData];
}

- (void)_updateUseDefaultButtons;
{
    [useDefaultParameterButton setEnabled:[parameterTableView numberOfSelectedRows] == 1];
    [useDefaultMetaParameterButton setEnabled:[metaParameterTableView numberOfSelectedRows] == 1];
    [useDefaultSymbolButton setEnabled:[symbolTableView numberOfSelectedRows] == 1];
}

- (MMPosture *)selectedPosture;
{
    int selectedRow;

    selectedRow = [postureTableView selectedRow];
    if (selectedRow == -1)
        return nil;

    return [[[self model] postures] objectAtIndex:selectedRow];
}

- (IBAction)addPosture:(id)sender;
{
    MMPosture *newPosture;
    unsigned int index;

    newPosture = [[MMPosture alloc] initWithModel:[self model]];
    [[self model] addPosture:newPosture];

    [self updateViews];

    index = [[[self model] postures] indexOfObject:newPosture];
    [newPosture release];

    [postureTableView scrollRowToVisible:index];

    // The row needs to be selected before we start editing it.
    [postureTableView selectRow:index byExtendingSelection:NO];
    [postureTableView editColumn:[postureTableView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
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
    int selectedRow;
    MMParameter *selectedParameter;
    MMTarget *selectedTarget;

    selectedRow = [parameterTableView selectedRow];
    selectedParameter = [[[self model] parameters] objectAtIndex:selectedRow];
    assert(selectedParameter != nil);

    selectedTarget = [[[self selectedPosture] parameterTargets] objectAtIndex:selectedRow];
    assert(selectedTarget != nil);

    [selectedTarget setValue:[selectedParameter defaultValue]];
    [self updateViews];
}

- (IBAction)useDefaultValueForMetaParameter:(id)sender;
{
    int selectedRow;
    MMParameter *selectedParameter;
    MMTarget *selectedTarget;

    selectedRow = [metaParameterTableView selectedRow];
    selectedParameter = [[[self model] metaParameters] objectAtIndex:selectedRow];
    assert(selectedParameter != nil);

    selectedTarget = [[[self selectedPosture] metaParameterTargets] objectAtIndex:selectedRow];
    assert(selectedTarget != nil);

    [selectedTarget setValue:[selectedParameter defaultValue]];
    [self updateViews];
}

- (IBAction)useDefaultValueForSymbol:(id)sender;
{
    int selectedRow;
    MMSymbol *selectedSymbol;
    MMTarget *selectedTarget;

    selectedRow = [symbolTableView selectedRow];
    selectedSymbol = [[[self model] symbols] objectAtIndex:selectedRow];
    assert(selectedSymbol != nil);

    selectedTarget = [[[self selectedPosture] symbolTargets] objectAtIndex:selectedRow];
    assert(selectedTarget != nil);

    [selectedTarget setValue:[selectedSymbol defaultValue]];
    [self updateViews];
}

//
// NSTableView data source
//

- (int)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == postureTableView)
        return [[[self model] postures] count];

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

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
{
    id identifier;

    identifier = [tableColumn identifier];

    if (tableView == postureTableView) {
        MMPosture *posture = [[[self model] postures] objectAtIndex:row];

        if ([@"hasComment" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[posture hasComment]];
        } else if ([@"name" isEqual:identifier] == YES) {
            return [posture name];
        }
    } else if (tableView == categoryTableView) {
        MMCategory *category = [[[self model] categories] objectAtIndex:row];

        if ([@"isMember" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[[self selectedPosture] isMemberOfCategory:category]];
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

        if ([@"name" isEqual:identifier] == YES) {
            return [parameter name];
        } else if ([@"value" isEqual:identifier] == YES) {
            MMTarget *aTarget;

            if (tableView == parameterTableView)
                aTarget = [[[self selectedPosture] parameterTargets] objectAtIndex:row];
            else
                aTarget = [[[self selectedPosture] metaParameterTargets] objectAtIndex:row];
            if (aTarget == nil)
                return nil;

            return [NSNumber numberWithDouble:[aTarget value]];
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
            return [symbol name];
        } else if ([@"value" isEqual:identifier] == YES) {
            MMTarget *aTarget;

            aTarget = [[[self selectedPosture] symbolTargets] objectAtIndex:row];
            if (aTarget == nil)
                return nil;

            return [NSNumber numberWithDouble:[aTarget value]];
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

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row;
{
    id identifier;

    identifier = [tableColumn identifier];

    if (tableView == postureTableView) {
        MMPosture *posture = [[[self model] postures] objectAtIndex:row];

        if ([@"name" isEqual:identifier] == YES) {
            [posture setName:object];
        }
    } else if (tableView == categoryTableView) {
        MMCategory *category = [[[self model] categories] objectAtIndex:row];

        if ([@"isMember" isEqual:identifier] == YES) {
            if ([object boolValue] == YES)
                [[self selectedPosture] addCategory:category];
            else
                [[self selectedPosture] removeCategory:category];
        }
    } else if (tableView == parameterTableView || tableView == metaParameterTableView) {
        if ([@"value" isEqual:identifier] == YES) {
            MMTarget *aTarget;

            if (tableView == parameterTableView)
                aTarget = [[[self selectedPosture] parameterTargets] objectAtIndex:row];
            else
                aTarget = [[[self selectedPosture] metaParameterTargets] objectAtIndex:row];

            [aTarget setValue:[object doubleValue]];
        }
    } else if (tableView == symbolTableView) {
        if ([@"value" isEqual:identifier] == YES) {
            MMTarget *aTarget;

            aTarget = [[[self selectedPosture] symbolTargets] objectAtIndex:row];
            [aTarget setValue:[object doubleValue]];
        }
    }
}

//
// NSTableView delegate
//

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
{
    NSTableView *tableView;

    tableView = [aNotification object];

    if (tableView == postureTableView) {
        [self _updatePostureDetails];
    } else if (tableView == parameterTableView) {
        [self _updateUseDefaultButtons];
    } else if (tableView == metaParameterTableView) {
        [self _updateUseDefaultButtons];
    } else if (tableView == symbolTableView) {
        [self _updateUseDefaultButtons];
    }
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row;
{
    // TODO (2004-03-19): Would really prefer to have "isDefaultValue" method in the model.  Plus it could cache the value.
    if (tableView == parameterTableView || tableView == metaParameterTableView) {
        MMParameter *aParameter;
        MMTarget *aTarget;

        if (tableView == parameterTableView) {
            aParameter = [[[self model] parameters] objectAtIndex:row];
            aTarget = [[[self selectedPosture] parameterTargets] objectAtIndex:row];
        } else {
            aParameter = [[[self model] metaParameters] objectAtIndex:row];
            aTarget = [[[self selectedPosture] metaParameterTargets] objectAtIndex:row];
        }

        if ([aTarget value] == [aParameter defaultValue])
            [cell setFont:boldControlFont];
        else
            [cell setFont:regularControlFont];
    } else if (tableView == symbolTableView) {
        MMSymbol *aSymbol;
        MMTarget *aTarget;

        aSymbol = [[[self model] symbols] objectAtIndex:row];
        aTarget = [[[self selectedPosture] symbolTargets] objectAtIndex:row];
        if ([aTarget value] == [aSymbol defaultValue])
            [cell setFont:boldControlFont];
        else
            [cell setFont:regularControlFont];
    } else {
        [cell setFont:regularControlFont];
    }
}

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
            [postureTableView selectRow:index byExtendingSelection:NO];
            [postureTableView scrollRowToVisible:index];
            return NO;
        }
    }

    return YES;
}

//
// NSTextView delegate
//

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

    if (textView == postureCommentTextView) {
        [[self selectedPosture] setComment:newComment];
        // TODO (2004-03-18): Bleck.  Need notification from model that things have changed.
        [self updateViews];
    }

    [newComment release];
}

@end
