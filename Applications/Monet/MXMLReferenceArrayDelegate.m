//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MXMLReferenceArrayDelegate.h"

#import <Foundation/Foundation.h>
#import "MXMLParser.h"

@implementation MXMLReferenceArrayDelegate

- (id)initWithChildElementName:(NSString *)anElementName referenceAttribute:(NSString *)anAttribute delegate:(id)aDelegate addObjectSelector:(SEL)aSelector;
{
    if ([super init] == nil)
        return nil;

    childElementName = [anElementName retain];
    referenceAttribute = [anAttribute retain];
    delegate = [aDelegate retain];
    addObjectSelector = aSelector;
    references = [[NSMutableArray alloc] init];

    return self;
}

- (void)dealloc;
{
    [childElementName release];
    [referenceAttribute release];
    [delegate release];
    [references release];

    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([anElementName isEqualToString:childElementName]) {
        id referenceID;

        referenceID = [attributeDict objectForKey:referenceAttribute];
        if (referenceID != nil)
            [references addObject:referenceID];
        [(MXMLParser *)parser skipTree];
    } else {
        NSLog(@"MXMLArrayDelegate: skipping element: %@", anElementName);
        [(MXMLParser *)parser skipTree];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    NSLog(@"closing array element: '%@', popping delegate", anElementName);
    NSLog(@"references: %@", [references description]);
    if ([delegate respondsToSelector:addObjectSelector]) {
        unsigned int count, index;

        count = [references count];
        NSLog(@"Adding %d references to %@ with selector %s", count, delegate, addObjectSelector);
        for (index = 0; index < count; index++) {
            [delegate performSelector:addObjectSelector withObject:[references objectAtIndex:index]];
        }
    }

    [(MXMLParser *)parser popDelegate];
}

@end
