////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
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
//  MMSlope.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "MMSlope.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MXMLParser.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@implementation MMSlope

- (id)init;
{
    if ([super init] == nil)
        return nil;

    slope = 0.0;
    displayTime = 0;

    return self;
}

- (double)slope;
{
    return slope;
}

- (void)setSlope:(double)newSlope;
{
    slope = newSlope;
}

- (double)displayTime;
{
    return displayTime;
}

- (void)setDisplayTime:(double)newTime;
{
    displayTime = newTime;
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValueOfObjCType:@encode(double) at:&slope];
    //NSLog(@"slope: %g", slope);
    displayTime = 0;

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: slope: %g, displayTime: %g",
                     NSStringFromClass([self class]), self, slope, displayTime];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<slope slope=\"%g\" display-time=\"%g\"/>\n", slope, displayTime];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    NSString *str;

    if ([self init] == nil)
        return nil;

    str = [attributes objectForKey:@"slope"];
    if (str != nil)
        [self setSlope:[str doubleValue]];

    str = [attributes objectForKey:@"display-time"];
    if (str == nil)
        [self setDisplayTime:[str doubleValue]];

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    NSLog(@"%@, Unknown element: '%@', skipping", [self shortDescription], elementName);
    [(MXMLParser *)parser skipTree];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    [(MXMLParser *)parser popDelegate];
}

@end
