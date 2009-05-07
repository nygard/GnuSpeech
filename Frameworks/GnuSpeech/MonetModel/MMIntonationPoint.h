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
//  MMIntonationPoint.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h> // To get NSTimeInterval
#import <Foundation/NSXMLParser.h>

@class NSMutableString;
@class EventList;

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

// TODO (2004-08-09): absoluteTime is derived from offsetTime and beatTime.  And beatTime is derived from ruleIndex and eventList.

@interface MMIntonationPoint : NSObject
{
    EventList *nonretained_eventList;

    double semitone; // Value of the point in semitones
    double offsetTime; // Points are timed wrt a beat + this offset
    double slope;  // Slope of point

    int ruleIndex; // Index of the rule for the phone which is the focus of this point
}

- (id)init;

- (EventList *)eventList;
- (void)setEventList:(EventList *)newEventList;

- (double)semitone;
- (void)setSemitone:(double)newSemitone;

- (double)offsetTime;
- (void)setOffsetTime:(double)newOffsetTime;

- (double)slope;
- (void)setSlope:(double)newSlope;

- (int)ruleIndex;
- (void)setRuleIndex:(int)newRuleIndex;

- (double)absoluteTime;
- (double)beatTime;

- (double)semitoneInHertz;
- (void)setSemitoneInHertz:(double)newHertzValue;

- (void)incrementSemitone;
- (void)decrementSemitone;

- (void)incrementRuleIndex;
- (void)decrementRuleIndex;

- (NSComparisonResult)compareByAscendingAbsoluteTime:(MMIntonationPoint *)otherIntonationPoint;

// XML - Archiving
- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

// Debugging
- (NSString *)description;

@end
