//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "NSRegularExpression-GSExtensions.h"

@implementation NSRegularExpression (GSExtensions)

- (NSString *)stringByReplacingMatchesInString:(NSString *)string options:(NSMatchingOptions)options withTemplate:(NSString *)templ;
{
    return [self stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:templ];
}

@end
