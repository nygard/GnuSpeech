//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "NSXMLNode.h"

@interface NSXMLElement : NSXMLNode
{
    NSString *_name;
    NSMutableArray *_attributes;
    NSMutableArray *_children;
}

- (id)initWithName:(NSString *)name;
- (void)dealloc;

- (id)children;

- (NSXMLNode *)attributeForName:(NSString *)name;

- (NSString *)name;

- (NSArray *)elementsForName:(NSString *)name;

- (void)addChild:(NSXMLNode *)child;

- (void)_appendXMLToString:(NSMutableString *)resultString level:(int)level;

@end
