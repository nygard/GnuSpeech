//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MRuleManager.h"

#import <AppKit/AppKit.h>
#import "NSOutlineView-Extensions.h"

#import "MCommentCell.h"
#import "MMBooleanNode.h"
#import "MMBooleanParser.h"
#import "MMEquation.h"
#import "MModel.h"
#import "MMParameter.h"
#import "MMPosture.h"
#import "MMRule.h"
#import "MMTransition.h"
#import "NamedList.h"
#import "PhoneList.h"

static NSString *MRMLocalRuleDragPasteboardType = @"MRMLocalRuleDragPasteboardType";

@implementation MRuleManager

- (id)initWithModel:(MModel *)aModel;
{
    unsigned int index;

    if ([super initWithWindowNibName:@"RuleManager"] == nil)
        return nil;

    model = [aModel retain];

    matchLists = [[NSMutableArray alloc] init];
    for (index = 0; index < 4; index++) {
        NSMutableArray *aPhoneList;

        aPhoneList = [[NSMutableArray alloc] init];
        [matchLists addObject:aPhoneList];
        [aPhoneList release];
    }

    boolParser = [[MMBooleanParser alloc] initWithModel:model];

    [self setWindowFrameAutosaveName:@"New Rule Manager"];

    return self;
}

- (void)dealloc;
{
    [model release];
    [matchLists release];
    [regularControlFont release];
    [boldControlFont release];
    [boolParser release];

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

    [boolParser setModel:model];

    [self updateViews];
    [self expandOutlines];

    [ruleTableView selectRow:0 byExtendingSelection:NO];
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (MMRule *)selectedRule;
{
    int selectedRow;

    selectedRow = [ruleTableView selectedRow];
    if (selectedRow == -1)
        return nil;

    return [[model rules] objectAtIndex:selectedRow];
}

- (void)windowDidLoad;
{
    MCommentCell *commentImageCell;

    regularControlFont = [[NSFont controlContentFontOfSize:[NSFont systemFontSize]] retain];
    boldControlFont = [[[NSFontManager sharedFontManager] convertFont:regularControlFont toHaveTrait:NSBoldFontMask] retain];

    commentImageCell = [[MCommentCell alloc] initImageCell:nil];
    [commentImageCell setImageAlignment:NSImageAlignCenter];
    [[ruleTableView tableColumnWithIdentifier:@"hasComment"] setDataCell:commentImageCell];
    [commentImageCell release];

    [errorTextField setStringValue:@""];
    [possibleCombinationsTextField setIntValue:0];

    [ruleCommentTextView setFieldEditor:YES];

    [ruleTableView registerForDraggedTypes:[NSArray arrayWithObject:MRMLocalRuleDragPasteboardType]];

    [self updateViews];
    [self expandOutlines];

    [ruleTableView selectRow:0 byExtendingSelection:NO];
}

- (void)updateViews;
{
    [ruleTableView reloadData];

    [symbolTableView reloadData];
    [symbolEquationOutlineView reloadData];

    [parameterTableView reloadData];
    [parameterTransitionOutlineView reloadData];

    [specialParameterTableView reloadData];
    [specialParameterTransitionOutlineView reloadData];

    [metaParameterTableView reloadData];
    [metaParameterTransitionOutlineView reloadData];

    [self _updateSelectedRuleDetails];
}

- (void)expandOutlines;
{
    unsigned int count, index;

    count = [[model equations] count];
    for (index = 0; index < count; index++)
        [symbolEquationOutlineView expandItem:[[model equations] objectAtIndex:index]];

    count = [[model transitions] count];
    for (index = 0; index < count; index++)
        [parameterTransitionOutlineView expandItem:[[model transitions] objectAtIndex:index]];

    count = [[model specialTransitions] count];
    for (index = 0; index < count; index++)
        [specialParameterTransitionOutlineView expandItem:[[model specialTransitions] objectAtIndex:index]];

    count = [[model transitions] count];
    for (index = 0; index < count; index++)
        [metaParameterTransitionOutlineView expandItem:[[model transitions] objectAtIndex:index]];
}

- (void)_updateSelectedRuleDetails;
{
    MMRule *aRule;
    NSString *str;
    MMBooleanNode *anExpression;
    int index;

    aRule = [self selectedRule];

    for (index = 0; index < 4; index++) {
        anExpression = [aRule getExpressionNumber:index];
        str = [anExpression expressionString];
        if (str == nil)
            str = @"";
        [[expressionForm cellAtIndex:index] setStringValue:str];
        [self setExpression:anExpression atIndex:index];
    }

    [self evaluateMatchLists];

    [symbolTableView reloadData]; // To change the number of symbols
    [self _updateSelectedSymbolDetails];
    [self _updateSelectedParameterDetails];
    [specialParameterTableView setNeedsDisplay:YES]; // To update bold rows
    [self _updateSelectedSpecialParameterDetails];
    [self _updateSelectedMetaParameterDetails];
    [self _updateRuleComment];
}

- (void)_updateRuleComment;
{
    MMRule *aRule;
    NSString *str;

    aRule = [self selectedRule];
    str = [aRule comment];
    if (str == nil)
        str = @"";

    [ruleCommentTextView setString:str];
}

- (void)_updateSelectedSymbolDetails;
{
    int selectedRow;
    MMEquation *anEquation;

    [symbolTableView reloadData]; // To get changes to values

    selectedRow = [symbolTableView selectedRow];
    if (selectedRow == -1)
        anEquation = nil;
    else
        anEquation = [[[self selectedRule] symbols] objectAtIndex:selectedRow];

    if (anEquation == nil) {
        [symbolEquationOutlineView selectRow:0 byExtendingSelection:NO];
        [symbolEquationOutlineView scrollRowToVisible:0];
    } else {
        if ([anEquation group] != nil) {
            [symbolEquationOutlineView scrollRowForItemToVisible:[anEquation group]];
            [symbolEquationOutlineView expandItem:[anEquation group]];
        }
        [symbolEquationOutlineView selectItem:anEquation];
    }
}

- (void)_updateSelectedParameterDetails;
{
    int selectedRow;
    MMTransition *aTransition;

    [parameterTableView reloadData]; // To get updated values

    selectedRow = [parameterTableView selectedRow];
    aTransition = [[[self selectedRule] parameterList] objectAtIndex:selectedRow];
    if ([aTransition group] != nil) {
        [parameterTransitionOutlineView scrollRowForItemToVisible:[aTransition group]];
        [parameterTransitionOutlineView expandItem:[aTransition group]];
    }
    [parameterTransitionOutlineView selectItem:aTransition];
}

- (void)_updateSelectedSpecialParameterDetails;
{
    int selectedRow;
    MMTransition *aTransition;

    [specialParameterTableView reloadData]; // To get updated values

    selectedRow = [specialParameterTableView selectedRow];
    aTransition = [[self selectedRule] getSpecialProfile:selectedRow];
    if ([aTransition group] != nil) {
        [specialParameterTransitionOutlineView scrollRowForItemToVisible:[aTransition group]];
        [specialParameterTransitionOutlineView expandItem:[aTransition group]];
    }
    [specialParameterTransitionOutlineView selectItem:aTransition];
}

- (void)_updateSelectedMetaParameterDetails;
{
    int selectedRow;
    MMTransition *aTransition;

    [metaParameterTableView reloadData]; // To get updated values

    selectedRow = [metaParameterTableView selectedRow];
    aTransition = [[[self selectedRule] metaParameterList] objectAtIndex:selectedRow];
    if ([aTransition group] != nil) {
        [metaParameterTransitionOutlineView scrollRowForItemToVisible:[aTransition group]];
        [metaParameterTransitionOutlineView expandItem:[aTransition group]];
    }
    [metaParameterTransitionOutlineView selectItem:aTransition];
}

- (void)setExpression:(MMBooleanNode *)anExpression atIndex:(int)index;
{
    if (anExpression == expressions[index])
        return;

    [expressions[index] release];
    expressions[index] = [anExpression retain];
}

// Align the sub-expressions if one happens to have been removed.
- (void)realignExpressions;
{
    int index;
    NSCell *thisCell, *nextCell;

    for (index = 0; index < 3; index++) {

        thisCell = [expressionForm cellAtIndex:index];
        nextCell = [expressionForm cellAtIndex:index + 1];

        if ([[thisCell stringValue] isEqualToString:@""]) {
            [thisCell setStringValue:[nextCell stringValue]];
            [nextCell setStringValue:@""];
            [self setExpression:expressions[index + 1] atIndex:index];
            [self setExpression:nil atIndex:index + 1];
        }
    }

    thisCell = [expressionForm cellAtIndex:3];
    if ([[thisCell stringValue] isEqualToString:@""]) {
        [self setExpression:nil atIndex:3];
    }

    [self evaluateMatchLists];
}

- (void)evaluateMatchLists;
{
    unsigned int expressionIndex;
    unsigned int count, index;
    NSMutableArray *aMatchedPhoneList;
    NSArray *mainPhoneList = [[self model] postures];
    NSString *str;

    count = [[model postures] count];

    for (expressionIndex = 0; expressionIndex < 4; expressionIndex++) {
        aMatchedPhoneList = [matchLists objectAtIndex:expressionIndex];
        [aMatchedPhoneList removeAllObjects];

        for (index = 0; index < count; index++) {
            MMPosture *aPhone;

            aPhone = [mainPhoneList objectAtIndex:index];
            //NSLog(@"index: %d, phone categoryList count: %d", index, [[aPhone categories] count]);
            if ([expressions[expressionIndex] evaluateWithCategories:[aPhone categories]]) {
                [aMatchedPhoneList addObject:aPhone];
            }
        }
        //NSLog(@"expressions[%d]: %p, matches[%d] count: %d", expressionIndex, expressions[expressionIndex], expressionIndex, [aMatchedPhoneList count]);
    }

    // TODO (2004-03-24): We're getting an assertion failure in [NSMatrix lockFocus] somewhere in the following code.  This may be a good enough reason to switch to NSTableViews instead of NSBrowsers.
    str = [NSString stringWithFormat:@"Total Matches: %d", [[matchLists objectAtIndex:0] count]];
    [match1Browser setTitle:str ofColumn:0];
    [match1Browser loadColumnZero];

    str = [NSString stringWithFormat:@"Total Matches: %d", [[matchLists objectAtIndex:1] count]];
    [match2Browser setTitle:str ofColumn:0];
    [match2Browser loadColumnZero];

    str = [NSString stringWithFormat:@"Total Matches: %d", [[matchLists objectAtIndex:2] count]];
    [match3Browser setTitle:str ofColumn:0];
    [match3Browser loadColumnZero];

    str = [NSString stringWithFormat:@"Total Matches: %d", [[matchLists objectAtIndex:3] count]];
    [match4Browser setTitle:str ofColumn:0];
    [match4Browser loadColumnZero];

    [self updateCombinations];
}

- (void)updateCombinations;
{
    unsigned int index;
    int totalCombinations;

    totalCombinations = [[matchLists objectAtIndex:0] count];
    for (index = 1; index < 4; index++) {
        int matchCount;

        matchCount = [[matchLists objectAtIndex:index] count];
        if (matchCount != 0)
            totalCombinations *= matchCount;
    }

    [possibleCombinationsTextField setIntValue:totalCombinations];
}

//
// NSTableView data source
//

- (int)numberOfRowsInTableView:(NSTableView *)tableView;
{
    if (tableView == ruleTableView)
        return [[model rules] count];

    if (tableView == symbolTableView) {
        if ([self selectedRule] == nil)
            return 2;

        return 2 + [[self selectedRule] numberExpressions] - 1;
    }

    if (tableView == parameterTableView || tableView == specialParameterTableView)
        return [[[self model] parameters] count];

    if (tableView == metaParameterTableView)
        return [[[self model] metaParameters] count];

    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
{
    id identifier;

    identifier = [tableColumn identifier];

    if (tableView == ruleTableView) {
        MMRule *rule;

        rule = [[model rules] objectAtIndex:row];
        if ([@"hasComment" isEqual:identifier] == YES) {
            return [NSNumber numberWithBool:[rule hasComment]];
        } else if ([@"number" isEqual:identifier] == YES) {
            return [NSString stringWithFormat:@"%d.", row + 1];
        } else if ([@"rule" isEqual:identifier] == YES) {
            return [rule ruleString];
        } else if ([@"numberOfTokensConsumed" isEqual:identifier] == YES) {
            return [NSNumber numberWithInt:[rule numberExpressions]];
        }
    } else if (tableView == symbolTableView) {
        if ([@"name" isEqual:identifier] == YES) {
            switch (row) {
              case 0: return @"Rule Duration";
              case 1: return @"Beat";
              case 2: return @"Mark 1";
              case 3: return @"Mark 2";
              case 4: return @"Mark 3";
            }
        } else if ([@"equation" isEqual:identifier] == YES) {
            return [[[[self selectedRule] symbols] objectAtIndex:row] equationPath];
        }
    } else if (tableView == parameterTableView || tableView == specialParameterTableView) {
        MMParameter *parameter;

        parameter = [[[self model] parameters] objectAtIndex:row];
        if ([@"name" isEqual:identifier] == YES) {
            return [parameter symbol];
        } else if ([@"transition" isEqual:identifier] == YES) {
            if (tableView == parameterTableView)
                return [[[[self selectedRule] parameterList] objectAtIndex:row] transitionPath];
            else if (tableView == specialParameterTableView)
                return [[[self selectedRule] getSpecialProfile:row] transitionPath];
        }
    } else if (tableView == metaParameterTableView) {
        MMParameter *parameter;

        parameter = [[[self model] metaParameters] objectAtIndex:row];
        if ([@"name" isEqual:identifier] == YES) {
            return [parameter symbol];
        } else if ([@"transition" isEqual:identifier] == YES) {
            return [[[[self selectedRule] metaParameterList] objectAtIndex:row] transitionPath];
        }
    }


    return nil;
}

//
// NSTableView delegate
//

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
{
    NSTableView *tableView;

    tableView = [aNotification object];

    if (tableView == ruleTableView) {
        [self _updateSelectedRuleDetails];
    } else if (tableView == symbolTableView) {
        [self _updateSelectedSymbolDetails];
    } else if (tableView == parameterTableView) {
        [self _updateSelectedParameterDetails];
    } else if (tableView == specialParameterTableView) {
        [self _updateSelectedSpecialParameterDetails];
    } else if (tableView == metaParameterTableView) {
        [self _updateSelectedMetaParameterDetails];
    }
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row;
{
    if (tableView == specialParameterTableView) {
        if ([[self selectedRule] getSpecialProfile:row] != nil)
            [cell setFont:boldControlFont];
        else
            [cell setFont:regularControlFont];
    }
}

//
// NSTableView dragging
//

- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard;
{
    if (tableView == ruleTableView) {
        [pboard declareTypes:[NSArray arrayWithObject:MRMLocalRuleDragPasteboardType] owner:nil];
        [pboard setPropertyList:rows forType:MRMLocalRuleDragPasteboardType];
        return YES;
    }

    return NO;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;
{
    if  (tableView == ruleTableView) {
        NSPasteboard *pasteboard;
        NSString *availableType;

        pasteboard = [info draggingPasteboard];
        availableType = [pasteboard availableTypeFromArray:[NSArray arrayWithObject:MRMLocalRuleDragPasteboardType]];
        //NSLog(@"availableType: %@", availableType);

        if (op == NSTableViewDropOn)
            [tableView setDropRow:row dropOperation:NSTableViewDropAbove];

        return NSDragOperationMove;
    }

    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op;
{
    if  (tableView == ruleTableView) {
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
        aRule = [[[[self model] rules] objectAtIndex:sourceRowIndex] retain];
        [[[self model] rules] removeObject:aRule];
        [[[self model] rules] insertObject:aRule atIndex:row];
        [aRule release];

        [ruleTableView reloadData];
        [ruleTableView selectRow:row byExtendingSelection:NO];

        return YES;
    }

    return NO;
}

//
// MExtendedTableView delegate
//

- (BOOL)control:(NSControl *)aControl shouldProcessCharacters:(NSString *)characters;
{
    int count, index;

    count = [[model rules] count];
    index = [characters intValue];
    if (index > 0 && index <= count) {
        [ruleTableView selectRow:index - 1 byExtendingSelection:NO];
        [ruleTableView scrollRowToVisible:index - 1];
        return NO;
    }

    return YES;
}

//
// Browser delegate methods
//

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    if (sender == match1Browser)
        return [[matchLists objectAtIndex:0] count];

    if (sender == match2Browser)
        return [[matchLists objectAtIndex:1] count];

    if (sender == match3Browser)
        return [[matchLists objectAtIndex:2] count];

    if (sender == match4Browser)
        return [[matchLists objectAtIndex:3] count];

    return 0;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    MMPosture *aPosture;

    if (sender == match1Browser) {
        aPosture = [[matchLists objectAtIndex:0] objectAtIndex:row];
        [cell setStringValue:[aPosture symbol]];
    } else if (sender == match2Browser) {
        aPosture = [[matchLists objectAtIndex:1] objectAtIndex:row];
        [cell setStringValue:[aPosture symbol]];
    } else if (sender == match3Browser) {
        aPosture = [[matchLists objectAtIndex:2] objectAtIndex:row];
        [cell setStringValue:[aPosture symbol]];
    } else if (sender == match4Browser) {
        aPosture = [[matchLists objectAtIndex:3] objectAtIndex:row];
        [cell setStringValue:[aPosture symbol]];
    }

    [cell setLeaf:YES];
}

//
// NSOutlineView data source
//

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
{
    if (outlineView == symbolEquationOutlineView) {
        if (item == nil)
            return [[[self model] equations] count];
        else
            return [item count];
    } else if (outlineView == parameterTransitionOutlineView || outlineView == metaParameterTransitionOutlineView) {
        if (item == nil)
            return [[[self model] transitions] count];
        else
            return [item count];
    } else if (outlineView == specialParameterTransitionOutlineView) {
        if (item == nil)
            return [[[self model] specialTransitions] count];
        else
            return [item count];
    }

    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item;
{
    if (outlineView == symbolEquationOutlineView) {
        if (item == nil)
            return [[[self model] equations] objectAtIndex:index];
        else
            return [item objectAtIndex:index];
    } else if (outlineView == parameterTransitionOutlineView || outlineView == metaParameterTransitionOutlineView) {
        if (item == nil)
            return [[[self model] transitions] objectAtIndex:index];
        else
            return [item objectAtIndex:index];
    } else if (outlineView == specialParameterTransitionOutlineView) {
        if (item == nil)
            return [[[self model] specialTransitions] objectAtIndex:index];
        else
            return [item objectAtIndex:index];
    }

    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
{
    if (outlineView == symbolEquationOutlineView) {
        return [item isKindOfClass:[NamedList class]];
    } else if (outlineView == parameterTransitionOutlineView || outlineView == metaParameterTransitionOutlineView) {
        return [item isKindOfClass:[NamedList class]];
    } else if (outlineView == specialParameterTransitionOutlineView) {
        return [item isKindOfClass:[NamedList class]];
    }

    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
{
    id identifier;

    identifier = [tableColumn identifier];
    //NSLog(@"identifier: %@, item: %p, item class: %@", identifier, item, NSStringFromClass([item class]));

    if (outlineView == symbolEquationOutlineView) {
        if ([@"name" isEqual:identifier] == YES) {
            return [item name];
        }
    } else if (outlineView == parameterTransitionOutlineView || outlineView == metaParameterTransitionOutlineView) {
        if ([@"name" isEqual:identifier] == YES) {
            return [item name];
        }
    } else if (outlineView == specialParameterTransitionOutlineView) {
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
    if (outlineView == symbolEquationOutlineView) {
        return [symbolTableView selectedRow] != -1 && (item == nil || [item isKindOfClass:[MMEquation class]]);
    } else if (outlineView == parameterTransitionOutlineView) {
        return [parameterTableView selectedRow] != -1 && [item isKindOfClass:[MMTransition class]];
    } else if (outlineView == specialParameterTransitionOutlineView) {
        return [specialParameterTableView selectedRow] != -1 && (item == nil || [item isKindOfClass:[MMTransition class]]);
    } else if (outlineView == metaParameterTransitionOutlineView) {
        return [metaParameterTableView selectedRow] != -1 && (item == nil || [item isKindOfClass:[MMTransition class]]);
    }

    return YES;
}

// Disallow collapsing the group with the selection, otherwise we lose the selection
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item;
{
    if (outlineView == symbolEquationOutlineView) {
        MMEquation *selectedEquation;

        selectedEquation = [outlineView selectedItemOfClass:[MMEquation class]];
        return item != [selectedEquation group];
    } else if (outlineView == parameterTransitionOutlineView || outlineView == specialParameterTransitionOutlineView
               || outlineView == metaParameterTransitionOutlineView) {
        MMTransition *selectedTransition;

        selectedTransition = [outlineView selectedItemOfClass:[MMTransition class]];
        return item != [selectedTransition group];
    }

    return YES;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)aNotification;
{
    NSOutlineView *outlineView;

    outlineView = [aNotification object];

    if (outlineView == symbolEquationOutlineView) {
        MMEquation *selectedEquation;

        selectedEquation = [outlineView selectedItemOfClass:[MMEquation class]];
        if (selectedEquation != nil) {
            [[[self selectedRule] symbols] replaceObjectAtIndex:[symbolTableView selectedRow] withObject:selectedEquation];
        }
    } else if (outlineView == parameterTransitionOutlineView) {
        MMTransition *selectedTransition;

        selectedTransition = [outlineView selectedItemOfClass:[MMTransition class]];
        if (selectedTransition != nil) {
            [[[self selectedRule] parameterList] replaceObjectAtIndex:[parameterTableView selectedRow] withObject:selectedTransition];
        }
    } else if (outlineView == specialParameterTransitionOutlineView) {
        MMTransition *selectedTransition;

        selectedTransition = [outlineView selectedItemOfClass:[MMTransition class]];
        [[self selectedRule] setSpecialProfile:[specialParameterTableView selectedRow] to:selectedTransition];
        [specialParameterTableView setNeedsDisplay:YES]; // To update bolded rows
    } else if (outlineView == metaParameterTransitionOutlineView) {
        MMTransition *selectedTransition;

        selectedTransition = [outlineView selectedItemOfClass:[MMTransition class]];
        if (selectedTransition != nil) {
            [[[self selectedRule] metaParameterList] replaceObjectAtIndex:[metaParameterTableView selectedRow] withObject:selectedTransition];
        }
    }
}

//
// NSTextView delegate
//

- (void)textDidEndEditing:(NSNotification *)aNotification;
{
    NSTextView *textView;
    NSString *newStringValue;

    textView = [aNotification object];
    // NSTextMovement is a key in the user info
    //NSLog(@"[aNotification userInfo]: %@", [aNotification userInfo]);

    newStringValue = [[textView string] copy];

    //NSLog(@"(1) newStringValue: %@", newStringValue);
    if ([newStringValue length] == 0) {
        [newStringValue release];
        newStringValue = nil;
    }
    //NSLog(@"(2) newStringValue: %@", newStringValue);

    if (textView == ruleCommentTextView) {
        MMRule *selectedRule;

        selectedRule = [self selectedRule];
        [selectedRule setComment:newStringValue];
        [ruleTableView reloadData]; // To update the icon for the row
    }

    [newStringValue release];
}

//
// Actions
//

// Sender should be the form for postures 1-4
// Warning (building for 10.2 deployment) (2004-04-02): aBrowser might be used uninitialized in this function
- (IBAction)setExpression:(id)sender;
{
    NSMutableArray *matchedPhoneList;
    NSArray *mainPhoneList = [[self model] postures];
    MMBooleanNode *parsedExpression;
    int i;
    int tag;
    NSString *expressionString;
    NSBrowser *aBrowser;

    tag = [[sender selectedCell] tag];

    if (tag < 0 || tag > 3) {
        NSLog(@"%s, tag out of range (0-3)", _cmd);
        return;
    }

    expressionString = [[sender cellAtIndex:tag] stringValue];
    //NSLog(@"tag: %d, expressionString: %@", tag, expressionString);
    if ([expressionString isEqualToString:@""]) {
        //NSLog(@"Realigning...");
        [self realignExpressions];
        return;
    }

    parsedExpression = [boolParser parseString:expressionString];
    [errorTextField setStringValue:[boolParser errorMessage]];
    if (parsedExpression == nil) {
        //NSLog(@"parse error: %@", [boolParser errorMessage]);
        NSBeep();
        return;
    }

    [self setExpression:parsedExpression atIndex:tag];

    matchedPhoneList = [matchLists objectAtIndex:tag];
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
          aBrowser = match1Browser;
          break;
      case 1:
          aBrowser = match2Browser;
          break;
      case 2:
          aBrowser = match3Browser;
          break;
      case 3:
          aBrowser = match4Browser;
          break;
      default:
          aBrowser = nil;
    }

    [aBrowser setTitle:[NSString stringWithFormat:@"Total Matches: %d", [matchedPhoneList count]] ofColumn:0];
    [aBrowser loadColumnZero];
    [self updateCombinations];
}

- (IBAction)addRule:(id)sender;
{
    MMBooleanNode *exps[4];
    int index;
    MMRule *newRule;

    for (index = 0; index < 4; index++) {
        NSString *str;

        str = [[expressionForm cellAtIndex:index] stringValue];
        if ([str length] == 0)
            exps[index] = nil;
        else {
            exps[index] = [boolParser parseString:str];
            if (exps[index] == nil) {
                [errorTextField setStringValue:[boolParser errorMessage]];
                return;
            }
        }
    }

    [errorTextField setStringValue:[boolParser errorMessage]];

    newRule = [[MMRule alloc] init];
    [newRule setExpression:exps[0] number:0];
    [newRule setExpression:exps[1] number:1];
    [newRule setExpression:exps[2] number:2];
    [newRule setExpression:exps[3] number:3];
    [[self model] addRule:newRule];
    [newRule release];

    [ruleTableView reloadData];
    [ruleTableView selectRow:[[model rules] count] - 2 byExtendingSelection:NO];
    [ruleTableView scrollRowToVisible:[[model rules] count] - 2];
}

- (IBAction)updateRule:(id)sender;
{
    MMBooleanNode *exps[4];
    int index;
    MMRule *selectedRule;

    for (index = 0; index < 4; index++) {
        NSString *str;

        str = [[expressionForm cellAtIndex:index] stringValue];
        if ([str length] == 0)
            exps[index] = nil;
        else
            exps[index] = [boolParser parseString:str];
    }

    [errorTextField setStringValue:[boolParser errorMessage]];
    selectedRule = [self selectedRule];
    [selectedRule setRuleExpression1:exps[0] exp2:exps[1] exp3:exps[2] exp4:exps[3]];

    [ruleTableView reloadData];
}

- (IBAction)removeRule:(id)sender;
{
    MMRule *selectedRule;

    selectedRule = [self selectedRule];
    if (selectedRule != nil)
        [[[self model] rules] removeObject:selectedRule];

    [self updateViews];
}

@end
