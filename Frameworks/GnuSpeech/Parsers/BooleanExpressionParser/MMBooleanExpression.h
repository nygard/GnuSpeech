//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMBooleanNode.h"

enum {
    MMBooleanOperation_None        = 0,
    MMBooleanOperation_Not         = 1,
    MMBooleanOperation_Or          = 2,
    MMBooleanOperation_And         = 3,
    MMBooleanOperation_ExclusiveOr = 4,
};
typedef NSUInteger MMBooleanOperation;


// Non-leaf node in a boolean expression tree.
@interface MMBooleanExpression : MMBooleanNode

@property (assign) MMBooleanOperation operation;

- (void)addSubExpression:(MMBooleanNode *)expression;
@property (nonatomic, readonly) MMBooleanNode *operandOne;
@property (nonatomic, readonly) MMBooleanNode *operandTwo;

@end
