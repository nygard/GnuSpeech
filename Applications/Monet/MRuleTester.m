//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MRuleTester.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"

@implementation MRuleTester
{
    IBOutlet NSForm *posture1Form;
    IBOutlet NSForm *posture2Form;
    IBOutlet NSForm *posture3Form;
    IBOutlet NSForm *posture4Form;
    
    IBOutlet NSTextField *ruleOutputTextField;
    IBOutlet NSTextField *consumedTokensTextField;
    IBOutlet NSForm *durationOutputForm;
    
    MModel *model;
}

- (id)initWithModel:(MModel *)aModel;
{
    if ((self = [super initWithWindowNibName:@"RuleTester"])) {
        model = [aModel retain];

        [self setWindowFrameAutosaveName:@"Rule Tester"];
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
    NSUInteger index;

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

#pragma mark - Actions

- (IBAction)parseRule:(id)sender;
{
    NSInteger ruleIndex;
    NSMutableArray *testPhones, *testCategoryLists;
    MMPosture *aPosture;
    MMRule *aRule;
    MMFRuleSymbols *ruleSymbols = [[[MMFRuleSymbols alloc] init] autorelease];
    NSString *posture1Name, *posture2Name, *posture3Name, *posture4Name;

    testCategoryLists = [NSMutableArray array];
    testPhones = [NSMutableArray array];

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
    [testCategoryLists addObject:[aPosture categories]];
    [testPhones addObject:[[MMPhone alloc] initWithPosture:aPosture]];

    aPosture = [model postureWithName:posture2Name];
    if (aPosture == nil) {
        [ruleOutputTextField setStringValue:[NSString stringWithFormat:@"Unknown posture: \"%@\"", posture2Name]];
        return;
    }
    [testCategoryLists addObject:[aPosture categories]];
    [testPhones addObject:[[MMPhone alloc] initWithPosture:aPosture]];

    if ([posture3Name length]) {
        aPosture = [model postureWithName:posture3Name];
        if (aPosture == nil) {
            [ruleOutputTextField setStringValue:[NSString stringWithFormat:@"Unknown posture: \"%@\"", posture3Name]];
            return;
        }
        [testCategoryLists addObject:[aPosture categories]];
        [testPhones addObject:[[MMPhone alloc] initWithPosture:aPosture]];
    }

    if ([posture4Name length]) {
        aPosture = [model postureWithName:posture4Name];
        if (aPosture == nil) {
            [ruleOutputTextField setStringValue:[NSString stringWithFormat:@"Unknown posture: \"%@\"", posture4Name]];
            return;
        }
        [testCategoryLists addObject:[aPosture categories]];
        [testPhones addObject:[[MMPhone alloc] initWithPosture:aPosture]];
    }

    //NSLog(@"TempList count = %d", [testCategoryLists count]);

    aRule = [model findRuleMatchingCategories:testCategoryLists ruleIndex:&ruleIndex];
    if (aRule != nil) {
        NSString *str;

        str = [NSString stringWithFormat:@"%lu. %@", ruleIndex + 1, [aRule ruleString]];
        [ruleOutputTextField setStringValue:str];
        [consumedTokensTextField setIntegerValue:[aRule numberExpressions] - 1];

        [aRule evaluateSymbolEquationsWithPhonesInArray:testPhones ruleSymbols:ruleSymbols withCacheTag:[[self model] nextCacheTag]];

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
