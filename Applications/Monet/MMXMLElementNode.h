//
// $Id: MMXMLElementNode.h,v 1.2 2004/04/22 01:02:21 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "MMXMLNode.h"

@interface MMXMLElementNode : MMXMLNode
{
    NSString *name;
    NSMutableDictionary *attributes;
}

- (id)init;
- (void)dealloc;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (NSDictionary *)attributes;
- (void)addAttributeName:(NSString *)attributeName value:(NSString *)attributeValue;
- (NSString *)attributeWithName:(NSString *)attributeName;

- (NSString *)description;

@end
