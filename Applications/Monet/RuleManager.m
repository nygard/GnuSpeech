#import "RuleManager.h"

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "AppController.h"
#import "BooleanExpression.h"
#import "BooleanParser.h"
#import "CategoryList.h"
#import "DelegateResponder.h"
#import "GSXMLFunctions.h"
#import "Inspector.h"
#import "MonetList.h"
#import "MMPosture.h"
#import "PhoneList.h"
#import "MMEquation.h"
#import "Rule.h"
#import "RuleList.h"

#import "MModel.h"

@implementation RuleManager

- (id)init;
{
    int i;

    if ([super init] == nil)
        return nil;

    cacheValue = 1;

    matchLists = [[MonetList alloc] initWithCapacity:4];
    for (i = 0; i < 4; i++) {
        PhoneList *aPhoneList;

        aPhoneList = [[PhoneList alloc] init];
        [matchLists addObject:aPhoneList];
        [aPhoneList release];
    }

    boolParser = [[BooleanParser alloc] init];

    /* Set up responder for cut/copy/paste operations */
    delegateResponder = [[DelegateResponder alloc] init];
    [delegateResponder setDelegate:self];

    return self;
}

- (void)dealloc;
{
    [matchLists release];
    [model release];
    [boolParser release];
    [delegateResponder setDelegate:nil];
    [delegateResponder release];
    [expressions[0] release];
    [expressions[1] release];
    [expressions[2] release];
    [expressions[3] release];

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    BooleanExpression *temp, *temp1;

    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    [ruleMatrix setTarget:self];
    [ruleMatrix setAction:@selector(browserHit:)];
    [ruleMatrix setDoubleAction:@selector(browserDoubleHit:)];

    [boolParser setCategoryList:NXGetNamedObject(@"mainCategoryList", NSApp)];
    [boolParser setPhoneList:NXGetNamedObject(@"mainPhoneList", NSApp)];

    // TODO (2004-03-10): Move this into a document class
    temp = [boolParser parseString:@"phone"];
    temp1 = [boolParser parseString:@"phone"];
    [[model rules] seedListWith:temp:temp1];

    [errorTextField setStringValue:@""];

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
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
}

//
// Browser actions
//

- (IBAction)browserHit:(id)sender;
{
    Inspector *inspector;
    int selectedRow;
    Rule *aRule;
    NSString *str;
    BooleanExpression *anExpression;
    int index;

    if (sender != ruleMatrix)
        NSLog(@"Warning: Unexpected sender in %s", _cmd);

    selectedRow = [[sender matrixInColumn:0] selectedRow];
    aRule = [[model rules] objectAtIndex:selectedRow];

    inspector = [controller inspector];
    [inspector inspectRule:[[model rules] objectAtIndex:selectedRow]];

    for (index = 0; index < 4; index++) {
        anExpression = [aRule getExpressionNumber:index];
        str = [anExpression expressionString];
        if (str == nil)
            str = @"";
        [[expressionFields cellAtIndex:index] setStringValue:str];
        [self setExpression:anExpression atIndex:index];
    }

    [self evaluateMatchLists];

    //[[sender window] makeFirstResponder:delegateResponder];
}

- (IBAction)browserDoubleHit:(id)sender;
{
}

//
// Browser delegate methods
//

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
{
    if (sender == matchBrowser1)
        return [[matchLists objectAtIndex:0] count];

    if (sender == matchBrowser2)
        return [[matchLists objectAtIndex:1] count];

    if (sender == matchBrowser3)
        return [[matchLists objectAtIndex:2] count];

    if (sender == matchBrowser4)
        return [[matchLists objectAtIndex:3] count];

    if (sender == ruleMatrix)
        return [[model rules] count];

    return 0;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    MMPosture *aPhone;
    Rule *aRule;

    if (sender == matchBrowser1) {
        aPhone = [[matchLists objectAtIndex:0] objectAtIndex:row];
        [cell setStringValue:[aPhone symbol]];
    } else if (sender == matchBrowser2) {
        aPhone = [[matchLists objectAtIndex:1] objectAtIndex:row];
        [cell setStringValue:[aPhone symbol]];
    } else if (sender == matchBrowser3) {
        aPhone = [[matchLists objectAtIndex:2] objectAtIndex:row];
        [cell setStringValue:[aPhone symbol]];
    } else if (sender == matchBrowser4) {
        aPhone = [[matchLists objectAtIndex:3] objectAtIndex:row];
        [cell setStringValue:[aPhone symbol]];
    } else if (sender == ruleMatrix) {
        NSString *str;

        aRule = [[model rules] objectAtIndex:row];
        str = [NSString stringWithFormat:@"%d. %@", row + 1, [aRule ruleString]];
        [cell setStringValue:str];
    }

    [cell setLeaf:YES];
}

- (void)setExpression:(BooleanExpression *)anExpression atIndex:(int)index;
{
    if (anExpression == expressions[index])
        return;

    [expressions[index] release];
    expressions[index] = [anExpression retain];
}


// Sender should be the form for phones 1-4
- (IBAction)setExpression:(id)sender;
{
    PhoneList *matchedPhoneList;
    PhoneList *mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);
    BooleanExpression *parsedExpression;
    int i;
    int tag;
    NSString *expressionString;
    NSBrowser *aBrowser;

    tag = [[sender selectedCell] tag];
    NSLog(@" > %s, tag: %d", _cmd, tag);
    NSLog(@"sender class: %@", NSStringFromClass([sender class]));

    if (tag < 0 || tag > 3) {
        NSLog(@"%s, tag out of range (0-3)", _cmd);
        return;
    }

    expressionString = [[sender cellAtIndex:tag] stringValue];
    if ([expressionString isEqualToString:@""]) {
        NSLog(@"Realigning...");
        [self realignExpressions];
        //[sender selectTextAtIndex:tag];
        NSLog(@"<  %s", _cmd);
        return;
    }

    [boolParser setCategoryList:NXGetNamedObject(@"mainCategoryList", NSApp)];
    [boolParser setPhoneList:mainPhoneList];

    parsedExpression = [boolParser parseString:expressionString];
    [errorTextField setStringValue:[boolParser errorMessage]];
    if (parsedExpression == nil) {
        NSLog(@"parse error: %@", [boolParser errorMessage]);
        //[sender selectTextAtIndex:tag];
        NSBeep();
        NSLog(@"<  %s", _cmd);
        return;
    }

    [self setExpression:parsedExpression atIndex:tag];

    //[sender selectTextAtIndex:(tag + 1) % 4];

    matchedPhoneList = [matchLists objectAtIndex:tag];
    [matchedPhoneList removeAllObjects];

    for (i = 0; i < [mainPhoneList count]; i++) {
        MMPosture *currentPhone;

        currentPhone = [mainPhoneList objectAtIndex:i];
        if ([parsedExpression evaluate:[currentPhone categoryList]]) {
            [matchedPhoneList addObject:currentPhone];
        }
    }

    //[parsedExpression release];  // We didn't retain it.

    switch (tag) {
      case 0:
          aBrowser = matchBrowser1;
          break;
      case 1:
          aBrowser = matchBrowser2;
          break;
      case 2:
          aBrowser = matchBrowser3;
          break;
      case 3:
          aBrowser = matchBrowser4;
          break;
    }

    [aBrowser setTitle:[NSString stringWithFormat:@"Total Matches: %d", [matchedPhoneList count]] ofColumn:0];
    [aBrowser loadColumnZero];
    [self updateCombinations];

    NSLog(@"<  %s", _cmd);
}

/*===========================================================================

	Method: realignExpressions
	Purpose: The purpose of this method is to align the sub-expressions
		if one happens to have been removed.

===========================================================================*/
- (void)realignExpressions;
{
    int index;
    NSCell *thisCell, *nextCell;

    NSLog(@" > %s", _cmd);

    for (index = 0; index < 3; index++) {

        thisCell = [expressionFields cellAtIndex:index];
        nextCell = [expressionFields cellAtIndex:index + 1];

        if ([[thisCell stringValue] isEqualToString:@""]) {
            [thisCell setStringValue:[nextCell stringValue]];
            [nextCell setStringValue:@""];
            [self setExpression:expressions[index + 1] atIndex:index];
            [self setExpression:nil atIndex:index + 1];
        }
    }

    thisCell = [expressionFields cellAtIndex:3];
    if ([[thisCell stringValue] isEqualToString:@""]) {
        [self setExpression:nil atIndex:3];
    }

    [self evaluateMatchLists];

    NSLog(@"<  %s", _cmd);
}

- (void)evaluateMatchLists;
{
    int i, j;
    PhoneList *aMatchedPhoneList;
    PhoneList *mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);
    NSString *str;

    //NSLog(@"[mainPhoneList count]: %d", [mainPhoneList count]);

    for (j = 0; j < 4; j++) {
        aMatchedPhoneList = [matchLists objectAtIndex:j];
        [aMatchedPhoneList removeAllObjects];

        for (i = 0; i < [mainPhoneList count]; i++) {
            MMPosture *aPhone;

            aPhone = [mainPhoneList objectAtIndex:i];
            //NSLog(@"i: %d, phone categoryList count: %d", i, [[aPhone categoryList] count]);
            if ([expressions[j] evaluate:[aPhone categoryList]]) {
                [aMatchedPhoneList addObject:aPhone];
            }
        }
        //NSLog(@"expressions[%d]: %p, matches[%d] count: %d", j, expressions[j], j, [aMatchedPhoneList count]);
    }

    str = [NSString stringWithFormat:@"Total Matches: %d", [[matchLists objectAtIndex:0] count]];
    [matchBrowser1 setTitle:str ofColumn:0];
    [matchBrowser1 loadColumnZero];

    str = [NSString stringWithFormat:@"Total Matches: %d", [[matchLists objectAtIndex:1] count]];
    [matchBrowser2 setTitle:str ofColumn:0];
    [matchBrowser2 loadColumnZero];

    str = [NSString stringWithFormat:@"Total Matches: %d", [[matchLists objectAtIndex:2] count]];
    [matchBrowser3 setTitle:str ofColumn:0];
    [matchBrowser3 loadColumnZero];

    str = [NSString stringWithFormat:@"Total Matches: %d", [[matchLists objectAtIndex:3] count]];
    [matchBrowser4 setTitle:str ofColumn:0];
    [matchBrowser4 loadColumnZero];

    [self updateCombinations];
}

- (void)updateCombinations;
{
    int temp = 0, temp1 = 0;
    int i;

    temp = [[matchLists objectAtIndex:0] count];

    for (i = 1; i < 4; i++)
        if ((temp1 = [[matchLists objectAtIndex:i] count]))
            temp *= temp1;

    [possibleCombinations setIntValue:temp];
}

- (void)updateRuleDisplay;
{
    [ruleMatrix setTitle:[NSString stringWithFormat:@"Total Rules: %d", [[model rules] count]] ofColumn:0];
    [ruleMatrix loadColumnZero];
}

- (IBAction)add:(id)sender;
{
    PhoneList *mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);
    BooleanExpression *exps[4];
    int index;

    [boolParser setCategoryList:NXGetNamedObject(@"mainCategoryList", NSApp)];
    [boolParser setPhoneList:mainPhoneList];

    for (index = 0; index < 4; index++) {
        NSString *str;

        str = [[expressionFields cellAtIndex:index] stringValue];
        if ([str length] == 0)
            exps[index] = nil;
        else
            exps[index] = [boolParser parseString:str];
    }

    // TODO (2004-03-03): Might like flag to indicate we shouldn't clear the error message when we start parsing, so we get all the errors.
    [errorTextField setStringValue:[boolParser errorMessage]];

    [[model rules] addRuleExp1:exps[0] exp2:exps[1] exp3:exps[2] exp4:exps[3]];

    [ruleMatrix setTitle:[NSString stringWithFormat:@"Total Rules: %d", [[model rules] count]] ofColumn:0];
    [ruleMatrix loadColumnZero];
    [ruleMatrix selectRow:[[model rules] count] - 2 inColumn:0];
}

// TODO (2004-03-10): Actually, it's just "change"
- (IBAction)rename:(id)sender;
{
    PhoneList *mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);
    int selectedRow = [[ruleMatrix matrixInColumn:0] selectedRow];
    BooleanExpression *exps[4];
    int index;

    [boolParser setCategoryList:NXGetNamedObject(@"mainCategoryList", NSApp)];
    [boolParser setPhoneList:mainPhoneList];

    for (index = 0; index < 4; index++) {
        NSString *str;

        str = [[expressionFields cellAtIndex:index] stringValue];
        if ([str length] == 0)
            exps[index] = nil;
        else
            exps[index] = [boolParser parseString:str];
    }

    [errorTextField setStringValue:[boolParser errorMessage]];
    [[model rules] changeRuleAt:selectedRow exp1:exps[0] exp2:exps[1] exp3:exps[2] exp4:exps[3]];

    [ruleMatrix loadColumnZero];
    [ruleMatrix selectRow:selectedRow inColumn:0];
}

- (IBAction)remove:(id)sender;
{
    int selectedRow = [[ruleMatrix matrixInColumn:0] selectedRow];

    [[model rules] removeObjectAtIndex:selectedRow];
    [ruleMatrix loadColumnZero];
    if (selectedRow >= [[model rules] count])
        selectedRow = [[model rules] count] - 1;
    [ruleMatrix selectRow:selectedRow inColumn:0];
    [self browserHit:ruleMatrix];
}

- (IBAction)parseRule:(id)sender;
{
    int i, j, dummy, phones = 0;
    MonetList *tempList, *phoneList;
    PhoneList *mainPhoneList;
    MMPosture *tempPhone;
    Rule *aRule;
    double ruleSymbols[5] = {0.0, 0.0, 0.0, 0.0, 0.0};

    tempList = [[MonetList alloc] initWithCapacity:4];
    phoneList = [[MonetList alloc] initWithCapacity:4];
    mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);

    if ( ([[[phone1 cellAtIndex:0] stringValue] isEqualToString:@""]) || ([[[phone2 cellAtIndex:0] stringValue] isEqualToString:@""]) ) {
        [ruleOutput setStringValue:@"You need at least two phones to parse."];
        // TODO (2004-03-10): Clear out other text fields
        return;
    }

    tempPhone = [mainPhoneList binarySearchPhone:[[phone1 cellAtIndex:0] stringValue] index:&dummy];
    if (tempPhone == nil) {
        [ruleOutput setStringValue:[NSString stringWithFormat:@"Unknown phone: \"%@\"", [[phone1 cellAtIndex:0] stringValue]]];
        return;
    }
    [tempList addObject:[tempPhone categoryList]];
    [phoneList addObject:tempPhone];
    phones++;

    tempPhone = [mainPhoneList binarySearchPhone:[[phone2 cellAtIndex:0] stringValue] index:&dummy];
    if (tempPhone == nil) {
        [ruleOutput setStringValue:[NSString stringWithFormat:@"Unknown phone: \"%@\"", [[phone2 cellAtIndex:0] stringValue]]];
        return;
    }
    [tempList addObject:[tempPhone categoryList]];
    [phoneList addObject:tempPhone];
    phones++;

    if ([[[phone3 cellAtIndex:0] stringValue] length]) {
        tempPhone = [mainPhoneList binarySearchPhone:[[phone3 cellAtIndex:0] stringValue] index:&dummy];
        if (tempPhone == nil) {
            [ruleOutput setStringValue:[NSString stringWithFormat:@"Unknown phone: \"%@\"", [[phone3 cellAtIndex:0] stringValue]]];
            return;
        }
        [tempList addObject:[tempPhone categoryList]];
        [phoneList addObject:tempPhone];

        phones++;
    }

    if ([[[phone4 cellAtIndex:0] stringValue] length]) {
        tempPhone = [mainPhoneList binarySearchPhone:[[phone4 cellAtIndex:0] stringValue] index:&dummy];
        if (tempPhone == nil) {
            [ruleOutput setStringValue:[NSString stringWithFormat:@"Unknown phone: \"%@\"", [[phone4 cellAtIndex:0] stringValue]]];
            return;
        }
        [tempList addObject:[tempPhone categoryList]];
        [phoneList addObject:tempPhone];

        phones++;
    }

    //NSLog(@"TempList count = %d", [tempList count]);

    for (i = 0; i < [[model rules] count]; i++) {
        aRule = [[model rules] objectAtIndex:i];
        if ([aRule numberExpressions] <= [tempList count])
            if ([aRule matchRule:tempList]) {
                NSString *str;

                str = [NSString stringWithFormat:@"%d. %@", i + 1, [aRule ruleString]];
                [ruleOutput setStringValue:str];
                [consumedTokens setIntValue:[aRule numberExpressions]];
                // TODO (2004-03-02): Is being out of order significant?
                ruleSymbols[0] = [[aRule getExpressionSymbol:0] evaluate:ruleSymbols phones:phoneList andCacheWith:cacheValue++];
                ruleSymbols[2] = [[aRule getExpressionSymbol:2] evaluate:ruleSymbols phones:phoneList andCacheWith:cacheValue++];
                ruleSymbols[3] = [[aRule getExpressionSymbol:3] evaluate:ruleSymbols phones:phoneList andCacheWith:cacheValue++];
                ruleSymbols[4] = [[aRule getExpressionSymbol:4] evaluate:ruleSymbols phones:phoneList andCacheWith:cacheValue++];
                ruleSymbols[1] = [[aRule getExpressionSymbol:1] evaluate:ruleSymbols phones:phoneList andCacheWith:cacheValue++];
                for (j = 0; j < 5; j++) {
                    [[durationOutput cellAtIndex:j] setDoubleValue:ruleSymbols[j]];
                }
                [tempList release];
                return;
            }
    }

    NSBeep();
    [ruleOutput setStringValue:@"Cannot find rule"];
    [consumedTokens setIntValue:0];
    [tempList release];
}

- (RuleList *)ruleList;
{
    return [model rules];
}


- (void)addParameter;
{
    [[model rules] makeObjectsPerform:@selector(addDefaultParameter)];
}

- (void)addMetaParameter;
{
    [[model rules] makeObjectsPerform:@selector(addDefaultMetaParameter)];
}

- (void)removeParameter:(int)index;
{
    int i;

    for (i = 0; i < [[model rules] count]; i++)
        [[[model rules] objectAtIndex:i] removeParameter:index];
}

- (void)removeMetaParameter:(int)index;
{
    int i;

    for (i = 0; i < [[model rules] count]; i++)
        [[[model rules] objectAtIndex:i] removeMetaParameter:index];
}

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
{
    return [[model rules] isCategoryUsed:aCategory];
}

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
{
    return [[model rules] isEquationUsed:anEquation];
}

- (BOOL)isTransitionUsed:(MMTransition *)aTransition;
{
    return [[model rules] isTransitionUsed: aTransition];
}

- (void)findEquation:(MMEquation *)anEquation andPutIn:(MonetList *)aList;
{
    [[model rules] findEquation:anEquation andPutIn:aList];
}

- (void)findTemplate:(MMTransition *)aTemplate andPutIn:(MonetList *)aList;
{
    [[model rules] findTemplate:aTemplate andPutIn:aList];
}

- (IBAction)cut:(id)sender;
{
    NSLog(@"RuleManager: cut");
}

static NSString *ruleString = @"Rule";

- (IBAction)copy:(id)sender;
{
    NSPasteboard *myPasteboard;
    NSMutableData *mdata;
    NSArchiver *typed = nil;
    NSString *dataType;
    int retValue, column = [ruleMatrix selectedColumn];
    id tempEntry;

    myPasteboard = [NSPasteboard pasteboardWithName:@"MonetPasteboard"];

    NSLog(@"RuleManager: copy  |%@|\n", [myPasteboard name]);

    if (column != 0) {
        NSBeep();
        NSLog(@"Nothing selected");
        return;
    }

    mdata = [NSMutableData dataWithCapacity:16];
    typed = [[NSArchiver alloc] initForWritingWithMutableData:mdata];

    tempEntry = [[model rules] objectAtIndex:[[ruleMatrix matrixInColumn:0] selectedRow]];
    [tempEntry encodeWithCoder:typed];

    dataType = ruleString;
    retValue = [myPasteboard declareTypes:[NSArray arrayWithObject:dataType] owner:nil];

    [myPasteboard setData:mdata forType:ruleString];

    [typed release];
}

- (IBAction)paste:(id)sender;
{
    NSPasteboard *myPasteboard;
    NSData *mdata;
    NSArchiver *typed = nil;
    NSArray *dataTypes;
    int row = [[ruleMatrix matrixInColumn: 0] selectedRow];
    id temp;

    myPasteboard = [NSPasteboard pasteboardWithName:@"MonetPasteboard"];
    NSLog(@"RuleManager: paste  changeCount = %d  |%@|\n", [myPasteboard changeCount], [myPasteboard name]);

    dataTypes = [myPasteboard types];
    if ([[dataTypes objectAtIndex:0] isEqual:ruleString]) {
        NSBeep();
        return;
    }

    mdata = [myPasteboard dataForType:ruleString];
    typed = [[NSUnarchiver alloc] initForReadingWithData:mdata];

    temp = [[Rule alloc] init];
    [temp initWithCoder:typed];
    [typed release];

    if (row == -1)
        [[model rules] insertObject:temp atIndex:[[model rules] count]-1];
    else
        [[model rules] insertObject:temp atIndex:row+1];

    [temp release];

    [ruleMatrix loadColumnZero];
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    int i;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    matchLists = [[MonetList alloc] initWithCapacity:4];
    for (i = 0; i < 4; i++) {
        PhoneList *aPhoneList;

        aPhoneList = [[PhoneList alloc] init];
        [matchLists addObject:aPhoneList];
        [aPhoneList release];
    }

    boolParser = [[BooleanParser alloc] init];

    [self applicationDidFinishLaunching:nil];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
#ifdef PORTING
    [aCoder encodeObject:ruleList];
#endif
}

//
// Archiving - Degas support
//

- (void)readDegasFileFormat:(FILE *)fp;
{
    [[model rules] readDegasFileFormat:fp];
}

//
// Window delegate methods
//

- (void)windowDidBecomeMain:(NSNotification *)notification;
{
    Inspector *inspector;

    inspector = [controller inspector];
    if (inspector) {
        int index = 0;

        index = [[ruleMatrix matrixInColumn:0] selectedRow];
        if (index == -1)
            [inspector cleanInspectorWindow];
        else
            [inspector inspectRule:[[model rules] objectAtIndex:index]];
    }
}

- (BOOL)windowShouldClose:(id)sender;
{
    [[controller inspector] cleanInspectorWindow];

    return YES;
}

- (void)windowDidResignMain:(NSNotification *)notification;
{
    [[controller inspector] cleanInspectorWindow];
}

- (IBAction)shiftPhonesLeft:(id)sender;
{
    NSString *p2, *p3, *p4;

    p2 = [[phone2 cellAtIndex:0] stringValue];
    p3 = [[phone3 cellAtIndex:0] stringValue];
    p4 = [[phone4 cellAtIndex:0] stringValue];

    [[phone1 cellAtIndex:0] setStringValue:p2];
    [[phone2 cellAtIndex:0] setStringValue:p3];
    [[phone3 cellAtIndex:0] setStringValue:p4];
    [[phone4 cellAtIndex:0] setStringValue:@""];
}

@end
