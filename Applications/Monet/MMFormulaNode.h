//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

#import "MMFRuleSymbols.h"

@interface MMFormulaNode : NSObject
{
}

- (int)precedence;

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols phones:(NSArray *)phones;
- (double)evaluate:(MMFRuleSymbols *)ruleSymbols phones:(NSArray *)phones tempos:(double *)tempos;

- (int)maxPhone;

- (NSString *)expressionString;
- (void)expressionString:(NSMutableString *)resultString;

@end
