#import "GSXMLFunctions.h"

#import <Foundation/Foundation.h>

NSString *GSXMLAttributeString(NSString *aString, BOOL isSingleQuoted)
{
    // TODO (2004-03-05): Do stuff necessary to ensure we generate well-formed XML
    return aString;
}

NSString *GSXMLCharacterData(NSString *aString)
{
    // TODO (2004-03-05): Create entities for characters that can't be represented in the target encoding
    return aString;
}

NSString *GSXMLBoolAttributeString(BOOL aFlag)
{
    if (aFlag == YES)
        return @"yes";

    return @"no";
}
