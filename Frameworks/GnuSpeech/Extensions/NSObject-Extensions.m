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
//  This file is part of SNFoundation, a personal collection of Foundation
//  extensions. Copyright (C) 2004 Steve Nygard.  All rights reserved.
//
//  NSObject-Extensions.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "NSObject-Extensions.h"

#import <Foundation/Foundation.h>

@implementation NSObject (Extensions)

+ (id)objectWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    return [[[[self class] alloc] initWithXMLAttributes:attributes context:context] autorelease];
}

- (id)initWithXMLAttributes:(NSDictionary *)attributes context:(id)context;
{
    // This should be implemented by subclasses, and they shouldn't call this method
    NSLog(@"Warning: %s should be implemented by subclasses.");
    [self release];

    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    // Implemented so that subclasses don't need to know what their superclass is to correctly implement this method.
    // They can always call [super initWithCoder:] without needing to know if they are a direct subclass of NSObject.
    return self;
}

- (NSString *)shortDescription;
{
    return [NSString stringWithFormat:@"<%@>[%p]", NSStringFromClass([self class]), self];
}

@end
