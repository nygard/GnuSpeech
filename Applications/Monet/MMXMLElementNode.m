//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import "MMXMLElementNode.h"

#import <Foundation/Foundation.h>

@implementation MMXMLElementNode

- (id)init;
{
    if ([super init] == nil)
        return nil;

    name = nil;
    attributes = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)dealloc;
{
    [name release];
    [attributes release];

    [super dealloc];
}

- (NSString *)name;
{
    return name;
}

- (void)setName:(NSString *)newName;
{
    if (newName == name)
        return;

    [name release];
    name = [newName retain];
}

- (NSDictionary *)attributes;
{
    return attributes;
}

- (void)addAttributeName:(NSString *)attributeName value:(NSString *)attributeValue;
{
    [attributes setObject:attributeValue forKey:attributeName];
}

- (NSString *)attributeWithName:(NSString *)attributeName;
{
    return [attributes objectForKey:attributeName];
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: name: %@, child count: %d", NSStringFromClass([self class]), self, name, [children count]];
}

@end
