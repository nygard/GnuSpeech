//
// $Id: MXMLArrayDelegate.h,v 1.3 2004/04/22 19:17:21 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@interface MXMLArrayDelegate : NSObject
{
    NSString *childElementName;
    Class objectClass;
    id delegate;
    SEL addObjectSelector;
}

- (id)initWithChildElementName:(NSString *)anElementName class:(Class)aClass delegate:(id)aDelegate addObjectSelector:(SEL)aSelector;
- (void)dealloc;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
