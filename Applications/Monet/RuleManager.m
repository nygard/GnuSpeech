#import "RuleManager.h"

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "BooleanExpression.h"
#import "BooleanParser.h"
#import "DelegateResponder.h"
#import "Inspector.h"
#import "MonetList.h"
#import "MyController.h"
#import "Phone.h"
#import "PhoneList.h"
#import "ProtoEquation.h"
#import "Rule.h"
#import "RuleList.h"

#ifdef PORTING
#import "SymbolList.h"
#import "ParameterList.h"
#endif


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

    ruleList = [[RuleList alloc] initWithCapacity: 20];

    boolParser = [[BooleanParser alloc] init];

    /* Set up responder for cut/copy/paste operations */
    delegateResponder = [[DelegateResponder alloc] init];
    [delegateResponder setDelegate:self];

    return self;
}

- (void)dealloc;
{
    [matchLists release];
    [ruleList release];
    [boolParser release];
    [delegateResponder setDelegate:nil];
    [delegateResponder release];

    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
    id temp, temp1;

    NSLog(@"<%@>[%p]  > %s", NSStringFromClass([self class]), self, _cmd);

    [ruleMatrix setTarget:self];
    [ruleMatrix setAction:@selector(browserHit:)];
    [ruleMatrix setDoubleAction:@selector(browserDoubleHit:)];

    [boolParser setCategoryList:NXGetNamedObject(@"mainCategoryList", NSApp)];
    [boolParser setPhoneList:NXGetNamedObject(@"mainPhoneList", NSApp)];

    temp = [boolParser parseString:@"phone"];
    temp1 = [boolParser parseString:@"phone"];
    [ruleList seedListWith:temp:temp1];

    NSLog(@"<%@>[%p] <  %s", NSStringFromClass([self class]), self, _cmd);
}

- (void)browserHit:sender;
{
    id temp;
    int index;
    Rule *aRule;
    NSString *str;

    index = [[sender matrixInColumn:0] selectedRow];
    aRule = [ruleList objectAtIndex:index];

    temp = [controller inspector];
    [temp inspectRule:[ruleList objectAtIndex:index]];

    str = [[aRule getExpressionNumber:0] expressionString];
    [[expressionFields cellAtIndex:0] setStringValue:str];

    str = [[aRule getExpressionNumber:1] expressionString];
    [[expressionFields cellAtIndex:1] setStringValue:str];

    str = [[aRule getExpressionNumber:2] expressionString];
    [[expressionFields cellAtIndex:2] setStringValue:str];

    str = [[aRule getExpressionNumber:3] expressionString];
    [[expressionFields cellAtIndex:3] setStringValue:str];

    [self evaluateMatchLists];

    [[sender window] makeFirstResponder:delegateResponder];
}

- (void)browserDoubleHit:sender;
{
}

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
        return [ruleList count];

    return 0;
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column;
{
    Phone *aPhone;
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
        NSMutableString *str, *str2;

        aRule = [ruleList objectAtIndex:row];
        str = [[NSMutableString alloc] init];

        [str appendFormat:@"%d. ", row + 1];

        [[aRule getExpressionNumber:0] expressionString:str];
        [str appendString:@" >> "];
        [[aRule getExpressionNumber:1] expressionString:str];

        str2 = [[aRule getExpressionNumber:2] expressionString];
        if (str2 != nil) {
            [str appendString:@" >> "];
            [str appendString:str2];
        }

        str2 = [[aRule getExpressionNumber:3] expressionString];
        if (str2 != nil) {
            [str appendString:@" >> "];
            [str appendString:str2];
        }

        [cell setStringValue:str];
    }

    [cell setLeaf:YES];
}

- (NSString *)expressionStringForRule:(int)index;
{
    NSMutableString *resultString;
    Rule *tempRule;
    NSString *str;

    resultString = [NSMutableString string];
    tempRule = [ruleList objectAtIndex:index];

    [resultString appendFormat:@"%d. ", index + 1];

    [[tempRule getExpressionNumber:0] expressionString:resultString];
    [resultString appendString:@" >> "];
    [[tempRule getExpressionNumber:1] expressionString:resultString];

    str = [[tempRule getExpressionNumber:2] expressionString];
    if (str != nil) {
        [resultString appendString:@" >> "];
        [resultString appendString:str];
    }

    str = [[tempRule getExpressionNumber:3] expressionString];
    if (str != nil) {
        [resultString appendString:@" >> "];
        [resultString appendString:str];
    }

    return resultString;
}

- (void)setExpression1:sender;
{
    id tempList;
    PhoneList *mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);
    BooleanExpression *tempExpression;
    int i;

    if ([[[sender cellAtIndex:0] stringValue] isEqualToString:@""]) {
        [self realignExpressions];
        [sender selectTextAtIndex:0];
        return;
    }

    [boolParser setCategoryList:NXGetNamedObject(@"mainCategoryList", NSApp)];
    [boolParser setPhoneList:mainPhoneList];

    tempExpression = [boolParser parseString:[[sender cellAtIndex:0] stringValue]];
    [errorTextField setStringValue:[boolParser errorMessage]];
    if (tempExpression == nil) {
        [sender selectTextAtIndex:0];
        NSBeep();
        return;
    }

    [sender selectTextAtIndex:1];

    tempList = [matchLists objectAtIndex:0];
    [tempList removeAllObjects];

    for (i = 0; i < [mainPhoneList count]; i++) {
        if ([tempExpression evaluate:[[mainPhoneList objectAtIndex:i] categoryList]]) {
            [tempList addObject:[mainPhoneList objectAtIndex:i]];
        }
    }

    [tempExpression release];

    [matchBrowser1 setTitle:[NSString stringWithFormat:@"Total Matches: %d", [tempList count]] ofColumn:0];
    [matchBrowser1 loadColumnZero];
    [self updateCombinations];
}

- (void)setExpression2:sender;
{
    id tempList;
    PhoneList *mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);
    BooleanExpression *tempExpression;
    int i;

    if ([[[sender cellAtIndex:1] stringValue] isEqualToString:@""]) {
        [self realignExpressions];
        [sender selectTextAtIndex:0];
        return;
    }

    [boolParser setCategoryList:NXGetNamedObject(@"mainCategoryList", NSApp)];
    [boolParser setPhoneList:mainPhoneList];

    tempExpression = [boolParser parseString:[[sender cellAtIndex:1] stringValue]];
    [errorTextField setStringValue:[boolParser errorMessage]];
    if (tempExpression == nil) {
        [sender selectTextAtIndex:1];
        NSBeep();
        return;
    }

    [sender selectTextAtIndex:2];

    tempList = [matchLists objectAtIndex:1];
    [tempList removeAllObjects];

    for (i = 0; i < [mainPhoneList count]; i++) {
        if ([tempExpression evaluate:[[mainPhoneList objectAtIndex:i] categoryList]]) {
            [tempList addObject:[mainPhoneList objectAtIndex:i]];
        }
    }

    [tempExpression release];

    [matchBrowser2 setTitle:[NSString stringWithFormat:@"Total Matches: %d", [tempList count]] ofColumn:0];
    [matchBrowser2 loadColumnZero];
    [self updateCombinations];
}

- (void)setExpression3:sender;
{
    id tempList;
    PhoneList *mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);
    BooleanExpression *tempExpression;
    int i;

    if ([[[sender cellAtIndex:2] stringValue] isEqualToString:@""]) {
        [self realignExpressions];
        [sender selectTextAtIndex:0];
        return;
    }

    [boolParser setCategoryList:NXGetNamedObject(@"mainCategoryList", NSApp)];
    [boolParser setPhoneList:mainPhoneList];

    tempExpression = [boolParser parseString:[[sender cellAtIndex:2] stringValue]];
    [errorTextField setStringValue:[boolParser errorMessage]];
    if (tempExpression == nil) {
        [sender selectTextAtIndex:2];
        NSBeep();
        return;
    }

    [sender selectTextAtIndex:3];

    tempList = [matchLists objectAtIndex:2];
    [tempList removeAllObjects];

    for (i = 0; i < [mainPhoneList count]; i++) {
        if ([tempExpression evaluate:[[mainPhoneList objectAtIndex:i] categoryList]]) {
            [tempList addObject:[mainPhoneList objectAtIndex:i]];
        }
    }

    [tempExpression release];

    [matchBrowser3 setTitle:[NSString stringWithFormat:@"Total Matches: %d", [tempList count]] ofColumn:0];
    [matchBrowser3 loadColumnZero];
    [self updateCombinations];
}

- (void)setExpression4:sender;
{
    id tempList;
    PhoneList *mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);
    BooleanExpression *tempExpression;
    int i;

    if ([[[sender cellAtIndex:3] stringValue] isEqualToString:@""]) {
        [self realignExpressions];
        [sender selectTextAtIndex:0];
        return;
    }

    [boolParser setCategoryList:NXGetNamedObject(@"mainCategoryList", NSApp)];
    [boolParser setPhoneList:mainPhoneList];

    tempExpression = [boolParser parseString:[[sender cellAtIndex:3] stringValue]];
    [errorTextField setStringValue:[boolParser errorMessage]];
    if (tempExpression == nil) {
        [sender selectTextAtIndex:3];
        NSBeep();
        return;
    }

    [sender selectTextAtIndex:0];

    tempList = [matchLists objectAtIndex:3];
    [tempList removeAllObjects];

    for (i = 0; i < [mainPhoneList count]; i++) {
        if ([tempExpression evaluate:[[mainPhoneList objectAtIndex:i] categoryList]]) {
            [tempList addObject:[mainPhoneList objectAtIndex:i]];
        }
    }

    [tempExpression release];

    [matchBrowser4 setTitle:[NSString stringWithFormat:@"Total Matches: %d", [tempList count]] ofColumn:0];
    [matchBrowser4 loadColumnZero];
    [self updateCombinations];
}

/*===========================================================================

	Method: realignExpressions
	Purpose: The purpose of this method is to align the sub-expressions
		if one happens to have been removed.

===========================================================================*/
- (void)realignExpressions;
{
    if ([[[expressionFields cellAtIndex:0] stringValue] isEqualToString:@""]) {
        [[expressionFields cellAtIndex:0] setStringValue:[[expressionFields cellAtIndex:1] stringValue]];
        [[expressionFields cellAtIndex:1] setStringValue:@""];
    }

    if ([[[expressionFields cellAtIndex:1] stringValue] isEqualToString:@""]) {
        [[expressionFields cellAtIndex:1] setStringValue:[[expressionFields cellAtIndex:2] stringValue]];
        [[expressionFields cellAtIndex:2] setStringValue:@""];
    }

    if ([[[expressionFields cellAtIndex:2] stringValue] isEqualToString:@""]) {
        [[expressionFields cellAtIndex:2] setStringValue:[[expressionFields cellAtIndex:3] stringValue]];
        [[expressionFields cellAtIndex:3] setStringValue:@""];
    }

    if ([[[expressionFields cellAtIndex:3] stringValue] isEqualToString:@""]) {
        [expressions removeObjectAtIndex:3];
    }

    [self evaluateMatchLists];
}

- (void)evaluateMatchLists;
{
    int i, j;
    id tempList;
    PhoneList *mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);
    NSString *str;

    for (j = 0; j < 4; j++) {
        tempList = [matchLists objectAtIndex:j];
        [tempList removeAllObjects];

        for (i = 0; i < [mainPhoneList count]; i++) {
            if ([[expressions objectAtIndex:j] evaluate:[[mainPhoneList objectAtIndex:i] categoryList]]) {
                [tempList addObject:[mainPhoneList objectAtIndex:i]];
            }
        }
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
    [ruleMatrix loadColumnZero];
}

- (void)add:sender;
{
    PhoneList *mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);
    BooleanExpression *exp1, *exp2, *exp3, *exp4;

    exp1 = exp2 = exp3 = exp4 = nil;

    [boolParser setCategoryList:NXGetNamedObject(@"mainCategoryList", NSApp)];
    [boolParser setPhoneList:mainPhoneList];

    if ([[[expressionFields cellAtIndex:0] stringValue] length])
        exp1 = [boolParser parseString:[[expressionFields cellAtIndex:0] stringValue]];
    if ([[[expressionFields cellAtIndex:1] stringValue] length])
        exp2 = [boolParser parseString:[[expressionFields cellAtIndex:1] stringValue]];
    if ([[[expressionFields cellAtIndex:2] stringValue] length])
        exp3 = [boolParser parseString:[[expressionFields cellAtIndex:2] stringValue]];
    if ([[[expressionFields cellAtIndex:3] stringValue] length])
        exp4 = [boolParser parseString:[[expressionFields cellAtIndex:3] stringValue]];

    // TODO (2004-03-03): Might like flag to indicate we shouldn't clear the error message when we start parsing, so we get all the errors.
    [errorTextField setStringValue:[boolParser errorMessage]];

    [ruleList addRuleExp1:exp1 exp2:exp2 exp3:exp3 exp4:exp4];

    [ruleMatrix setTitle:[NSString stringWithFormat:@"Total Rules: %d", [ruleList count]] ofColumn:0];
    [ruleMatrix loadColumnZero];
}

- (void)rename:sender;
{
    PhoneList *mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);
    BooleanExpression *exp1, *exp2, *exp3, *exp4;
    int index = [[ruleMatrix matrixInColumn:0] selectedRow];

    exp1 = exp2 = exp3 = exp4 = nil;

    [boolParser setCategoryList:NXGetNamedObject(@"mainCategoryList", NSApp)];
    [boolParser setPhoneList:mainPhoneList];

    if ([[[expressionFields cellAtIndex:0] stringValue] length])
        exp1 = [boolParser parseString:[[expressionFields cellAtIndex:0] stringValue]];
    if ([[[expressionFields cellAtIndex:1] stringValue] length])
        exp2 = [boolParser parseString:[[expressionFields cellAtIndex:1] stringValue]];
    if ([[[expressionFields cellAtIndex:2] stringValue] length])
        exp3 = [boolParser parseString:[[expressionFields cellAtIndex:2] stringValue]];
    if ([[[expressionFields cellAtIndex:3] stringValue] length])
        exp4 = [boolParser parseString:[[expressionFields cellAtIndex:3] stringValue]];

    [errorTextField setStringValue:[boolParser errorMessage]];
    [ruleList changeRuleAt:index exp1:exp1 exp2:exp2 exp3:exp3 exp4:exp4];

    [ruleMatrix loadColumnZero];
}

- (void)remove:sender;
{
    int index = [[ruleMatrix matrixInColumn:0] selectedRow];

    [ruleList removeObjectAtIndex:index];
    [ruleMatrix loadColumnZero];
}

- (void)parseRule:sender;
{
    int i, j, dummy, phones = 0;
    MonetList *tempList, *phoneList;
    PhoneList *mainPhoneList;
    Phone *tempPhone;
    Rule *tempRule;
    //char string[1024];
    double ruleSymbols[5] = {0.0, 0.0, 0.0, 0.0, 0.0};

    tempList = [[MonetList alloc] initWithCapacity:4];
    phoneList = [[MonetList alloc] initWithCapacity:4];
    mainPhoneList = NXGetNamedObject(@"mainPhoneList", NSApp);

    if ( ([[[phone1 cellAtIndex:0] stringValue] isEqualToString:@""]) || ([[[phone2 cellAtIndex:0] stringValue] isEqualToString:@""]) ) {
        [ruleOutput setStringValue:@"You need at least to phones to parse."];
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
        [tempPhone categoryList];
        [tempList addObject:tempPhone];
        [phoneList addObject:tempPhone];

        phones++;
    }

    if ([[[phone4 cellAtIndex:0] stringValue] length]) {
        tempPhone = [mainPhoneList binarySearchPhone:[[phone4 cellAtIndex:0] stringValue] index:&dummy];
        if (tempPhone == nil) {
            [ruleOutput setStringValue:[NSString stringWithFormat:@"Unknown phone: \"%@\"", [[phone4 cellAtIndex:0] stringValue]]];
            return;
        }
        [tempPhone categoryList];
        [tempList addObject:tempPhone];
        [phoneList addObject:tempPhone];

        phones++;
    }

    //NSLog(@"TempList count = %d", [tempList count]);

    for (i = 0; i < [ruleList count]; i++) {
        tempRule = [ruleList objectAtIndex:i];
        if ([tempRule numberExpressions] <= [tempList count])
            if ([[ruleList objectAtIndex:i] matchRule:tempList]) {
                NSString *str;

                str = [self expressionStringForRule:i];
                [ruleOutput setStringValue:str];
                [consumedTokens setIntValue:[tempRule numberExpressions]];
                // TODO (2004-03-02): Is being out of order significant?
                ruleSymbols[0] = [[tempRule getExpressionSymbol:0] evaluate:ruleSymbols phones:phoneList andCacheWith:cacheValue++];
                ruleSymbols[2] = [[tempRule getExpressionSymbol:2] evaluate:ruleSymbols phones:phoneList andCacheWith:cacheValue++];
                ruleSymbols[3] = [[tempRule getExpressionSymbol:3] evaluate:ruleSymbols phones:phoneList andCacheWith:cacheValue++];
                ruleSymbols[4] = [[tempRule getExpressionSymbol:4] evaluate:ruleSymbols phones:phoneList andCacheWith:cacheValue++];
                ruleSymbols[1] = [[tempRule getExpressionSymbol:1] evaluate:ruleSymbols phones:phoneList andCacheWith:cacheValue++];
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
    return ruleList;
}


- (void)addParameter;
{
    [ruleList makeObjectsPerform:@selector(addDefaultParameter)];
}

- (void)addMetaParameter;
{
    [ruleList makeObjectsPerform:@selector(addDefaultMetaParameter)];
}

- (void)removeParameter:(int)index;
{
    int i;

    for (i = 0; i < [ruleList count]; i++)
        [[ruleList objectAtIndex:i] removeParameter:index];
}

- (void)removeMetaParameter:(int)index;
{
    int i;

    for (i = 0; i < [ruleList count]; i++)
        [[ruleList objectAtIndex:i] removeMetaParameter:index];
}

- (BOOL)isCategoryUsed:aCategory;
{
    return [ruleList isCategoryUsed:aCategory];
}

- (BOOL)isEquationUsed:anEquation;
{
    return [ruleList isEquationUsed:anEquation];
}
- (BOOL)isTransitionUsed:aTransition;
{
    return [ruleList isTransitionUsed: aTransition];
}

- findEquation:anEquation andPutIn:(MonetList *)aList;
{
    return [ruleList findEquation:anEquation andPutIn:aList];
}

- findTemplate:aTemplate andPutIn:aList;
{
    return [ruleList findTemplate:aTemplate andPutIn:aList];
}

- (void)cut:(id)sender;
{
    NSLog(@"RuleManager: cut");
}

static NSString *ruleString = @"Rule";

- (void)copy:(id)sender;
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

    tempEntry = [ruleList objectAtIndex:[[ruleMatrix matrixInColumn:0] selectedRow]];
    [tempEntry encodeWithCoder:typed];

    dataType = ruleString;
    retValue = [myPasteboard declareTypes:[NSArray arrayWithObject:dataType] owner:nil];

    [myPasteboard setData:mdata forType:ruleString];

    [typed release];
}

- (void)paste:(id)sender;
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
        [ruleList insertObject:temp atIndex:[ruleList count]-1];
    else
        [ruleList insertObject:temp atIndex:row+1];

    [temp release];

    [ruleMatrix loadColumnZero];
}

- (void)readDegasFileFormat:(FILE *)fp;
{
    [ruleList readDegasFileFormat:(FILE *) fp];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    int i;

    matchLists = [[MonetList alloc] initWithCapacity:4];
    for (i = 0; i < 4; i++) {
        PhoneList *aPhoneList;

        aPhoneList = [[PhoneList alloc] init];
        [matchLists addObject:aPhoneList];
        [aPhoneList release];
    }

    boolParser = [[BooleanParser alloc] init];
    ruleList = [[aDecoder decodeObject] retain];

    [self applicationDidFinishLaunching:nil];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:ruleList];
}

- (void)readRulesFrom:(NSArchiver *)stream;
{
    [ruleList release];

    cacheValue = 1;

    ruleList = [[stream decodeObject] retain];
}

- (void)writeRulesTo:(NSArchiver *)stream;
{
    [stream encodeObject:ruleList];
}

- (void)windowDidBecomeMain:(NSNotification *)notification;
{
    id temp;
    int index = 0;

    temp = [controller inspector];
    index = [[ruleMatrix matrixInColumn:0] selectedRow];
    if (temp) {
        if (index == -1)
            [temp cleanInspectorWindow];
        else
            [temp inspectRule:[ruleList objectAtIndex:index]];
    }
}

- (BOOL)windowShouldClose:(id)sender;
{
    id temp;

    temp = [controller inspector];
    [temp cleanInspectorWindow];

    return YES;
}

- (void)windowDidResignMain:(NSNotification *)notification;
{
    id temp;

    temp = [controller inspector];
    [temp cleanInspectorWindow];
}

@end
