//  This file is part of __APPNAME__, __SHORT_DESCRIPTION__.
//  Copyright (C) 2004 __OWNER__.  All rights reserved.

#import "NSNumberFormatter-Extensions.h"

#import <Foundation/Foundation.h>

@implementation NSNumberFormatter (Extensions)

+ (NSNumberFormatter *)defaultNumberFormatter;
{
    static NSNumberFormatter *instance = nil;

    if (instance == nil) {
        instance = [[NSNumberFormatter alloc] init];
        [instance setFormat:@"#,##0.###"];
    }

    return instance;
}

@end
