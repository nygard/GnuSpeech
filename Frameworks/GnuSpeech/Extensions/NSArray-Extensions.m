//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "NSArray-Extensions.h"

#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

@implementation NSArray (Extensions)

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(NSUInteger)level;
{
    [self appendXMLToString:resultString elementName:elementName level:level numberCommentPrefix:nil];
}

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(NSUInteger)level numberCommentPrefix:(NSString *)prefix;
{
    if ([self count] == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<%@>\n", elementName];

    [self enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        if (prefix != nil) {
            [resultString indentToLevel:level+1];
            [resultString appendFormat:@"<!-- %@: %lu -->\n", prefix, index + 1];
        }

        [object appendXMLToString:resultString level:level+1];
    }];

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</%@>\n", elementName];
}

@end
