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
