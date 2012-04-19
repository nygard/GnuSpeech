//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

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
