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
//  MXMLReferenceArrayDelegate.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "MXMLReferenceArrayDelegate.h"

#import <Foundation/Foundation.h>
#import "MXMLParser.h"

@implementation MXMLReferenceArrayDelegate

- (id)initWithChildElementName:(NSString *)anElementName referenceAttribute:(NSString *)anAttribute delegate:(id)aDelegate addObjectSelector:(SEL)aSelector;
{
    if ([super init] == nil)
        return nil;

    childElementName = [anElementName retain];
    referenceAttribute = [anAttribute retain];
    delegate = [aDelegate retain];
    addObjectSelector = aSelector;
    references = [[NSMutableArray alloc] init];

    return self;
}

- (void)dealloc;
{
    [childElementName release];
    [referenceAttribute release];
    [delegate release];
    [references release];

    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([anElementName isEqualToString:childElementName]) {
        id referenceID;

        referenceID = [attributeDict objectForKey:referenceAttribute];
        if (referenceID != nil)
            [references addObject:referenceID];
        [(MXMLParser *)parser skipTree];
    } else {
        NSLog(@"Warning: %@: skipping element: %@", NSStringFromClass([self class]), anElementName);
        [(MXMLParser *)parser skipTree];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    //NSLog(@"%@: closing element: '%@', popping delegate", NSStringFromClass([self class]), anElementName);
    if ([delegate respondsToSelector:addObjectSelector]) {
        unsigned int count, index;

        count = [references count];
        //NSLog(@"Adding %d references to %@ with selector %s", count, delegate, addObjectSelector);
        for (index = 0; index < count; index++)
            [delegate performSelector:addObjectSelector withObject:[references objectAtIndex:index]];
    }

    [(MXMLParser *)parser popDelegate];
}

@end
