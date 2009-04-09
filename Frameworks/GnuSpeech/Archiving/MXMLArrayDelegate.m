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
//  MXMLArrayDelegate.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "MXMLArrayDelegate.h"

#import <Foundation/Foundation.h>
#import "MXMLParser.h"

@implementation MXMLArrayDelegate

- (id)initWithChildElementName:(NSString *)anElementName class:(Class)aClass delegate:(id)aDelegate addObjectSelector:(SEL)aSelector;
{
    NSDictionary *mapping;

    mapping = [NSDictionary dictionaryWithObject:aClass forKey:anElementName];
    return [self initWithChildElementToClassMapping:mapping delegate:aDelegate addObjectSelector:aSelector];
}

- (id)initWithChildElementToClassMapping:(NSDictionary *)aMapping delegate:(id)aDelegate addObjectSelector:(SEL)aSelector;
{
    if ([super init] == nil)
        return nil;

    classesByChildElementName = [[NSMutableDictionary alloc] init];
    [classesByChildElementName addEntriesFromDictionary:aMapping];
    delegate = [aDelegate retain];
    addObjectSelector = aSelector;

    return self;
}

- (void)dealloc;
{
    [classesByChildElementName release];
    [delegate release];

    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([classesByChildElementName objectForKey:anElementName] != nil) {
        Class objectClass;
        id newObject;

        objectClass = [classesByChildElementName objectForKey:anElementName];
        newObject = [objectClass objectWithXMLAttributes:attributeDict context:[(MXMLParser *)parser context]];
        //NSLog(@"newObject: %@", newObject);
        if ([delegate respondsToSelector:addObjectSelector]) {
            [delegate performSelector:addObjectSelector withObject:newObject];
        }
        [(MXMLParser *)parser pushDelegate:newObject];
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
