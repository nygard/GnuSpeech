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
//  TTSParserPartial.h
//  GnuSpeech
//
//  Created by Dalmazio Brisinda on 04/27/2009.
//
//  Version: 0.8
//
////////////////////////////////////////////////////////////////////////////////

@class GSPronunciationDictionary;

@interface TTSParserPartial : NSObject
{
    GSPronunciationDictionary * mainDictionary;
	GSPronunciationDictionary * userDictionary;
	GSPronunciationDictionary * appDictionary;

	NSDictionary * specialAcronyms;
}

- (id)initWithPronunciationDictionary:(GSPronunciationDictionary *)aDictionary;
- (void)dealloc;

- (NSString *)parseString:(NSString *)aString;  // entry point

/**** DIRECT CONVERSION ****/

//- (int)setEscapeCode:(unichar)new_escape_code;
//- (int)setDictData:(const short [4])order userDict:(GSPronunciationDictionary *)userDict appDict:(GSPronunciationDictionary *)appDict;


//- (int)parser:(const char *)input output:(char **)output;

//- (const char *)lookupWord:(const char *)word dictionary:(short *)dict;

//- (void)conditionInput:(const char *)input output:(char *)output length:(int)length outputLength:(int *)output_length;
//- (void)conditionInput:(NSString *)input resultString:(NSMutableString *)output;

//- (int) markModes:(char *)input output:(char *)output length:(int)length outputLength:(int *)output_length;
//- (int)markModes:(NSString *)input resultString:(NSMutableString *)output;

//- (void)stripPunctuation:(NSString *)buffer resultString:(NSMutableString *)stream;
//- (void)finalConversion:(NSString *)stream1 resultString:(NSMutableString *)stream2;
//- (int)getState:(NSString *)stream1 externalIndex:(long *)i mode:(int *)mode nextMode:(int *)next_mode currentState:(int *)current_state nextState:(int *)next_state rawModeFlag:(int *)raw_mode_flag word:(NSMutableString *)word resultString:(NSMutableString *)stream2;
//- (int)setToneGroup:(NSMutableString *)stream tgPosition:(long)tg_pos word:(NSString *)word;
//- (float)convertSilence:(NSString *)buffer resultString:(NSMutableString *)stream;
//- (int)anotherWordFollows:(NSString *)buffer index:(long)i mode:(int)mode;
//- (int)shiftSilence:(NSString *)buffer index:(long)i mode:(int)mode resultString:(NSMutableString *)stream;
//- (void)insertTag:(NSMutableString *)stream insertPoint:(long)insert_point word:(NSString *)word;
//- (void)expandWord:(NSString *)word isTonic:(int)is_tonic resultString:(NSMutableString *)stream;
//- (int)expandRawMode:(NSString *)buffer externalIndex:(long *)j resultString:(NSMutableString *)stream;
//- (int)illegalToken:(NSString *)token;
//- (int)illegalSlashCode:(NSString *)code;
//- (int)expandTagNumber:(NSString *)buffer externalIndex:(long *)j resultString:(NSMutableString *)stream;
//- (int)isMode:(unichar c);
//- (int)isIsolated:(NSString *)buffer index:(int)i;
//- (int)partOfNumber:(NSString *)buffer index:(int)i;
//- (int)numberFollows:(NSString *)buffer index:(int)i;
//- (void)deleteEllipsis:(NSMutableString *)buffer externalIndex:(int *)i;
//- (int)convertDash:(NSMutableString *)buffer externalIndex:(int *)i;
//- (int)isTelephoneNumber:(NSMutableString *)buffer index:(int)i;
//- (int)isPunctuation:(unichar c);
//- (int)wordFollows:(NSMutableString *)buffer index:(int)i;
//- (int)expandAbbreviation:(NSMutableString *)buffer index:(int)i resultString:(NSMutableString *)stream;
//- (void)expandLetterMode:(NSString *)buffer externalIndex:(int *)i resultString:(NSMutableString *)stream status:(int *)status;
//- (int)isAllUpperCase:(NSString *)word;
//- (NSMutableString *)toLowerCase:(NSMutableString *)word;
//- (NSString *)isSpecialAcronym:(NSString *)word;
//- (int)containsPrimaryStress:(NSString *)pronunciation;
//- (int)convertedStress:(NSMutableString *)pronunciation;
//- (int)isPossessive:(NSMutableString *)word;
//- (void)safetyCheck:(NSMutableString *)stream;
//- (void)insertChunkMarker:(NSMutableString *)stream insertPoint:(long)insert_point tgType:(unichar)tg_type;
//- (void)checkTonic:(NSMutableString *)stream startPosition:(long)start_pos endPosition:(long)end_pos;
//- (void)printStream:(NSString *)stream;

@end
