//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMBooleanExpression-Compatibility.h"

#import "NSObject-Extensions.h"

@implementation MMBooleanExpression (Compatibility)

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int numExpressions, maxExpressions;
    int i;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"iii", &operation, &numExpressions, &maxExpressions];
    //NSLog(@"operation: %d, numExpressions: %d, maxExpressions: %d", operation, numExpressions, maxExpressions);
    expressions = [[NSMutableArray alloc] init];

    for (i = 0; i < numExpressions; i++) {
        MMBooleanNode *anExpression;

        anExpression = [aDecoder decodeObject];
        if (anExpression != nil)
            [self addSubExpression:anExpression];
    }

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

@end
