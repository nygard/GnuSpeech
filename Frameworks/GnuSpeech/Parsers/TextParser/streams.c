/*******************************************************************************
 *
 *  Copyright (c) 2009 Dalmazio Brisinda
 *
 *  Contributors: Dalmazio Brisinda
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 ******************************************************************************/

#include "streams.h"
#import "NXStream.h"

void NXGetMemoryBuffer(NXStream *stream, const char **streambuf, int *len, int *maxLen)
{
    *streambuf = [stream mutableBytes];
    if (len != NULL)    *len = (int)[stream length];
    if (maxLen != NULL) *maxLen = INT_MAX;
}

void NXVPrintf(NXStream *stream, const char *format, va_list args)
{
    [stream vprintf:format argumentList:args];
}

void NXPrintf(NXStream *stream, const char *format, ...)
{
    va_list args;
    va_start(args, format);
    [stream vprintf:format argumentList:args];
    va_end(args);
}

void NXSeek(NXStream *stream, long offset, int whence)
{
    if (![stream seekWithOffset:offset fromPosition:whence])
        NSLog(@"NXSeek(): Cannot seek to offset.");
}

void NXVLogError(const char * format, va_list args)
{
    NSLogv([NSString stringWithCString:format encoding:NSASCIIStringEncoding], args);
}

void NXLogError(const char * format, ...)
{
    va_list args;
    va_start(args, format);
    NXVLogError(format, args);
    va_end(args);
}
