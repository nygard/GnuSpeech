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
//  MMDisplayParameter.h
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.3
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/NSObject.h>

@class MMParameter;

@interface MMDisplayParameter : NSObject
{
    MMParameter *parameter;
    BOOL isSpecial;
    int tag;
    BOOL shouldDisplay;
}

- (id)initWithParameter:(MMParameter *)aParameter;
- (void)dealloc;

- (MMParameter *)parameter;

- (BOOL)isSpecial;
- (void)setIsSpecial:(BOOL)newFlag;

- (int)tag;
- (void)setTag:(int)newTag;

- (BOOL)shouldDisplay;
- (void)setShouldDisplay:(BOOL)newFlag;
- (void)toggleShouldDisplay;

- (NSString *)name;
- (NSString *)label;

@end
