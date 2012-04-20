//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import "MXMLReferenceDictionaryDelegate.h"

#import "MXMLParser.h"

@implementation MXMLReferenceDictionaryDelegate

- (id)initWithChildElementName:(NSString *)anElementName keyAttributeName:(NSString *)aKeyAttribute referenceAttributeName:(NSString *)aReferenceAttribute
                      delegate:(id)aDelegate addObjectsSelector:(SEL)aSelector;
{
    if ([super init] == nil)
        return nil;

    childElementName = [anElementName retain];
    keyAttributeName = [aKeyAttribute retain];
    referenceAttributeName = [aReferenceAttribute retain];
    delegate = [aDelegate retain];
    addObjectsSelector = aSelector;
    objects = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)dealloc;
{
    [childElementName release];
    [keyAttributeName release];
    [referenceAttributeName release];
    [delegate release];
    [objects release];

    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([anElementName isEqualToString:childElementName]) {
        NSString *key, *reference;

        key = [attributeDict objectForKey:keyAttributeName];
        reference = [attributeDict objectForKey:referenceAttributeName];
        if (key == nil) {
            NSLog(@"Warning: key attribute (%@) not set for element: %@", keyAttributeName, anElementName);
        } else {
            if ([objects objectForKey:key] != nil)
                NSLog(@"Warning: already have an object for key: %@, replacing", key);

            [objects setObject:reference forKey:key];
        }
        [(MXMLParser *)parser skipTree];
    } else {
        NSLog(@"Warning: %@: skipping element: %@", NSStringFromClass([self class]), anElementName);
        [(MXMLParser *)parser skipTree];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    //NSLog(@"%@: closing element: '%@', popping delegate", NSStringFromClass([self class]), anElementName);
    if ([delegate respondsToSelector:addObjectsSelector])
        [delegate performSelector:addObjectsSelector withObject:objects];

    [(MXMLParser *)parser popDelegate];
}

@end
