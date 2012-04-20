//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

#import "MMFRuleSymbols.h"

@interface MMFormulaNode : NSObject
{
}

- (NSUInteger)precedence;

- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures;
- (double)evaluate:(MMFRuleSymbols *)ruleSymbols postures:(NSArray *)postures tempos:(double *)tempos;

- (NSUInteger)maxPhone;

- (NSString *)expressionString;
- (void)expressionString:(NSMutableString *)resultString;

@end
