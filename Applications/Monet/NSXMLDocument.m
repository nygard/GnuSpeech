//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "NSXMLDocument.h"

#import "STXMLTreeBuilder.h"

@implementation NSXMLDocument

- (id)initWithData:(NSData *)data options:(unsigned int)mask error:(NSError **)error;
{
    STXMLTreeBuilder *treeBuilder;

    if ([super initWithKind:NSXMLDocumentKind] == nil)
        return nil;

    _children = [[NSMutableArray alloc] init];
    _rootElement = nil;

    treeBuilder = [[STXMLTreeBuilder alloc] init];
    [treeBuilder parseData:data intoDocument:self];
    [treeBuilder release];

    return self;
}

- (void)dealloc;
{
    [_children release];
    [_rootElement release];

    [super dealloc];
}

- (id)children;
{
    return _children;
}

- (id)DTD;
{
    return nil;
}

- (NSXMLElement *)rootElement;
{
    return _rootElement;
}

- (NSXMLDocument *)rootDocument;
{
    return self;
}

@end
