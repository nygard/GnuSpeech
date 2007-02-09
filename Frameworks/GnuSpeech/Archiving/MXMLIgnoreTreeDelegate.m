//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import "MXMLIgnoreTreeDelegate.h"

#import <Foundation/Foundation.h>
#import "MXMLParser.h"

@implementation MXMLIgnoreTreeDelegate

- (id)init;
{
    if ([super init] == nil)
        return nil;

    depth = 1;

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    depth++;
    //NSLog(@"<%@ depth='%d'>", elementName, depth);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    depth--;
    //NSLog(@"</%@>, depth now %d", elementName, depth);
    if (depth == 0) {
        //NSLog(@"done ignoring tree '%@'", elementName);
        [(MXMLParser *)parser popDelegate];
    }
}

@end
