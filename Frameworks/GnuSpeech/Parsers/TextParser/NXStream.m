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

#import "NXStream.h"

#define NX_DEFAULT_SIZE	1024

@implementation NXStream
{
    NSMutableData *_streamBuffer;
    long _streamPosition;
}

- (id)init;
{
    return [self initWithCapacity:NX_DEFAULT_SIZE];
}

- (id)initWithCapacity:(NSUInteger)capacity;
{
    if ((self =	[super init])) {
        _streamBuffer = [[NSMutableData alloc] initWithCapacity:capacity];
        _streamPosition = 0;
    }

    return self;
}

- (NSUInteger)length;
{
    return [_streamBuffer length];
}

- (void *)mutableBytes;
{
    return [_streamBuffer mutableBytes];
}

- (int)putChar:(char)c;
{
    char buf[2];
    buf[0] = c;
    buf[1] = '\0';

    NSRange range;
    range.location = _streamPosition;
    range.length = 1;

    if (_streamPosition == [_streamBuffer length]) {
        [_streamBuffer appendBytes:buf length:1];
    } else {
        [_streamBuffer replaceBytesInRange:range withBytes:buf];
    }

    _streamPosition++;

    return (int)c;  // make it behave similar to the stdio *putc() functions
}

- (int)getChar;
{
    if (_streamPosition == [_streamBuffer length])
        return EOF;
    int ch;
    [_streamBuffer getBytes:&ch range:NSMakeRange(_streamPosition++, 1)];
    return ch;
}

- (void)ungetChar;
{
    _streamPosition--;
}

- (long)tell;
{
    return _streamPosition;
}

- (BOOL)seekWithOffset:(long)offset fromPosition:(int)whence;
{
    long streamLength = [_streamBuffer length];
    long newPosition;

    if (whence == NX_FROMSTART) {  // from beginning

        newPosition = offset;

    } else if (whence == NX_FROMCURRENT) {  // from current

        newPosition = _streamPosition + offset;

    } else if (whence == NX_FROMEND) {  // from end

        newPosition = streamLength + offset;

    } else {
        NSLog(@"%s: Cannot seek to offset.", __PRETTY_FUNCTION__);

        return NO;
    }

    if (newPosition > streamLength)
        _streamPosition = streamLength;
    else if (newPosition < 0)
        _streamPosition = 0;
    else
        _streamPosition = newPosition;

    return YES;
}

- (BOOL)atEOS;
{
    if (_streamPosition == [_streamBuffer length])
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
    char *buf;

    if (vasprintf(&buf, format, args) == -1) {
        NSLog(@"printf: Sufficient space could not be allocated.");
        return;
    }

    long buflen = strlen(buf);

    NSRange range;
    range.location = _streamPosition;
    range.length = buflen;

    if ([self atEOS]) {

        [_streamBuffer appendBytes:buf length:buflen];

    } else {

        NSUInteger streamBufferLength = [_streamBuffer length];
        if (_streamPosition > (int)streamBufferLength - (int)range.length) {  // range to write is beyond string bounds; note necessary casts to (int)

            range.length = streamBufferLength - _streamPosition;  // adjust range to be within stream buffer bounds
            [_streamBuffer replaceBytesInRange:range withBytes:buf length:buflen];
            
        } else {  // range to write is within string bounds; replace characters in range
            
            [_streamBuffer replaceBytesInRange:range withBytes:buf];
        }
    }
    
    _streamPosition += buflen;
    
    free(buf);
}


@end
