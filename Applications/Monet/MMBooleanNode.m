//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMBooleanNode.h"

#import <Foundation/Foundation.h>
#import "CategoryList.h"

@implementation MMBooleanNode

// TODO (2004-05-15): Change this to return a BOOL
- (int)evaluateWithCategories:(CategoryList *)categories;
{
    return 0;
}

- (void)optimize;
{
}

- (void)optimizeSubExpressions;
{
}

// General purpose routines

- (NSString *)expressionString;
{
    NSMutableString *resultString;

    resultString = [NSMutableString string];
    [self expressionString:resultString];

    return resultString;
}

- (void)expressionString:(NSMutableString *)resultString;
{
}

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;
{
    return NO;
}

@end
