//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "NSXMLDocument.h"

#import "NSString-Extensions.h"
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

- (void)setRootElement:(NSXMLNode *)newRootElement;
{
    if (newRootElement == _rootElement)
        return;

    [_rootElement release];
    _rootElement = [newRootElement retain];
}

- (NSXMLDocument *)rootDocument;
{
    return self;
}

- (void)_appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendString:@"<?xml version='1.0' encoding='utf-8'?>\n"];

    NSLog(@"%s, rootElement: %p", _cmd, _rootElement);
    [_rootElement _appendXMLToString:resultString level:0];
}

@end
