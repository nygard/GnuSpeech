//  This file is part of STAppKit, a framework of AppKit extensions.
//  Copyright (C) 2004-2012 Steve Nygard.  All rights reserved.

#import "NSColor-STExtensions.h"

#import <AppKit/AppKit.h>

@implementation NSColor (STExtensions)

+ (NSColor *)lightBlueColor;
{
    return [NSColor colorWithCalibratedRed:(165.0 / 255.0) green:(211.0 / 255.0) blue:(255.0 / 255.0) alpha:1.0];
}

+ (NSColor *)lightPinkColor;
{
    return [NSColor colorWithCalibratedRed:(255.0 / 255.0) green:(184.0 / 255.0) blue:(209.0 / 255.0) alpha:1.0];
}

+ (NSColor *)lighterGrayColor;
{
    return [NSColor colorWithCalibratedWhite:0.9 alpha:1.0];
}

@end
