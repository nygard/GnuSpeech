//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MXMLArrayDelegate.h"

#import <Foundation/Foundation.h>
#import "MXMLParser.h"

@implementation MXMLArrayDelegate

- (id)initWithChildElementName:(NSString *)anElementName class:(Class)aClass;
{
    if ([super init] == nil)
        return nil;

    childElementName = [anElementName retain];
    objects = [[NSMutableArray alloc] init];
    objectClass = aClass;

    return self;
}

- (void)dealloc;
{
    [childElementName release];
    [objects release];

    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:childElementName]) {
        id newObject;

        newObject = [[objectClass alloc] initWithXMLAttributes:attributeDict];
        [objects addObject:newObject];
        [(MXMLParser *)parser pushDelegate:newObject];
        [newObject release];
    } else {
        NSLog(@"skipping element: %@", elementName);
        [(MXMLParser *)parser skipTree];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
}

@end
