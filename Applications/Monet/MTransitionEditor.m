//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MTransitionEditor.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"
#import "NSOutlineView-Extensions.h"

#import "TransitionView.h"

@implementation MTransitionEditor
{
    IBOutlet NSTextField *transitionNameTextField;
    IBOutlet NSPopUpButton *transitionTypePopUpButton;
    IBOutlet TransitionView *transitionView;
    IBOutlet NSForm *controlParametersForm;
    
    IBOutlet NSOutlineView *equationOutlineView;
    IBOutlet NSTextField *valueTextField;
    IBOutlet NSButton *isPhantomSwitch;
    
    IBOutlet NSButton *type1Button;
    IBOutlet NSButton *type2Button;
    IBOutlet NSButton *type3Button;
    
    IBOutlet NSTextView *equationTextView;
    
    MModel *model;
    
    MMTransition *transition;
}

- (id)init;
{
    if ((self = [super initWithWindowNibName:@"TransitionEditor"])) {
        [self setWindowFrameAutosaveName:@"Transition Editor"];
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
    if (newModel != model) {
        [model release];
        model = [newModel retain];

        [transitionView setModel:model];
        [self setTransition:nil];

        [self updateViews];
    }
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
    NSNumberFormatter *defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];
    [[valueTextField cell] setFormatter:defaultNumberFormatter];

    [transitionView setModel:model];
    [transitionView setTransition:transition];

    [self updateViews];
}

- (void)updateViews;
{
    NSString *name = [transition name];
    if (name == nil)
        name = @"--";
    [transitionNameTextField setStringValue:name];

    [transitionTypePopUpButton selectItemWithTag:[transition type]];

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
    for (MMGroup *group in model.equationGroups) {
        [equationOutlineView expandItem:group];
    }

    [equationOutlineView sizeToFit];
}

- (MMTransition *)transition;
{
    return transition;
}

- (void)setTransition:(MMTransition *)newTransition;
{
    if (newTransition != transition) {
        [transition release];
        transition = [newTransition retain];

        [transitionView setTransition:transition];

        [self updateViews];
    }
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
{
    //NSLog(@"-> %s, item: %p", _cmd, item);
    if (outlineView == equationOutlineView) {
        if (item == nil)
            return [model.equationGroups count];
        else {
            MMGroup *group = item;
            return [group.objects count];
        }
    }

    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
{
    if (outlineView == equationOutlineView) {
        if (item == nil)
            return [model.equationGroups objectAtIndex:index];
        else {
            MMGroup *group = item;
            return [group.objects objectAtIndex:index];
        }
    }

    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
{
    if (outlineView == equationOutlineView) {
        return [item isKindOfClass:[MMGroup class]];
    }

    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
{
    id identifier = [tableColumn identifier];
    //NSLog(@"identifier: %@, item: %p, item class: %@", identifier, item, NSStringFromClass([item class]));

    if (outlineView == equationOutlineView) {
        if ([@"name" isEqual:identifier] == YES) {
            return [item name];
        }
    }

    return nil;
}

#pragma mark - NSOutlineViewDelegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
{
    return [transitionView selectedPoint] != nil && [item isKindOfClass:[MMEquation class]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item;
{
    MMEquation *selectedEquation = [equationOutlineView selectedItemOfClass:[MMEquation class]];

    // Don't allow collapsing the group with the selection, otherwise we lose the selection
    return item != [selectedEquation group];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)aNotification;
{
    NSOutlineView *outlineView = [aNotification object];

    if (outlineView == equationOutlineView) {
        MMEquation *selectedEquation = [equationOutlineView selectedItemOfClass:[MMEquation class]];
        [[transitionView selectedPoint] setTimeEquation:selectedEquation];
        [self _updateSelectedPointDetails];
        [transitionView setNeedsDisplay:YES];
    }
}

#pragma mark - TransitionViewDelegate

- (void)transitionViewSelectionDidChange:(NSNotification *)aNotification;
{
    if ([aNotification object] == transitionView) {
        [self _updateSelectedPointDetails];
    }
}

- (BOOL)transitionView:(TransitionView *)aTransitionView shouldAddPoint:(MMPoint *)aPoint;
{
    if ([[transitionView transition] isTimeInSlopeRatio:[aPoint cachedTime]] == YES) {
        if (NSRunAlertPanel(@"Insert Point", @"Insert Point into Slope Ratio?", @"Insert", @"Don't Insert", nil) == NSAlertDefaultReturn)
            return YES;
        else
            return NO;
    }

    return YES;
}

- (void)_updateSelectedPointDetails;
{
    MMPoint *selectedPoint = [transitionView selectedPoint];
    if (selectedPoint != nil) {
        MMEquation *equation = [selectedPoint timeEquation];
        if (equation == nil) {
            [equationOutlineView deselectAll:nil];

            [equationTextView setString:[NSString stringWithFormat:@"Fixed: %.3f ms", [selectedPoint freeTime]]];
        } else {
            MMGroup *group = [equation group];
            NSInteger groupRow = [equationOutlineView rowForItem:group];
            NSInteger row = [equationOutlineView rowForItem:equation];
            [equationOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
            if ([equationOutlineView isItemExpanded:group] == NO)
                [equationOutlineView expandItem:group];
            [equationOutlineView scrollRowToVisible:groupRow];
            [equationOutlineView scrollRowToVisible:row];

            NSString *str = [[equation formula] expressionString];
            if (str == nil)
                str = @"";
            [equationTextView setString:str];
        }

        // TODO (2004-03-22): You shouldn't be able to set the value of points in a SlopeRatio (except maybe the first point).
        [valueTextField setDoubleValue:[selectedPoint value]];
        switch ([selectedPoint type]) {
          case MMPhoneType_Diphone:
              [type1Button setState:1];
              [type2Button setState:0];
              [type3Button setState:0];
              break;
          case MMPhoneType_Triphone:
              [type1Button setState:0];
              [type2Button setState:1];
              [type3Button setState:0];
              break;
          case MMPhoneType_Tetraphone:
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
    NSInteger tag = [sender tag];

    [type1Button setState:tag == 2];
    [type2Button setState:tag == 3];
    [type3Button setState:tag == 4];
    [[transitionView selectedPoint] setType:tag];

    [transitionView setNeedsDisplay:YES];
    [self _updateSelectedPointDetails];
}

- (IBAction)setPointValue:(id)sender;
{
    [[transitionView selectedPoint] setValue:[valueTextField doubleValue]];
    [transitionView setNeedsDisplay:YES];
}

- (IBAction)setPhantom:(id)sender;
{
    [[transitionView selectedPoint] setIsPhantom:[isPhantomSwitch state]];
    [transitionView setNeedsDisplay:YES];
}

- (IBAction)setTransitionType:(id)sender;
{
    [transition setType:[[transitionTypePopUpButton selectedItem] tag]];
    [transitionView updateTransitionType];
    [self updateViews]; // To get change in control parameters
}

@end
