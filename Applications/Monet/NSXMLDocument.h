//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "NSXMLNode.h"

@class NSXMLElement;

@interface NSXMLDocument : NSXMLNode
{
    NSMutableArray *_children;
    NSXMLElement *_rootElement;
}

- (id)initWithData:(NSData *)data options:(unsigned int)mask error:(NSError **)error;
- (void)dealloc;

- (id)children;

- (id)DTD;
- (NSXMLElement *)rootElement;

- (NSXMLDocument *)rootDocument;

@end
