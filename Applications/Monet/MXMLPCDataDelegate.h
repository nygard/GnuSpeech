//
// $Id: MXMLPCDataDelegate.h,v 1.1 2004/04/22 19:00:19 nygard Exp $
//

//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

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
