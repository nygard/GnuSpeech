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
//  MUnarchiver.m
//  GnuSpeech
//
//  Created by Steve Nygard in 2004
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "MUnarchiver.h"

#import <Foundation/Foundation.h>

@implementation MUnarchiver

- (void)dealloc;
{
    [userInfo release];

    [super dealloc];
}

- (id)userInfo;
{
    return userInfo;
}

- (void)setUserInfo:(id)newUserInfo;
{
    if (newUserInfo == userInfo)
        return;

    [userInfo release];
    userInfo = [newUserInfo retain];
}

@end
