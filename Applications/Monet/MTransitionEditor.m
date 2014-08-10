//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MTransitionEditor.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"
#import "NSOutlineView-Extensions.h"

#import "TransitionView.h"

@implementation MTransitionEditor
{
    IBOutlet NSTextField *_transitionNameTextField;
    IBOutlet NSPopUpButton *_transitionTypePopUpButton;
    IBOutlet TransitionView *_transitionView;
    IBOutlet NSForm *_controlParametersForm;
    
    IBOutlet NSOutlineView *_equationOutlineView;
    IBOutlet NSTextField *_valueTextField;
    IBOutlet NSButton *_isPhantomSwitch;
    
    IBOutlet NSButton *_type1Button;
    IBOutlet NSButton *_type2Button;
    IBOutlet NSButton *_type3Button;
    
    IBOutlet NSTextView *_equationTextView;
    
    MModel *_model;
    
    MMTransition *_transition;
}

- (id)init;
{
    if ((self = [super initWithWindowNibName:@"TransitionEditor"])) {
        [self setWindowFrameAutosaveName:@"Transition Editor"];
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
    if (newModel != _model) {
        _model = newModel;

        [_transitionView setModel:_model];
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
    [[_valueTextField cell] setFormatter:defaultNumberFormatter];

    [_transitionView setModel:_model];
    [_transitionView setTransition:_transition];

    [self updateViews];
}

- (void)updateViews;
{
    NSString *name = [_transition name];
    if (name == nil)
        name = @"--";
    [_transitionNameTextField setStringValue:name];

    [_transitionTypePopUpButton selectItemWithTag:[_transition type]];

    [[_controlParametersForm cellAtIndex:0] setDoubleValue:[_transitionView ruleDuration]];
    [[_controlParametersForm cellAtIndex:1] setDoubleValue:[_transitionView beatLocation]];
    [[_controlParametersForm cellAtIndex:2] setDoubleValue:[_transitionView mark1]];
    [[_controlParametersForm cellAtIndex:3] setDoubleValue:[_transitionView mark2]];
    [[_controlParametersForm cellAtIndex:4] setDoubleValue:[_transitionView mark3]];

    [_equationOutlineView reloadData];
    [self expandEquations];
}

- (void)expandEquations;
{
    for (MMGroup *group in _model.equationGroups) {
        [_equationOutlineView expandItem:group];
    }

    [_equationOutlineView sizeToFit];
}

- (MMTransition *)transition;
{
    return _transition;
}

- (void)setTransition:(MMTransition *)newTransition;
{
    if (newTransition != _transition) {
        _transition = newTransition;

        [_transitionView setTransition:_transition];

        [self updateViews];
    }
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
{
    //NSLog(@"-> %s, item: %p", _cmd, item);
    if (outlineView == _equationOutlineView) {
        if (item == nil)
            return [_model.equationGroups count];
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
            return [_model.equationGroups objectAtIndex:index];
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
        return [item isKindOfClass:[MMGroup class]];
    }

    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
{
    id identifier = [tableColumn identifier];
    //NSLog(@"identifier: %@, item: %p, item class: %@", identifier, item, NSStringFromClass([item class]));

    if (outlineView == _equationOutlineView) {
        if ([@"name" isEqual:identifier] == YES) {
            return [item name];
        }
    }

    return nil;
}

#pragma mark - NSOutlineViewDelegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
{
    return [_transitionView selectedPoint] != nil && [item isKindOfClass:[MMEquation class]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item;
{
    MMEquation *selectedEquation = [_equationOutlineView selectedItemOfClass:[MMEquation class]];

    // Don't allow collapsing the group with the selection, otherwise we lose the selection
    return item != [selectedEquation group];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification;
{
    NSOutlineView *outlineView = [notification object];

    if (outlineView == _equationOutlineView) {
        MMEquation *selectedEquation = [_equationOutlineView selectedItemOfClass:[MMEquation class]];
        [[_transitionView selectedPoint] setTimeEquation:selectedEquation];
        [self _updateSelectedPointDetails];
        [_transitionView setNeedsDisplay:YES];
    }
}

#pragma mark - TransitionViewDelegate

- (void)transitionViewSelectionDidChange:(NSNotification *)notification;
{
    if ([notification object] == _transitionView) {
        [self _updateSelectedPointDetails];
    }
}

- (BOOL)transitionView:(TransitionView *)transitionView shouldAddPoint:(MMPoint *)point;
{
    if ([[_transitionView transition] isTimeInSlopeRatio:[point cachedTime]] == YES) {
        if (NSRunAlertPanel(@"Insert Point", @"Insert Point into Slope Ratio?", @"Insert", @"Don't Insert", nil) == NSAlertDefaultReturn)
            return YES;
        else
            return NO;
    }

    return YES;
}

- (void)_updateSelectedPointDetails;
{
    MMPoint *selectedPoint = [_transitionView selectedPoint];
    if (selectedPoint != nil) {
        MMEquation *equation = [selectedPoint timeEquation];
        if (equation == nil) {
            [_equationOutlineView deselectAll:nil];

            [_equationTextView setString:[NSString stringWithFormat:@"Fixed: %.3f ms", [selectedPoint freeTime]]];
        } else {
            MMGroup *group = [equation group];
            NSInteger groupRow = [_equationOutlineView rowForItem:group];
            NSInteger row = [_equationOutlineView rowForItem:equation];
            [_equationOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
            if ([_equationOutlineView isItemExpanded:group] == NO)
                [_equationOutlineView expandItem:group];
            [_equationOutlineView scrollRowToVisible:groupRow];
            [_equationOutlineView scrollRowToVisible:row];

            NSString *str = [[equation formula] expressionString];
            if (str == nil)
                str = @"";
            [_equationTextView setString:str];
        }

        // TODO (2004-03-22): You shouldn't be able to set the value of points in a SlopeRatio (except maybe the first point).
        [_valueTextField setDoubleValue:[selectedPoint value]];
        switch ([selectedPoint type]) {
          case MMPhoneType_Diphone:
              [_type1Button setState:1];
              [_type2Button setState:0];
              [_type3Button setState:0];
              break;
          case MMPhoneType_Triphone:
              [_type1Button setState:0];
              [_type2Button setState:1];
              [_type3Button setState:0];
              break;
          case MMPhoneType_Tetraphone:
              [_type1Button setState:0];
              [_type2Button setState:0];
              [_type3Button setState:1];
              break;
        }
        [_isPhantomSwitch setState:[selectedPoint isPhantom]];
    } else {
        [_equationOutlineView deselectAll:nil];

        [_valueTextField setStringValue:@""];
        [_type1Button setState:0];
        [_type2Button setState:0];
        [_type3Button setState:0];
        [_isPhantomSwitch setState:0];
        [_equationTextView setString:@""];
    }
}

- (IBAction)setType:(id)sender;
{
    NSInteger tag = [sender tag];

    [_type1Button setState:tag == 2];
    [_type2Button setState:tag == 3];
    [_type3Button setState:tag == 4];
    [[_transitionView selectedPoint] setType:tag];

    [_transitionView setNeedsDisplay:YES];
    [self _updateSelectedPointDetails];
}

- (IBAction)setPointValue:(id)sender;
{
    [[_transitionView selectedPoint] setValue:[_valueTextField doubleValue]];
    [_transitionView setNeedsDisplay:YES];
}

- (IBAction)setPhantom:(id)sender;
{
    [[_transitionView selectedPoint] setIsPhantom:[_isPhantomSwitch state]];
    [_transitionView setNeedsDisplay:YES];
}

- (IBAction)setTransitionType:(id)sender;
{
    [_transition setType:[[_transitionTypePopUpButton selectedItem] tag]];
    [_transitionView updateTransitionType];
    [self updateViews]; // To get change in control parameters
}

@end
