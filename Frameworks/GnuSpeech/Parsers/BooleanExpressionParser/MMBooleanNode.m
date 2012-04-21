//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMBooleanNode.h"

#import "CategoryList.h"

@implementation MMBooleanNode
{
}

#pragma mark - Debugging

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@: %p>",
            NSStringFromClass([self class]), self];
}

#pragma mark -

- (BOOL)evaluateWithCategories:(CategoryList *)categories;
{
    return NO;
}

#pragma mark - General purpose routines

- (NSString *)expressionString;
{
    NSMutableString *resultString = [NSMutableString string];
    [self appendExpressionToString:resultString];

    return resultString;
}

- (void)appendExpressionToString:(NSMutableString *)resultString;
{
    // Implement in subclasses
}

- (BOOL)isCategoryUsed:(MMCategory *)category;
{
    return NO;
}

@end
