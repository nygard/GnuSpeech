////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard, Dalmazio Brisinda
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
//  TTSParser.h
//  GnuSpeech
//
//  Created by Dalmazio Brisinda on 04/27/2009.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

@class GSPronunciationDictionary;

@interface TTSParser : NSObject
{
    GSPronunciationDictionary * mainDictionary;
	GSPronunciationDictionary * userDictionary;
	GSPronunciationDictionary * appDictionary;

	NSDictionary * specialAcronyms;
}

- (id)initWithPronunciationDictionary:(GSPronunciationDictionary *)aDictionary;
- (void)dealloc;

- (NSString *)parseString:(NSString *)aString;  // entry point

@end
