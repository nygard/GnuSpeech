////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 1997-1998, 2000-2001, 2004  Steve Nygard
//
//  Contributors: Steve Nygard
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
//  This file is part of class-dump, a utility for examining the Objective-C 
//  segment of Mach-O files.
//
//  Copyright (C) 1997-1998, 2000-2001, 2004  Steve Nygard
//
//  NSScanner-Extensions.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004
//
//  Version: 0.9
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/NSScanner.h>

#import <Foundation/NSString.h> // for unichar

@interface NSScanner (CDExtensions)

+ (NSCharacterSet *)gsBooleanIdentifierCharacterSet;

- (NSString *)peekCharacter;
- (unichar)peekChar;
- (BOOL)scanCharacter:(unichar *)value;
- (BOOL)scanCharacterIntoString:(NSString **)value;
- (BOOL)scanCharacterFromString:(NSString *)aString intoString:(NSString **)value;
- (BOOL)scanCharacterFromSet:(NSCharacterSet *)set intoString:(NSString **)value;
- (BOOL)my_scanCharactersFromSet:(NSCharacterSet *)set intoString:(NSString **)value;

- (BOOL)scanIdentifierIntoString:(NSString **)stringPointer;

@end
