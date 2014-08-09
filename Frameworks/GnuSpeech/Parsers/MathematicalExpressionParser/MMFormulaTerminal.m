//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFormulaTerminal.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "MMPosture.h"
#import "MMSymbol.h"
#import "MMTarget.h"

#import "MModel.h"

@implementation MMFormulaTerminal
{
    MMSymbol *symbol;
    double value;
    MMPhoneIndex whichPhone; // TODO (2004-03-10): Rename this
}

- (id)init;
{
    if ((self = [super init])) {
        symbol = nil;
        value = 0.0;
        whichPhone = -1;
    }

    return self;
}

- (void)dealloc;
{
    [symbol release];

    [super dealloc];
}

#pragma mark - Superclass methods

- (NSUInteger)precedence;
{
    return 3;
}

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures tempos:(double *)tempos;
{
    // Duration of the rule itself
    switch (whichPhone) {
        case MMPhoneIndex_RuleDuration: return ruleSymbols.ruleDuration;
        case MMPhoneIndex_Beat:         return ruleSymbols.beat;
        case MMPhoneIndex_Mark1:        return ruleSymbols.mark1;
        case MMPhoneIndex_Mark2:        return ruleSymbols.mark2;
        case MMPhoneIndex_Mark3:        return ruleSymbols.mark3;
        case MMPhoneIndex_Tempo0:       return tempos[0];
        case MMPhoneIndex_Tempo1:       return tempos[1];
        case MMPhoneIndex_Tempo2:       return tempos[2];
        case MMPhoneIndex_Tempo3:       return tempos[3];
            
        default:
            break;
    }
    
    // Constant value
    if (symbol == nil)
        return value;

    NSParameterAssert(whichPhone >= 0 && whichPhone < 4);
    
    MMTarget *symbolTarget = [[postures objectAtIndex:whichPhone] targetForSymbol:symbol];
    if (symbolTarget == nil)
        return 0.0;
    
    return [symbolTarget value];
}

- (NSInteger)maxPhone;
{
    return self.whichPhone;
}

- (void)appendExpressionToString:(NSMutableString *)resultString;
{
    switch (whichPhone) {
        case MMPhoneIndex_RuleDuration: [resultString appendString:@"rd"];     break;
        case MMPhoneIndex_Beat:         [resultString appendString:@"beat"];   break;
        case MMPhoneIndex_Mark1:        [resultString appendString:@"mark1"];  break;
        case MMPhoneIndex_Mark2:        [resultString appendString:@"mark2"];  break;
        case MMPhoneIndex_Mark3:        [resultString appendString:@"mark3"];  break;
        case MMPhoneIndex_Tempo0:       [resultString appendString:@"tempo1"]; break;
        case MMPhoneIndex_Tempo1:       [resultString appendString:@"tempo2"]; break;
        case MMPhoneIndex_Tempo2:       [resultString appendString:@"tempo3"]; break;
        case MMPhoneIndex_Tempo3:       [resultString appendString:@"tempo4"]; break;
            
        default:
            if (symbol == nil) {
                [resultString appendFormat:@"%f", value];
            } else {
                NSParameterAssert(whichPhone >= 0 && whichPhone < 4);
                [resultString appendFormat:@"%@%lu", [symbol name], whichPhone+1];
            }
            break;
    }
}

@synthesize symbol, value, whichPhone;

@end
