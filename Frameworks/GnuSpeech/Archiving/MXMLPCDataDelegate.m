////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.
//  
//  Contributors: Steve Nygard
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  This file is part of SNFoundation, a personal collection of Foundation 
//  extensions. Copyright (C) 2004 Steve Nygard.  All rights reserved.
//
//  MXMLPCDataDelegate.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

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
