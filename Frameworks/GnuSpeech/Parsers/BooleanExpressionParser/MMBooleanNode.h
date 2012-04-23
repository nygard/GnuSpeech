//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@class MMCategory;


@interface MMBooleanNode : NSObject

- (BOOL)evaluateWithCategories:(NSArray *)categories;

- (NSString *)expressionString;
- (void)appendExpressionToString:(NSMutableString *)resultString;

- (BOOL)isCategoryUsed:(MMCategory *)category;

@end
