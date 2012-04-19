//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/NSArray.h>

@class NSMutableString;

@interface NSArray (Extensions)

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(NSUInteger)level;
- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(NSUInteger)level numberCommentPrefix:(NSString *)prefix;

@end
