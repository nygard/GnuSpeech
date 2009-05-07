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
//  NSString-Extensions.h
//  GnuSpeech
//
//  Created by Steve Nygard in 2004
//
//  Version: 0.9
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/NSString.h>

@interface NSString (CDExtensions)

+ (NSString *)stringWithFileSystemRepresentation:(const char *)str;
+ (NSString *)spacesIndentedToLevel:(int)level;
+ (NSString *)spacesIndentedToLevel:(int)level spacesPerLevel:(int)spacesPerLevel;
+ (NSString *)spacesOfLength:(int)targetLength;
+ (NSString *)stringWithUnichar:(unichar)character;

- (BOOL)isFirstLetterUppercase;
- (BOOL)hasPrefix:(NSString *)aString ignoreCase:(BOOL)shouldIgnoreCase;

+ (NSString *)stringWithASCIICString:(const char *)bytes;

- (NSString *)leftJustifiedStringPaddedToLength:(int)paddedLength;
- (NSString *)rightJustifiedStringPaddedToLength:(int)paddedLength;

- (BOOL)startsWithLetter;
- (BOOL)isAllUpperCase;
- (BOOL)containsPrimaryStress;
- (NSString *)convertedStress;

@end

@interface NSMutableString (Extensions)

- (void)indentToLevel:(int)level;

@end
