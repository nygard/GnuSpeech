//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MTransitionEditor.h"

#import <AppKit/AppKit.h>
#import "NSNumberFormatter-Extensions.h"
#import "NSOutlineView-Extensions.h"

#import "FormulaExpression.h"
#import "MMEquation.h"
#import "MModel.h"
#import "MMPoint.h"
#import "MMTransition.h"
#import "MonetList.h"
#import "TransitionView.h"

@implementation MTransitionEditor

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"TransitionEditor"] == nil)
        return nil;

    model = [aModel retain];

    [self setWindowFrameAutosaveName:@"Transition Editor"];

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

    [transitionView setModel:model];

    [self updateViews];
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
    NSNumberFormatter *defaultNumberFormatter;

    defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];
    [[valueTextField cell] setFormatter:defaultNumberFormatter];

    [transitionView setModel:model];
    [transitionView setTransition:transition];

    NSLog(@"[transitionView refusesFirstResponder]: %d", [transitionView refusesFirstResponder]);

    [self updateViews];
}

- (void)updateViews;
{
    NSString *name;

    name = [transition name];
    if (name == nil)
        name = @"--";
    [transitionNameTextField setStringValue:name];

    [[controlParametersForm cellAtIndex:0] setDoubleValue:[transitionView ruleDuration]];
    [[controlParametersForm cellAtIndex:1] setDoubleValue:[transitionView beatLocation]];
    [[controlParametersForm cellAtIndex:2] setDoubleValue:[transitionView mark1]];
    [[controlParametersForm cellAtIndex:3] setDoubleValue:[transitionView mark2]];
    [[controlParametersForm cellAtIndex:4] setDoubleValue:[transitionView mark3]];

    [equationOutlineView reloadData];
    [self expandEquations];
}

- (void)expandEquations;
{
    unsigned int count, index;

    count = [[model equations] count];
    for (index = 0; index < count; index++)
        [equationOutlineView expandItem:[[model equations] objectAtIndex:index]];

    [equationOutlineView sizeToFit];
}

- (MMTransition *)transition;
{
    return transition;
}

- (void)setTransition:(MMTransition *)newTransition;
{
    NSLog(@" > %s", _cmd);

    NSLog(@"transition: %p, newTransition: %p", transition, newTransition);

    if (newTransition == transition) {
        NSLog(@"<  %s", _cmd);
        return;
    }

    [transition release];
    transition = [newTransition retain];

    NSLog(@"transitionView: %p", transitionView);
    [transitionView setTransition:transition];

    [self updateViews];

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
    }

    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
{
    if (outlineView == equationOutlineView) {
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
        }
    }

    return nil;
}

//
// NSOutlineView delegate
//

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
{
    return [transitionView selectedPoint] != nil && [item isKindOfClass:[MMEquation class]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item;
{
    MMEquation *selectedEquation;

    selectedEquation = [equationOutlineView selectedItemOfClass:[MMEquation class]];

    // Don't allow collapsing the group with the selection, otherwise we lose the selection
    return item != [selectedEquation group];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)aNotification;
{
    NSOutlineView *outlineView;

    outlineView = [aNotification object];

    if (outlineView == equationOutlineView) {
        MMEquation *selectedEquation;

        selectedEquation = [equationOutlineView selectedItemOfClass:[MMEquation class]];
        [[transitionView selectedPoint] setExpression:selectedEquation];
        [self _updateSelectedPointDetails];
        [transitionView setNeedsDisplay:YES];
    }
}

//
// TransitionView delegate
//

- (void)transitionViewSelectionDidChange:(NSNotification *)aNotification;
{
    NSLog(@" > %s", _cmd);
    NSLog(@"[aNotification object]: %@", [aNotification object]);

    if ([aNotification object] == transitionView) {
        [self _updateSelectedPointDetails];
    }

    NSLog(@"<  %s", _cmd);
}

- (BOOL)transitionView:(TransitionView *)aTransitionView shouldAddPoint:(MMPoint *)aPoint;
{
    if ([[transitionView transition] isTimeInSlopeRatio:[aPoint getTime]] == YES) {
        if (NSRunAlertPanel(@"Insert Point", @"Insert Point into Slope Ratio?", @"Insert", @"Don't Insert", nil) == NSAlertDefaultReturn)
            return YES;
        else
            return NO;
    }

    return YES;
}

- (void)_updateSelectedPointDetails;
{
    MMPoint *selectedPoint;

    selectedPoint = [transitionView selectedPoint];
    NSLog(@"selectedPoint: %p", selectedPoint);
    if (selectedPoint != nil) {
        MMEquation *equation;

        equation = [selectedPoint expression];
        if (equation == nil) {
            [equationOutlineView deselectAll:nil];

            [equationTextView setString:[NSString stringWithFormat:@"Fixed: %.3f ms", [selectedPoint freeTime]]];
        } else {
            NamedList *group;
            int row, groupRow;

            group = [equation group];
            groupRow = [equationOutlineView rowForItem:group];
            row = [equationOutlineView rowForItem:equation];
            [equationOutlineView selectRow:row byExtendingSelection:NO];
            if ([equationOutlineView isItemExpanded:group] == NO)
                [equationOutlineView expandItem:group];
            [equationOutlineView scrollRowToVisible:groupRow];
            [equationOutlineView scrollRowToVisible:row];

            [equationTextView setString:[[equation expression] expressionString]];
        }

        // TODO (2004-03-22): You shouldn't be able to set the value of points in a SlopeRatio (except maybe the first point).
        [valueTextField setDoubleValue:[selectedPoint value]];
        switch ([selectedPoint type]) {
          case DIPHONE:
              [type1Button setState:1];
              [type2Button setState:0];
              [type3Button setState:0];
              break;
          case TRIPHONE:
              [type1Button setState:0];
              [type2Button setState:1];
              [type3Button setState:0];
              break;
          case TETRAPHONE:
              [type1Button setState:0];
              [type2Button setState:0];
              [type3Button setState:1];
              break;
        }
        [isPhantomSwitch setState:[selectedPoint isPhantom]];
    } else {
        [equationOutlineView deselectAll:nil];

        [valueTextField setStringValue:@""];
        [type1Button setState:0];
        [type2Button setState:0];
        [type3Button setState:0];
        [isPhantomSwitch setState:0];
        [equationTextView setString:@""];
    }
}

- (IBAction)setType:(id)sender;
{
    int tag = [sender tag];

    [type1Button setState:tag == 2];
    [type2Button setState:tag == 3];
    [type3Button setState:tag == 4];
    [[transitionView selectedPoint] setType:tag];

    [transitionView setNeedsDisplay:YES];
    [self _updateSelectedPointDetails];
}

- (IBAction)setValue:(id)sender;
{
    [[transitionView selectedPoint] setValue:[valueTextField doubleValue]];
    [transitionView setNeedsDisplay:YES];
}

- (IBAction)setPhantom:(id)sender;
{
    [[transitionView selectedPoint] setIsPhantom:[isPhantomSwitch state]];
    [transitionView setNeedsDisplay:YES];
}

@end