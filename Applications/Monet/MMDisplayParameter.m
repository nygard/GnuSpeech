////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
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
//  MMDisplayParameter.m
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.6
//
////////////////////////////////////////////////////////////////////////////////

#import "MMDisplayParameter.h"

#import <Foundation/Foundation.h>
#import <GnuSpeech/GnuSpeech.h>

@implementation MMDisplayParameter

- (id)initWithParameter:(MMParameter *)aParameter;
{
    if ([super init] == nil)
        return nil;

    parameter = [aParameter retain];
    isSpecial = NO;
    tag = 0;

    return self;
}

- (void)dealloc;
{
    [parameter release];

    [super dealloc];
}

- (MMParameter *)parameter;
{
    return parameter;
}

- (BOOL)isSpecial;
{
    return isSpecial;
}

- (void)setIsSpecial:(BOOL)newFlag;
{
    isSpecial = newFlag;
}

- (int)tag;
{
    return tag;
}

- (void)setTag:(int)newTag;
{
    tag = newTag;
}

- (BOOL)shouldDisplay;
{
    return shouldDisplay;
}

- (void)setShouldDisplay:(BOOL)newFlag;
{
    shouldDisplay = newFlag;
}

- (void)toggleShouldDisplay;
{
    shouldDisplay = !shouldDisplay;
}

- (NSString *)name;
{
    if (isSpecial == YES)
        return [NSString stringWithFormat:@"%@ (special)", [parameter name]];

    return [parameter name];
}

// Used in the EventList view
- (NSString *)label;
{
    if (isSpecial == YES)
        return [NSString stringWithFormat:@"%@\n(special)", [parameter name]];

    return [parameter name];
}

@end
