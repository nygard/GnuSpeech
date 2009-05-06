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
//  NXStream.h
//  GnuSpeech
//
//  Created by Dalmazio on 04/05/09.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

#import "NXStream.h"

#define NX_DEFAULT_SIZE	1024

@implementation NXStream

- (id)init;
{
	return [self initWithCapacity:NX_DEFAULT_SIZE];
}

- (id)initWithCapacity:(NSUInteger)capacity;
{
	[super init];
	
	streamBuffer = [[[NSMutableString alloc] initWithCapacity:capacity] retain];
	streamPosition = 0;
	
	return self;
}

- (void)dealloc;
{
	[streamBuffer release];
    [super dealloc];
}

- (NSMutableString *)buffer;
{
	return streamBuffer;
}

- (NSUInteger)length;
{
	return [streamBuffer length];
}

- (const char *)cStringUsingEncoding:(NSStringEncoding)encoding;
{
	return [streamBuffer cStringUsingEncoding:encoding];
}

- (const char *)cString;
{
	return [streamBuffer cStringUsingEncoding:NSASCIIStringEncoding];
}

- (int)putChar:(char)c;
{
	char buf[2];
	buf[0] = c;
	buf[1] = '\0';
	
	NSRange range;
	range.location = streamPosition;
	range.length = 1;

	if (streamPosition == [streamBuffer length])
		[streamBuffer appendString:[NSString stringWithCString:buf encoding:NSASCIIStringEncoding]];
	else
		[streamBuffer replaceCharactersInRange:range 
									withString:[NSString stringWithCString:buf encoding:NSASCIIStringEncoding]];
	
	streamPosition++;

	return (int)c;  // make it behave similar to the stdio *putc() functions 
}

- (int)getChar;
{
	if (streamPosition == [streamBuffer length])
		return EOF;
	return (int)[streamBuffer characterAtIndex:streamPosition++];
}

- (void)ungetChar;
{
	streamPosition--;
}

- (long)tell;
{
	return streamPosition;
}

- (BOOL)seekWithOffset:(long)offset fromPosition:(int)whence;
{
	long streamLength = [streamBuffer length];
	long newPosition;

	if (whence == NX_FROMSTART) {  // from beginning
		
		newPosition = offset;
				
	} else if (whence == NX_FROMCURRENT) {  // from current
		
		newPosition = streamPosition + offset;
				
	} else if (whence == NX_FROMEND) {  // from end
		
		newPosition = streamLength + offset;
				
	} else {
		
		return NO;
	}
	
	if (newPosition > streamLength)
		streamPosition = streamLength;
	else if (newPosition < 0)
		streamPosition = 0;
	else 
		streamPosition = newPosition;
	
	return YES;
}

- (BOOL)atEOS;
{
	if (streamPosition == [streamBuffer length])
		return YES;
	return NO;
}

- (void)printf:(const char *)format, ...;
{
	va_list args;
	va_start(args, format);	
	[self vprintf:format argumentList:args];	
	va_end(args);	
}


- (void)vprintf:(const char *)format argumentList:(va_list)args;
{
	char * buf;	

	if (vasprintf(&buf, format, args) == -1) {
		NSLog(@"printf: Sufficient space could not be allocated.");
		return;
	}
	
	int buflen = strlen(buf);

	NSRange range;
	range.location = streamPosition;
	range.length = buflen;
			
	if ([self atEOS]) {
		
		[streamBuffer appendString:[NSString stringWithCString:buf encoding:NSASCIIStringEncoding]];
		
	} else {
		
		int streamBufferLength = [streamBuffer length];
		if (streamPosition > (int)streamBufferLength - (int)range.length) {  // range to write is beyond string bounds; note necessary casts to (int)
		
			range.length = streamBufferLength - streamPosition;  // adjust range to be within stream buffer bounds
			[streamBuffer replaceCharactersInRange:range 
										withString:[NSString stringWithCString:buf encoding:NSASCIIStringEncoding]];		
		
		} else {  // range to write is within string bounds; replace characters in range
		
			[streamBuffer replaceCharactersInRange:range 
										withString:[NSString stringWithCString:buf encoding:NSASCIIStringEncoding]];
		}
	}
	
	streamPosition += buflen;
	
	free(buf);
}


@end
