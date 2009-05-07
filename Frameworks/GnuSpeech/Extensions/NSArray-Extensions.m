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
//  NSArray-Extensions.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004
//
//  Version: 0.9
//
////////////////////////////////////////////////////////////////////////////////

#import "NSArray-Extensions.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

@implementation NSArray (Extensions)

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level;
{
    [self appendXMLToString:resultString elementName:elementName level:level numberCommentPrefix:nil];
}

- (void)appendXMLToString:(NSMutableString *)resultString elementName:(NSString *)elementName level:(int)level numberCommentPrefix:(NSString *)prefix;
{
    int count, index;

    count = [self count];
    if (count == 0)
        return;

    [resultString indentToLevel:level];
    [resultString appendFormat:@"<%@>\n", elementName];

    for (index = 0; index < count; index++) {
        if (prefix != nil) {
            [resultString indentToLevel:level+1];
            [resultString appendFormat:@"<!-- %@: %d -->\n", prefix, index + 1];
        }

        [[self objectAtIndex:index] appendXMLToString:resultString level:level+1];
    }

    [resultString indentToLevel:level];
    [resultString appendFormat:@"</%@>\n", elementName];
}

@end
