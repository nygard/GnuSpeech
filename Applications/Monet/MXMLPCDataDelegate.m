//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.

#import "MXMLPCDataDelegate.h"

#import <Foundation/Foundation.h>
#import "MXMLParser.h"

@implementation MXMLPCDataDelegate

// TODO (2004-04-22): Reject unused init method
// TODO (2004-04-22): Perhaps use keypaths instead of selectors.

- (id)initWithElementName:(NSString *)anElementName delegate:(id)aDelegate setSelector:(SEL)aSetSelector;
{
    if ([super init] == nil)
        return nil;

    elementName = [anElementName retain];
    delegate = [aDelegate retain];
    setSelector = aSetSelector;
    string = [[NSMutableString alloc] init];

    return self;
}

- (void)dealloc;
{
    [elementName release];
    [delegate release];
    [string release];

    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)aString;
{
    [string appendString:aString];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    if ([anElementName isEqualToString:elementName]) {
        //NSLog(@"PCData: '%@'", string);

        if ([delegate respondsToSelector:setSelector]) {
            // Make an immutable copy of the string
            [delegate performSelector:setSelector withObject:[NSString stringWithString:string]];
        } else {
            NSLog(@"%@ doesn not respond to selector: %s", delegate, setSelector);
        }

        [delegate release];
        delegate = nil;

        // Popping the delegate (this instance) will most likely deallocate us.
        [(MXMLParser *)parser popDelegate];
    }
}

@end
