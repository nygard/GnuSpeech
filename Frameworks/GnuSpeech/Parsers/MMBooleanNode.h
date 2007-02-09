//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@class NSMutableString;
@class MMCategory, CategoryList;

@interface MMBooleanNode : NSObject
{
}

- (BOOL)evaluateWithCategories:(CategoryList *)categories;

// General purpose routines
- (NSString *)expressionString;
- (void)expressionString:(NSMutableString *)resultString;

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;

- (NSString *)description;

@end
