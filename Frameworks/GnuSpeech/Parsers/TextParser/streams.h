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
 *******************************************************************************
 *
 *  streams.h
 *  GnuSpeech
 *
 *  Created by Dalmazio on 04/05/09.
 *
 *  Version: 0.9.1
 *
 ******************************************************************************/

#import "NXStream.h"

extern NXStream * NXOpenMemory(const char * address, int size, int mode);
extern void NXCloseMemory(NXStream * stream, int option);
extern void NXGetMemoryBuffer(NXStream * stream, const char ** streambuf, int * len, int * maxLen);

extern int NXPutc(NXStream * stream, char c);
extern int NXGetc(NXStream * stream);
extern void NXUngetc(NXStream * stream);

extern void NXVPrintf(NXStream * stream, const char * format, va_list args);
extern void NXPrintf(NXStream * stream, const char * format, ...);

extern void NXSeek(NXStream * stream, long offset, int whence);
extern long NXTell(NXStream * stream);
extern BOOL NXAtEOS(NXStream *stream);

extern void NXVLogError(const char * format, va_list args);
extern void NXLogError(const char * format, ...);
