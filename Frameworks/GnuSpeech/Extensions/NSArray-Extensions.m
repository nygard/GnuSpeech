//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock

#import "NSArray-Extensions.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

@implementation NSArray (Extensions)

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;
{
    [self appendXMLToString:resultString elementName:elementName level:level numberCommentPrefix:nil];
}

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level numberCommentPrefix:(NSString *)prefix;
{
    int count, index;

    count = [self count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<%@>\n", elementName];

    for (index = 0; index < count; index++) {
        if (prefix != nil) {
            [resultString indentToLevel:level+1];
            [resultString appendFormat:@"<!-- %@: %d -->\n", prefix, index + 1];
        }

        [[self objectAtIndex:index] appendXMLToString:resultString level:level+1];
    }

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</%@>\n", elementName];
}

@end
