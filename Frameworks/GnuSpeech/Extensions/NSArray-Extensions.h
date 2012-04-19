//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/NSArray.h>

@class NSMutableString;

@interface NSArray (Extensions)

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;
- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level numberCommentPrefix:(NSString *)prefix;

@end
