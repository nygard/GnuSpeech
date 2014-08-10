//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MRuleTester.h"

#import <GnuSpeech/GnuSpeech.h>

#import "NSNumberFormatter-Extensions.h"

@implementation MRuleTester
{
    IBOutlet NSForm *_posture1Form;
    IBOutlet NSForm *_posture2Form;
    IBOutlet NSForm *_posture3Form;
    IBOutlet NSForm *_posture4Form;

    IBOutlet NSTextField *_ruleOutputTextField;
    IBOutlet NSTextField *_consumedTokensTextField;
    IBOutlet NSForm *_durationOutputForm;

    MModel *_model;
}

- (id)initWithModel:(MModel *)aModel;
{
    if ((self = [super initWithWindowNibName:@"RuleTester"])) {
        _model = aModel;

        [self setWindowFrameAutosaveName:@"Rule Tester"];
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
        [[_durationOutputForm cellAtIndex:index] setFormatter:defaultNumberFormatter];

    [self clearOutput];
}

- (void)clearOutput;
{
    [[_durationOutputForm cellAtIndex:0] setStringValue:@""];
    [[_durationOutputForm cellAtIndex:1] setStringValue:@""];
    [[_durationOutputForm cellAtIndex:2] setStringValue:@""];
    [[_durationOutputForm cellAtIndex:3] setStringValue:@""];
    [[_durationOutputForm cellAtIndex:4] setStringValue:@""];

    [_ruleOutputTextField setStringValue:@""];
    [_consumedTokensTextField setStringValue:@""];
}

#pragma mark - Actions

- (IBAction)parseRule:(id)sender;
{
    NSInteger ruleIndex;
    NSMutableArray *testPhones, *testCategoryLists;
    MMPosture *aPosture;
    MMRule *aRule;
    MMFRuleSymbols *ruleSymbols = [[MMFRuleSymbols alloc] init];
    NSString *posture1Name, *posture2Name, *posture3Name, *posture4Name;

    testCategoryLists = [NSMutableArray array];
    testPhones = [NSMutableArray array];

    posture1Name = [[_posture1Form cellAtIndex:0] stringValue];
    posture2Name = [[_posture2Form cellAtIndex:0] stringValue];
    posture3Name = [[_posture3Form cellAtIndex:0] stringValue];
    posture4Name = [[_posture4Form cellAtIndex:0] stringValue];

    if ( ([posture1Name isEqualToString:@""]) || ([posture2Name isEqualToString:@""]) ) {
        [self clearOutput];
        [_ruleOutputTextField setStringValue:@"You need at least two postures to parse."];
        return;
    }

    aPosture = [_model postureWithName:posture1Name];
    if (aPosture == nil) {
        [self clearOutput];
        [_ruleOutputTextField setStringValue:[NSString stringWithFormat:@"Unknown posture: \"%@\"", posture1Name]];
        return;
    }
    [testCategoryLists addObject:[aPosture categories]];
    [testPhones addObject:[[MMPhone alloc] initWithPosture:aPosture]];

    aPosture = [_model postureWithName:posture2Name];
    if (aPosture == nil) {
        [_ruleOutputTextField setStringValue:[NSString stringWithFormat:@"Unknown posture: \"%@\"", posture2Name]];
        return;
    }
    [testCategoryLists addObject:[aPosture categories]];
    [testPhones addObject:[[MMPhone alloc] initWithPosture:aPosture]];

    if ([posture3Name length]) {
        aPosture = [_model postureWithName:posture3Name];
        if (aPosture == nil) {
            [_ruleOutputTextField setStringValue:[NSString stringWithFormat:@"Unknown posture: \"%@\"", posture3Name]];
            return;
        }
        [testCategoryLists addObject:[aPosture categories]];
        [testPhones addObject:[[MMPhone alloc] initWithPosture:aPosture]];
    }

    if ([posture4Name length]) {
        aPosture = [_model postureWithName:posture4Name];
        if (aPosture == nil) {
            [_ruleOutputTextField setStringValue:[NSString stringWithFormat:@"Unknown posture: \"%@\"", posture4Name]];
            return;
        }
        [testCategoryLists addObject:[aPosture categories]];
        [testPhones addObject:[[MMPhone alloc] initWithPosture:aPosture]];
    }

    //NSLog(@"TempList count = %d", [testCategoryLists count]);

    aRule = [_model findRuleMatchingCategories:testCategoryLists ruleIndex:&ruleIndex];
    if (aRule != nil) {
        NSString *str;

        str = [NSString stringWithFormat:@"%lu. %@", ruleIndex + 1, [aRule ruleString]];
        [_ruleOutputTextField setStringValue:str];
        [_consumedTokensTextField setIntegerValue:[aRule numberExpressions] - 1];

        [aRule evaluateSymbolEquationsWithPhonesInArray:testPhones ruleSymbols:ruleSymbols withCacheTag:[[self model] nextCacheTag]];

        [[_durationOutputForm cellAtIndex:0] setDoubleValue:ruleSymbols.ruleDuration];
        [[_durationOutputForm cellAtIndex:1] setDoubleValue:ruleSymbols.beat];
        [[_durationOutputForm cellAtIndex:2] setDoubleValue:ruleSymbols.mark1];
        [[_durationOutputForm cellAtIndex:3] setDoubleValue:ruleSymbols.mark2];
        [[_durationOutputForm cellAtIndex:4] setDoubleValue:ruleSymbols.mark3];

        return;
    }

    NSBeep();
    [self clearOutput];
    [_ruleOutputTextField setStringValue:@"Cannot find rule"];
    [_consumedTokensTextField setIntValue:0];
}

- (IBAction)shiftPosturesLeft:(id)sender;
{
    NSString *p2, *p3, *p4;

    p2 = [[_posture2Form cellAtIndex:0] stringValue];
    p3 = [[_posture3Form cellAtIndex:0] stringValue];
    p4 = [[_posture4Form cellAtIndex:0] stringValue];

    [[_posture1Form cellAtIndex:0] setStringValue:p2];
    [[_posture2Form cellAtIndex:0] setStringValue:p3];
    [[_posture3Form cellAtIndex:0] setStringValue:p4];
    [[_posture4Form cellAtIndex:0] setStringValue:@""];
}

@end
