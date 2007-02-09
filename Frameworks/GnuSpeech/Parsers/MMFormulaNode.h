//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

#import "MMFRuleSymbols.h"

@class NSArray, NSMutableString;

@interface MMFormulaNode : NSObject
{
}

- (int)precedence;

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures;
- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures tempos:(double *)tempos;

- (int)maxPhone;

- (NSString *)expressionString;
- (void)expressionString:(NSMutableString *)resultString;

@end
