//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMBooleanNode.h"

#import <Foundation/Foundation.h>
#import "CategoryList.h"

@implementation MMBooleanNode

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
