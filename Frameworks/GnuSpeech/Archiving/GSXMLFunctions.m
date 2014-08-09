//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import "GSXMLFunctions.h"

#import "NSCharacterSet-Extensions.h"
#import "NSScanner-Extensions.h"

NSString *GSXMLEscapeGeneralEntities(NSString *string, GSXMLEntityMask entityMask)
{
    NSCharacterSet *generalXMLEntityCharacterSet = [NSCharacterSet generalXMLEntityCharacterSet];
    NSMutableString *result = [NSMutableString string];

    NSScanner *scanner = [[NSScanner alloc] initWithString:string];
    [scanner setCharactersToBeSkipped:nil]; // Keep whitespace
    do {
        NSString *str;
        if ([scanner scanUpToCharactersFromSet:generalXMLEntityCharacterSet intoString:&str] == YES)
            [result appendString:str];

        if ([scanner scanCharacterFromSet:generalXMLEntityCharacterSet intoString:&str] == YES) {
            if ((entityMask & GSXMLEntityMask_Ampersand)        && [str isEqual:@"&"] == YES)  [result appendString:@"&amp;"];
            else if ((entityMask & GSXMLEntityMask_LessThan)    && [str isEqual:@"<"] == YES)  [result appendString:@"&lt;"];
            else if ((entityMask & GSXMLEntityMask_GreaterThan) && [str isEqual:@">"] == YES)  [result appendString:@"&gt;"];
            else if ((entityMask & GSXMLEntityMask_SingleQuote) && [str isEqual:@"'"] == YES)  [result appendString:@"&apos;"];
            else if ((entityMask & GSXMLEntityMask_DoubleQuote) && [str isEqual:@"\""] == YES) [result appendString:@"&quot;"];
            else
                [result appendString:str];
        }
    } while ([scanner isAtEnd] == NO);

    // TODO (2004-03-05): Create entities for characters that can't be represented in the target encoding

    return result;
}

NSString *GSXMLAttributeString(NSString *string, BOOL isSingleQuoted)
{
    if (string == nil)
        return nil;

    if (isSingleQuoted)
        return GSXMLEscapeGeneralEntities(string, GSXMLEntityMask_Ampersand|GSXMLEntityMask_SingleQuote);

    return GSXMLEscapeGeneralEntities(string, GSXMLEntityMask_Ampersand|GSXMLEntityMask_DoubleQuote);
}

NSString *GSXMLCharacterData(NSString *string)
{
    if (string == nil)
        return nil;

    return GSXMLEscapeGeneralEntities(string, GSXMLEntityMask_Ampersand|GSXMLEntityMask_LessThan);
}

NSString *GSXMLBoolAttributeString(BOOL flag)
{
    if (flag)
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

    [NSException raise:NSInvalidArgumentException format:@"Unkonwn phone type: %ld", type];
    return nil;
}

MMPhoneType MMPhoneTypeFromString(NSString *str)
{
    if ([str isEqualToString:@"diphone"])         return 2;
    else if ([str isEqualToString:@"triphone"])   return 3;
    else if ([str isEqualToString:@"tetraphone"]) return 4;

    [NSException raise:NSInvalidArgumentException format:@"Unkonwn phone type: %@", str];
    return 0;
}
