//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class MMFRuleSymbols;

@interface MMFormulaNode : NSObject

@property (nonatomic, readonly) NSUInteger precedence;

/// This takes an array of 0-4 MMPhone objects, and the rule symbols, and returns the appropriate value.
- (double)evaluateWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols;

- (NSInteger)maxPhone;

- (NSString *)expressionString;
- (void)appendExpressionToString:(NSMutableString *)resultString;

@end
