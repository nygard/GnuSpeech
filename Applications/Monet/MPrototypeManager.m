//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MPrototypeManager.h"

#import <AppKit/AppKit.h>
#import "NSOutlineView-Extensions.h"

#import "FormulaExpression.h"
#import "FormulaParser.h"
#import "MCommentCell.h"
#import "MMEquation.h"
#import "MModel.h"
#import "MonetList.h"
#import "NamedList.h"
#import "MMTransition.h"

@implementation MPrototypeManager

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"PrototypeManager"] == nil)
        return nil;

    model = [aModel retain];
    formulaParser = [[FormulaParser alloc] init];
    [formulaParser setSymbolList:[model symbols]];

    [self setWindowFrameAutosaveName:@"Prototype Manager"];

    return self;
}

- (void)dealloc;
{
    [model release];
    [formulaParser release];

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

    [formulaParser setSymbolList:[model symbols]];

    [self updateViews];
    [self expandOutlines];
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
    NSButtonCell *checkboxCell;
    MCommentCell *commentImageCell;

    checkboxCell = [[NSButtonCell alloc] initTextCell:@""];
    [checkboxCell setControlSize:NSSmallControlSize];
    [checkboxCell setButtonType:NSSwitchButton];
    [checkboxCell setImagePosition:NSImageOnly];
    [checkboxCell setEditable:NO];

    [[equationOutlineView tableColumnWithIdentifier:@"isUsed"] setDataCell:checkboxCell];
    [[transitionOutlineView tableColumnWithIdentifier:@"isUsed"] setDataCell:checkboxCell];
    [[specialTransitionOutlineView tableColumnWithIdentifier:@"isUsed"] setDataCell:checkboxCell];

    [checkboxCell release];

    commentImageCell = [[MCommentCell alloc] initImageCell:nil];
    [commentImageCell setImageAlignment:NSImageAlignCenter];
    [[equationOutlineView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[transitionOutlineView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[specialTransitionOutlineView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [commentImageCell release];

    [equationOutlineView moveColumn:[equationOutlineView columnWithIdentifier:@"hasComment"] toColumn:0];
    [transitionOutlineView moveColumn:[transitionOutlineView columnWithIdentifier:@"hasComment"] toColumn:0];
    [specialTransitionOutlineView moveColumn:[specialTransitionOutlineView columnWithIdentifier:@"hasComment"] toColumn:0];

    [equationTextView setFieldEditor:YES];
    [equationCommentTextView setFieldEditor:YES];
    [transitionCommentTextView setFieldEditor:YES];
    [specialTransitionCommentTextView setFieldEditor:YES];

    [self updateViews];
    [self expandOutlines];
}

- (void)updateViews;
{
    [equationOutlineView reloadData];
    [transitionOutlineView reloadData];
    [specialTransitionOutlineView reloadData];

    [self _updateEquationDetails];
    [self _updateTransitionDetails];
    [self _updateSpecialTransitionDetails];
}

- (void)expandOutlines;
{
    unsigned int count, index;

    count = [[model equations] count];
    for (index = 0; index < count; index++)
        [equationOutlineView expandItem:[[model equations] objectAtIndex:index]];

    count = [[model transitions] count];
    for (index = 0; index < count; index++)
        [transitionOutlineView expandItem:[[model transitions] objectAtIndex:index]];

    count = [[model specialTransitions] count];
    for (index = 0; index < count; index++)
        [specialTransitionOutlineView expandItem:[[model specialTransitions] objectAtIndex:index]];

    [equationOutlineView sizeToFit];
    [transitionOutlineView sizeToFit];
    [specialTransitionOutlineView sizeToFit];
}

- (void)_updateEquationDetails;
{
    if ([equationOutlineView numberOfSelectedRows] == 1) {
        id selectedEquationOrGroup;
        NSString *comment;

        selectedEquationOrGroup = [equationOutlineView itemAtRow:[equationOutlineView selectedRow]];
        [equationCommentTextView setEditable:YES];
        comment = [selectedEquationOrGroup comment];
        if (comment == nil)
            comment = @"";
        [equationCommentTextView setString:comment];
        [removeEquationButtonCell setEnabled:YES];

        if ([selectedEquationOrGroup isKindOfClass:[MMEquation class]] == YES) {
            NSString *expressionString;

            [equationTextView setEditable:YES];
            expressionString = [[selectedEquationOrGroup expression] expressionString];
            if (expressionString == nil)
                expressionString = @"";
            [equationTextView setString:expressionString];
        } else {
            [equationTextView setEditable:NO];
            [equationTextView setString:@""];
        }

        [equationParserMessagesTextView setString:@""];
    } else {
        [equationTextView setEditable:NO];
        [equationTextView setString:@""];
        [equationCommentTextView setEditable:NO];
        [equationCommentTextView setString:@""];
        [removeEquationButtonCell setEnabled:NO];
    }
}

- (void)_updateTransitionDetails;
{
    if ([transitionOutlineView numberOfSelectedRows] == 1) {
        id selectedTransitionOrGroup;
        NSString *comment;

        selectedTransitionOrGroup = [transitionOutlineView itemAtRow:[transitionOutlineView selectedRow]];
        [transitionCommentTextView setEditable:YES];
        comment = [selectedTransitionOrGroup comment];
        if (comment == nil)
            comment = @"";
        [transitionCommentTextView setString:comment];
        [removeTransitionButtonCell setEnabled:YES];

        if ([selectedTransitionOrGroup isKindOfClass:[MMTransition class]] == YES) {
            [transitionTypeMatrix setEnabled:YES];
            [transitionTypeMatrix selectCellWithTag:[(MMTransition *)selectedTransitionOrGroup type]];
        } else {
            [transitionTypeMatrix setEnabled:NO];
            [transitionTypeMatrix selectCellWithTag:2];
        }
    } else {
        [transitionCommentTextView setEditable:NO];
        [transitionCommentTextView setString:@""];
        [removeTransitionButtonCell setEnabled:NO];

        [transitionTypeMatrix setEnabled:NO];
        [transitionTypeMatrix selectCellWithTag:2];
    }
}

- (void)_updateSpecialTransitionDetails;
{
    if ([specialTransitionOutlineView numberOfSelectedRows] == 1) {
        id selectedSpecialTransitionOrGroup;
        NSString *comment;

        selectedSpecialTransitionOrGroup = [specialTransitionOutlineView itemAtRow:[specialTransitionOutlineView selectedRow]];
        [specialTransitionCommentTextView setEditable:YES];
        comment = [selectedSpecialTransitionOrGroup comment];
        if (comment == nil)
            comment = @"";
        [specialTransitionCommentTextView setString:comment];
        [removeSpecialTransitionButtonCell setEnabled:YES];

        if ([selectedSpecialTransitionOrGroup isKindOfClass:[MMTransition class]] == YES) {
            [specialTransitionTypeMatrix setEnabled:YES];
            [specialTransitionTypeMatrix selectCellWithTag:[(MMTransition *)selectedSpecialTransitionOrGroup type]];
        } else {
            [specialTransitionTypeMatrix setEnabled:NO];
            [specialTransitionTypeMatrix selectCellWithTag:2];
        }
    } else {
        [specialTransitionCommentTextView setEditable:NO];
        [specialTransitionCommentTextView setString:@""];
        [removeSpecialTransitionButtonCell setEnabled:NO];

        [specialTransitionTypeMatrix setEnabled:NO];
        [specialTransitionTypeMatrix selectCellWithTag:2];
    }
}

- (MMEquation *)selectedEquation;
{
    return [equationOutlineView selectedItemOfClass:[MMEquation class]];
}

- (MMTransition *)selectedTransition;
{
    return [transitionOutlineView selectedItemOfClass:[MMTransition class]];
}

- (MMTransition *)selectedSpecialTransition;
{
    return [specialTransitionOutlineView selectedItemOfClass:[MMTransition class]];
}

//
// Equations
//

- (IBAction)addEquationGroup:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)addEquation:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)removeEquation:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)setEquation:(id)sender;
{
    FormulaExpression *result;
    NSString *str;

    result = [formulaParser parseString:[equationTextView string]];

    str = [formulaParser errorMessage];
    if ([str length] == 0)
        str = @"Equation parsed.";
    [equationParserMessagesTextView setString:str];

    if (result == nil) {
        [equationTextView setSelectedRange:[formulaParser errorRange]];
        [[self window] makeFirstResponder:equationTextView];
    } else {
        [[self selectedEquation] setExpression:result];
    }
}

- (IBAction)revertEquation:(id)sender;
{
    [self _updateEquationDetails];
}

//
// Transitions
//

- (IBAction)addTransitionGroup:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)addTransition:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)removeTransition:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)setTransitionType:(id)sender;
{
    NSLog(@" > %s", _cmd);
    [[self selectedTransition] setType:[[transitionTypeMatrix selectedCell] tag]];
    NSLog(@"<  %s", _cmd);
}

- (IBAction)editTransition:(id)sender;
{
    NSLog(@" > %s", _cmd);
    [[NSApp delegate] editTransition:[self selectedTransition]];
    NSLog(@"<  %s", _cmd);
}

//
// Special Transitions
//

- (IBAction)addSpecialTransitionGroup:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)addSpecialTransition:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)removeSpecialTransition:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)setSpecialTransitionType:(id)sender;
{
    NSLog(@" > %s", _cmd);
    [[self selectedSpecialTransition] setType:[[specialTransitionTypeMatrix selectedCell] tag]];
    NSLog(@"<  %s", _cmd);
}

- (IBAction)editSpecialTransition:(id)sender;
{
    NSLog(@" > %s", _cmd);
    [[NSApp delegate] editSpecialTransition:[self selectedSpecialTransition]];
    NSLog(@"<  %s", _cmd);
}

//
// NSOutlineView data source
//

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
{
    //NSLog(@"-> %s, item: %p", _cmd, item);
    if (outlineView == equationOutlineView) {
        if (item == nil)
            return [[model equations] count];
        else
            return [item count];
    } else if (outlineView == transitionOutlineView) {
        if (item == nil)
            return [[model transitions] count];
        else
            return [item count];
    } else if (outlineView == specialTransitionOutlineView) {
        if (item == nil)
            return [[model specialTransitions] count];
        else
            return [item count];
    }

    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item;
{
    if (outlineView == equationOutlineView) {
        if (item == nil)
            return [[model equations] objectAtIndex:index];
        else
            return [item objectAtIndex:index];
    } else if (outlineView == transitionOutlineView) {
        if (item == nil)
            return [[model transitions] objectAtIndex:index];
        else
            return [item objectAtIndex:index];
    } else if (outlineView == specialTransitionOutlineView) {
        if (item == nil)
            return [[model specialTransitions] objectAtIndex:index];
        else
            return [item objectAtIndex:index];
    }

    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
{
    if (outlineView == equationOutlineView) {
        return [item isKindOfClass:[NamedList class]];
    } else if (outlineView == transitionOutlineView) {
        return [item isKindOfClass:[NamedList class]];
    } else if (outlineView == specialTransitionOutlineView) {
        return [item isKindOfClass:[NamedList class]];
    }

    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
{
    id identifier;

    identifier = [tableColumn identifier];
    //NSLog(@"identifier: %@, item: %p, item class: %@", identifier, item, NSStringFromClass([item class]));

    if (outlineView == equationOutlineView) {
        if ([@"name" isEqual:identifier] == YES) {
            return [item name];
        } else if ([@"hasComment" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[item hasComment]];
        } else if ([@"isUsed" isEqual:identifier] == YES) {
        }
    } else if (outlineView == transitionOutlineView) {
        if ([@"name" isEqual:identifier] == YES) {
            return [item name];
        } else if ([@"hasComment" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[item hasComment]];
        }
    } else if (outlineView == specialTransitionOutlineView) {
        if ([@"name" isEqual:identifier] == YES) {
            return [item name];
        } else if ([@"hasComment" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[item hasComment]];
        }
    }

    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item;
{
    NSLog(@"-> %s", _cmd);
    return YES;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item;
{
    //[outlineView expandItem:item];
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item;
{
    id identifier;

    identifier = [tableColumn identifier];

    if (outlineView == equationOutlineView) {
        if ([@"isUsed" isEqual:identifier] == YES) {
            if ([item isKindOfClass:[MMEquation class]] == YES)
                [cell setTransparent:NO];
            else
                [cell setTransparent:YES];
        }
    } else if (outlineView == transitionOutlineView || outlineView == specialTransitionOutlineView) {
        if ([@"isUsed" isEqual:identifier] == YES) {
            if ([item isKindOfClass:[MMTransition class]] == YES)
                [cell setTransparent:NO];
            else
                [cell setTransparent:YES];
        }
    }
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
{
    id identifier;

    identifier = [tableColumn identifier];

    if (outlineView == equationOutlineView) {
        if ([@"name" isEqual:identifier] == YES) {
            if ([item respondsToSelector:@selector(setName:)] == YES)
                [(MMEquation *)item setName:object];
        }
    } else if (outlineView == transitionOutlineView || outlineView == specialTransitionOutlineView) {
        if ([@"name" isEqual:identifier] == YES) {
            if ([item respondsToSelector:@selector(setName:)] == YES)
                [(MMTransition *)item setName:object];
        }
    }
}
//
// NSOutlineView delegate
//

- (void)outlineViewSelectionDidChange:(NSNotification *)aNotification;
{
    NSOutlineView *outlineView;

    NSLog(@" > %s", _cmd);

    outlineView = [aNotification object];

    if (outlineView == equationOutlineView) {
        [self _updateEquationDetails];
    } else if (outlineView == transitionOutlineView) {
        [self _updateTransitionDetails];
    } else if (outlineView == specialTransitionOutlineView) {
        [self _updateSpecialTransitionDetails];
    }

    NSLog(@"<  %s", _cmd);
}

//
// NSTextView delegate
//

- (void)textDidEndEditing:(NSNotification *)aNotification;
{
    NSTextView *textView;

    NSLog(@" > %s", _cmd);

    textView = [aNotification object];
    // NSTextMovement is a key in the user info
    //NSLog(@"[aNotification userInfo]: %@", [aNotification userInfo]);

    if (textView == equationTextView) {
        [self setEquation:nil];
    } else {
        NSString *newStringValue;
        id selectedItem;

        newStringValue = [[textView string] copy];

        //NSLog(@"(1) newStringValue: %@", newStringValue);
        if ([newStringValue length] == 0) {
            [newStringValue release];
            newStringValue = nil;
        }
        //NSLog(@"(2) newStringValue: %@", newStringValue);

        if (textView == equationCommentTextView) {
            selectedItem = [equationOutlineView selectedItem];
            if ([selectedItem respondsToSelector:@selector(setComment:)] == YES) {
                [selectedItem setComment:newStringValue];
                // TODO (2004-03-18): Bleck.  Need notification from model that things have changed.
                [equationOutlineView reloadItem:selectedItem]; // To show note icon
            }
        } else if (textView == transitionCommentTextView) {
            selectedItem = [transitionOutlineView selectedItem];
            if ([selectedItem respondsToSelector:@selector(setComment:)] == YES) {
                [selectedItem setComment:newStringValue];
                [transitionOutlineView reloadItem:selectedItem]; // To show note icon
            }
        } else if (textView == specialTransitionCommentTextView) {
            selectedItem = [transitionOutlineView selectedItem];
            if ([selectedItem respondsToSelector:@selector(setComment:)] == YES) {
                [selectedItem setComment:newStringValue];
                [specialTransitionOutlineView reloadItem:selectedItem]; // To show note icon
            }
        }

        [newStringValue release];
    }


    NSLog(@"<  %s", _cmd);
}

@end
