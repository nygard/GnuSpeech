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
//
//  NXStream.m
//  GnuSpeech
//
//  Created by Dalmazio on 04/05/09.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

#define NX_READWRITE		0
#define NX_READONLY			1

#define NX_FROMSTART		0
#define NX_FROMCURRENT		1
#define NX_FROMEND			2

#define NX_FREEBUFFER		0
#define NX_TRUNCATEBUFFER	1

@interface NXStream : NSObject {
	NSMutableString * streamBuffer;
	long streamPosition;
}

- (id)init;
- (id)initWithCapacity:(NSUInteger)size;
- (void)dealloc;

- (NSMutableString *)buffer;
- (NSUInteger)length;
- (const char *)cString;
- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding;

- (int)putChar:(char)c;
- (int)getChar;
- (void)ungetChar;

- (long)tell;
- (BOOL)seekWithOffset:(long)offset fromPosition:(int)whence;
- (BOOL)atEOS;

- (void)vprintf:(const char *)format argumentList:(va_list)args;
- (void)printf:(const char *)format, ...;

@end
