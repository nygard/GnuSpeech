//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMBooleanExpression.h"

#import "NSObject-Extensions.h"

@interface MMBooleanExpression ()
@property (readonly) NSMutableArray *expressions;
@property (nonatomic, readonly) NSString *operationString;
@end

#pragma mark -

@implementation MMBooleanExpression
{
    MMBooleanOperation m_operation;
    NSMutableArray *m_expressions;
}

- (id)init;
{
    if ((self = [super init])) {
        m_operation = MMBooleanOperation_None;
        m_expressions = [[NSMutableArray alloc] initWithCapacity:4];
    }

    return self;
}

- (void)dealloc;
{
    [m_expressions release];

    [super dealloc];
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p> operation: %lu, expressions: %@, expressionString: %@",
            NSStringFromClass([self class]), self,
            self.operation, self.expressions, self.expressionString];
}

#pragma mark - Superclass methods

- (BOOL)evaluateWithCategories:(CategoryList *)categories;
{
    switch (self.operation) {
        case MMBooleanOperation_Not:
            return ![self.operandOne evaluateWithCategories:categories];
            
        case MMBooleanOperation_And:
            return [self.operandOne evaluateWithCategories:categories] && [self.operandTwo evaluateWithCategories:categories];
            
        case MMBooleanOperation_Or:
            return [self.operandOne evaluateWithCategories:categories] || [self.operandTwo evaluateWithCategories:categories];
            
        case MMBooleanOperation_ExclusiveOr:
            // TODO (2012-04-20): This is a bitwise exclusive or, not necessarily a logical one.
            return [self.operandOne evaluateWithCategories:categories] ^ [self.operandTwo evaluateWithCategories:categories];
            
        default:
            return YES;
    }

    return NO;
}

- (void)appendExpressionToString:(NSMutableString *)resultString;
{
    NSString *operationString = [self operationString];

    [resultString appendString:@"("];

    if (self.operation == MMBooleanOperation_Not) {
        [resultString appendString:@"not "];
        if ([self.expressions count] > 0)
            [[self.expressions objectAtIndex:0] appendExpressionToString:resultString];
    } else {
        [self.expressions enumerateObjectsUsingBlock:^(MMBooleanNode *node, NSUInteger index, BOOL *stop){
            if (index != 0)
                [resultString appendString:operationString];
            [node appendExpressionToString:resultString];
        }];
    }

    [resultString appendString:@")"];
}

- (BOOL)isCategoryUsed:(MMCategory *)category;
{
    for (MMBooleanExpression *expression in self.expressions) {
        if ([expression isCategoryUsed:category])
            return YES;
    }

    return NO;
}

#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)decoder;
{
    if ((self = [super initWithCoder:decoder])) {
        [decoder versionForClassName:NSStringFromClass([self class])];

        NSUInteger expressionCount, maxExpressionCount;
        
        // TODO (2012-04-20): Separate required archived values of operation from current enum values.
        NSUInteger archivedOperation;
        [decoder decodeValuesOfObjCTypes:"iii", &archivedOperation, &expressionCount, &maxExpressionCount];
        self.operation = archivedOperation;
        m_expressions = [[NSMutableArray alloc] init];
        
        for (NSUInteger i = 0; i < expressionCount; i++) {
            MMBooleanNode *expression = [decoder decodeObject];
            if (expression != nil)
                [self addSubExpression:expression];
        }
    }

    return self;
}

#pragma mark -

@synthesize operation = m_operation;
@synthesize expressions = m_expressions;

- (void)addSubExpression:(MMBooleanNode *)expression;
{
    if (expression != nil)
        [self.expressions addObject:expression];
}

- (MMBooleanNode *)operandOne;
{
    if ([self.expressions count] > 0)
        return [self.expressions objectAtIndex:0];
    
    return nil;
}

- (MMBooleanNode *)operandTwo;
{
    if ([self.expressions count] > 1)
        return [self.expressions objectAtIndex:1];
    
    return nil;
}

- (NSString *)operationString;
{
    switch (self.operation) {
        default:
        case MMBooleanOperation_Not:         return @" not ";
        case MMBooleanOperation_None:        return @"";
        case MMBooleanOperation_Or:          return @" or ";
        case MMBooleanOperation_And:         return @" and ";
        case MMBooleanOperation_ExclusiveOr: return @" xor ";
    }
    
    return @"";
}

@end
