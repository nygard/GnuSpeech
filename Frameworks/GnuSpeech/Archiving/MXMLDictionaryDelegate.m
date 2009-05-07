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
//  MXMLDictionaryDelegate.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004
//
//  Version: 0.9
//
////////////////////////////////////////////////////////////////////////////////

#import "MXMLDictionaryDelegate.h"

#import <Foundation/Foundation.h>
#import "MXMLParser.h"

@implementation MXMLDictionaryDelegate

- (id)initWithChildElementName:(NSString *)anElementName class:(Class)aClass keyAttributeName:(NSString *)anAttributeName delegate:(id)aDelegate addObjectsSelector:(SEL)aSelector;
{
    if ([super init] == nil)
        return nil;

    childElementName = [anElementName retain];
    objectClass = aClass;
    keyAttributeName = [anAttributeName retain];
    delegate = [aDelegate retain];
    addObjectsSelector = aSelector;
    objects = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)dealloc;
{
    [childElementName release];
    [keyAttributeName release];
    [delegate release];
    [objects release];

    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([anElementName isEqualToString:childElementName]) {
        id newObject;
        NSString *key;

        newObject = [objectClass objectWithXMLAttributes:attributeDict context:[(MXMLParser *)parser context]];
        key = [attributeDict objectForKey:keyAttributeName];
        //NSLog(@"newObject: %@, key: %@", newObject, key);
        if (key == nil) {
            NSLog(@"Warning: key attribute (%@) not set for element: %@", keyAttributeName, anElementName);
        } else {
            if ([objects objectForKey:key] != nil)
                NSLog(@"Warning: already have an object for key: %@, replacing", key);

            [objects setObject:newObject forKey:key];
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
    if ([delegate respondsToSelector:addObjectsSelector])
        [delegate performSelector:addObjectsSelector withObject:objects];

    [(MXMLParser *)parser popDelegate];
}

@end
