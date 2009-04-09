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
//  MXMLParser.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "MXMLParser.h"

#import <Foundation/Foundation.h>
#import "MXMLIgnoreTreeDelegate.h"

@implementation MXMLParser

- (id)initWithData:(NSData *)data;
{
    if ([super initWithData:data] == nil)
        return nil;

    delegateStack = [[NSMutableArray alloc] init];

    return self;
}

- (void)dealloc;
{
    [delegateStack release];
    [context release];

    [super dealloc];
}

- (id)context;
{
    return context;
}

- (void)setContext:(id)newContext;
{
    if (newContext == context)
        return;

    [context release];
    context = [newContext retain];
}

- (void)pushDelegate:(id)newDelegate;
{
    [delegateStack addObject:newDelegate];
    [self setDelegate:newDelegate];
}

- (void)popDelegate;
{
    // TODO (2004-04-21): I'm a little worried about this object retaining the delegate...
    if ([delegateStack count] > 0)
        [delegateStack removeLastObject];

    if ([delegateStack count] > 0)
        [self setDelegate:[delegateStack lastObject]];
    else
        [self setDelegate:nil];
}

- (void)skipTree;
{
    MXMLIgnoreTreeDelegate *ignoreTreeDelegate;

    ignoreTreeDelegate = [[MXMLIgnoreTreeDelegate alloc] init];
    [self pushDelegate:ignoreTreeDelegate];
    [ignoreTreeDelegate release];
}

@end
