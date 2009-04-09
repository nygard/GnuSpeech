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
//  MMTarget.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "MMTarget.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MXMLParser.h"

@implementation MMTarget

- (id)init;
{
    if ([super init] == nil)
        return nil;

    isDefault = YES;
    value = 0.0;

    return self;
}

- (id)initWithValue:(double)newValue isDefault:(BOOL)shouldBeDefault;
{
    if ([self init] == nil)
        return nil;

    [self setValue:newValue];
    [self setIsDefault:shouldBeDefault];

    return self;
}

- (double)value;
{
    return value;
}

- (void)setValue:(double)newValue;
{
    value = newValue;
}

- (BOOL)isDefault;
{
    return isDefault;
}

- (void)setIsDefault:(BOOL)newFlag;
{
    isDefault = newFlag;
}

- (void)setValue:(double)newValue isDefault:(BOOL)shouldBeDefault;
{
    [self setValue:newValue];
    [self setIsDefault:shouldBeDefault];
}

- (void)changeDefaultValueFrom:(double)oldDefault to:(double)newDefault;
{
    if (value == oldDefault) {
        value = newDefault;
        isDefault = YES;
    }
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    int defaultInt;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"id", &defaultInt, &value];
    isDefault = defaultInt;

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: isDefault: %d, value: %g", NSStringFromClass([self class]), self, isDefault, value];
}

- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<target ptr=\"%p\" value=\"%g\"/>", self, value];
    if (isDefault)
        [resultString appendString:@"<!-- default -->"];
    [resultString appendString:@"\n"];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    NSString *str;

    if ([self init] == nil)
        return nil;

    str = [attributes objectForKey:@"value"];
    if (str != nil)
        [self setValue:[str doubleValue]];

    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    NSLog(@"%@: skipping element: %@", NSStringFromClass([self class]), anElementName);
    [(MXMLParser *)parser skipTree];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)anElementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    [(MXMLParser *)parser popDelegate];
}

@end
