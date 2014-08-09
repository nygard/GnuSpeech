//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import "MXMLPCDataDelegate.h"

#import "MXMLParser.h"

@implementation MXMLPCDataDelegate
{
    NSString *elementName;
    id delegate;
    SEL setSelector;
    
    NSMutableString *string;
}

// TODO (2004-04-22): Reject unused init method
// TODO (2004-04-22): Perhaps use keypaths instead of selectors.

- (id)initWithElementName:(NSString *)anElementName delegate:(id)aDelegate setSelector:(SEL)aSetSelector;
{
    if ((self = [super init])) {
        elementName = anElementName;
        delegate = aDelegate;
        setSelector = aSetSelector;
        string = [[NSMutableString alloc] init];
    }

    return self;
}

#pragma mark -

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
            NSLog(@"%@ does not respond to selector: %@", delegate, NSStringFromSelector(setSelector));
        }

        delegate = nil;

        // Popping the delegate (this instance) will most likely deallocate us.
        [(MXMLParser *)parser popDelegate];
    }
}

@end
