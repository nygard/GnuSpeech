//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMFormulaNode.h"

#import <Foundation/Foundation.h>

@implementation MMFormulaNode

- (int)precedence;
{
    // Implement in subclasses
    return 0;
}

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures;
{
    double tempos[4] = {1.0, 1.0, 1.0, 1.0};

    return [self evaluate:ruleSymbols postures:postures tempos:tempos];
}

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures tempos:(double *)tempos;
{
    // Implement in subclasses
    return 0;
}

- (int)maxPhone;
{
    // Implement in subclasses
    return 0;
}

- (NSString *)expressionString;
{
    NSMutableString *resultString;

    resultString = [NSMutableString string];
    [self expressionString:resultString];

    return resultString;
}

- (void)expressionString:(NSMutableString *)resultString;
{
    // Implement in subclasses
}

@end
