//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MRuleTester.h"

#import <AppKit/AppKit.h>
#import "NSNumberFormatter-Extensions.h"

#import "MMEquation.h"
#import "MMFRuleSymbols.h"
#import "MModel.h"
#import "MMPosture.h"
#import "MMRule.h"
#import "MonetList.h"

@implementation MRuleTester

- (id)initWithModel:(MModel *)aModel;
{
    if ([super initWithWindowNibName:@"RuleTester"] == nil)
        return nil;

    model = [aModel retain];

    [self setWindowFrameAutosaveName:@"Rule Tester"];

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

    [self clearOutput];
}

- (NSUndoManager *)undoManager;
{
    return nil;
}

- (void)windowDidLoad;
{
    int index;

    NSNumberFormatter *defaultNumberFormatter;

    defaultNumberFormatter = [NSNumberFormatter defaultNumberFormatter];

    for (index = 0; index < 5; index++)
        [[durationOutputForm cellAtIndex:index] setFormatter:defaultNumberFormatter];

    [self clearOutput];
}

- (void)clearOutput;
{
    [[durationOutputForm cellAtIndex:0] setStringValue:@""];
    [[durationOutputForm cellAtIndex:1] setStringValue:@""];
    [[durationOutputForm cellAtIndex:2] setStringValue:@""];
    [[durationOutputForm cellAtIndex:3] setStringValue:@""];
    [[durationOutputForm cellAtIndex:4] setStringValue:@""];

    [ruleOutputTextField setStringValue:@""];
    [consumedTokensTextField setStringValue:@""];
}

//
// Actions
//

- (IBAction)parseRule:(id)sender;
{
    int ruleIndex;
    MonetList *testCategoryLists;
    NSMutableArray *testPostures;
    MMPosture *aPosture;
    MMRule *aRule;
    MMFRuleSymbols ruleSymbols = {0.0, 0.0, 0.0, 0.0, 0.0};
    NSString *posture1Name, *posture2Name, *posture3Name, *posture4Name;

    testCategoryLists = [[[MonetList alloc] initWithCapacity:4] autorelease];
    testPostures = [NSMutableArray array];

    posture1Name = [[posture1Form cellAtIndex:0] stringValue];
    posture2Name = [[posture2Form cellAtIndex:0] stringValue];
    posture3Name = [[posture3Form cellAtIndex:0] stringValue];
    posture4Name = [[posture4Form cellAtIndex:0] stringValue];

    if ( ([posture1Name isEqualToString:@""]) || ([posture2Name isEqualToString:@""]) ) {
        [self clearOutput];
        [ruleOutputTextField setStringValue:@"You need at least two postures to parse."];
        return;
    }

    aPosture = [model postureWithName:posture1Name];
    if (aPosture == nil) {
        [self clearOutput];
        [ruleOutputTextField setStringValue:[NSString stringWithFormat:@"Unknown posture: \"%@\"", posture1Name]];
        return;
    }
    [testCategoryLists addObject:[aPosture categoryList]];
    [testPostures addObject:aPosture];

    aPosture = [model postureWithName:posture2Name];
    if (aPosture == nil) {
        [ruleOutputTextField setStringValue:[NSString stringWithFormat:@"Unknown posture: \"%@\"", posture2Name]];
        return;
    }
    [testCategoryLists addObject:[aPosture categoryList]];
    [testPostures addObject:aPosture];

    if ([posture3Name length]) {
        aPosture = [model postureWithName:posture3Name];
        if (aPosture == nil) {
            [ruleOutputTextField setStringValue:[NSString stringWithFormat:@"Unknown posture: \"%@\"", posture3Name]];
            return;
        }
        [testCategoryLists addObject:[aPosture categoryList]];
        [testPostures addObject:aPosture];
    }

    if ([posture4Name length]) {
        aPosture = [model postureWithName:posture4Name];
        if (aPosture == nil) {
            [ruleOutputTextField setStringValue:[NSString stringWithFormat:@"Unknown posture: \"%@\"", posture4Name]];
            return;
        }
        [testCategoryLists addObject:[aPosture categoryList]];
        [testPostures addObject:aPosture];
    }

    //NSLog(@"TempList count = %d", [testCategoryLists count]);

    aRule = [model findRuleMatchingCategories:testCategoryLists ruleIndex:&ruleIndex];
    if (aRule != nil) {
        NSString *str;

        str = [NSString stringWithFormat:@"%d. %@", ruleIndex + 1, [aRule ruleString]];
        [ruleOutputTextField setStringValue:str];
        [consumedTokensTextField setIntValue:[aRule numberExpressions] - 1];

        // TODO (2004-03-02): Is being out of order significant?
        // TODO (2004-03-23): I think that the last value may not always be accurate, i.e. for diphones, triphones
        ruleSymbols.ruleDuration = [[aRule getExpressionSymbol:0] evaluate:&ruleSymbols phones:testPostures andCacheWith:[[self model] nextCacheTag]];
        ruleSymbols.mark1 = [[aRule getExpressionSymbol:2] evaluate:&ruleSymbols phones:testPostures andCacheWith:[[self model] nextCacheTag]];
        ruleSymbols.mark2 = [[aRule getExpressionSymbol:3] evaluate:&ruleSymbols phones:testPostures andCacheWith:[[self model] nextCacheTag]];
        ruleSymbols.mark3 = [[aRule getExpressionSymbol:4] evaluate:&ruleSymbols phones:testPostures andCacheWith:[[self model] nextCacheTag]];
        ruleSymbols.beat = [[aRule getExpressionSymbol:1] evaluate:&ruleSymbols phones:testPostures andCacheWith:[[self model] nextCacheTag]];

        [[durationOutputForm cellAtIndex:0] setDoubleValue:ruleSymbols.ruleDuration];
        [[durationOutputForm cellAtIndex:1] setDoubleValue:ruleSymbols.beat];
        [[durationOutputForm cellAtIndex:2] setDoubleValue:ruleSymbols.mark1];
        [[durationOutputForm cellAtIndex:3] setDoubleValue:ruleSymbols.mark2];
        [[durationOutputForm cellAtIndex:4] setDoubleValue:ruleSymbols.mark3];

        return;
    }

    NSBeep();
    [self clearOutput];
    [ruleOutputTextField setStringValue:@"Cannot find rule"];
    [consumedTokensTextField setIntValue:0];
}

- (IBAction)shiftPosturesLeft:(id)sender;
{
    NSString *p2, *p3, *p4;

    p2 = [[posture2Form cellAtIndex:0] stringValue];
    p3 = [[posture3Form cellAtIndex:0] stringValue];
    p4 = [[posture4Form cellAtIndex:0] stringValue];

    [[posture1Form cellAtIndex:0] setStringValue:p2];
    [[posture2Form cellAtIndex:0] setStringValue:p3];
    [[posture3Form cellAtIndex:0] setStringValue:p4];
    [[posture4Form cellAtIndex:0] setStringValue:@""];
}

@end
