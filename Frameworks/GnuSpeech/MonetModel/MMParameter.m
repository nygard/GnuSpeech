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
//  MMParameter.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "MMParameter.h"

#import <Foundation/Foundation.h>
#import "NSObject-Extensions.h"
#import "NSString-Extensions.h"

#import "GSXMLFunctions.h"
#import "MModel.h"

#import "MXMLParser.h"
#import "MXMLPCDataDelegate.h"

#define DEFAULT_MIN 100.0
#define DEFAULT_MAX 1000.0

@implementation MMParameter

- (id)init;
{
    if ([super init] == nil)
        return nil;

    minimum = DEFAULT_MIN;
    maximum = DEFAULT_MAX;
    defaultValue = DEFAULT_MIN;

    return self;
}

- (double)minimumValue;
{
    return minimum;
}

- (void)setMinimumValue:(double)newMinimum;
{
    minimum = newMinimum;
}

- (double)maximumValue;
{
    return maximum;
}

- (void)setMaximumValue:(double)newMaximum;
{
    maximum = newMaximum;
}

- (double)defaultValue;
{
    return defaultValue;
}

- (void)setDefaultValue:(double)newDefault;
{
    if (newDefault != defaultValue)
        [[self model] parameter:self willChangeDefaultValue:newDefault];

    defaultValue = newDefault;
}

//
// Archiving
//

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    unsigned archivedVersion;
    char *c_name, *c_comment;

    if ([super initWithCoder:aDecoder] == nil)
        return nil;

    //NSLog(@"[%p]<%@>  > %s", self, NSStringFromClass([self class]), _cmd);
    archivedVersion = [aDecoder versionForClassName:NSStringFromClass([self class])];
    //NSLog(@"aDecoder version for class %@ is: %u", NSStringFromClass([self class]), archivedVersion);

    [aDecoder decodeValuesOfObjCTypes:"**ddd", &c_name, &c_comment, &minimum, &maximum, &defaultValue];
    //NSLog(@"c_name: %s, c_comment: %s, minimum: %g, maximum: %g, defaultValue: %g", c_name, c_comment, minimum, maximum, defaultValue);

    name = [[NSString stringWithASCIICString:c_name] retain];
    comment = [[NSString stringWithASCIICString:c_comment] retain];
    free(c_name);
    free(c_comment);

    //NSLog(@"[%p]<%@> <  %s", self, NSStringFromClass([self class]), _cmd);
    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@>[%p]: name: %@, comment: %@, minimum: %g, maximum: %g, defaultValue: %g",
                     NSStringFromClass([self class]), self, name, comment, minimum, maximum, defaultValue];
}


- (void)appendXMLToString:(NSMutableString *)resultString level:(int)level;
{
    [resultString indentToLevel:level];
    [resultString appendFormat:@"<parameter name=\"%@\" minimum=\"%g\" maximum=\"%g\" default=\"%g\"",
                  GSXMLAttributeString(name, NO), minimum, maximum, defaultValue];

    if ([self hasComment] == NO) {
        [resultString appendString:@"/>\n"];
    } else {
        [resultString appendString:@">\n"];
        [resultString indentToLevel:level + 1];
        [resultString appendFormat:@"<comment>%@</comment>\n", GSXMLCharacterData(comment)];

        [resultString indentToLevel:level];
        [resultString appendString:@"</parameter>\n"];
    }
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    id value;

    if ([super initWithXMLAttributes:attributes context:context] == nil)
        return nil;

    value = [attributes objectForKey:@"minimum"];
    if (value != nil)
        [self setMinimumValue:[value doubleValue]];

    value = [attributes objectForKey:@"maximum"];
    if (value != nil)
        [self setMaximumValue:[value doubleValue]];

    value = [attributes objectForKey:@"default"];
    if (value != nil)
        [self setDefaultValue:[value doubleValue]];

    return self;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    if ([elementName isEqualToString:@"parameter"])
        [(MXMLParser *)parser popDelegate];
    else
        [NSException raise:@"Unknown close tag" format:@"Unknown closing tag (%@) in %@", elementName, NSStringFromClass([self class])];
}

@end
