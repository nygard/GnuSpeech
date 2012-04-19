//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

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
