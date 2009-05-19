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
//  GSXMLFunctions.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004
//
//  Version: 0.9.1
//
////////////////////////////////////////////////////////////////////////////////

#import "GSXMLFunctions.h"

#import <Foundation/Foundation.h>
#import "NSCharacterSet-Extensions.h"
#import "NSScanner-Extensions.h"

NSString *GSXMLEscapeGeneralEntities(NSString *aString, int entityMask)
{
    NSScanner *scanner;
    NSString *str;
    NSMutableString *result;
    NSCharacterSet *generalXMLEntityCharacterSet;

    generalXMLEntityCharacterSet = [NSCharacterSet generalXMLEntityCharacterSet];
    result = [NSMutableString string];

    scanner = [[NSScanner alloc] initWithString:aString];
    [scanner setCharactersToBeSkipped:nil]; // Keep whitespace
    do {
        if ([scanner scanUpToCharactersFromSet:generalXMLEntityCharacterSet intoString:&str] == YES)
            [result appendString:str];
        if ([scanner scanCharacterFromSet:generalXMLEntityCharacterSet intoString:&str] == YES) {
            if ((entityMask & GSXMLEntityMaskAmpersand) && [str isEqual:@"&"] == YES)
                [result appendString:@"&amp;"];
            else if ((entityMask & GSXMLEntityMaskLessThan) && [str isEqual:@"<"] == YES)
                [result appendString:@"&lt;"];
            else if ((entityMask & GSXMLEntityMaskGreaterThan) && [str isEqual:@">"] == YES)
                [result appendString:@"&gt;"];
            else if ((entityMask & GSXMLEntityMaskSingleQuote) && [str isEqual:@"'"] == YES)
                [result appendString:@"&apos;"];
            else if ((entityMask & GSXMLEntityMaskDoubleQuote) && [str isEqual:@"\""] == YES)
                [result appendString:@"&quot;"];
            else
                [result appendString:str];
        }
    } while ([scanner isAtEnd] == NO);

    [scanner release];
    // TODO (2004-03-05): Create entities for characters that can't be represented in the target encoding

    return result;
}

NSString *GSXMLAttributeString(NSString *aString, BOOL isSingleQuoted)
{
    if (aString == nil)
        return nil;

    if (isSingleQuoted == YES)
        return GSXMLEscapeGeneralEntities(aString, GSXMLEntityMaskAmpersand|GSXMLEntityMaskSingleQuote);

    return GSXMLEscapeGeneralEntities(aString, GSXMLEntityMaskAmpersand|GSXMLEntityMaskDoubleQuote);
}

NSString *GSXMLCharacterData(NSString *aString)
{
    if (aString == nil)
        return nil;

    return GSXMLEscapeGeneralEntities(aString, GSXMLEntityMaskAmpersand|GSXMLEntityMaskLessThan);
}

NSString *GSXMLBoolAttributeString(BOOL aFlag)
{
    if (aFlag == YES)
        return @"yes";

    return @"no";
}

BOOL GSXMLBoolFromString(NSString *str)
{
    return [str isEqualToString:@"yes"];
}

// TODO (2004-04-22): Maybe these should be in another file.
NSString *MMStringFromPhoneType(MMPhoneType type)
{
    switch (type) {
      case 2: return @"diphone";
      case 3: return @"triphone";
      case 4: return @"tetraphone";
    }

    [NSException raise:NSInvalidArgumentException format:@"Unkonwn phone type: %d", type];
    return nil;
}

MMPhoneType MMPhoneTypeFromString(NSString *str)
{
    if ([str isEqualToString:@"diphone"])
        return 2;
    else if ([str isEqualToString:@"triphone"])
        return 3;
    else if ([str isEqualToString:@"tetraphone"])
        return 4;

    [NSException raise:NSInvalidArgumentException format:@"Unkonwn phone type: %@", str];
    return 0;
}
