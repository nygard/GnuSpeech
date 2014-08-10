//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MPrototypeManager.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSOutlineView-Extensions.h"

#import "MCommentCell.h"
#import "SpecialView.h"
#import "TransitionView.h"
#import "AppController.h"

// TODO (2004-03-23): Implement copy/paste of equations, transitions, special transitions.  Original code didn't copy groups.

@implementation MPrototypeManager
{
    IBOutlet NSOutlineView *_equationOutlineView;
    IBOutlet NSButtonCell *_addEquationButtonCell;
    IBOutlet NSButtonCell *_removeEquationButtonCell;
    IBOutlet NSTextView *_equationTextView;
    IBOutlet NSTextView *_equationParserMessagesTextView;
    IBOutlet NSTextView *_equationCommentTextView;

    IBOutlet NSOutlineView *_transitionOutlineView;
    IBOutlet NSButtonCell *_addTransitionButtonCell;
    IBOutlet NSButtonCell *_removeTransitionButtonCell;
    IBOutlet TransitionView *_miniTransitionView;
    IBOutlet NSTextView *_transitionCommentTextView;

    IBOutlet NSOutlineView *_specialTransitionOutlineView;
    IBOutlet NSButtonCell *_addSpecialTransitionButtonCell;
    IBOutlet NSButtonCell *_removeSpecialTransitionButtonCell;
    IBOutlet SpecialView *_miniSpecialTransitionView;
    IBOutlet NSTextView *_specialTransitionCommentTextView;

    MModel *_model;

    MMFormulaParser *_formulaParser;

    NSMutableDictionary *_cachedEquationUsage;
    NSMutableDictionary *_cachedTransitionUsage;
    //NSMutableDictionary *_cachedSpecialTransitionUsage;
}

- (id)initWithModel:(MModel *)aModel;
{
    if ((self = [super initWithWindowNibName:@"PrototypeManager"])) {
        _model = aModel;
        _formulaParser = [[MMFormulaParser alloc] initWithModel:_model];
        
        [self setWindowFrameAutosaveName:@"Prototype Manager"];
        
        _cachedEquationUsage = [[NSMutableDictionary alloc] init];
        _cachedTransitionUsage = [[NSMutableDictionary alloc] init];
        //cachedSpecialTransitionUsage = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (MModel *)model;
{
    return _model;
}

- (void)setModel:(MModel *)newModel;
{
    if (newModel == _model)
        return;

    _model = newModel;

    [_formulaParser setModel:_model];
    [_miniTransitionView setModel:_model];
    [_miniSpecialTransitionView setModel:_model];

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

    [[_equationOutlineView tableColumnWithIdentifier:@"isUsed"] setDataCell:checkboxCell];
    [[_transitionOutlineView tableColumnWithIdentifier:@"isUsed"] setDataCell:checkboxCell];
    [[_specialTransitionOutlineView tableColumnWithIdentifier:@"isUsed"] setDataCell:checkboxCell];

    commentImageCell = [[MCommentCell alloc] initImageCell:nil];
    [commentImageCell setImageAlignment:NSImageAlignCenter];
    [[_equationOutlineView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[_transitionOutlineView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [[_specialTransitionOutlineView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];

    [_equationOutlineView moveColumn:[_equationOutlineView columnWithIdentifier:@"hasComment"] toColumn:0];
    [_transitionOutlineView moveColumn:[_transitionOutlineView columnWithIdentifier:@"hasComment"] toColumn:0];
    [_specialTransitionOutlineView moveColumn:[_specialTransitionOutlineView columnWithIdentifier:@"hasComment"] toColumn:0];

    [_equationTextView setFieldEditor:YES];
    [_equationCommentTextView setFieldEditor:YES];
    [_transitionCommentTextView setFieldEditor:YES];
    [_specialTransitionCommentTextView setFieldEditor:YES];

    [_miniTransitionView setModel:_model];
    [_miniSpecialTransitionView setModel:_model];

    // We don't need to allow selection, adding points, editing slopes
    [_miniTransitionView setEnabled:NO];
    [_miniSpecialTransitionView setEnabled:NO];

    [_equationOutlineView setTarget:self];
    [_equationOutlineView setDoubleAction:@selector(doubleHit:)];

    [self updateViews];
    [self expandOutlines];
}

- (void)updateViews;
{
    [self clearEquationUsageCache]; // TODO (2004-03-22): Not sure when I need to do this.
    [_equationOutlineView reloadData];
    [_transitionOutlineView reloadData];
    [_specialTransitionOutlineView reloadData];

    [self _updateEquationDetails];
    [self _updateTransitionDetails];
    [self _updateSpecialTransitionDetails];
}

- (void)expandOutlines;
{
    NSUInteger count, index;

    count = [[_model equationGroups] count];
    for (index = 0; index < count; index++)
        [_equationOutlineView expandItem:[[_model equationGroups] objectAtIndex:index]];

    count = [[_model transitionGroups] count];
    for (index = 0; index < count; index++)
        [_transitionOutlineView expandItem:[[_model transitionGroups] objectAtIndex:index]];

    count = [[_model specialTransitionGroups] count];
    for (index = 0; index < count; index++)
        [_specialTransitionOutlineView expandItem:[[_model specialTransitionGroups] objectAtIndex:index]];

    //[equationOutlineView sizeToFit];
    [_transitionOutlineView sizeToFit];
    [_specialTransitionOutlineView sizeToFit];
}

- (void)_updateEquationDetails;
{
    if ([_equationOutlineView numberOfSelectedRows] == 1) {
        id selectedEquationOrGroup;
        NSString *comment;

        selectedEquationOrGroup = [_equationOutlineView itemAtRow:[_equationOutlineView selectedRow]];
        if ([selectedEquationOrGroup isKindOfClass:[NSString class]] == YES) {
            [_equationTextView setEditable:NO];
            [_equationTextView setString:@""];
            [_equationCommentTextView setEditable:NO];
            [_equationCommentTextView setString:@""];

            [_addEquationButtonCell setEnabled:NO];
            [_removeEquationButtonCell setEnabled:NO];
        } else {
            [_equationCommentTextView setEditable:YES];
            comment = [selectedEquationOrGroup comment];
            if (comment == nil)
                comment = @"";
            [_equationCommentTextView setString:comment];
            [_addEquationButtonCell setEnabled:YES];
            [_removeEquationButtonCell setEnabled:YES];
        }

        if ([selectedEquationOrGroup isKindOfClass:[MMEquation class]] == YES) {
            NSString *expressionString;

            [_equationTextView setEditable:YES];
            expressionString = [[selectedEquationOrGroup formula] expressionString];
            if (expressionString == nil)
                expressionString = @"";
            [_equationTextView setString:expressionString];
        } else {
            [_equationTextView setEditable:NO];
            [_equationTextView setString:@""];
        }

        [_equationParserMessagesTextView setString:@""];
    } else {
        [_equationTextView setEditable:NO];
        [_equationTextView setString:@""];
        [_equationCommentTextView setEditable:NO];
        [_equationCommentTextView setString:@""];

        [_addEquationButtonCell setEnabled:NO];
        [_removeEquationButtonCell setEnabled:NO];
    }
}

- (void)_updateTransitionDetails;
{
    if ([_transitionOutlineView numberOfSelectedRows] == 1) {
        id selectedTransitionOrGroup;
        NSString *comment;

        selectedTransitionOrGroup = [_transitionOutlineView itemAtRow:[_transitionOutlineView selectedRow]];
        if ([selectedTransitionOrGroup isKindOfClass:[NSString class]] == YES) {
            [_transitionCommentTextView setEditable:NO];
            [_transitionCommentTextView setString:@""];
            [_addTransitionButtonCell setEnabled:NO];
            [_removeTransitionButtonCell setEnabled:NO];
        } else {
            [_transitionCommentTextView setEditable:YES];
            comment = [selectedTransitionOrGroup comment];
            if (comment == nil)
                comment = @"";
            [_transitionCommentTextView setString:comment];
            [_addTransitionButtonCell setEnabled:YES];
            [_removeTransitionButtonCell setEnabled:YES];
        }

        [_miniTransitionView setTransition:[self selectedTransition]];
    } else {
        [_transitionCommentTextView setEditable:NO];
        [_transitionCommentTextView setString:@""];
        [_addTransitionButtonCell setEnabled:NO];
        [_removeTransitionButtonCell setEnabled:NO];

        [_miniTransitionView setTransition:nil];
    }
}

- (void)_updateSpecialTransitionDetails;
{
    if ([_specialTransitionOutlineView numberOfSelectedRows] == 1) {
        id selectedSpecialTransitionOrGroup;
        NSString *comment;

        selectedSpecialTransitionOrGroup = [_specialTransitionOutlineView itemAtRow:[_specialTransitionOutlineView selectedRow]];
        if ([selectedSpecialTransitionOrGroup isKindOfClass:[NSString class]] == YES) {
            [_specialTransitionCommentTextView setEditable:NO];
            [_specialTransitionCommentTextView setString:@""];
            [_addSpecialTransitionButtonCell setEnabled:NO];
            [_removeSpecialTransitionButtonCell setEnabled:NO];
        } else {
            [_specialTransitionCommentTextView setEditable:YES];
            comment = [selectedSpecialTransitionOrGroup comment];
            if (comment == nil)
                comment = @"";
            [_specialTransitionCommentTextView setString:comment];
            [_addSpecialTransitionButtonCell setEnabled:YES];
            [_removeSpecialTransitionButtonCell setEnabled:YES];
        }

        [_miniSpecialTransitionView setTransition:[self selectedSpecialTransition]];
    } else {
        [_specialTransitionCommentTextView setEditable:NO];
        [_specialTransitionCommentTextView setString:@""];
        [_addSpecialTransitionButtonCell setEnabled:NO];
        [_removeSpecialTransitionButtonCell setEnabled:NO];

        [_miniSpecialTransitionView setTransition:nil];
    }
}

- (MMEquation *)selectedEquation;
{
    return [_equationOutlineView selectedItemOfClass:[MMEquation class]];
}

- (MMTransition *)selectedTransition;
{
    return [_transitionOutlineView selectedItemOfClass:[MMTransition class]];
}

- (MMTransition *)selectedSpecialTransition;
{
    return [_specialTransitionOutlineView selectedItemOfClass:[MMTransition class]];
}

#pragma mark - Equations

- (IBAction)addEquationGroup:(id)sender;
{
    MMGroup *newGroup;
    NSUInteger index;

    newGroup = [[MMGroup alloc] init];
    [newGroup setName:@"Untitled"];
    [[[self model] equationGroups] addObject:newGroup];

    [self updateViews];

    index = [_equationOutlineView rowForItem:newGroup];
    [_equationOutlineView expandItem:newGroup];

    // The row needs to be selected before we start editing it.
    [_equationOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [_equationOutlineView editColumn:[_equationOutlineView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
}

- (IBAction)addEquation:(id)sender;
{
    id selectedItem;
    MMGroup *targetGroup;

    selectedItem = [_equationOutlineView selectedItem];
    if ([selectedItem isKindOfClass:[MMGroup class]] == YES) {
        targetGroup = selectedItem;
    } else if ([selectedItem isKindOfClass:[MMEquation class]] == YES) {
        targetGroup = [selectedItem group];
    } else
        targetGroup = nil;

    if (targetGroup != nil) {
        MMEquation *newEquation;
        NSUInteger index;

        // TODO (2004-03-22): Need to do something to ensure unique names.
        newEquation = [[MMEquation alloc] init];
        newEquation.name = @"Untitled";
        [targetGroup addObject:newEquation];
        [_equationOutlineView reloadItem:targetGroup reloadChildren:YES];

        index = [_equationOutlineView rowForItem:newEquation];

        // The row needs to be selected before we start editing it.
        [_equationOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
        [_equationOutlineView editColumn:[_equationOutlineView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
    }
}

- (IBAction)removeEquation:(id)sender;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (IBAction)setEquation:(id)sender;
{
    MMFormulaExpression *result;
    NSString *str;

    result = [_formulaParser parseString:[_equationTextView string]];

    str = [_formulaParser errorMessage];
    if ([str length] == 0)
        str = @"Equation parsed.";
    [_equationParserMessagesTextView setString:str];

    if (result == nil) {
        [_equationTextView setSelectedRange:[_formulaParser errorRange]];
        [[self window] makeFirstResponder:_equationTextView];
    } else {
        [[self selectedEquation] setFormula:result];
    }
}

- (IBAction)revertEquation:(id)sender;
{
    [self _updateEquationDetails];
}

#pragma mark - Transitions

- (IBAction)addTransitionGroup:(id)sender;
{
    MMGroup *newGroup;
    NSUInteger index;

    newGroup = [[MMGroup alloc] init];
    [newGroup setName:@"Untitled"];
    [[[self model] transitionGroups] addObject:newGroup];

    [self updateViews];

    index = [_transitionOutlineView rowForItem:newGroup];
    [_transitionOutlineView expandItem:newGroup];

    // The row needs to be selected before we start editing it.
    [_transitionOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [_transitionOutlineView editColumn:[_transitionOutlineView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
}

- (IBAction)addTransition:(id)sender;
{
    id selectedItem;
    MMGroup *targetGroup;

    selectedItem = [_transitionOutlineView selectedItem];
    if ([selectedItem isKindOfClass:[MMGroup class]] == YES) {
        targetGroup = selectedItem;
    } else if ([selectedItem isKindOfClass:[MMTransition class]] == YES) {
        targetGroup = [selectedItem group];
    } else
        targetGroup = nil;

    if (targetGroup != nil) {
        MMTransition *newTransition;
        NSUInteger index;

        // TODO (2004-03-22): Need to do something to ensure unique names.
        newTransition = [[MMTransition alloc] init];
        newTransition.name = @"Untitled";
        [newTransition addInitialPoint];
        [targetGroup addObject:newTransition];
        [_transitionOutlineView reloadItem:targetGroup reloadChildren:YES];

        index = [_transitionOutlineView rowForItem:newTransition];

        // The row needs to be selected before we start editing it.
        [_transitionOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
        [_transitionOutlineView editColumn:[_transitionOutlineView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
    }
}

- (IBAction)removeTransition:(id)sender;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (IBAction)editTransition:(id)sender;
{
    [(AppController *)[NSApp delegate] editTransition:[self selectedTransition]];
}

#pragma mark - Special Transitions

- (IBAction)addSpecialTransitionGroup:(id)sender;
{
    MMGroup *newGroup;
    NSUInteger index;

    newGroup = [[MMGroup alloc] init];
    [newGroup setName:@"Untitled"];
    [[[self model] specialTransitionGroups] addObject:newGroup];

    [self updateViews];

    index = [_specialTransitionOutlineView rowForItem:newGroup];
    [_specialTransitionOutlineView expandItem:newGroup];

    // The row needs to be selected before we start editing it.
    [_specialTransitionOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [_specialTransitionOutlineView editColumn:[_specialTransitionOutlineView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
}

- (IBAction)addSpecialTransition:(id)sender;
{
    id selectedItem;
    MMGroup *targetGroup;

    selectedItem = [_specialTransitionOutlineView selectedItem];
    if ([selectedItem isKindOfClass:[MMGroup class]] == YES) {
        targetGroup = selectedItem;
    } else if ([selectedItem isKindOfClass:[MMTransition class]] == YES) {
        targetGroup = [selectedItem group];
    } else
        targetGroup = nil;

    if (targetGroup != nil) {
        MMTransition *newTransition;
        NSUInteger index;

        // TODO (2004-03-22): Need to do something to ensure unique names.
        newTransition = [[MMTransition alloc] init];
        newTransition.name = @"Untitled";
        [newTransition addInitialPoint];
        [targetGroup addObject:newTransition];
        [_specialTransitionOutlineView reloadItem:targetGroup reloadChildren:YES];

        index = [_specialTransitionOutlineView rowForItem:newTransition];

        // The row needs to be selected before we start editing it.
        [_specialTransitionOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
        [_specialTransitionOutlineView editColumn:[_specialTransitionOutlineView columnWithIdentifier:@"name"] row:index withEvent:nil select:YES];
    }
}

- (IBAction)removeSpecialTransition:(id)sender;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

- (IBAction)editSpecialTransition:(id)sender;
{
    [(AppController *)[NSApp delegate] editSpecialTransition:[self selectedSpecialTransition]];
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
{
   // NSLog(@"-> %s, item: %p", __PRETTY_FUNCTION__, item);
    if (outlineView == _equationOutlineView) {
        if (item == nil)
            return [[_model equationGroups] count];
        else if ([item isKindOfClass:[MMEquation class]])
            return [[self usageOfEquation:item] count];
        else {
            MMGroup *group = item;
            return [group.objects count];
        }
    } else if (outlineView == _transitionOutlineView) {
        if (item == nil)
            return [[_model transitionGroups] count];
        else if ([item isKindOfClass:[MMTransition class]])
            return [[self usageOfTransition:item] count];
        else {
            MMGroup *group = item;
            return [group.objects count];
        }
    } else if (outlineView == _specialTransitionOutlineView) {
        if (item == nil)
            return [[_model specialTransitionGroups] count];
        else if ([item isKindOfClass:[MMTransition class]])
            return [[self usageOfTransition:item] count];
        else {
            MMGroup *group = item;
            return [group.objects count];
        }
    }

    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
{
    if (outlineView == _equationOutlineView) {
        if (item == nil)
            return [[_model equationGroups] objectAtIndex:index];
        else if ([item isKindOfClass:[MMEquation class]] == YES)
            return [[self usageOfEquation:item] objectAtIndex:index];
        else {
            MMGroup *group = item;
            return [group.objects objectAtIndex:index];
        }
    } else if (outlineView == _transitionOutlineView) {
        if (item == nil)
            return [[_model transitionGroups] objectAtIndex:index];
        else if ([item isKindOfClass:[MMTransition class]] == YES)
            return [[self usageOfTransition:item] objectAtIndex:index];
        else {
            MMGroup *group = item;
            return [group.objects objectAtIndex:index];
        }
    } else if (outlineView == _specialTransitionOutlineView) {
        if (item == nil)
            return [[_model specialTransitionGroups] objectAtIndex:index];
        else if ([item isKindOfClass:[MMTransition class]] == YES)
            return [[self usageOfTransition:item] objectAtIndex:index];
        else {
            MMGroup *group = item;
            return [group.objects objectAtIndex:index];
        }
    }

    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
{
    if (outlineView == _equationOutlineView) {
        return [item isKindOfClass:[MMGroup class]] || ([item isKindOfClass:[MMEquation class]] && [self isEquationUsed:item]);
    } else if (outlineView == _transitionOutlineView) {
        return [item isKindOfClass:[MMGroup class]] || ([item isKindOfClass:[MMTransition class]] && [self isTransitionUsed:item]);
    } else if (outlineView == _specialTransitionOutlineView) {
        return [item isKindOfClass:[MMGroup class]] || ([item isKindOfClass:[MMTransition class]] && [self isTransitionUsed:item]);
    }

    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
{
    id identifier;

    identifier = [tableColumn identifier];
    //NSLog(@"identifier: %@, item: %p, item class: %@", identifier, item, NSStringFromClass([item class]));

    if (outlineView == _equationOutlineView) {
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
    } else if (outlineView == _transitionOutlineView) {
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
    } else if (outlineView == _specialTransitionOutlineView) {
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

    if (outlineView == _equationOutlineView) {
        if ([@"isUsed" isEqual:identifier] == YES) {
            if ([item isKindOfClass:[MMEquation class]] == YES)
                [cell setTransparent:NO];
            else
                [cell setTransparent:YES];
        }
    } else if (outlineView == _transitionOutlineView || outlineView == _specialTransitionOutlineView) {
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

    if (outlineView == _equationOutlineView) {
        if ([@"name" isEqual:identifier] == YES) {
            if ([item respondsToSelector:@selector(setName:)] == YES)
                [(MMEquation *)item setName:object];
        }
    } else if (outlineView == _transitionOutlineView || outlineView == _specialTransitionOutlineView) {
        if ([@"name" isEqual:identifier] == YES) {
            if ([item respondsToSelector:@selector(setName:)] == YES)
                [(MMTransition *)item setName:object];
        }
    }
}

#pragma mark - NSOutlineViewDelegate

- (void)outlineViewSelectionDidChange:(NSNotification *)aNotification;
{
    NSOutlineView *outlineView;

    outlineView = [aNotification object];

    if (outlineView == _equationOutlineView) {
        [self _updateEquationDetails];
    } else if (outlineView == _transitionOutlineView) {
        [self _updateTransitionDetails];
    } else if (outlineView == _specialTransitionOutlineView) {
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
    if (outlineView == _equationOutlineView) {
        if ([item isKindOfClass:[MMEquation class]] == YES) {
            NSArray *usage;

            usage = [self usageOfEquation:item recache:YES];
            [_equationOutlineView reloadItem:item reloadChildren:YES];
            if ([usage count] == 0)
                return NO;
        }
    }

    return YES;
}

#pragma mark - NSTextViewDelegate

- (void)textDidEndEditing:(NSNotification *)aNotification;
{
    NSTextView *textView;

    textView = [aNotification object];
    // NSTextMovement is a key in the user info
    //NSLog(@"[aNotification userInfo]: %@", [aNotification userInfo]);

    if (textView == _equationTextView) {
        [self setEquation:nil];
    } else {
        NSString *newStringValue;
        id selectedItem;

        newStringValue = [[textView string] copy];

        //NSLog(@"(1) newStringValue: %@", newStringValue);
        if ([newStringValue length] == 0) {
            newStringValue = nil;
        }
        //NSLog(@"(2) newStringValue: %@", newStringValue);

        if (textView == _equationCommentTextView) {
            selectedItem = [_equationOutlineView selectedItem];
            if ([selectedItem respondsToSelector:@selector(setComment:)] == YES) {
                [selectedItem setComment:newStringValue];
                // TODO (2004-03-18): Bleck.  Need notification from model that things have changed.
                [_equationOutlineView reloadItem:selectedItem]; // To show note icon
            }
        } else if (textView == _transitionCommentTextView) {
            selectedItem = [_transitionOutlineView selectedItem];
            if ([selectedItem respondsToSelector:@selector(setComment:)] == YES) {
                [selectedItem setComment:newStringValue];
                [_transitionOutlineView reloadItem:selectedItem]; // To show note icon
            }
        } else if (textView == _specialTransitionCommentTextView) {
            selectedItem = [_specialTransitionOutlineView selectedItem];
            if ([selectedItem respondsToSelector:@selector(setComment:)] == YES) {
                [selectedItem setComment:newStringValue];
                [_specialTransitionOutlineView reloadItem:selectedItem]; // To show note icon
            }
        }
    }
}

#pragma mark - Equation usage caching

- (void)clearEquationUsageCache;
{
    [_cachedEquationUsage removeAllObjects];
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
        [_cachedEquationUsage removeObjectForKey:key];

    usage = [_cachedEquationUsage objectForKey:key];
    if (usage == nil) {
        usage = [[self model] usageOfEquation:anEquation];
        [_cachedEquationUsage setObject:usage forKey:key];
    }

    return usage;
}

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
{
    return [[self usageOfEquation:anEquation] count] > 0;
}

#pragma mark - Transition usage caching

- (void)clearTransitionUsageCache;
{
    [_cachedTransitionUsage removeAllObjects];
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
        [_cachedTransitionUsage removeObjectForKey:key];

    usage = [_cachedTransitionUsage objectForKey:key];
    if (usage == nil) {
        usage = [[self model] usageOfTransition:aTransition];
        [_cachedTransitionUsage setObject:usage forKey:key];
    }

    return usage;
}

- (BOOL)isTransitionUsed:(MMTransition *)aTransition;
{
    return [[self usageOfTransition:aTransition] count] > 0;
}

- (IBAction)doubleHit:(id)sender;
{
    NSLog(@" > %s", __PRETTY_FUNCTION__);
    // We could open the selected Rule, Transition, or Special Transition that was double clicked in the Usage.
    NSLog(@"<  %s", __PRETTY_FUNCTION__);
}

@end
