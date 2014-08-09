//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import "MXMLStringArrayDelegate.h"

#import "MXMLParser.h"
#import "MXMLPCDataDelegate.h"

@implementation MXMLStringArrayDelegate
{
    NSString *childElementName;
    id delegate;
    SEL addObjectSelector;
}

- (id)initWithChildElementName:(NSString *)anElementName delegate:(id)aDelegate addObjectSelector:(SEL)aSelector;
{
    if ((self = [super init])) {
        childElementName = anElementName;
        delegate = aDelegate;
        addObjectSelector = aSelector;
    }

    return self;
}

#pragma mark -

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([anElementName isEqualToString:childElementName] == YES) {
        MXMLPCDataDelegate *newDelegate;

        newDelegate = [[MXMLPCDataDelegate alloc] initWithElementName:childElementName delegate:delegate setSelector:addObjectSelector];
        [(MXMLParser *)parser pushDelegate:newDelegate];
    } else {
        NSLog(@"Warning: %@: skipping element: %@", NSStringFromClass([self class]), anElementName);
        [(MXMLParser *)parser skipTree];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    //NSLog(@"%@: closing element: '%@', popping delegate", NSStringFromClass([self class]), anElementName);
    [(MXMLParser *)parser popDelegate];
}

@end
