//  This file is part of SNFoundation, a personal collection of Foundation extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

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

+ (NSNumberFormatter *)defaultNumberFormatter2;
{
    static NSNumberFormatter *instance = nil;

    if (instance == nil) {
        instance = [[NSNumberFormatter alloc] init];
        [instance setFormat:@"#,##0.###"];
        [instance setAttributedStringForNotANumber:nil];
    }

    return instance;
}

@end
