//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import <Foundation/NSObject.h>

@interface MXMLPCDataDelegate : NSObject
{
    NSString *elementName;
    id delegate;
    SEL setSelector;

    NSMutableString *string;
}

- (id)initWithElementName:(NSString *)anElementName delegate:(id)aDelegate setSelector:(SEL)aSetSelector;
- (void)dealloc;

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)aString;

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
