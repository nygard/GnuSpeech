//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import <Foundation/NSObject.h>

@class NSXMLParser;

@interface MXMLStringArrayDelegate : NSObject
{
    NSString *childElementName;
    id delegate;
    SEL addObjectSelector;
}

- (id)initWithChildElementName:(NSString *)anElementName delegate:(id)aDelegate addObjectSelector:(SEL)aSelector;
- (void)dealloc;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
