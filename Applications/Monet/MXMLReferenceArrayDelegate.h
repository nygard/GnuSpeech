//
// $Id: MXMLReferenceArrayDelegate.h,v 1.1 2004/04/22 20:42:59 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import <Foundation/NSObject.h>

@interface MXMLReferenceArrayDelegate : NSObject
{
    NSString *childElementName;
    NSString *referenceAttribute;
    id delegate;
    SEL addObjectSelector;

    NSMutableArray *references;
}

- (id)initWithChildElementName:(NSString *)anElementName referenceAttribute:(NSString *)anAttribute delegate:(id)aDelegate addObjectSelector:(SEL)aSelector;
- (void)dealloc;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
