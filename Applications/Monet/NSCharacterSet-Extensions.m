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

@end
