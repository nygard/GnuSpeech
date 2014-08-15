//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <Foundation/Foundation.h>

@interface NSRegularExpression (GSExtensions)

- (NSString *)stringByReplacingMatchesInString:(NSString *)string options:(NSMatchingOptions)options withTemplate:(NSString *)templ;
- (NSUInteger)replaceMatchesInString:(NSMutableString *)string options:(NSMatchingOptions)options withTemplate:(NSString *)templ;

@end
