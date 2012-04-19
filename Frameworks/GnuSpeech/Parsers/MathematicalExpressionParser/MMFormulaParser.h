//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSParser.h"

@class MMFormulaTerminal, MMFormulaNode, MModel;

@interface MMFormulaParser : GSParser
{
    MModel *model;

    int lookahead;
}

+ (MMFormulaNode *)parsedExpressionFromString:(NSString *)aString model:(MModel *)aModel;
+ (NSString *)nameForToken:(int)aToken;

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (int)nextToken;
- (BOOL)scanNumber;


- (void)match:(int)token;
- (MMFormulaNode *)parseExpression;
- (MMFormulaNode *)parseTerm;
- (MMFormulaNode *)parseFactor;

- (MMFormulaTerminal *)parseNumber;
- (MMFormulaNode *)parseSymbol;

- (id)beginParseString;

@end
