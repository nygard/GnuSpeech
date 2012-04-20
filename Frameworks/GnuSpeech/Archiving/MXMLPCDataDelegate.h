//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import <Foundation/Foundation.h>

@interface MXMLPCDataDelegate : NSObject

- (id)initWithElementName:(NSString *)anElementName delegate:(id)aDelegate setSelector:(SEL)aSetSelector;
- (void)dealloc;

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)aString;

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
