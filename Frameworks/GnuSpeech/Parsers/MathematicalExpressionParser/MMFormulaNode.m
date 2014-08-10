//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMFormulaNode.h"

@implementation MMFormulaNode
{
}

- (NSUInteger)precedence;
{
    // Implement in subclasses.
    return 0;
}

- (double)evaluateWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols;
{
    // Implement in subclasses.
    return 0;
}

//- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures;
//{
//    double tempos[4] = {1.0, 1.0, 1.0, 1.0};
//
//    return [self evaluate:ruleSymbols postures:postures tempos:tempos];
//}
//
//- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures tempos:(double *)tempos;
//{
//    // Implement in subclasses.
//    return 0;
//}

- (NSInteger)maxPhone;
{
    // Implement in subclasses.
    return 0;
}

- (NSString *)expressionString;
{
    NSMutableString *resultString;

    resultString = [NSMutableString string];
    [self appendExpressionToString:resultString];

    return resultString;
}

- (void)appendExpressionToString:(NSMutableString *)resultString;
{
    // Implement in subclasses.
}

@end
