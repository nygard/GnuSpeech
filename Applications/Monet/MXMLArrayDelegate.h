//
// $Id: MXMLArrayDelegate.h,v 1.1 2004/04/22 17:48:10 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@interface MXMLArrayDelegate : NSObject
{
    NSString *childElementName;
    NSMutableArray *objects;
    Class objectClass;
}

- (id)initWithChildElementName:(NSString *)childElementName class:(Class)aClass;
- (void)dealloc;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
