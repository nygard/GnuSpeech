////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2009 Dalmazio Brisinda
//
//  Contributors: Dalmazio Brisinda
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

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    NXStreamLocation_Start   = 0,
    NXStreamLocation_Current = 1,
    NXStreamLocation_End     = 2,
} NXStreamLocation;

@interface NXStream : NSObject

- (id)initWithCapacity:(NSUInteger)size;

- (NSUInteger)length;
- (void *)mutableBytes NS_RETURNS_INNER_POINTER;

- (void)putChar:(char)ch;
- (int)getChar;
- (void)ungetChar;

- (long)position;
- (BOOL)seekWithOffset:(long)offset fromPosition:(NXStreamLocation)whence;

- (void)printf:(const char *)format, ...;

@end
