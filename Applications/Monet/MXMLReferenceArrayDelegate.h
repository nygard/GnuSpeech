//
// $Id: MXMLReferenceArrayDelegate.h,v 1.1 2004/04/22 20:42:59 nygard Exp $
//

//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import <Foundation/NSObject.h>

@interface MXMLReferenceArrayDelegate : NSObject
{
    NSString *childElementName;
    NSString *referenceAttribute;
    id delegate;
    SEL addObjectSelector;

    NSMutableArray *references;
}

// TODO (2004-05-16): Change this to referenceAttributeName:, to be consistent
- (id)initWithChildElementName:(NSString *)anElementName referenceAttribute:(NSString *)anAttribute delegate:(id)aDelegate addObjectSelector:(SEL)aSelector;
- (void)dealloc;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
