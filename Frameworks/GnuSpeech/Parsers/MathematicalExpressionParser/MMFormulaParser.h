//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSParser.h"

@class MMFormulaNode, MModel;

@interface MMFormulaParser : GSParser

+ (MMFormulaNode *)parsedExpressionFromString:(NSString *)string model:(MModel *)model;
+ (NSString *)nameForToken:(NSUInteger)token;

- (id)initWithModel:(MModel *)model;

@property (retain) MModel *model;

@end
