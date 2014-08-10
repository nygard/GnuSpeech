//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFormulaTerminal.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "MMPosture.h"
#import "MMSymbol.h"
#import "MMTarget.h"
#import "MMPhone.h"
#import "MMFRuleSymbols.h"

#import "MModel.h"

@implementation MMFormulaTerminal
{
    MMSymbol *_symbol;
    double _value;
    MMPhoneIndex _whichPhone; // TODO (2004-03-10): Rename this
}

- (id)init;
{
    if ((self = [super init])) {
        _symbol = nil;
        _value = 0.0;
        _whichPhone = -1;
    }

    return self;
}

#pragma mark - Superclass methods

- (NSUInteger)precedence;
{
    return 3;
}

/// This takes an array of 0-4 MMPhone objects, and the rule symbols, and returns the appropriate value.
- (double)evaluateWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols;
{
    NSParameterAssert([phones count] <= 4);

    switch (_whichPhone) {
        case MMPhoneIndex_RuleDuration: return ruleSymbols.ruleDuration; // Duration of the rule itself
        case MMPhoneIndex_Beat:         return ruleSymbols.beat;
        case MMPhoneIndex_Mark1:        return ruleSymbols.mark1;
        case MMPhoneIndex_Mark2:        return ruleSymbols.mark2;
        case MMPhoneIndex_Mark3:        return ruleSymbols.mark3;
        case MMPhoneIndex_Tempo0:       { MMPhone *phone = phones[0]; return phone.tempo; }
        case MMPhoneIndex_Tempo1:       { MMPhone *phone = phones[1]; return phone.tempo; }
        case MMPhoneIndex_Tempo2:       { MMPhone *phone = phones[2]; return phone.tempo; }
        case MMPhoneIndex_Tempo3:       { MMPhone *phone = phones[3]; return phone.tempo; }

        default:
            break;
    }

    // Constant value
    if (_symbol == nil)
        return _value;

    NSParameterAssert(_whichPhone >= 0 && _whichPhone < 4);

    MMPhone *phone = phones[_whichPhone];
    MMTarget *symbolTarget = [phone.posture targetForSymbol:_symbol];
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
    switch (_whichPhone) {
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
            if (_symbol == nil) {
                [resultString appendFormat:@"%f", _value];
            } else {
                NSParameterAssert(_whichPhone >= 0 && _whichPhone < 4);
                [resultString appendFormat:@"%@%lu", [_symbol name], _whichPhone+1];
            }
            break;
    }
}

@end
