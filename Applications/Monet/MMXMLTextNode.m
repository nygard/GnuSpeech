//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMXMLTextNode.h"

#import <Foundation/Foundation.h>

@implementation MMXMLTextNode

- (void)dealloc;
{
    [contents release];

    [super dealloc];
}

- (NSString *)contents;
{
    return contents;
}

- (void)setContents:(NSString *)newContents;
{
    if (newContents == contents)
        return;

    [contents release];
    contents = [newContents retain];
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: child count: %d, content: '%@'", NSStringFromClass([self class]), self, [children count], contents];
}

@end
