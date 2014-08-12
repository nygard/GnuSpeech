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

@class NXStream;

void NXGetMemoryBuffer(NXStream *stream, const char **streambuf, int *len, int *maxLen);

void NXPrintf(NXStream *stream, const char *format, ...);

void NXLogError(const char *format, ...);
