//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "NSXMLElement.h"

@implementation NSXMLElement

- (id)initWithName:(NSString *)name;
{
    if ([super initWithKind:NSXMLElementKind] == nil)
        return nil;

    _name = [name retain];
    _attributes = [[NSMutableArray alloc] init];
    _children = [[NSMutableArray alloc] init];

    return self;
}

- (void)dealloc;
{
    [_name release];
    [_attributes release];
    [_children release];

    [super dealloc];
}

- (id)children;
{
    return _children;
}

- (NSXMLNode *)attributeForName:(NSString *)name;
{
    return nil;
}

- (NSString *)name;
{
    return _name;
}

- (NSArray *)elementsForName:(NSString *)name;
{
    return nil;
}

@end
