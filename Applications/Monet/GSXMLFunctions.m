#import "GSXMLFunctions.h"

#import <Foundation/Foundation.h>
#import "NSCharacterSet-Extensions.h"
#import "NSScanner-Extensions.h"

NSString *GSXMLAttributeString(NSString *aString, BOOL isSingleQuoted)
{
    // TODO (2004-03-05): Do stuff necessary to ensure we generate well-formed XML
    return aString;
}

NSString *GSXMLCharacterData(NSString *aString)
{
    NSScanner *scanner;
    NSString *str;
    NSMutableString *result;
    NSCharacterSet *minimumXMLEntityCharacterSet;

    minimumXMLEntityCharacterSet = [NSCharacterSet minimumXMLEntityCharacterSet];
    result = [NSMutableString string];

    scanner = [[NSScanner alloc] initWithString:aString];
    [scanner setCharactersToBeSkipped:nil]; // Keep whitespace
    do {
        if ([scanner scanUpToCharactersFromSet:minimumXMLEntityCharacterSet intoString:&str] == YES)
            [result appendString:str];
        if ([scanner scanCharacterFromSet:minimumXMLEntityCharacterSet intoString:&str] == YES) {
            if ([str isEqual:@"&"] == YES)
                [result appendString:@"&amp;"];
            else if ([str isEqual:@"<"] == YES)
                [result appendString:@"&lt;"];
        }
    } while ([scanner isAtEnd] == NO);

    [scanner release];
    // TODO (2004-03-05): Create entities for characters that can't be represented in the target encoding

    return result;
}

NSString *GSXMLBoolAttributeString(BOOL aFlag)
{
    if (aFlag == YES)
        return @"yes";

    return @"no";
}
