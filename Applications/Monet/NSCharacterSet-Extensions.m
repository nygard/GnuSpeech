//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "NSCharacterSet-Extensions.h"

#import <Foundation/Foundation.h>

@implementation NSCharacterSet (Extensions)

+ (NSCharacterSet *)generalXMLEntityCharacterSet;
{
    static NSCharacterSet *characterSet = nil;

    if (characterSet == nil)
        characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"&<>'\""] retain];

    return characterSet;
}

+ (NSCharacterSet *)phoneStringWhitespaceCharacterSet;
{
    static NSCharacterSet *characterSet = nil;

    if (characterSet == nil) {
        NSMutableCharacterSet *aSet;

        aSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
        [aSet addCharactersInString:@"_"];
        characterSet = [aSet copy];

        [aSet release];
    }

    return characterSet;
}

+ (NSCharacterSet *)phoneStringIdentifierCharacterSet;
{
    static NSCharacterSet *characterSet = nil;

    if (characterSet == nil) {
        NSMutableCharacterSet *aSet;

        aSet = [[NSCharacterSet letterCharacterSet] mutableCopy];
        [aSet addCharactersInString:@"^'#"];
        characterSet = [aSet copy];

        [aSet release];
    }

    return characterSet;
}

@end
