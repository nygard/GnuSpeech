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
//  MMTransition.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/NSObject.h>
#import "GSXMLFunctions.h" // To get MMPhoneType

@class MonetList, MMEquation, MMPoint, NamedList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@interface MMTransition : NSObject
{
    NamedList *nonretained_group;

    NSString *name;
    NSString *comment;
    MMPhoneType type;
    NSMutableArray *points; // Of MMSlopeRatios and/or MMPoints
}

- (id)init;
- (id)initWithName:(NSString *)newName;
- (void)dealloc;

- (void)addInitialPoint;

- (NamedList *)group;
- (void)setGroup:(NamedList *)newGroup;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (NSString *)comment;
- (void)setComment:(NSString *)newComment;
- (BOOL)hasComment;

- (NSMutableArray *)points;
- (void)setPoints:(NSMutableArray *)newList;
- (void)addPoint:(id)newPoint;

- (BOOL)isTimeInSlopeRatio:(double)aTime;
- (void)insertPoint:(MMPoint *)aPoint;

- (int)type;
- (void)setType:(int)type;

- (BOOL)isEquationUsed:(MMEquation *)anEquation;
- (void)findEquation:(MMEquation *)anEquation andPutIn:(MonetList *)aList;

- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

- (NSString *)transitionPath;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
