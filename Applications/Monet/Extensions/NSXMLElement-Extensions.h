//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSXMLElement.h>

@interface NSXMLElement (Extensions)

- (NSArray *)loadChildrenNamed:(NSString *)elementName class:(Class)childElementClass context:(id)context;
- (NSDictionary *)loadChildrenNamed:(NSString *)elementName class:(Class)childElementClass keyAttributeName:(NSString *)keyAttributeName context:(id)context;

@end
