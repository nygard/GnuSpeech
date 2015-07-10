//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMGroupedObject.h"

#import "NSObject-Extensions.h"

@class MMFormulaNode, MMFRuleSymbols;

@interface MMEquation : MMGroupedObject <GSXMLArchiving>

@property (strong) MMFormulaNode *formula;

- (void)setFormulaString:(NSString *)formulaString;

- (double)evaluateWithPhonesInArray:(NSArray *)phones ruleSymbols:(MMFRuleSymbols *)ruleSymbols andCacheWithTag:(NSUInteger)newCacheTag;
- (double)cacheValue;

- (NSString *)equationPath;

@end
