//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MRuleManager.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSOutlineView-Extensions.h"

#import "MCommentCell.h"

static NSString *MRMLocalRuleDragPasteboardType = @"MRMLocalRuleDragPasteboardType";

@implementation MRuleManager
{
    IBOutlet NSTableView *_ruleTableView;

    IBOutlet NSBrowser *_match1Browser;
    IBOutlet NSBrowser *_match2Browser;
    IBOutlet NSBrowser *_match3Browser;
    IBOutlet NSBrowser *_match4Browser;

    IBOutlet NSForm *_expressionForm;
    IBOutlet NSTextField *_errorTextField;
    IBOutlet NSTextField *_possibleCombinationsTextField;

    IBOutlet NSTableView *_symbolTableView;
    IBOutlet NSOutlineView *_symbolEquationOutlineView;

    IBOutlet NSTableView *_parameterTableView;
    IBOutlet NSOutlineView *_parameterTransitionOutlineView;

    IBOutlet NSTableView *_specialParameterTableView;
    IBOutlet NSOutlineView *_specialParameterTransitionOutlineView;

    IBOutlet NSTableView *_metaParameterTableView;
    IBOutlet NSOutlineView *_metaParameterTransitionOutlineView;

    IBOutlet NSTextView *_ruleCommentTextView;

    MModel *_model;

    NSMutableArray *_matchLists; // Of arrays of postures/categories?
    MMBooleanNode *_expressions[4];

    NSFont *_regularControlFont;
    NSFont *_boldControlFont;

    MMBooleanParser *_boolParser;
}

- (id)initWithModel:(MModel *)model;
{
    if ((self = [super initWithWindowNibName:@"RuleManager"])) {
        _model = model;
        
        _matchLists = [[NSMutableArray alloc] init];
        for (NSUInteger index = 0; index < 4; index++) {
            NSMutableArray *aPhoneList;
            
            aPhoneList = [[NSMutableArray alloc] init];
            [_matchLists addObject:aPhoneList];
        }
        
        _boolParser = [[MMBooleanParser alloc] initWithModel:_model];
        
        [self setWindowFrameAutosaveName:@"New Rule Manager"];
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

    [_boolParser setModel:_model];

    [self updateViews];
    [self expandOutlines];

    [_ruleTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (MMRule *)selectedRule;
{
    NSInteger selectedRow;

    selectedRow = [_ruleTableView selectedRow];
    if (selectedRow == -1)
        return nil;

    return [[_model rules] objectAtIndex:selectedRow];
}

- (void)windowDidLoad;
{
    MCommentCell *commentImageCell;

    _regularControlFont = [NSFont controlContentFontOfSize:[NSFont systemFontSize]];
    _boldControlFont = [[NSFontManager sharedFontManager] convertFont:_regularControlFont toHaveTrait:NSBoldFontMask];

    commentImageCell = [[MCommentCell alloc] initImageCell:nil];
    [commentImageCell setImageAlignment:NSImageAlignCenter];
    [[_ruleTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];

    [_errorTextField setStringValue:@""];
    [_possibleCombinationsTextField setIntValue:0];

    [_ruleCommentTextView setFieldEditor:YES];

    [_ruleTableView registerForDraggedTypes:[NSArray arrayWithObject:MRMLocalRuleDragPasteboardType]];

    [self updateViews];
    [self expandOutlines];

    [_ruleTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

- (void)updateViews;
{
    [_ruleTableView reloadData];

    [_symbolTableView reloadData];
    [_symbolEquationOutlineView reloadData];

    [_parameterTableView reloadData];
    [_parameterTransitionOutlineView reloadData];

    [_specialParameterTableView reloadData];
    [_specialParameterTransitionOutlineView reloadData];

    [_metaParameterTableView reloadData];
    [_metaParameterTransitionOutlineView reloadData];

    [self _updateSelectedRuleDetails];
}

- (void)expandOutlines;
{
    NSUInteger count, index;

    count = [[_model equationGroups] count];
    for (index = 0; index < count; index++)
        [_symbolEquationOutlineView expandItem:[[_model equationGroups] objectAtIndex:index]];

    count = [[_model transitionGroups] count];
    for (index = 0; index < count; index++)
        [_parameterTransitionOutlineView expandItem:[[_model transitionGroups] objectAtIndex:index]];

    count = [[_model specialTransitionGroups] count];
    for (index = 0; index < count; index++)
        [_specialParameterTransitionOutlineView expandItem:[[_model specialTransitionGroups] objectAtIndex:index]];

    count = [[_model transitionGroups] count];
    for (index = 0; index < count; index++)
        [_metaParameterTransitionOutlineView expandItem:[[_model transitionGroups] objectAtIndex:index]];
}

- (void)_updateSelectedRuleDetails;
{
    NSString *str;
    MMBooleanNode *expression;
    NSInteger index;

    MMRule *rule = [self selectedRule];

    for (index = 0; index < 4; index++) {
        expression = [rule getExpressionNumber:index];
        str = [expression expressionString];
        if (str == nil)
            str = @"";
        [[_expressionForm cellAtIndex:index] setStringValue:str];
        [self setExpression:expression atIndex:index];
    }

    [self evaluateMatchLists];

    [_symbolTableView reloadData]; // To change the number of symbols
    [self _updateSelectedSymbolDetails];
    [self _updateSelectedParameterDetails];
    [_specialParameterTableView setNeedsDisplay:YES]; // To update bold rows
    [self _updateSelectedSpecialParameterDetails];
    [self _updateSelectedMetaParameterDetails];
    [self _updateRuleComment];
}

- (void)_updateRuleComment;
{
    MMRule *rule = [self selectedRule];
    NSString *str = [rule comment];
    if (str == nil)
        str = @"";

    [_ruleCommentTextView setString:str];
}

- (void)_updateSelectedSymbolDetails;
{
    MMEquation *equation;

    [_symbolTableView reloadData]; // To get changes to values

    NSInteger selectedRow = [_symbolTableView selectedRow];
    if (selectedRow == -1)
        equation = nil;
    else
        equation = [[[self selectedRule] symbolEquations] objectAtIndex:selectedRow];

    if (equation == nil) {
        [_symbolEquationOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        [_symbolEquationOutlineView scrollRowToVisible:0];
    } else {
        if ([equation group] != nil) {
            [_symbolEquationOutlineView scrollRowForItemToVisible:[equation group]];
            [_symbolEquationOutlineView expandItem:[equation group]];
        }
        [_symbolEquationOutlineView selectItem:equation];
    }
}

- (void)_updateSelectedParameterDetails;
{
    [_parameterTableView reloadData]; // To get updated values

    NSInteger selectedRow = [_parameterTableView selectedRow];
    NSArray *transitions = [[self selectedRule] parameterTransitions];
    if (selectedRow < [transitions count]) {
        MMTransition *aTransition;

        aTransition = [transitions objectAtIndex:selectedRow];
        if ([aTransition group] != nil) {
            [_parameterTransitionOutlineView scrollRowForItemToVisible:[aTransition group]];
            [_parameterTransitionOutlineView expandItem:[aTransition group]];
        }
        [_parameterTransitionOutlineView selectItem:aTransition];
    }
}

- (void)_updateSelectedSpecialParameterDetails;
{
    [_specialParameterTableView reloadData]; // To get updated values

    NSInteger selectedRow = [_specialParameterTableView selectedRow];
    MMTransition *transition = [[self selectedRule] getSpecialProfile:selectedRow];
    if ([transition group] != nil) {
        [_specialParameterTransitionOutlineView scrollRowForItemToVisible:[transition group]];
        [_specialParameterTransitionOutlineView expandItem:[transition group]];
    }
    [_specialParameterTransitionOutlineView selectItem:transition];
}

- (void)_updateSelectedMetaParameterDetails;
{
    [_metaParameterTableView reloadData]; // To get updated values

    NSInteger selectedRow = [_metaParameterTableView selectedRow];
    NSArray *transitions = [[self selectedRule] metaParameterTransitions];
    if (selectedRow < [transitions count]) {
        MMTransition *aTransition;

        aTransition = [transitions objectAtIndex:selectedRow];
        if ([aTransition group] != nil) {
            [_metaParameterTransitionOutlineView scrollRowForItemToVisible:[aTransition group]];
            [_metaParameterTransitionOutlineView expandItem:[aTransition group]];
        }
        [_metaParameterTransitionOutlineView selectItem:aTransition];
    }
}

- (void)setExpression:(MMBooleanNode *)expression atIndex:(NSInteger)index;
{
    if (expression == _expressions[index])
        return;

    _expressions[index] = expression;
}

// Align the sub-expressions if one happens to have been removed.
- (void)realignExpressions;
{
    NSInteger index;
    NSCell *thisCell, *nextCell;

    for (index = 0; index < 3; index++) {

        thisCell = [_expressionForm cellAtIndex:index];
        nextCell = [_expressionForm cellAtIndex:index + 1];

        if ([[thisCell stringValue] isEqualToString:@""]) {
            [thisCell setStringValue:[nextCell stringValue]];
            [nextCell setStringValue:@""];
            [self setExpression:_expressions[index + 1] atIndex:index];
            [self setExpression:nil atIndex:index + 1];
        }
    }

    thisCell = [_expressionForm cellAtIndex:3];
    if ([[thisCell stringValue] isEqualToString:@""]) {
        [self setExpression:nil atIndex:3];
    }

    [self evaluateMatchLists];
}

- (void)evaluateMatchLists;
{
    NSUInteger expressionIndex;
    NSUInteger count, index;
    NSMutableArray *aMatchedPhoneList;
    NSArray *mainPhoneList = [[self model] postures];
    NSString *str;

    count = [[_model postures] count];

    for (expressionIndex = 0; expressionIndex < 4; expressionIndex++) {
        aMatchedPhoneList = [_matchLists objectAtIndex:expressionIndex];
        [aMatchedPhoneList removeAllObjects];

        for (index = 0; index < count; index++) {
            MMPosture *aPhone;

            aPhone = [mainPhoneList objectAtIndex:index];
            //NSLog(@"index: %d, phone categoryList count: %d", index, [[aPhone categories] count]);
            if ([_expressions[expressionIndex] evaluateWithCategories:[aPhone categories]]) {
                [aMatchedPhoneList addObject:aPhone];
            }
        }
        //NSLog(@"expressions[%d]: %p, matches[%d] count: %d", expressionIndex, expressions[expressionIndex], expressionIndex, [aMatchedPhoneList count]);
    }

    // TODO (2004-03-24): We're getting an assertion failure in [NSMatrix lockFocus] somewhere in the following code.  This may be a good enough reason to switch to NSTableViews instead of NSBrowsers.
    str = [NSString stringWithFormat:@"Total Matches: %lu", [[_matchLists objectAtIndex:0] count]];
    [_match1Browser setTitle:str ofColumn:0];
    [_match1Browser loadColumnZero];

    str = [NSString stringWithFormat:@"Total Matches: %lu", [[_matchLists objectAtIndex:1] count]];
    [_match2Browser setTitle:str ofColumn:0];
    [_match2Browser loadColumnZero];

    str = [NSString stringWithFormat:@"Total Matches: %lu", [[_matchLists objectAtIndex:2] count]];
    [_match3Browser setTitle:str ofColumn:0];
    [_match3Browser loadColumnZero];

    str = [NSString stringWithFormat:@"Total Matches: %lu", [[_matchLists objectAtIndex:3] count]];
    [_match4Browser setTitle:str ofColumn:0];
    [_match4Browser loadColumnZero];

    [self updateCombinations];
}

- (void)updateCombinations;
{
    NSUInteger index;
    NSUInteger totalCombinations;

    totalCombinations = [[_matchLists objectAtIndex:0] count];
    for (index = 1; index < 4; index++) {
        NSUInteger matchCount = [[_matchLists objectAtIndex:index] count];
        if (matchCount != 0)
            totalCombinations *= matchCount;
    }

    [_possibleCombinationsTextField setIntegerValue:totalCombinations];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == _ruleTableView) {
        return [[_model rules] count];
    }

    if (tableView == _symbolTableView) {
        if ([self selectedRule] == nil)
            return 2;

        return 2 + [[self selectedRule] numberExpressions] - 1;
    }

    if (tableView == _parameterTableView || tableView == _specialParameterTableView)
        return [[[self model] parameters] count];

    if (tableView == _metaParameterTableView)
        return [[[self model] metaParameters] count];

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    id identifier = [tableColumn identifier];

    if (tableView == _ruleTableView) {
        MMRule *rule;

        rule = [[_model rules] objectAtIndex:row];
        if ([@"hasComment" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[rule hasComment]];
        } else if ([@"number" isEqual:identifier] == YES) {
            return [NSString stringWithFormat:@"%lu.", row + 1];
        } else if ([@"rule" isEqual:identifier] == YES) {
            return [rule ruleString];
        } else if ([@"numberOfTokensConsumed" isEqual:identifier] == YES) {
            return [NSNumber numberWithInteger:[rule numberExpressions]];
        }
    } else if (tableView == _symbolTableView) {
        if ([@"name" isEqual:identifier] == YES) {
            switch (row) {
              case 0: return @"Rule Duration";
              case 1: return @"Beat";
              case 2: return @"Mark 1";
              case 3: return @"Mark 2";
              case 4: return @"Mark 3";
            }
        } else if ([@"equation" isEqual:identifier] == YES) {
            return [[[[self selectedRule] symbolEquations] objectAtIndex:row] equationPath];
        }
    } else if (tableView == _parameterTableView || tableView == _specialParameterTableView) {
        MMParameter *parameter;

        parameter = [[[self model] parameters] objectAtIndex:row];
        if ([@"name" isEqual:identifier] == YES) {
            return [parameter name];
        } else if ([@"transition" isEqual:identifier] == YES) {
            if (tableView == _parameterTableView)
                return [[[[self selectedRule] parameterTransitions] objectAtIndex:row] transitionPath];
            else if (tableView == _specialParameterTableView)
                return [[[self selectedRule] getSpecialProfile:row] transitionPath];
        }
    } else if (tableView == _metaParameterTableView) {
        MMParameter *parameter;

        parameter = [[[self model] metaParameters] objectAtIndex:row];
        if ([@"name" isEqual:identifier] == YES) {
            return [parameter name];
        } else if ([@"transition" isEqual:identifier] == YES) {
            return [[[[self selectedRule] metaParameterTransitions] objectAtIndex:row] transitionPath];
        }
    }


    return nil;
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification;
{
    NSTableView *tableView = [notification object];

    if (tableView == _ruleTableView) {
        [self _updateSelectedRuleDetails];
    } else if (tableView == _symbolTableView) {
        [self _updateSelectedSymbolDetails];
    } else if (tableView == _parameterTableView) {
        [self _updateSelectedParameterDetails];
    } else if (tableView == _specialParameterTableView) {
        [self _updateSelectedSpecialParameterDetails];
    } else if (tableView == _metaParameterTableView) {
        [self _updateSelectedMetaParameterDetails];
    }
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    if (tableView == _specialParameterTableView) {
        if ([[self selectedRule] getSpecialProfile:row] != nil)
            [cell setFont:_boldControlFont];
        else
            [cell setFont:_regularControlFont];
    }
}

#pragma mark - NSTableView dragging

- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard;
{
    if (tableView == _ruleTableView) {
        [pboard declareTypes:[NSArray arrayWithObject:MRMLocalRuleDragPasteboardType] owner:nil];
        [pboard setPropertyList:rows forType:MRMLocalRuleDragPasteboardType];
        return YES;
    }

    return NO;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op;
{
    if (tableView == _ruleTableView) {
        //NSString *availableType = [[info draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:MRMLocalRuleDragPasteboardType]];
        //NSLog(@"availableType: %@", availableType);

        if (op == NSTableViewDropOn)
            [tableView setDropRow:row dropOperation:NSTableViewDropAbove];

        return NSDragOperationMove;
    }

    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)op;
{
    if  (tableView == _ruleTableView) {
        NSPasteboard *pasteboard;
        NSString *availableType;
        NSArray *sourceRows;
        int sourceRowIndex;
        MMRule *aRule;

        pasteboard = [info draggingPasteboard];
        availableType = [pasteboard availableTypeFromArray:[NSArray arrayWithObject:MRMLocalRuleDragPasteboardType]];
        //NSLog(@"availableType: %@", availableType);

        if (availableType == nil)
            return NO;

        sourceRows = [pasteboard propertyListForType:availableType];
        sourceRowIndex = [[sourceRows objectAtIndex:0] intValue];

        // Adjust destination since we'll be removing the source from the list
        if (sourceRowIndex < row)
            row--;

        //NSLog(@"row: %d, op: %d, sourceRowIndex: %d", row, op, sourceRowIndex);
        aRule = [[[self model] rules] objectAtIndex:sourceRowIndex];
        [[[self model] rules] removeObject:aRule];
        [[[self model] rules] insertObject:aRule atIndex:row];

        [_ruleTableView reloadData];
        [_ruleTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];

        return YES;
    }

    return NO;
}

#pragma mark - MExtendedTableView delegate

- (BOOL)control:(NSControl *)control shouldProcessCharacters:(NSString *)characters;
{
    NSUInteger count = [[_model rules] count];
    NSUInteger index = [characters intValue];
    if (index > 0 && index <= count) {
        [_ruleTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index - 1] byExtendingSelection:NO];
        [_ruleTableView scrollRowToVisible:index - 1];
        return NO;
    }

    return YES;
}

#pragma mark - NSBrowserDelegate

- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column;
{
    if (sender == _match1Browser)
        return [[_matchLists objectAtIndex:0] count];

    if (sender == _match2Browser)
        return [[_matchLists objectAtIndex:1] count];

    if (sender == _match3Browser)
        return [[_matchLists objectAtIndex:2] count];

    if (sender == _match4Browser)
        return [[_matchLists objectAtIndex:3] count];

    return 0;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column;
{
    MMPosture *posture;

    if (sender == _match1Browser) {
        posture = [[_matchLists objectAtIndex:0] objectAtIndex:row];
        [cell setStringValue:[posture name]];
    } else if (sender == _match2Browser) {
        posture = [[_matchLists objectAtIndex:1] objectAtIndex:row];
        [cell setStringValue:[posture name]];
    } else if (sender == _match3Browser) {
        posture = [[_matchLists objectAtIndex:2] objectAtIndex:row];
        [cell setStringValue:[posture name]];
    } else if (sender == _match4Browser) {
        posture = [[_matchLists objectAtIndex:3] objectAtIndex:row];
        [cell setStringValue:[posture name]];
    }

    [cell setLeaf:YES];
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
{
    if (outlineView == _symbolEquationOutlineView) {
        if (item == nil) {
            return [[[self model] equationGroups] count];
        } else {
            MMGroup *group = item;
            return [group.objects count];
        }
    } else if (outlineView == _parameterTransitionOutlineView || outlineView == _metaParameterTransitionOutlineView) {
        if (item == nil) {
            return [[[self model] transitionGroups] count];
        } else {
            MMGroup *group = item;
            return [group.objects count];
        }
    } else if (outlineView == _specialParameterTransitionOutlineView) {
        if (item == nil) {
            return [[[self model] specialTransitionGroups] count];
        } else {
            MMGroup *group = item;
            return [group.objects count];
        }
    }

    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
{
    if (outlineView == _symbolEquationOutlineView) {
        if (item == nil) {
            return [[[self model] equationGroups] objectAtIndex:index];
        } else {
            MMGroup *group = item;
            return [group.objects objectAtIndex:index];
        }
    } else if (outlineView == _parameterTransitionOutlineView || outlineView == _metaParameterTransitionOutlineView) {
        if (item == nil) {
            return [[[self model] transitionGroups] objectAtIndex:index];
        } else {
            MMGroup *group = item;
            return [group.objects objectAtIndex:index];
        }
    } else if (outlineView == _specialParameterTransitionOutlineView) {
        if (item == nil) {
            return [[[self model] specialTransitionGroups] objectAtIndex:index];
        } else {
            MMGroup *group = item;
            return [group.objects objectAtIndex:index];
        }
    }

    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
{
    if (outlineView == _symbolEquationOutlineView) {
        return [item isKindOfClass:[MMGroup class]];
    } else if (outlineView == _parameterTransitionOutlineView || outlineView == _metaParameterTransitionOutlineView) {
        return [item isKindOfClass:[MMGroup class]];
    } else if (outlineView == _specialParameterTransitionOutlineView) {
        return [item isKindOfClass:[MMGroup class]];
    }

    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
{
    id identifier = [tableColumn identifier];
    //NSLog(@"identifier: %@, item: %p, item class: %@", identifier, item, NSStringFromClass([item class]));

    if (outlineView == _symbolEquationOutlineView) {
        if ([@"name" isEqual:identifier] == YES) {
            return [item name];
        }
    } else if (outlineView == _parameterTransitionOutlineView || outlineView == _metaParameterTransitionOutlineView) {
        if ([@"name" isEqual:identifier] == YES) {
            return [item name];
        }
    } else if (outlineView == _specialParameterTransitionOutlineView) {
        if ([@"name" isEqual:identifier] == YES) {
            return [item name];
        }
    }

    return nil;
}

#pragma mark - NSOutlineViewDelegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
{
    if (outlineView == _symbolEquationOutlineView) {
        return [_symbolTableView selectedRow] != -1 && (item == nil || [item isKindOfClass:[MMEquation class]]);
    } else if (outlineView == _parameterTransitionOutlineView) {
        return [_parameterTableView selectedRow] != -1 && [item isKindOfClass:[MMTransition class]];
    } else if (outlineView == _specialParameterTransitionOutlineView) {
        return [_specialParameterTableView selectedRow] != -1 && (item == nil || [item isKindOfClass:[MMTransition class]]);
    } else if (outlineView == _metaParameterTransitionOutlineView) {
        return [_metaParameterTableView selectedRow] != -1 && (item == nil || [item isKindOfClass:[MMTransition class]]);
    }

    return YES;
}

// Disallow collapsing the group with the selection, otherwise we lose the selection
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item;
{
    if (outlineView == _symbolEquationOutlineView) {
        MMEquation *selectedEquation = [outlineView selectedItemOfClass:[MMEquation class]];
        return item != [selectedEquation group];
    } else if (outlineView == _parameterTransitionOutlineView || outlineView == _specialParameterTransitionOutlineView
               || outlineView == _metaParameterTransitionOutlineView) {
        MMTransition *selectedTransition = [outlineView selectedItemOfClass:[MMTransition class]];
        return item != [selectedTransition group];
    }

    return YES;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification;
{
    NSOutlineView *outlineView = [notification object];

    if (outlineView == _symbolEquationOutlineView) {
        MMEquation *selectedEquation = [outlineView selectedItemOfClass:[MMEquation class]];
        if (selectedEquation != nil) {
            [[[self selectedRule] symbolEquations] replaceObjectAtIndex:[_symbolTableView selectedRow] withObject:selectedEquation];
        }
    } else if (outlineView == _parameterTransitionOutlineView) {
        MMTransition *selectedTransition = [outlineView selectedItemOfClass:[MMTransition class]];
        if (selectedTransition != nil) {
            [[[self selectedRule] parameterTransitions] replaceObjectAtIndex:[_parameterTableView selectedRow] withObject:selectedTransition];
        }
    } else if (outlineView == _specialParameterTransitionOutlineView) {
        MMTransition *selectedTransition = [outlineView selectedItemOfClass:[MMTransition class]];
        [[self selectedRule] setSpecialProfile:[_specialParameterTableView selectedRow] to:selectedTransition];
        [_specialParameterTableView setNeedsDisplay:YES]; // To update bolded rows
    } else if (outlineView == _metaParameterTransitionOutlineView) {
        MMTransition *selectedTransition = [outlineView selectedItemOfClass:[MMTransition class]];
        if (selectedTransition != nil) {
            [[[self selectedRule] metaParameterTransitions] replaceObjectAtIndex:[_metaParameterTableView selectedRow] withObject:selectedTransition];
        }
    }
}

#pragma mark - NSTextViewDelegate

- (void)textDidEndEditing:(NSNotification *)notification;
{
    NSTextView *textView = [notification object];
    // NSTextMovement is a key in the user info
    //NSLog(@"[aNotification userInfo]: %@", [aNotification userInfo]);

    NSString *newStringValue = [[textView string] copy];

    //NSLog(@"(1) newStringValue: %@", newStringValue);
    if ([newStringValue length] == 0) {
        newStringValue = nil;
    }
    //NSLog(@"(2) newStringValue: %@", newStringValue);

    if (textView == _ruleCommentTextView) {
        MMRule *selectedRule = [self selectedRule];
        [selectedRule setComment:newStringValue];
        [_ruleTableView reloadData]; // To update the icon for the row
    }
}

#pragma mark - Actions

// Sender should be the form for postures 1-4
// Warning (building for 10.2 deployment) (2004-04-02): aBrowser might be used uninitialized in this function
- (IBAction)setExpression:(id)sender;
{
    NSMutableArray *matchedPhoneList;
    NSArray *mainPhoneList = [[self model] postures];
    MMBooleanNode *parsedExpression;
    NSUInteger i;
    NSInteger tag;
    NSString *expressionString;
    NSBrowser *browser;

    tag = [[sender selectedCell] tag];

    if (tag < 0 || tag > 3) {
        NSLog(@"%s, tag out of range (0-3)", __PRETTY_FUNCTION__);
        return;
    }

    expressionString = [[sender cellAtIndex:tag] stringValue];
    //NSLog(@"tag: %d, expressionString: %@", tag, expressionString);
    if ([expressionString isEqualToString:@""]) {
        //NSLog(@"Realigning...");
        [self realignExpressions];
        return;
    }

    parsedExpression = [_boolParser parseString:expressionString];
    [_errorTextField setStringValue:[_boolParser errorMessage]];
    if (parsedExpression == nil) {
        //NSLog(@"parse error: %@", [boolParser errorMessage]);
        NSBeep();
        return;
    }

    [self setExpression:parsedExpression atIndex:tag];

    matchedPhoneList = [_matchLists objectAtIndex:tag];
    [matchedPhoneList removeAllObjects];

    for (i = 0; i < [mainPhoneList count]; i++) {
        MMPosture *currentPhone;

        currentPhone = [mainPhoneList objectAtIndex:i];
        if ([parsedExpression evaluateWithCategories:[currentPhone categories]]) {
            [matchedPhoneList addObject:currentPhone];
        }
    }

    switch (tag) {
      case 0:
          browser = _match1Browser;
          break;
      case 1:
          browser = _match2Browser;
          break;
      case 2:
          browser = _match3Browser;
          break;
      case 3:
          browser = _match4Browser;
          break;
      default:
          browser = nil;
    }

    [browser setTitle:[NSString stringWithFormat:@"Total Matches: %lu", [matchedPhoneList count]] ofColumn:0];
    [browser loadColumnZero];
    [self updateCombinations];
}

- (IBAction)addRule:(id)sender;
{
    MMBooleanNode *exps[4];

    for (NSUInteger index = 0; index < 4; index++) {
        NSString *str = [[_expressionForm cellAtIndex:index] stringValue];
        if ([str length] == 0)
            exps[index] = nil;
        else {
            exps[index] = [_boolParser parseString:str];
            if (exps[index] == nil) {
                [_errorTextField setStringValue:[_boolParser errorMessage]];
                return;
            }
        }
    }

    [_errorTextField setStringValue:[_boolParser errorMessage]];

    MMRule *newRule = [[MMRule alloc] init];
    [newRule setExpression:exps[0] number:0];
    [newRule setExpression:exps[1] number:1];
    [newRule setExpression:exps[2] number:2];
    [newRule setExpression:exps[3] number:3];
    [[self model] addRule:newRule];

    [_ruleTableView reloadData];
    [_ruleTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[[_model rules] count] - 2] byExtendingSelection:NO];
    [_ruleTableView scrollRowToVisible:[[_model rules] count] - 2];
}

- (IBAction)updateRule:(id)sender;
{
    MMBooleanNode *exps[4];

    for (NSUInteger index = 0; index < 4; index++) {
        NSString *str = [[_expressionForm cellAtIndex:index] stringValue];
        if ([str length] == 0)
            exps[index] = nil;
        else
            exps[index] = [_boolParser parseString:str];
    }

    [_errorTextField setStringValue:[_boolParser errorMessage]];
    MMRule *selectedRule = [self selectedRule];
    [selectedRule setRuleExpression1:exps[0] exp2:exps[1] exp3:exps[2] exp4:exps[3]];

    [_ruleTableView reloadData];
}

- (IBAction)removeRule:(id)sender;
{
    MMRule *selectedRule = [self selectedRule];
    if (selectedRule != nil)
        [[[self model] rules] removeObject:selectedRule];

    [self updateViews];
}

@end
