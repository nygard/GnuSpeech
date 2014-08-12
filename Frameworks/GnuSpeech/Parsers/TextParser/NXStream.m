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
    NSMutableData *_buffer;
    long _position;
}

- (id)init;
{
    return [self initWithCapacity:NX_DEFAULT_SIZE];
}

- (id)initWithCapacity:(NSUInteger)capacity;
{
    if ((self =	[super init])) {
        _buffer = [[NSMutableData alloc] initWithCapacity:capacity];
        _position = 0;
    }

    return self;
}

- (NSUInteger)length;
{
    return [_buffer length];
}

- (void *)mutableBytes;
{
    return [_buffer mutableBytes];
}

- (void)putChar:(char)ch;
{
    if (_position == [_buffer length]) {
        [_buffer appendBytes:&ch length:1];
    } else {
        [_buffer replaceBytesInRange:NSMakeRange(_position, 1) withBytes:&ch];
    }

    _position++;
}

- (int)getChar;
{
    if (_position == [_buffer length])
        return EOF;
    int ch;
    [_buffer getBytes:&ch range:NSMakeRange(_position++, 1)];
    return ch;
}

- (void)ungetChar;
{
    _position--;
}

- (long)position;
{
    return _position;
}

- (BOOL)seekWithOffset:(long)offset fromPosition:(int)whence;
{
    long streamLength = [_buffer length];
    long newPosition;

    if (whence == NX_FROMSTART) {  // from beginning

        newPosition = offset;

    } else if (whence == NX_FROMCURRENT) {  // from current

        newPosition = _position + offset;

    } else if (whence == NX_FROMEND) {  // from end

        newPosition = streamLength + offset;

    } else {
        NSLog(@"%s: Cannot seek to offset.", __PRETTY_FUNCTION__);

        return NO;
    }

    if (newPosition > streamLength)
        _position = streamLength;
    else if (newPosition < 0)
        _position = 0;
    else
        _position = newPosition;

    return YES;
}

- (BOOL)atEOS;
{
    if (_position == [_buffer length])
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
    range.location = _position;
    range.length = buflen;

    if ([self atEOS]) {

        [_buffer appendBytes:buf length:buflen];

    } else {

        NSUInteger streamBufferLength = [_buffer length];
        if (_position > (int)streamBufferLength - (int)range.length) {  // range to write is beyond string bounds; note necessary casts to (int)

            range.length = streamBufferLength - _position;  // adjust range to be within stream buffer bounds
            [_buffer replaceBytesInRange:range withBytes:buf length:buflen];
            
        } else {  // range to write is within string bounds; replace characters in range
            
            [_buffer replaceBytesInRange:range withBytes:buf];
        }
    }
    
    _position += buflen;
    
    free(buf);
}


@end
