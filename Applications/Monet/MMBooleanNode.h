//
// $Id$
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@class MMCategory, CategoryList;

@interface MMBooleanNode : NSObject
{
}

// Evaluate yourself
- (BOOL)evaluateWithCategories:(CategoryList *)categories;

// General purpose routines
- (NSString *)expressionString;
- (void)expressionString:(NSMutableString *)resultString;

- (BOOL)isCategoryUsed:(MMCategory *)aCategory;

@end
