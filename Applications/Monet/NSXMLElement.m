//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "NSXMLElement.h"
#import "NSString-Extensions.h"

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

- (void)addChild:(NSXMLNode *)child;
{
    [_children addObject:child];
}

- (void)_appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    unsigned int count, index;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<%@>\n", _name];

    count = [_children count];
    for (index = 0; index < count; index++)
        [[_children objectAtIndex:index] _appendXMLToString:resultString level:level + 1];

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</%@>\n", _name];
}

@end
