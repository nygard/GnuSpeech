//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MPrototypeManager.h"

#import <AppKit/AppKit.h>
#import "NSOutlineView-Extensions.h"

#import "MCommentCell.h"
#import "MMEquation.h"
#import "MMFormulaExpression.h"
#import "MMFormulaParser.h"
#import "MModel.h"
#import "MMTransition.h"
#import "MonetList.h"
#import "NamedList.h"
#import "SpecialView.h"
#import "TransitionView.h"

// TODO (2004-03-23): Implement copy/paste of equations, transitions, special transitions.  Original code didn't copy groups.

@implementation MPrototypeManager

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"PrototypeManager"] == nil)
        return nil;

    model = [aModel retain];
    formulaParser = [[MMFormulaParser alloc] initWithModel:model];

    [self setWindowFrameAutosaveName:@"Prototype Manager"];

    cachedEquationUsage = [[NSMutableDictionary alloc] init];
    cachedTransitionUsage = [[NSMutableDictionary alloc] init];
    //cachedSpecialTransitionUsage = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)dealloc;
{
    [model release];
    [formulaParser release];
    [cachedEquationUsage release];
    [cachedTransitionUsage release];
    //[cachedSpecialTransitionUsage release];

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

    [formulaParser setModel:model];
    [miniTransitionView setModel:model];
    [miniSpecialTransitionView setModel:model];

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

    [miniTransitionView setModel:model];
    [miniSpecialTransitionView setModel:model];

    // We don't need to allow selection, adding points, editing slopes
    [miniTransitionView setEnabled:NO];
    [miniSpecialTransitionView setEnabled:NO];

    [equationOutlineView setTarget:self];
    [equationOutlineView setDoubleAction:@selector(doubleHit:)];

    [self updateViews];
    [self expandOutlines];
}

- (void)updateViews;
{
    [self clearEquationUsageCache]; // TODO (2004-03-22): Not sure when I need to do this.
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

    //[equationOutlineView sizeToFit];
    [transitionOutlineView sizeToFit];
    [specialTransitionOutlineView sizeToFit];
}

- (void)_updateEquationDetails;
{
    if ([equationOutlineView numberOfSelectedRows] == 1) {
        id selectedEquationOrGroup;
        NSString *comment;

        selectedEquationOrGroup = [equationOutlineView itemAtRow:[equationOutlineView selectedRow]];
        if ([selectedEquationOrGroup isKindOfClass:[NSString class]] == YES) {
            [equationTextView setEditable:NO];
            [equationTextView setString:@""];
            [equationCommentTextView setEditable:NO];
            [equationCommentTextView setString:@""];

            [addEquationButtonCell setEnabled:NO];
            [removeEquationButtonCell setEnabled:NO];
        } else {
            [equationCommentTextView setEditable:YES];
            comment = [selectedEquationOrGroup comment];
            if (comment == nil)
                comment = @"";
            [equationCommentTextView setString:comment];
            [addEquationButtonCell setEnabled:YES];
            [removeEquationButtonCell setEnabled:YES];
        }

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

        [addEquationButtonCell setEnabled:NO];
        [removeEquationButtonCell setEnabled:NO];
    }
}

- (void)_updateTransitionDetails;
{
    if ([transitionOutlineView numberOfSelectedRows] == 1) {
        id selectedTransitionOrGroup;
        NSString *comment;

        selectedTransitionOrGroup = [transitionOutlineView itemAtRow:[transitionOutlineView selectedRow]];
        if ([selectedTransitionOrGroup isKindOfClass:[NSString class]] == YES) {
            [transitionCommentTextView setEditable:NO];
            [transitionCommentTextView setString:@""];
            [addTransitionButtonCell setEnabled:NO];
            [removeTransitionButtonCell setEnabled:NO];

            [transitionTypeMatrix setEnabled:NO];
            [transitionTypeMatrix selectCellWithTag:2];
        } else {
            [transitionCommentTextView setEditable:YES];
            comment = [selectedTransitionOrGroup comment];
            if (comment == nil)
                comment = @"";
            [transitionCommentTextView setString:comment];
            [addTransitionButtonCell setEnabled:YES];
            [removeTransitionButtonCell setEnabled:YES];
        }

        if ([selectedTransitionOrGroup isKindOfClass:[MMTransition class]] == YES) {
            [transitionTypeMatrix setEnabled:YES];
            [transitionTypeMatrix selectCellWithTag:[(MMTransition *)selectedTransitionOrGroup type]];
        } else {
            [transitionTypeMatrix setEnabled:NO];
            [transitionTypeMatrix selectCellWithTag:2];
        }

        [miniTransitionView setTransition:[self selectedTransition]];
    } else {
        [transitionCommentTextView setEditable:NO];
        [transitionCommentTextView setString:@""];
        [addTransitionButtonCell setEnabled:NO];
        [removeTransitionButtonCell setEnabled:NO];

        [transitionTypeMatrix setEnabled:NO];
        [transitionTypeMatrix selectCellWithTag:2];

        [miniTransitionView setTransition:nil];
    }
}

- (void)_updateSpecialTransitionDetails;
{
    if ([specialTransitionOutlineView numberOfSelectedRows] == 1) {
        id selectedSpecialTransitionOrGroup;
        NSString *comment;

        selectedSpecialTransitionOrGroup = [specialTransitionOutlineView itemAtRow:[specialTransitionOutlineView selectedRow]];
        if ([selectedSpecialTransitionOrGroup isKindOfClass:[NSString class]] == YES) {
            [specialTransitionCommentTextView setEditable:NO];
            [specialTransitionCommentTextView setString:@""];
            [addSpecialTransitionButtonCell setEnabled:NO];
            [removeSpecialTransitionButtonCell setEnabled:NO];

            [specialTransitionTypeMatrix setEnabled:NO];
            [specialTransitionTypeMatrix selectCellWithTag:2];
        } else {
            [specialTransitionCommentTextView setEditable:YES];
            comment = [selectedSpecialTransitionOrGroup comment];
            if (comment == nil)
                comment = @"";
            [specialTransitionCommentTextView setString:comment];
            [addSpecialTransitionButtonCell setEnabled:YES];
            [removeSpecialTransitionButtonCell setEnabled:YES];
        }

        if ([selectedSpecialTransitionOrGroup isKindOfClass:[MMTransition class]] == YES) {
            [specialTransitionTypeMatrix setEnabled:YES];
            [specialTransitionTypeMatrix selectCellWithTag:[(MMTransition *)selectedSpecialTransitionOrGroup type]];
        } else {
            [specialTransitionTypeMatrix setEnabled:NO];
            [specialTransitionTypeMatrix selectCellWithTag:2];
        }

        [miniSpecialTransitionView setTransition:[self selectedSpecialTransition]];
    } else {
        [specialTransitionCommentTextView setEditable:NO];
        [specialTransitionCommentTextView setString:@""];
        [addSpecialTransitionButtonCell setEnabled:NO];
        [removeSpecialTransitionButtonCell setEnabled:NO];

        [specialTransitionTypeMatrix setEnabled:NO];
        [specialTransitionTypeMatrix selectCellWithTag:2];

        [miniSpecialTransitionView setTransition:nil];
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
    NamedList *newGroup;
    unsigned int index;

    newGroup = [[NamedList alloc] init];
    [newGroup setName:@"Untitled"];
    [[[self model] equations] addObject:newGroup];

    [self updateViews];

    index = [equationOutlineView rowForItem:newGroup];
    [equationOutlineView expandItem:newGroup];
    [newGroup release];

    // The row needs to be selected before we start editing it.
    [equationOutlineView selectRow:index byExtendingSelection:NO];
    [equationOutlineView editColumn:[equationOutlineView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
}

- (IBAction)addEquation:(id)sender;
{
    id selectedItem;
    NamedList *targetGroup;

    selectedItem = [equationOutlineView selectedItem];
    if ([selectedItem isKindOfClass:[NamedList class]] == YES) {
        targetGroup = selectedItem;
    } else if ([selectedItem isKindOfClass:[MMEquation class]] == YES) {
        targetGroup = [selectedItem group];
    } else
        targetGroup = nil;

    if (targetGroup != nil) {
        MMEquation *newEquation;
        int index;

        // TODO (2004-03-22): Need to do something to ensure unique names.
        newEquation = [[MMEquation alloc] initWithName:@"Untitled"];
        [targetGroup addObject:newEquation];
        [equationOutlineView reloadItem:targetGroup reloadChildren:YES];

        index = [equationOutlineView rowForItem:newEquation];
        [newEquation release];

        // The row needs to be selected before we start editing it.
        [equationOutlineView selectRow:index byExtendingSelection:NO];
        [equationOutlineView editColumn:[equationOutlineView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
    }
}

- (IBAction)removeEquation:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)setEquation:(id)sender;
{
    MMFormulaExpression *result;
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
    NamedList *newGroup;
    unsigned int index;

    newGroup = [[NamedList alloc] init];
    [newGroup setName:@"Untitled"];
    [[[self model] transitions] addObject:newGroup];

    [self updateViews];

    index = [transitionOutlineView rowForItem:newGroup];
    [transitionOutlineView expandItem:newGroup];
    [newGroup release];

    // The row needs to be selected before we start editing it.
    [transitionOutlineView selectRow:index byExtendingSelection:NO];
    [transitionOutlineView editColumn:[transitionOutlineView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
}

- (IBAction)addTransition:(id)sender;
{
    id selectedItem;
    NamedList *targetGroup;

    selectedItem = [transitionOutlineView selectedItem];
    if ([selectedItem isKindOfClass:[NamedList class]] == YES) {
        targetGroup = selectedItem;
    } else if ([selectedItem isKindOfClass:[MMTransition class]] == YES) {
        targetGroup = [selectedItem group];
    } else
        targetGroup = nil;

    if (targetGroup != nil) {
        MMTransition *newTransition;
        int index;

        // TODO (2004-03-22): Need to do something to ensure unique names.
        newTransition = [[MMTransition alloc] initWithName:@"Untitled"];
        [newTransition addInitialPoint];
        [targetGroup addObject:newTransition];
        [transitionOutlineView reloadItem:targetGroup reloadChildren:YES];

        index = [transitionOutlineView rowForItem:newTransition];
        [newTransition release];

        // The row needs to be selected before we start editing it.
        [transitionOutlineView selectRow:index byExtendingSelection:NO];
        [transitionOutlineView editColumn:[transitionOutlineView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
    }
}

- (IBAction)removeTransition:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)setTransitionType:(id)sender;
{
    [[self selectedTransition] setType:[[transitionTypeMatrix selectedCell] tag]];
    [self  _updateTransitionDetails];
}

- (IBAction)editTransition:(id)sender;
{
    [[NSApp delegate] editTransition:[self selectedTransition]];
}

//
// Special Transitions
//

- (IBAction)addSpecialTransitionGroup:(id)sender;
{
    NamedList *newGroup;
    unsigned int index;

    newGroup = [[NamedList alloc] init];
    [newGroup setName:@"Untitled"];
    [[[self model] specialTransitions] addObject:newGroup];

    [self updateViews];

    index = [specialTransitionOutlineView rowForItem:newGroup];
    [specialTransitionOutlineView expandItem:newGroup];
    [newGroup release];

    // The row needs to be selected before we start editing it.
    [specialTransitionOutlineView selectRow:index byExtendingSelection:NO];
    [specialTransitionOutlineView editColumn:[specialTransitionOutlineView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
}

- (IBAction)addSpecialTransition:(id)sender;
{
    id selectedItem;
    NamedList *targetGroup;

    selectedItem = [specialTransitionOutlineView selectedItem];
    if ([selectedItem isKindOfClass:[NamedList class]] == YES) {
        targetGroup = selectedItem;
    } else if ([selectedItem isKindOfClass:[MMTransition class]] == YES) {
        targetGroup = [selectedItem group];
    } else
        targetGroup = nil;

    if (targetGroup != nil) {
        MMTransition *newTransition;
        int index;

        // TODO (2004-03-22): Need to do something to ensure unique names.
        newTransition = [[MMTransition alloc] initWithName:@"Untitled"];
        [newTransition addInitialPoint];
        [targetGroup addObject:newTransition];
        [specialTransitionOutlineView reloadItem:targetGroup reloadChildren:YES];

        index = [specialTransitionOutlineView rowForItem:newTransition];
        [newTransition release];

        // The row needs to be selected before we start editing it.
        [specialTransitionOutlineView selectRow:index byExtendingSelection:NO];
        [specialTransitionOutlineView editColumn:[specialTransitionOutlineView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
    }
}

- (IBAction)removeSpecialTransition:(id)sender;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"<  %s", _cmd);
}

- (IBAction)setSpecialTransitionType:(id)sender;
{
    [[self selectedSpecialTransition] setType:[[specialTransitionTypeMatrix selectedCell] tag]];
    [self _updateSpecialTransitionDetails];
}

- (IBAction)editSpecialTransition:(id)sender;
{
    [[NSApp delegate] editSpecialTransition:[self selectedSpecialTransition]];
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
        else if ([item isKindOfClass:[MMEquation class]] == YES)
            return [[self usageOfEquation:item] count];
        else
            return [item count];
    } else if (outlineView == transitionOutlineView) {
        if (item == nil)
            return [[model transitions] count];
        else if ([item isKindOfClass:[MMTransition class]] == YES)
            return [[self usageOfTransition:item] count];
        else
            return [item count];
    } else if (outlineView == specialTransitionOutlineView) {
        if (item == nil)
            return [[model specialTransitions] count];
        else if ([item isKindOfClass:[MMTransition class]] == YES)
            return [[self usageOfTransition:item] count];
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
        else if ([item isKindOfClass:[MMEquation class]] == YES)
            return [[self usageOfEquation:item] objectAtIndex:index];
        else
            return [item objectAtIndex:index];
    } else if (outlineView == transitionOutlineView) {
        if (item == nil)
            return [[model transitions] objectAtIndex:index];
        else if ([item isKindOfClass:[MMTransition class]] == YES)
            return [[self usageOfTransition:item] objectAtIndex:index];
        else
            return [item objectAtIndex:index];
    } else if (outlineView == specialTransitionOutlineView) {
        if (item == nil)
            return [[model specialTransitions] objectAtIndex:index];
        else if ([item isKindOfClass:[MMTransition class]] == YES)
            return [[self usageOfTransition:item] objectAtIndex:index];
        else
            return [item objectAtIndex:index];
    }

    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
{
    if (outlineView == equationOutlineView) {
        return [item isKindOfClass:[NamedList class]] || ([item isKindOfClass:[MMEquation class]] && [self isEquationUsed:item]);
    } else if (outlineView == transitionOutlineView) {
        return [item isKindOfClass:[NamedList class]] || ([item isKindOfClass:[MMTransition class]] && [self isTransitionUsed:item]);
    } else if (outlineView == specialTransitionOutlineView) {
        return [item isKindOfClass:[NamedList class]] || ([item isKindOfClass:[MMTransition class]] && [self isTransitionUsed:item]);
    }

    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
{
    id identifier;

    identifier = [tableColumn identifier];
    //NSLog(@"identifier: %@, item: %p, item class: %@", identifier, item, NSStringFromClass([item class]));

    if (outlineView == equationOutlineView) {
        if ([item isKindOfClass:[NSString class]] == YES) {
            if ([@"name" isEqual:identifier] == YES)
                return item;

            return nil;
        } else if ([@"name" isEqual:identifier] == YES) {
            return [item name];
        } else if ([@"hasComment" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[item hasComment]];
        } else if ([@"isUsed" isEqual:identifier] == YES) {
            if ([item isKindOfClass:[MMEquation class]] == YES)
                return [NSNumber numberWithBool:[self isEquationUsed:item]];
        }
    } else if (outlineView == transitionOutlineView) {
        if ([item isKindOfClass:[NSString class]] == YES) {
            if ([@"name" isEqual:identifier] == YES)
                return item;

            return nil;
        } else if ([@"name" isEqual:identifier] == YES) {
            return [item name];
        } else if ([@"hasComment" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[item hasComment]];
        } else if ([@"isUsed" isEqual:identifier] == YES) {
            if ([item isKindOfClass:[MMTransition class]] == YES)
                return [NSNumber numberWithBool:[self isTransitionUsed:item]];
        }
    } else if (outlineView == specialTransitionOutlineView) {
        if ([item isKindOfClass:[NSString class]] == YES) {
            if ([@"name" isEqual:identifier] == YES)
                return item;

            return nil;
        } else if ([@"name" isEqual:identifier] == YES) {
            return [item name];
        } else if ([@"hasComment" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[item hasComment]];
        } else if ([@"isUsed" isEqual:identifier] == YES) {
            if ([item isKindOfClass:[MMTransition class]] == YES)
                return [NSNumber numberWithBool:[self isTransitionUsed:item]];
        }
    }

    return nil;
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

    outlineView = [aNotification object];

    if (outlineView == equationOutlineView) {
        [self _updateEquationDetails];
    } else if (outlineView == transitionOutlineView) {
        [self _updateTransitionDetails];
    } else if (outlineView == specialTransitionOutlineView) {
        [self _updateSpecialTransitionDetails];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item;
{
    return [item isKindOfClass:[NSString class]] == NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item;
{
    // This is just a crummy hack.  We really need notification when things that use equations change, so we can recache.
    if (outlineView == equationOutlineView) {
        if ([item isKindOfClass:[MMEquation class]] == YES) {
            NSArray *usage;

            usage = [self usageOfEquation:item recache:YES];
            [equationOutlineView reloadItem:item reloadChildren:YES];
            if ([usage count] == 0)
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
            selectedItem = [specialTransitionOutlineView selectedItem];
            if ([selectedItem respondsToSelector:@selector(setComment:)] == YES) {
                [selectedItem setComment:newStringValue];
                [specialTransitionOutlineView reloadItem:selectedItem]; // To show note icon
            }
        }

        [newStringValue release];
    }
}

//
// Equation usage caching
//

- (void)clearEquationUsageCache;
{
    [cachedEquationUsage removeAllObjects];
}

- (NSArray *)usageOfEquation:(MMEquation *)anEquation;
{
    return [self usageOfEquation:anEquation recache:NO];
}

- (NSArray *)usageOfEquation:(MMEquation *)anEquation recache:(BOOL)shouldRecache;
{
    NSString *key;
    NSArray *usage;

    key = [anEquation equationPath];
    if (shouldRecache == YES)
        [cachedEquationUsage removeObjectForKey:key];

    usage = [cachedEquationUsage objectForKey:key];
    if (usage == nil) {
        usage = [[self model] usageOfEquation:anEquation];
        [cachedEquationUsage setObject:usage forKey:key];
    }

    return usage;
}

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
{
    return [[self usageOfEquation:anEquation] count] > 0;
}

//
// Transition usage caching
//

- (void)clearTransitionUsageCache;
{
    [cachedTransitionUsage removeAllObjects];
}

- (NSArray *)usageOfTransition:(MMTransition *)aTransition;
{
    return [self usageOfTransition:aTransition recache:NO];
}

// TODO (2004-03-22): Could we just cache these in the model?
- (NSArray *)usageOfTransition:(MMTransition *)aTransition recache:(BOOL)shouldRecache;
{
    NSString *key;
    NSArray *usage;

    key = [aTransition transitionPath];
    if (shouldRecache == YES)
        [cachedTransitionUsage removeObjectForKey:key];

    usage = [cachedTransitionUsage objectForKey:key];
    if (usage == nil) {
        usage = [[self model] usageOfTransition:aTransition];
        [cachedTransitionUsage setObject:usage forKey:key];
    }

    return usage;
}

- (BOOL)isTransitionUsed:(MMTransition *)aTransition;
{
    return [[self usageOfTransition:aTransition] count] > 0;
}

- (IBAction)doubleHit:(id)sender;
{
    NSLog(@" > %s", _cmd);
    // We could open the selected Rule, Transition, or Special Transition that was double clicked in the Usage.
    NSLog(@"<  %s", _cmd);
}

@end
