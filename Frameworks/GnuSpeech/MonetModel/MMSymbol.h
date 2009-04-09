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
//  MMSymbol.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "MMNamedObject.h"

/*===========================================================================

	Author: Craig-Richard Taube-Schock
		Copyright (c) 1994, Trillium Sound Research Incorporated.
		All Rights Reserved.

=============================================================================
*/

@class NSMutableString;

@interface MMSymbol : MMNamedObject
{
    double minimum;
    double maximum;
    double defaultValue;
}

- (id)init;

- (double)minimumValue;
- (void)setMinimumValue:(double)newMinimum;

- (double)maximumValue;
- (void)setMaximumValue:(double)newMaximum;

- (double)defaultValue;
- (void)setDefaultValue:(double)newDefault;

// Archiving
- (id)initWithCoder:(NSCoder *)aDecoder;

- (NSString *)description;

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
