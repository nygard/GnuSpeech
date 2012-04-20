//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "MMBooleanNode.h"

#import "CategoryList.h"

@implementation MMBooleanNode
{
}

- (BOOL)evaluateWithCategories:(CategoryList *)categories;
{
    return NO;
}

//
// General purpose routines
//

- (NSString *)expressionString;
{
    NSMutableString *resultString;

    resultString = [NSMutableString string];
    [self expressionString:resultString];

    return resultString;
}

- (void)expressionString:(NSMutableString *)resultString;
{
    // Implement in subclasses
}

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
{
    return NO;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]", NSStringFromClass([self class]), self];
}

@end
