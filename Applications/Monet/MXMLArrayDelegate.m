//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MXMLArrayDelegate.h"

#import <Foundation/Foundation.h>
#import "MXMLParser.h"

@implementation MXMLArrayDelegate

- (id)initWithChildElementName:(NSString *)anElementName class:(Class)aClass delegate:(id)aDelegate addObjectSelector:(SEL)aSelector;
{
    if ([super init] == nil)
        return nil;

    childElementName = [anElementName retain];
    objectClass = aClass;
    delegate = [aDelegate retain];
    addObjectSelector = aSelector;

    return self;
}

- (void)dealloc;
{
    [childElementName release];
    [delegate release];

    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([anElementName isEqualToString:childElementName]) {
        id newObject;

        newObject = [[objectClass alloc] initWithXMLAttributes:attributeDict];
        NSLog(@"newObject: %@", newObject);
        if ([delegate respondsToSelector:addObjectSelector]) {
            [delegate performSelector:addObjectSelector withObject:newObject];
        }
        [(MXMLParser *)parser pushDelegate:newObject];
        [newObject release];
    } else {
        NSLog(@"MXMLArrayDelegate: skipping element: %@", anElementName);
        [(MXMLParser *)parser skipTree];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    NSLog(@"closing array element: '%@', popping delegate", anElementName);
    [(MXMLParser *)parser popDelegate];
}

@end
