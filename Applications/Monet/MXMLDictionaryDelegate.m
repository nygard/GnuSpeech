//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MXMLDictionaryDelegate.h"

#import <Foundation/Foundation.h>
#import "MXMLParser.h"

@implementation MXMLDictionaryDelegate

- (id)initWithChildElementName:(NSString *)anElementName class:(Class)aClass keyAttributeName:(NSString *)anAttributeName delegate:(id)aDelegate addObjectsSelector:(SEL)aSelector;
{
    if ([super init] == nil)
        return nil;

    childElementName = [anElementName retain];
    objectClass = aClass;
    keyAttributeName = [anAttributeName retain];
    delegate = [aDelegate retain];
    addObjectsSelector = aSelector;
    objects = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)dealloc;
{
    [childElementName release];
    [keyAttributeName release];
    [delegate release];
    [objects release];

    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([anElementName isEqualToString:childElementName]) {
        id newObject;
        NSString *key;

        newObject = [objectClass objectWithXMLAttributes:attributeDict context:[(MXMLParser *)parser context]];
        key = [attributeDict objectForKey:keyAttributeName];
        //NSLog(@"newObject: %@, key: %@", newObject, key);
        if (key == nil) {
            NSLog(@"Warning: key attribute (%@) not set for element: %@", keyAttributeName, anElementName);
        } else {
            if ([objects objectForKey:key] != nil)
                NSLog(@"Warning: already have an object for key: %@, replacing", key);

            [objects setObject:newObject forKey:key];
        }
        [(MXMLParser *)parser pushDelegate:newObject];
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
