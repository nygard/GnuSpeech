//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import "MXMLArrayDelegate.h"

#import "MXMLParser.h"

@implementation MXMLArrayDelegate
{
    NSMutableDictionary *classesByChildElementName;
    id delegate;
    SEL addObjectSelector;
}

- (id)initWithChildElementName:(NSString *)anElementName class:(Class)aClass delegate:(id)aDelegate addObjectSelector:(SEL)aSelector;
{
    NSDictionary *mapping = [NSDictionary dictionaryWithObject:aClass forKey:anElementName];
    return [self initWithChildElementToClassMapping:mapping delegate:aDelegate addObjectSelector:aSelector];
}

- (id)initWithChildElementToClassMapping:(NSDictionary *)aMapping delegate:(id)aDelegate addObjectSelector:(SEL)aSelector;
{
    if ((self = [super init])) {
        classesByChildElementName = [[NSMutableDictionary alloc] init];
        [classesByChildElementName addEntriesFromDictionary:aMapping];
        delegate = [aDelegate retain];
        addObjectSelector = aSelector;
    }

    return self;
}

- (void)dealloc;
{
    [classesByChildElementName release];
    [delegate release];

    [super dealloc];
}

#pragma mark -

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([classesByChildElementName objectForKey:anElementName] != nil) {
        Class objectClass;
        id newObject;

        objectClass = [classesByChildElementName objectForKey:anElementName];
        newObject = [objectClass objectWithXMLAttributes:attributeDict context:[(MXMLParser *)parser context]];
        //NSLog(@"newObject: %@", newObject);
        if ([delegate respondsToSelector:addObjectSelector]) {
            [delegate performSelector:addObjectSelector withObject:newObject];
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
    [(MXMLParser *)parser popDelegate];
}

@end
