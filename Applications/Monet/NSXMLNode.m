//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "NSXMLNode.h"

#import <Foundation/Foundation.h>

@implementation NSXMLNode

- (id)initWithKind:(NSXMLNodeKind)kind;
{
    if ([super init] == nil)
        return nil;

    _kind = kind;

    return self;
}

- (NSXMLNodeKind)kind;
{
    return _kind;
}

- (id)children;
{
    return nil;
}

- (unsigned int)childCount;
{
    return [[self children] count];
}

- (NSXMLNode *)childAtIndex:(unsigned int)index;
{
    return [[self children] objectAtIndex:index];
}

- (NSString *)stringValue;
{
    return nil;
}

- (id)objectValue;
{
    return nil;
}

- (void)setObjectValue:(id)value;
{
}

- (NSXMLDocument *)rootDocument;
{
    return [_parent rootDocument];
}

@end
