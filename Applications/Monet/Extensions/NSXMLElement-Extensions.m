//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "NSXMLElement-Extensions.h"

@interface NSObject(foo)
- (id)loadFromXMLElement:(NSXMLElement *)element context:(id)context;
@end

@implementation NSXMLElement (Extensions)

- (NSArray *)loadChildrenNamed:(NSString *)elementName class:(Class)childElementClass context:(id)context;
{
    unsigned int count, index;
    NSArray *children;
    NSMutableArray *result;
    id object;

    result = [NSMutableArray array];

    children = [self elementsForName:elementName];
    count = [children count];
    for (index = 0; index < count; index++) {
        object = [[childElementClass alloc] init];
        [object loadFromXMLElement:[children objectAtIndex:index] context:context];
        [result addObject:object];
        [object release];
    }

    return result;
}

- (NSDictionary *)loadChildrenNamed:(NSString *)elementName class:(Class)childElementClass keyAttributeName:(NSString *)keyAttributeName context:(id)context;
{
    unsigned int count, index;
    NSArray *children;
    NSMutableDictionary *result;
    id object;

    result = [NSMutableDictionary dictionary];

    children = [self elementsForName:elementName];
    count = [children count];
    for (index = 0; index < count; index++) {
        NSXMLElement *childElement;

        childElement = [children objectAtIndex:index];
        object = [[childElementClass alloc] init];
        [object loadFromXMLElement:childElement context:context];
        [result setObject:object forKey:[[childElement attributeForName:keyAttributeName] stringValue]];
        [object release];
    }

    return result;
}

@end
