////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.
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
//  This file is part of STAppKit, a framework of AppKit extensions.
//  Copyright (C) 2004 Steve Nygard.  All rights reserved.
//
//  NSColor-STExtensions.m
//  Monet
//
//  Created by Steve Nygard in 2004
//
//  Version: 0.9.4
//
////////////////////////////////////////////////////////////////////////////////

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
